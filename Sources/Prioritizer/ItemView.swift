import SwiftUI

struct ItemView: View {
    let item: PriorityItem
    let matrixSize: CGSize
    @EnvironmentObject var store: ItemStore

    @GestureState private var dragOffset: CGSize? = nil
    @State private var showingEdit = false
    @State private var now = Date()

    // Tick every 60 seconds so faces update as time passes.
    private let ticker = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var isDragging: Bool { dragOffset != nil }

    var body: some View {
        HStack(spacing: 4) {
            Text(item.faceEmoji(now: now))
                .font(.system(size: 14))
                .contentShape(Rectangle())
                .onTapGesture {
                    store.resetAddedDate(id: item.id)
                    now = Date()
                }
                .help("Click to reset the anger timer")
            Text(item.name)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
                .foregroundColor(item.color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(isDragging ? 0.9 : 0))
        )
        .contentShape(Rectangle())
        .onReceive(ticker) { now = $0 }
        .popover(isPresented: $showingEdit, arrowEdge: .bottom) {
            EditItemView(item: item, store: store, isPresented: $showingEdit)
        }
        .highPriorityGesture(dragGesture)
        .contextMenu {
            Button {
                showingEdit = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive) {
                store.removeItem(id: item.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .shadow(radius: isDragging ? 2 : 0)
        .offset(dragOffset ?? .zero)
        .position(x: item.x * matrixSize.width, y: item.y * matrixSize.height)
        .zIndex(isDragging ? 10 : 0)
    }

    private var dragGesture: some Gesture {
        // Measure movement in the popover so the coordinates stay fixed as the item moves.
        DragGesture(minimumDistance: 4, coordinateSpace: .named("popover"))
            .updating($dragOffset) { value, offset, _ in
                offset = value.translation
            }
            .onEnded { value in
                guard matrixSize.width > 0, matrixSize.height > 0 else { return }
                let newX = item.x + value.translation.width / matrixSize.width
                let newY = item.y + value.translation.height / matrixSize.height
                store.updatePosition(id: item.id, x: newX, y: newY)
            }
    }
}

struct EditItemView: View {
    let item: PriorityItem
    let store: ItemStore
    @Binding var isPresented: Bool

    @State private var name: String
    @State private var selectedColor: String

    private let availableColors = ["red", "orange", "yellow", "green", "blue", "purple", "pink"]

    init(item: PriorityItem, store: ItemStore, isPresented: Binding<Bool>) {
        self.item = item
        self.store = store
        self._isPresented = isPresented
        self._name = State(initialValue: item.name)
        self._selectedColor = State(initialValue: item.colorName)
    }

    var body: some View {
        VStack(spacing: 8) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 160)
                .onSubmit { save() }

            HStack(spacing: 6) {
                ForEach(availableColors, id: \.self) { colorName in
                    Circle()
                        .fill(colorFor(colorName))
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selectedColor == colorName ? 2 : 0)
                        )
                        .onTapGesture { selectedColor = colorName }
                }
            }

            HStack(spacing: 8) {
                Button("Cancel") { isPresented = false }
                Button("Save") { save() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(12)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.updateItem(id: item.id, name: trimmed, colorName: selectedColor)
        isPresented = false
    }

    private func colorFor(_ name: String) -> Color {
        switch name {
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        default: return .gray
        }
    }
}
