import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let store = ItemStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "Priority Matrix")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        let contentView = MatrixView()
            .environmentObject(store)
            .frame(width: 420)  // fixed width; height grows with open panels

        popover = NSPopover()
        popover.behavior = .transient
        let host = NSHostingController(rootView: contentView)
        host.sizingOptions = [.preferredContentSize]
        popover.contentViewController = host
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
