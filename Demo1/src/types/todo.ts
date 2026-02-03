export type Priority = 'low' | 'medium' | 'high'
export type Filter = 'all' | 'active' | 'completed'

export interface Todo {
  id: string
  text: string
  priority: Priority
  dueDate: string | null
  completed: boolean
  createdAt: string
}

export interface TodoState {
  todos: Todo[]
  filter: Filter
  addTodo: (todo: Omit<Todo, 'id' | 'createdAt'>) => void
  updateTodo: (id: string, updates: Partial<Pick<Todo, 'text' | 'priority' | 'dueDate' | 'completed'>>) => void
  deleteTodo: (id: string) => void
  toggleTodo: (id: string) => void
  setFilter: (filter: Filter) => void
  clearCompleted: () => void
  getFilteredTodos: () => Todo[]
  getActiveTodosCount: () => number
}
