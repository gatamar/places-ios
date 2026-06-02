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
                
                if viewModel.isFetchingData {
                    VStack {
                        ProgressView("Loading places...")
                        Spacer()
                    }
                    .padding()
                } else {
                    Text("Select a place from the list below to open it in the Wiki app")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    List {
                        ForEach(viewModel.locations, id: \.self) { location in
                            let locationName = viewModel.name(for: location)
                            
                            VStack(alignment: .leading) {
                                Text(locationName)
                                
                                Text("\(String(format: "%.4f", location.longitude)), \(String(format: "%.4f", location.latitude))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .accessibilityHint("Open \(locationName) in the Wiki app")
                            .onTapGesture {
                                viewModel.handleTap(on: location)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
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
