import SwiftUI

struct PortListMenuBarView: View {
    @StateObject private var processService = ProcessService()
    @AppStorage("autoRefresh") private var autoRefresh = false
    @AppStorage("filterSystem") private var filterSystem = true
    
    // Timer for auto-refresh
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let horizontalPadding: CGFloat = 14 // Tighter padding
        let rowHeight: CGFloat = 40 // Tighter row height
        let headerHeight: CGFloat = 48
        let sectionHeaderHeight: CGFloat = 30
        
        let itemsCount = CGFloat(max(processService.activeProcesses.count, 3))
        let listHeight = min(itemsCount * rowHeight, 300)
        let totalHeight: CGFloat = headerHeight + sectionHeaderHeight + listHeight + 8
        
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
            
            Divider()
                .padding(.horizontal, horizontalPadding)
            
            // Section Header
            Text("LISTENING PORTS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, horizontalPadding)
                .frame(height: sectionHeaderHeight, alignment: .bottomLeading)
                .padding(.bottom, 4)
            
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
                                if let nsImage = process.icon {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 18, height: 18)
                                } else {
                                    Image(systemName: "network")
                                        .font(.system(size: 13))
                                        .foregroundColor(.blue)
                                        .frame(width: 18)
                                }
                                
                                Text(process.name)
                                    .font(.body.weight(.medium))
                                
                                Spacer()
                                
                                Text(":\(String(process.port))")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 2)
                                
                                HStack(spacing: 8) {
                                    Button(action: {
                                        processService.terminate(pid: process.pid, force: false)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.blue.opacity(0.8))
                                    }
                                    .buttonStyle(.plain)
                                    .help("Quit Process")
                                    
                                    Button(action: {
                                        processService.terminate(pid: process.pid, force: true)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                    .buttonStyle(.plain)
                                    .help("Force Quit Process")
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            .frame(height: rowHeight)
                            
                            if process.id != processService.activeProcesses.last?.id {
                                Divider()
                                    .padding(.leading, horizontalPadding + 30) // Adjusted for smaller icon/padding
                                    .padding(.trailing, horizontalPadding)
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
