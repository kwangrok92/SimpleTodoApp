//
//  SimpleMemoAppApp.swift
//  SimpleMemoApp
//
//  Created by 김광록 on 2023/07/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct SimpleMemoAppApp: App {
  var body: some Scene {
    WindowGroup {
      HomeView(store: Store(initialState: AppState(todos: []),
                               reducer: appReducer,
                               environment: ()))
    }
  }
}
