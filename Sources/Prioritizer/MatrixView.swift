import SwiftUI

struct MatrixView: View {
    @EnvironmentObject var store: ItemStore
    @State private var showingAddItem = false
    @State private var showingDeleted = false
    @State private var showingIdeas = false

    // Drag-from-ideas state
    @State private var draggingIdea: IdeaItem?
    @State private var dragLocation: CGPoint = .zero
    @State private var matrixFrame: CGRect = .zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                titleBar
                topAxisLabel
                matrixArea
                bottomAxisLabel
                xAxisLabel

                if showingAddItem {
                    Divider()
                    AddItemView(isShowing: $showingAddItem)
                        .padding(.bottom, 8)
                }

                if showingIdeas {
                    Divider()
                    IdeasPanelView(
                        draggingIdea: $draggingIdea,
                        dragLocation: $dragLocation,
                        onDrop: handleIdeaDrop
                    )
                }
            }

            // Ghost preview of dragged idea (follows cursor)
            if let idea = draggingIdea {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.yellow)
                    Text(idea.name)
                        .font(.system(size: 11, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .windowBackgroundColor))
                )
                .shadow(radius: 3)
                .position(x: dragLocation.x, y: dragLocation.y)
                .allowsHitTesting(false)
            }
        }
        .coordinateSpace(name: "popover")
    }

    private var titleBar: some View {
        HStack(spacing: 10) {
            Button(action: { showingDeleted.toggle() }) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingDeleted, arrowEdge: .bottom) {
                DeletedItemsView()
                    .environmentObject(store)
            }

            Button(action: { showingIdeas.toggle() }) {
                Image(systemName: showingIdeas ? "lightbulb.fill" : "lightbulb")
                    .font(.system(size: 13))
                    .foregroundColor(showingIdeas ? .yellow : .secondary)
            }
            .buttonStyle(.plain)

            Spacer()
            Text("Priority Matrix")
                .font(.system(size: 14, weight: .semibold))
            Spacer()

            Button(action: { showingAddItem.toggle() }) {
                Image(systemName: showingAddItem ? "xmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    private var topAxisLabel: some View {
        HStack {
            Image(systemName: "arrow.up")
                .font(.system(size: 8, weight: .bold))
            Text("Important")
            Spacer()
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundColor(.secondary)
        .padding(.horizontal, 12)
        .padding(.bottom, 2)
    }

    private var bottomAxisLabel: some View {
        HStack {
            Image(systemName: "arrow.down")
                .font(.system(size: 8, weight: .bold))
            Text("Not Important")
            Spacer()
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundColor(.secondary)
        .padding(.horizontal, 12)
        .padding(.top, 2)
    }

    private var xAxisLabel: some View {
        HStack {
            HStack(spacing: 2) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 8, weight: .bold))
                Text("Urgent")
            }
            Spacer()
            HStack(spacing: 2) {
                Text("Not Urgent")
                Image(systemName: "arrow.right")
                    .font(.system(size: 8, weight: .bold))
            }
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundColor(.secondary)
        .padding(.horizontal, 12)
        .padding(.bottom, (showingAddItem || showingIdeas) ? 4 : 10)
    }

    private var matrixArea: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        quadrant(color: .red)
                        quadrant(color: .blue)
                    }
                    HStack(spacing: 0) {
                        quadrant(color: .green)
                        quadrant(color: .gray)
                    }
                }

                Path { path in
                    path.move(to: CGPoint(x: size.width / 2, y: 0))
                    path.addLine(to: CGPoint(x: size.width / 2, y: size.height))
                }
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: size.height / 2))
                    path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
                }
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)

                ForEach(store.items) { item in
                    ItemView(item: item, matrixSize: size)
                        .position(
                            x: item.x * size.width,
                            y: item.y * size.height
                        )
                }

                // Highlight when dragging an idea over the matrix
                if draggingIdea != nil && matrixFrame.contains(dragLocation) {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .allowsHitTesting(false)
                }
            }
            .onAppear {
                matrixFrame = geometry.frame(in: .named("popover"))
            }
            .onChange(of: geometry.frame(in: .named("popover"))) { newFrame in
                matrixFrame = newFrame
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 340)
        .clipped()
    }

    private func quadrant(color: Color) -> some View {
        Rectangle()
            .fill(color.opacity(0.06))
    }

    private func handleIdeaDrop(_ idea: IdeaItem, at point: CGPoint) {
        guard matrixFrame.contains(point), matrixFrame.width > 0, matrixFrame.height > 0 else { return }
        let fx = (point.x - matrixFrame.minX) / matrixFrame.width
        let fy = (point.y - matrixFrame.minY) / matrixFrame.height
        store.promoteIdea(id: idea.id, x: fx, y: fy)
    }
}
