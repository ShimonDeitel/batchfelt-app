import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BatchFeltStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("batchfelt_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("batchfelt_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                BFTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(BFTheme.accent)
                                Text("Batch Felt Pro active")
                                    .foregroundStyle(BFTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(BFTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(BFTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(BFTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(BFTheme.card)

                    if purchases.isPro {
                        Section("Shrinkage-Rate Calculator") {
                            Text("Estimate final size shrinkage by wool type and technique.")
                                .font(.caption)
                                .foregroundStyle(BFTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.woolType)
                                        .foregroundStyle(BFTheme.ink)
                                    Spacer()
                                    Text(p.technique)
                                        .font(.caption)
                                        .foregroundStyle(BFTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(BFTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                BFHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(BFTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddProjectButton")
                    }
                    .listRowBackground(BFTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/batchfelt-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/batchfelt-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(BFTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(BFTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                ProjectFormView(mode: .add)
            }
        }
    }
}
