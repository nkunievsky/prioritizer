import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var lastLeftClick: TimeInterval?
    private let store = ItemStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "Priority Matrix")
            button.action = #selector(statusItemClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
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

    @objc private func statusItemClicked(_ button: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            lastLeftClick = nil
            togglePopover()
            return
        }

        switch event.type {
        case .rightMouseDown, .rightMouseUp:
            showQuitMenu(from: button)
        case .leftMouseDown, .leftMouseUp:
            let isDoubleClick = lastLeftClick.map { previousClick in
                (0...NSEvent.doubleClickInterval).contains(event.timestamp - previousClick)
            } ?? false
            if event.modifierFlags.contains(.control) || isDoubleClick {
                showQuitMenu(from: button)
            } else {
                lastLeftClick = event.timestamp
                togglePopover()
            }
        default:
            lastLeftClick = nil
            togglePopover()
        }
    }

    private func showQuitMenu(from button: NSStatusBarButton) {
        lastLeftClick = nil
        popover.performClose(button)

        let menu = NSMenu()
        let quit = menu.addItem(
            withTitle: "Quit Prioritizer",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: ""
        )
        quit.target = NSApp

        statusItem.menu = menu
        button.performClick(nil)
        statusItem.menu = nil
    }

    private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(button)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
