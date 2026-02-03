export interface Document {
  id: string
  title: string
  content: string
  createdAt: string
  updatedAt: string
}

export interface DocumentState {
  documents: Document[]
  currentDocId: string | null
  addDocument: (doc: Omit<Document, 'id' | 'createdAt' | 'updatedAt'>) => string
  updateDocument: (id: string, updates: Partial<Pick<Document, 'title' | 'content'>>) => void
  deleteDocument: (id: string) => void
  setCurrentDoc: (id: string | null) => void
  getCurrentDoc: () => Document | undefined
}
