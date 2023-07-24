//
//  ContentView.swift
//  SimpleMemoApp
//
//  Created by 김광록 on 2023/07/24.
//

// ContentView.swift

import SwiftUI
import ComposableArchitecture

// 앱 상태 정의
struct AppState: Equatable {
  var todos: [String]
}

// 앱 동작 정의
enum AppAction: Equatable {
  case addTodo
  case removeTodo(index: Int)
}

// 앱 Reducer 정의
let appReducer = AnyReducer<AppState, AppAction, Void> { state, action, _ in
  switch action {
  case .addTodo:
    state.todos.append("New Todo")
    return .none
  case let .removeTodo(index):
    state.todos.remove(at: index)
    return .none
  }
}

// 메인 뷰 정의
struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        HStack {
          Button("추가") {
            viewStore.send(.addTodo)
          }
        }
        List {
          ForEach(viewStore.todos.indices, id: \.self) { index in
            Text(viewStore.todos[index])
          }
          .onDelete { indices in // 여기서 삭제 동작을 처리합니다.
            indices.forEach { index in
              viewStore.send(.removeTodo(index: index))
            }
          }
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: Store(initialState: AppState(todos: []),
                             reducer: appReducer,
                             environment: ()))
  }
}
