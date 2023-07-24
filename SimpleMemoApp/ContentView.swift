//
//  ContentView.swift
//  SimpleMemoApp
//
//  Created by 김광록 on 2023/07/24.
//

// ContentView.swift

// ContentView.swift

import SwiftUI
import ComposableArchitecture

// 앱 상태 정의
struct AppState: Equatable {
  var todos: [String]
  var selectedIndex: Int?
  var editingState: EditingState?
}

// 선택된 항목의 수정 내용 저장을 위한 상태 정의
struct EditingState: Equatable {
  var index: Int
  var todo: String
}

// 앱 동작 정의
enum AppAction: Equatable {
  case addTodo
  case removeTodo(index: Int)
  case selectTodo(index: Int)
  case updateEditedTodo(String)
  case saveTodoEdit
}

// 앱 Reducer 정의
let appReducer = Reducer<AppState, AppAction, Void> { state, action, _ in
  switch action {
  case .addTodo:
    state.todos.append("New Todo")
    return .none
  case let .removeTodo(index):
    state.todos.remove(at: index)
    return .none
  case let .selectTodo(index):
    state.selectedIndex = index
    if let selectedTodo = state.todos[safe: index] {
      state.editingState = EditingState(index: index, todo: selectedTodo)
    }
    return .none
  case let .updateEditedTodo(todo):
    state.editingState?.todo = todo
    return .none
  case .saveTodoEdit:
    if let selectedIndex = state.selectedIndex {
      state.editingState = nil
      state.todos[selectedIndex] = state.editingState?.todo ?? state.todos[selectedIndex]
      state.selectedIndex = nil
    }
    return .none
  }
}

// View Extension to Get Safe Array Index
extension Array {
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

// 메인 뷰 정의
struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        List {
          ForEach(viewStore.todos.indices, id: \.self) { index in
            if let selectedIndex = viewStore.selectedIndex, selectedIndex == index {
              TextField("Edit Todo", text: viewStore.binding(
                get: { state in viewStore.editingState?.todo ?? viewStore.todos[index] },
                send: { .updateEditedTodo($0) }
              ))
            } else {
              Text(viewStore.todos[index])
                .onTapGesture {
                  viewStore.send(.selectTodo(index: index))
                }
            }
          }
          .onDelete { indices in
            indices.forEach { index in
              viewStore.send(.removeTodo(index: index))
            }
          }
        }
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") {
              viewStore.send(.saveTodoEdit)
            }
            .disabled(viewStore.selectedIndex == nil)
          }
        }
        HStack {
          Button("삭제") {
            viewStore.send(.addTodo)
          }
          Spacer()
          Button("추가") {
            viewStore.send(.addTodo)
          }
        }
        .padding(.horizontal, 40)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(
          todos: ["Buy groceries", "Go for a walk", "Read a book", "1 day 1 commit"],
          selectedIndex: nil,
          editingState: nil
        ),
        reducer: appReducer,
        environment: ()
      )
    )
  }
}
