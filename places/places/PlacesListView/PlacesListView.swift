//
//  ContentView.swift
//  places
//
//  Created by olia on 5/27/26.
//

import SwiftUI

struct PlacesListView: View {
    @State private var isShowingAddPlaceSheet = false
    @State private var viewModel: PlacesListViewModel
    private let dependencies: PlacesDependencies
    init(dependencies: PlacesDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: PlacesListViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Places!")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Select a place from the list below to open it in the Wiki app")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                List {
                    ForEach(viewModel.locations, id: \.self) { location in
                        Text(location.name ?? "untitled")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .accessibilityHint("Open \(location.name ?? "untitled") in the Wiki app")
                            .onTapGesture {
                                viewModel.handleTap(on: location)
                            }
                    }
                }
                .listStyle(.plain)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddPlaceSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add another place")
                            .accessibilityHint("Select a place on the map")
                    }
                }
            }
            .alert(
                isPresented: .init(get: {
                    viewModel.userFacingError != nil
                }, set: { _ in
                    // no-op
                }),
                error: viewModel.userFacingError,
                actions: {
                    Button("Got it") {
                        viewModel.userFacingError = nil
                    }
                }
            )
            .sheet(isPresented: $isShowingAddPlaceSheet) {
                AddCustomPlaceView(dependencies: dependencies)
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
}
