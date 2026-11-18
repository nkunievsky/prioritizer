import SwiftUI

struct IdeasPanelView: View {
    @EnvironmentObject var store: ItemStore
    @Binding var draggingIdea: IdeaItem?
    @Binding var dragLocation: CGPoint
    let onDrop: (IdeaItem, CGPoint) -> Void

    @State private var newIdeaText = ""

    var body: some View {
        VStack(spacing: 6) {
            // Add row
            HStack(spacing: 6) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                TextField("Add an idea…", text: $newIdeaText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .onSubmit { commit() }
                if !newIdeaText.isEmpty {
                    Button("Add") { commit() }
                        .font(.system(size: 10))
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.secondary.opacity(0.08))
            )

            // Ideas list — vertical, compact, max 3 rows visible, rest scrollable
            if store.ideas.isEmpty {
                Text("No ideas yet. Drag one onto the matrix to start.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 2)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 3) {
                        ForEach(store.ideas) { idea in
                            IdeaRow(
                                idea: idea,
                                draggingIdea: $draggingIdea,
                                dragLocation: $dragLocation,
                                onDrop: onDrop
                            )
                        }
                    }
                }
                .frame(maxHeight: 84)  // ~3 rows visible; rest scroll
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func commit() {
        let trimmed = newIdeaText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.addIdea(name: trimmed)
        newIdeaText = ""
    }
}

struct IdeaRow: View {
    let idea: IdeaItem
    @EnvironmentObject var store: ItemStore
    @Binding var draggingIdea: IdeaItem?
    @Binding var dragLocation: CGPoint
    let onDrop: (IdeaItem, CGPoint) -> Void

    @State private var isDragging = false
    @State private var showingEditor = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 9))
                .foregroundColor(.yellow)
            Text(idea.name)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
            if !idea.notes.isEmpty {
                Image(systemName: "text.bubble")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 8))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.secondary.opacity(isDragging ? 0.25 : 0.08))
        )
        .opacity(isDragging ? 0.5 : 1.0)
        .contentShape(Rectangle())  // full row is tappable
        .onTapGesture { showingEditor = true }
        .popover(isPresented: $showingEditor, arrowEdge: .trailing) {
            IdeaEditorView(idea: idea, isPresented: $showingEditor)
                .environmentObject(store)
        }
        .gesture(
            DragGesture(minimumDistance: 4, coordinateSpace: .named("popover"))
                .onChanged { value in
                    isDragging = true
                    draggingIdea = idea
                    dragLocation = value.location
                }
                .onEnded { value in
                    onDrop(idea, value.location)
                    isDragging = false
                    draggingIdea = nil
                }
        )
        .contextMenu {
            Button {
                showingEditor = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive) {
                store.removeIdea(id: idea.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct IdeaEditorView: View {
    let idea: IdeaItem
    @EnvironmentObject var store: ItemStore
    @Binding var isPresented: Bool

    @State private var name: String
    @State private var notes: String

    init(idea: IdeaItem, isPresented: Binding<Bool>) {
        self.idea = idea
        self._isPresented = isPresented
        self._name = State(initialValue: idea.name)
        self._notes = State(initialValue: idea.notes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.yellow)
                TextField("Idea", text: $name)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, weight: .semibold))
            }

            Divider()

            Text("Notes")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)

            TextEditor(text: $notes)
                .font(.system(size: 11))
                .frame(minHeight: 100, maxHeight: 180)
                .scrollContentBackground(.hidden)
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(4)

            HStack {
                Spacer()
                Button("Cancel") { isPresented = false }
                Button("Save") { save() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(12)
        .frame(width: 300)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.updateIdea(id: idea.id, name: trimmed, notes: notes)
        isPresented = false
    }
}
