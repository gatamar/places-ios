//
//  ContentView.swift
//  places
//
//  Created by olia on 5/27/26.
//

import SwiftUI

struct PlacesListView: View {
    private let viewModel = PlacesListViewModel()

    var body: some View {
        List {
            ForEach(viewModel.locations, id: \.self) { location in
                Text(location.name ?? "unknown")
                    .onTapGesture {
                        viewModel.handleTap(on: location)
                    }
            }
        }
        .padding()
        .task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    PlacesListView()
}
