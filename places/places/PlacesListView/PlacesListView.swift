//
//  ContentView.swift
//  places
//
//  Created by olia on 5/27/26.
//

import SwiftUI

struct PlacesListView: View {
    private let viewModel = PlacesListViewModel()

    @State private var isShowingAddPlaceSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.locations, id: \.self) { location in
                    Text(location.name ?? "untitled")
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
            .sheet(isPresented: $isShowingAddPlaceSheet) {
                AddCustomPlaceView()
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    PlacesListView()
}
