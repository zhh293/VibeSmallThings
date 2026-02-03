import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { Todo, TodoState, Filter } from '../types/todo'

export const useTodoStore = create<TodoState>()(
  persist(
    (set, get) => ({
      todos: [],
      filter: 'all' as Filter,

      addTodo: (todo) => {
        const newTodo: Todo = {
          id: 'task_' + Date.now(),
          text: todo.text,
          priority: todo.priority,
          dueDate: todo.dueDate,
          completed: false,
          createdAt: new Date().toISOString()
        }
        set((state) => ({
          todos: [newTodo, ...state.todos]
        }))
      },

      updateTodo: (id, updates) => {
        set((state) => ({
          todos: state.todos.map((todo) =>
            todo.id === id ? { ...todo, ...updates } : todo
          )
        }))
      },

      deleteTodo: (id) => {
        set((state) => ({
          todos: state.todos.filter((todo) => todo.id !== id)
        }))
      },

      toggleTodo: (id) => {
        set((state) => ({
          todos: state.todos.map((todo) =>
            todo.id === id ? { ...todo, completed: !todo.completed } : todo
          )
        }))
      },

      setFilter: (filter) => {
        set({ filter })
      },

      clearCompleted: () => {
        set((state) => ({
          todos: state.todos.filter((todo) => !todo.completed)
        }))
      },

      getFilteredTodos: () => {
        const state = get()
        switch (state.filter) {
          case 'active':
            return state.todos.filter((todo) => !todo.completed)
          case 'completed':
            return state.todos.filter((todo) => todo.completed)
          default:
            return state.todos
        }
      },

      getActiveTodosCount: () => {
        return get().todos.filter((todo) => !todo.completed).length
      }
    }),
    {
      name: 'office-todos'
    }
  )
)
