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
            List {
                ForEach(viewModel.locations, id: \.self) { location in
                    Text(location.name ?? "untitled")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.handleTap(on: location)
                        }
                }
            }
            .padding()
            .navigationTitle("Welcome to Places!")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddPlaceSheet = true
                    } label: {
                        Image(systemName: "plus")
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
