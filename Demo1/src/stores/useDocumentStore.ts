import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { Document, DocumentState } from '../types/document'

export const useDocumentStore = create<DocumentState>()(
  persist(
    (set, get) => ({
      documents: [],
      currentDocId: null,

      addDocument: (doc) => {
        const id = 'doc_' + Date.now()
        const now = new Date().toISOString()
        const newDoc: Document = {
          id,
          title: doc.title || '未命名文档',
          content: doc.content || '',
          createdAt: now,
          updatedAt: now
        }
        set((state) => ({
          documents: [newDoc, ...state.documents],
          currentDocId: id
        }))
        return id
      },

      updateDocument: (id, updates) => {
        set((state) => ({
          documents: state.documents.map((doc) =>
            doc.id === id
              ? { ...doc, ...updates, updatedAt: new Date().toISOString() }
              : doc
          )
        }))
      },

      deleteDocument: (id) => {
        set((state) => ({
          documents: state.documents.filter((doc) => doc.id !== id),
          currentDocId: state.currentDocId === id ? null : state.currentDocId
        }))
      },

      setCurrentDoc: (id) => {
        set({ currentDocId: id })
      },

      getCurrentDoc: () => {
        const state = get()
        return state.documents.find((doc) => doc.id === state.currentDocId)
      }
    }),
    {
      name: 'office-documents'
    }
  )
)
