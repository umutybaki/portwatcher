import SwiftUI

struct PortListMenuBarView: View {
    @StateObject private var processService = ProcessService()
    @AppStorage("autoRefresh") private var autoRefresh = false
    @AppStorage("filterSystem") private var filterSystem = true
    
    // Timer for auto-refresh
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let rowHeight: CGFloat = 50
        let itemsCount = CGFloat(max(processService.activeProcesses.count, 3)) // at least enough space for 3
        let listHeight = min(itemsCount * rowHeight, 300)
        let totalHeight: CGFloat = 50 + listHeight // 50 for the header
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("PortWatcher")
                    .font(.headline)
                Spacer()
                Button(action: refresh) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .frame(height: 50)
            
            Divider()
            
            if processService.activeProcesses.isEmpty {
                VStack {
                    Spacer()
                    Text("No active processes found.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(processService.activeProcesses) { process in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(process.name) (:\(process.port))")
                                        .font(.system(.body, design: .monospaced).bold())
                                }
                                
                                Spacer()
                                
                                Button("Quit") {
                                    processService.terminate(pid: process.pid, force: false)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                                
                                Button("Force") {
                                    processService.terminate(pid: process.pid, force: true)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .frame(height: rowHeight) // Enforce row height
                            
                            if process.id != processService.activeProcesses.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 350, height: totalHeight)
        .onAppear {
            refresh()
        }
        .onReceive(timer) { _ in
            if autoRefresh {
                refresh()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProcessTerminated"))) { _ in
            refresh()
        }
    }
    
    private func refresh() {
        processService.fetchProcesses(filterSystem: filterSystem)
    }
}
