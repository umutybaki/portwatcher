import Foundation
import Combine
import AppKit

struct ActiveProcess: Identifiable, Hashable {
    let id = UUID()
    let pid: Int
    let name: String
    let port: Int
    let icon: NSImage?

    func hash(into hasher: inout Hasher) {
        hasher.combine(pid)
        hasher.combine(port)
        hasher.combine(name)
    }

    static func == (lhs: ActiveProcess, rhs: ActiveProcess) -> Bool {
        lhs.pid == rhs.pid && lhs.port == rhs.port && lhs.name == rhs.name
    }
}

class ProcessService: ObservableObject {
    @Published var activeProcesses: [ActiveProcess] = []
    
    // System processes that usually hold ports but aren't interesting to developers
    let systemProcesses = [
        "SystemUIServer", "ControlCenter", "nsurlsessiond", "rapportd", 
        "apsd", "remindd", "identityservicesd", "mDNSResponder",
        "AirPlayUIAgent", "CommCenter", "sharingd", "coreauthd"
    ]
    
    func fetchProcesses(filterSystem: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            let pipe = Pipe()
            
            task.standardOutput = pipe
            task.standardError = pipe
            task.arguments = ["-c", "lsof -iTCP -sTCP:LISTEN -P -n"]
            task.executableURL = URL(fileURLWithPath: "/bin/sh")
            
            do {
                try task.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    self.parseLsofOutput(output, filterSystem: filterSystem)
                }
            } catch {
                print("Failed to run lsof: \(error)")
            }
        }
    }
    
    private func parseLsofOutput(_ output: String, filterSystem: Bool) {
        var newProcesses: [ActiveProcess] = []
        let lines = output.components(separatedBy: .newlines)
        
        // Skip the first line (header)
        for line in lines.dropFirst() {
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            
            let columns = line.split(separator: " ", omittingEmptySubsequences: true).map { String($0) }
            
            guard columns.count >= 8 else { continue }
            
            let name = columns[0]
            guard let pid = Int(columns[1]) else { continue }
            
            // Name column might be something like "*:8080" or "127.0.0.1:3000"
            // Find the column that contains ":" and does not contain "->" (which means established connection, though we already filter for LISTEN state)
            guard let portColumn = columns.first(where: { $0.contains(":") && !$0.contains("->") }) else { continue }
            
            let parts = portColumn.split(separator: ":")
            guard let portString = parts.last?.replacingOccurrences(of: "(LISTEN)", with: "").trimmingCharacters(in: .whitespaces), 
                  let port = Int(portString) else { continue }
            
            if filterSystem && systemProcesses.contains(name) { continue }
            
            // Avoid duplicates (e.g., IPv4 and IPv6)
            if !newProcesses.contains(where: { $0.port == port }) {
                let resolvedName = self.getAppName(for: pid, fallbackName: name)
                let icon = self.getIcon(for: pid)
                newProcesses.append(ActiveProcess(pid: pid, name: resolvedName, port: port, icon: icon))
            }
        }
        
        DispatchQueue.main.async {
            self.activeProcesses = newProcesses.sorted(by: { $0.port < $1.port })
        }
    }
    
    private func getAppName(for pid: Int, fallbackName: String) -> String {
        let task = Process()
        let pipe = Pipe()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-p", "\(pid)", "-o", "comm="]
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty {
                // Find the highest level .app/
                if let regex = try? NSRegularExpression(pattern: "/([^/]+)\\.app/"),
                   let match = regex.firstMatch(in: path, range: NSRange(path.startIndex..., in: path)) {
                    if let r = Range(match.range(at: 1), in: path) {
                        return String(path[r])
                    }
                }
            }
        } catch { }
        
        return fallbackName
    }
    
    private func getIcon(for pid: Int) -> NSImage? {
        if let app = NSRunningApplication(processIdentifier: Int32(pid)) {
            // We use the icon for regular apps and accessory apps (like menubar-only apps)
            // This generally excludes CLI tools which would have activationPolicy == .prohibited
            if app.activationPolicy == .regular || app.activationPolicy == .accessory {
                return app.icon
            }
        }
        return nil
    }
    
    func terminate(pid: Int, force: Bool = false) {
        let signal = force ? "-9" : "-15"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/kill")
        task.arguments = [signal, "\(pid)"]
        
        do {
            try task.run()
            // Wait slightly for the process to actually die, then refresh
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // The view will handle the refresh, or we can broadcast an event
                NotificationCenter.default.post(name: NSNotification.Name("ProcessTerminated"), object: nil)
            }
        } catch {
            print("Failed to kill process \(pid): \(error)")
        }
    }
}
