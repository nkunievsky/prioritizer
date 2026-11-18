import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var store: ItemStore
    @Binding var isShowing: Bool

    @State private var name = ""
    @State private var selectedColor = "red"

    private let availableColors = ["red", "orange", "yellow", "green", "blue", "purple", "pink"]

    var body: some View {
        HStack(spacing: 8) {
            TextField("New item…", text: $name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
                .onSubmit { addItem() }

            ForEach(availableColors, id: \.self) { colorName in
                Circle()
                    .fill(colorFor(colorName))
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: selectedColor == colorName ? 2 : 0)
                    )
                    .onTapGesture { selectedColor = colorName }
            }

            Button("Add") { addItem() }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func addItem() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.addItem(name: trimmed, colorName: selectedColor)
        name = ""
        isShowing = false
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
