# Prioritizer App Overview

## What It Is

A macOS menu bar (tray) app that shows an Eisenhower priority matrix (4-quadrant urgent/important grid) in a popover. Users can add, drag, edit, and delete prioritization items.

**Why:** The goal was a quick-access priority matrix that behaves like a menu (popover, not a window) — click the menu bar icon, rearrange priorities, click away to dismiss.

## Tech Stack

- **SwiftUI** for UI and **AppKit** for NSStatusItem and NSPopover
- **Swift Package Manager** for builds
- Built as an SPM executable, then wrapped in a `.app` bundle for Launchpad

## Project Structure

```
prioritizer/
├── Package.swift                          # SPM config, targets macOS 13+
├── Sources/Prioritizer/
│   ├── main.swift                         # Bootstrap NSApplication, set .accessory policy (no dock icon)
│   ├── AppDelegate.swift                  # NSStatusItem (SF Symbol "square.grid.2x2") + NSPopover (.transient)
│   ├── PriorityItem.swift                 # Data models: PriorityItem (id, name, x, y, colorName, addedDate) + DeletedItem
│   ├── ItemStore.swift                    # ObservableObject: items array, deleted items, JSON persistence, CRUD methods
│   ├── MatrixView.swift                   # Root SwiftUI view: title bar, axis labels (arrows), 4 quadrant grid, items
│   ├── ItemView.swift                     # Draggable item (colored dot + name), right-click context menu (Edit/Delete)
│   ├── AddItemView.swift                  # Inline add bar: text field, color picker dots, add button
│   ├── IdeasPanelView.swift               # Capture ideas and drag them onto the matrix
│   └── DeletedItemsView.swift             # Popover list of deleted items with added/deleted dates
└── example.png                            # Original mockup image
```

## Key Design Decisions

- **Positions stored as fractions (0.0–1.0)** of matrix area — resolution-independent
- **NSPopover with .transient behavior** — auto-dismisses on outside click
- **NSApp.setActivationPolicy(.accessory)** — hides dock icon without needing Info.plist in SPM build
- **Right-click (two-finger click) for Edit/Delete** — left click reserved for dragging
- **DragGesture with local @State offset** — only re-renders the dragged item, not all items
- **Axis labels**: horizontal text with arrows (up/down for Important, left/right for Urgent) — not rotated text

## Persistence

- Active items: `~/Library/Application Support/Prioritizer/items.json`
- Deleted items: `~/Library/Application Support/Prioritizer/deleted.json`
- Ideas: `~/Library/Application Support/Prioritizer/ideas.json`
- Saved after every mutation (add, remove, move, edit). Survives restarts.

## Build Commands

```bash
swift build
swift build -c release
swift run -c release Prioritizer
```

## Available Colors

red, orange, yellow, green, blue, purple, pink
