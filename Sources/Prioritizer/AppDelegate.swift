import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var singleClickTimer: Timer?
    private let store = ItemStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "Priority Matrix")
            button.action = #selector(statusItemClicked(_:))
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

    @objc private func statusItemClicked(_ button: NSStatusBarButton) {
        singleClickTimer?.invalidate()
        singleClickTimer = nil

        guard let event = NSApp.currentEvent,
              event.type == .leftMouseDown || event.type == .leftMouseUp else {
            togglePopover()
            return
        }

        if event.clickCount >= 2 {
            showQuitMenu(from: button)
        } else {
            // Wait for the system's double-click interval before opening the matrix.
            singleClickTimer = Timer.scheduledTimer(
                timeInterval: NSEvent.doubleClickInterval,
                target: self,
                selector: #selector(handleSingleClick(_:)),
                userInfo: nil,
                repeats: false
            )
        }
    }

    @objc private func handleSingleClick(_ timer: Timer) {
        singleClickTimer = nil
        togglePopover()
    }

    private func showQuitMenu(from button: NSStatusBarButton) {
        popover.performClose(button)

        let menu = NSMenu()
        let quit = menu.addItem(
            withTitle: "Quit Prioritizer",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: ""
        )
        quit.target = NSApp

        let bottom = button.isFlipped ? button.bounds.maxY : button.bounds.minY
        menu.popUp(positioning: nil, at: NSPoint(x: button.bounds.minX, y: bottom), in: button)
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
