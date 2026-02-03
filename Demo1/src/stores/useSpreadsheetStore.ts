import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { Spreadsheet, SpreadsheetState } from '../types/spreadsheet'

export const useSpreadsheetStore = create<SpreadsheetState>()(
  persist(
    (set, get) => ({
      sheets: [],
      currentSheetId: null,
      selectedCell: null,

      addSheet: (sheet) => {
        const id = 'sheet_' + Date.now()
        const now = new Date().toISOString()
        const newSheet: Spreadsheet = {
          id,
          title: sheet.title || '未命名表格',
          data: sheet.data || {},
          rows: sheet.rows || 20,
          cols: sheet.cols || 10,
          createdAt: now,
          updatedAt: now
        }
        set((state) => ({
          sheets: [newSheet, ...state.sheets],
          currentSheetId: id
        }))
        return id
      },

      updateSheet: (id, updates) => {
        set((state) => ({
          sheets: state.sheets.map((sheet) =>
            sheet.id === id
              ? { ...sheet, ...updates, updatedAt: new Date().toISOString() }
              : sheet
          )
        }))
      },

      deleteSheet: (id) => {
        set((state) => ({
          sheets: state.sheets.filter((sheet) => sheet.id !== id),
          currentSheetId: state.currentSheetId === id ? null : state.currentSheetId
        }))
      },

      setCurrentSheet: (id) => {
        set({ currentSheetId: id, selectedCell: null })
      },

      setSelectedCell: (cellId) => {
        set({ selectedCell: cellId })
      },

      getCurrentSheet: () => {
        const state = get()
        return state.sheets.find((sheet) => sheet.id === state.currentSheetId)
      },

      updateCellData: (cellId, value) => {
        const state = get()
        if (!state.currentSheetId) return

        const sheet = state.sheets.find((s) => s.id === state.currentSheetId)
        if (!sheet) return

        const newData = { ...sheet.data, [cellId]: value }
        set((state) => ({
          sheets: state.sheets.map((s) =>
            s.id === state.currentSheetId
              ? { ...s, data: newData, updatedAt: new Date().toISOString() }
              : s
          )
        }))
      }
    }),
    {
      name: 'office-sheets'
    }
  )
)
