import SwiftUI

struct DeletedItemsView: View {
    @EnvironmentObject var store: ItemStore

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Deleted Items")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                if !store.deletedItems.isEmpty {
                    Button("Clear All") {
                        store.clearDeletedItems()
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.red)
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 8)

            if store.deletedItems.isEmpty {
                Text("No deleted items")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(store.deletedItems) { item in
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 10, height: 10)
                                    Text(item.name)
                                        .font(.system(size: 12, weight: .medium))
                                        .lineLimit(1)
                                }
                                HStack(spacing: 12) {
                                    Label(dateFormatter.string(from: item.addedDate), systemImage: "plus.circle")
                                    Label(dateFormatter.string(from: item.deletedDate), systemImage: "trash")
                                }
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            Divider().padding(.leading, 12)
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
        }
        .frame(width: 280)
        .padding(.bottom, 8)
    }
}
