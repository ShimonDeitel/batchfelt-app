import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ProjectListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(BFTheme.accent)
    }
}

struct ProjectListView: View {
    @EnvironmentObject private var store: BatchFeltStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Project?

    var body: some View {
        NavigationStack {
            ZStack {
                BFTheme.backdrop.ignoresSafeArea()
                if store.projects.isEmpty {
                    ContentUnavailableView("No Projects Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.projects) { item in
                            ProjectRow(item: item)
                                .listRowBackground(BFTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteProject(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Batch Felt")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addProjectButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ProjectFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                ProjectFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct ProjectRow: View {
    let item: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.projectName)
                .font(BFTheme.headlineFont)
                .foregroundStyle(BFTheme.ink)
            Text(String(describing: item.woolType))
                .font(.caption)
                .foregroundStyle(BFTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum ProjectFormMode: Identifiable {
    case add
    case edit(Project)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct ProjectFormView: View {
    @EnvironmentObject private var store: BatchFeltStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: ProjectFormMode

    @State private var draftProjectName: String = ""
    @State private var draftWoolType: String = ""
    @State private var draftTechnique: String = ""
    @State private var draftFinishedSize: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BFTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                TextField("Project", text: $draftProjectName)
                    .accessibilityIdentifier("projectNameField")
                Picker("Wool Type", selection: $draftWoolType) {
                    ForEach(BFWoolTypeOption.all, id: \.self) { Text($0) }
                }
                Picker("Technique", selection: $draftTechnique) {
                    ForEach(BFTechniqueOption.all, id: \.self) { Text($0) }
                }
                TextField("Finished Size (in)", text: $draftFinishedSize)
                    .accessibilityIdentifier("finishedSizeField")
                    }
                    .listRowBackground(BFTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("projectSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftProjectName = item.projectName
        draftWoolType = item.woolType
        draftTechnique = item.technique
        draftFinishedSize = item.finishedSize
        } else {
        draftProjectName = ""
        draftWoolType = ""
        draftTechnique = ""
        draftFinishedSize = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addProject(draftProjectName, draftWoolType, draftTechnique, draftFinishedSize, isPro: purchases.isPro)
        case .edit(let item):
            store.updateProject(item.id, draftProjectName, draftWoolType, draftTechnique, draftFinishedSize)
        }
        BFHaptics.success()
        dismiss()
    }
}
