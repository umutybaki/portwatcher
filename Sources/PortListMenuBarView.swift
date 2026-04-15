import SwiftUI

struct PortListMenuBarView: View {
    @StateObject private var processService = ProcessService()
    @AppStorage("autoRefresh") private var autoRefresh = false
    @AppStorage("filterSystem") private var filterSystem = true
    @State private var hoveredProcessID: UUID?
    
    // Timer for auto-refresh
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let horizontalPadding: CGFloat = 12
        let rowHeight: CGFloat = 28
        let headerHeight: CGFloat = 40
        let itemsCount = CGFloat(max(processService.activeProcesses.count, 1))
        let listHeight = min(itemsCount * rowHeight, 400)
        let totalHeight: CGFloat = headerHeight + listHeight + 8
        
        VStack(alignment: .leading, spacing: 0) {
            // Main Header
            HStack {
                Text("PortWatcher")
                    .font(.headline)
                Spacer()
                Button(action: refresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Refresh items")
            }
            .padding(.horizontal, horizontalPadding)
            .frame(height: headerHeight)
            
            if processService.activeProcesses.isEmpty {
                VStack {
                    Spacer()
                    Text("No active processes found.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(processService.activeProcesses) { process in
                            HStack(spacing: 12) {
                                HStack(spacing: 8) {
                                    Button(action: {
                                        processService.terminate(pid: process.pid, force: false)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue.opacity(0.8))
                                    }
                                    .buttonStyle(.plain)
                                    .help("Quit Process (\(process.name))")
                                    
                                    Button(action: {
                                        processService.terminate(pid: process.pid, force: true)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                    .buttonStyle(.plain)
                                    .help("Force Quit Process (\(process.name))")
                                }
                                
                                Text(process.name)
                                    .font(.body)
                                    .padding(.leading, 2)
                                
                                Spacer()
                                
                                Text(":\(String(process.port))")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 2)
                            }
                            .padding(.horizontal, horizontalPadding)
                            .frame(height: rowHeight)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(hoveredProcessID == process.id ? Color.primary.opacity(0.1) : Color.clear)
                                    .padding(.horizontal, 4)
                            )
                            .onHover { isHovered in
                                hoveredProcessID = isHovered ? process.id : nil
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 340, height: totalHeight) // Slightly narrower
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

// Custom button style for the "Apple" look
struct MenubarButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(configuration.isPressed ? 0.2 : 0.1))
            )
            .foregroundColor(color.opacity(0.9))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}
