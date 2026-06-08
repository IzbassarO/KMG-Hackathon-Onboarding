import SwiftUI
import SwiftData

struct TemplatesListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Template.createdAt, order: .reverse) private var templates: [Template]

    @State private var isShowingNew = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    header

                    if templates.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: Theme.Spacing.m) {
                            ForEach(templates) { template in
                                NavigationLink(value: template) {
                                    TemplateRow(template: template)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) { delete(template) } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.l)
            }
            .background(Theme.Surface.base)
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { isShowingNew = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Template.self) { template in
                FlowchartBuilderView(template: template)
            }
            .sheet(isPresented: $isShowingNew) {
                NewTemplateSheet { name, category in
                    let template = Template(name: name, category: category)
                    context.insert(template)
                    try? context.save()
                    isShowingNew = false
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Your flowcharts")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.Ink.primary)
            Text("Define the stages of an onboarding once. Reuse the chart for every new hire.")
                .font(Theme.Font.callout)
                .foregroundStyle(Theme.Ink.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.m) {
            ThreadlineLogo(size: 96)
            Text("No templates yet")
                .font(Theme.Font.section)
                .foregroundStyle(Theme.Ink.primary)
            Text("Tap + to build your first flowchart.")
                .font(Theme.Font.callout)
                .foregroundStyle(Theme.Ink.secondary)
                .multilineTextAlignment(.center)
            Button {
                isShowingNew = true
            } label: {
                Label("New template", systemImage: "plus")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, Theme.Spacing.m)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .threadCard()
    }

    private func delete(_ template: Template) {
        context.delete(template)
        try? context.save()
    }
}

private struct TemplateRow: View {
    var template: Template

    var body: some View {
        Card {
            HStack(spacing: Theme.Spacing.m) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Radius.control)
                        .fill(Theme.Brand.primary.opacity(0.12))
                    Image(systemName: "rectangle.connected.to.line.below")
                        .font(.title3)
                        .foregroundStyle(Theme.Brand.primary)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(template.name)
                        .font(Theme.Font.headline)
                        .foregroundStyle(Theme.Ink.primary)
                    if !template.summary.isEmpty {
                        Text(template.summary)
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.Ink.secondary)
                            .lineLimit(2)
                    }
                    HStack(spacing: Theme.Spacing.s) {
                        Pill(template.category, systemImage: "tag", tint: Theme.Brand.primary)
                        Pill("\(template.stageCount) stage\(template.stageCount == 1 ? "" : "s")",
                             systemImage: "square.stack",
                             tint: Theme.Ink.secondary)
                    }
                }

                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.Ink.secondary)
            }
        }
    }
}

private struct NewTemplateSheet: View {
    var onSave: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var category: String = "Direct hire"

    private let categories = ["Direct hire", "Contractor", "Field rotation", "Internship", "Custom"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Template") {
                    TextField("e.g. Engineering direct hire", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }
            }
            .navigationTitle("New template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSave(trimmed, category)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    TemplatesListView()
        .modelContainer(ModelContainerFactory.makePreview())
}
