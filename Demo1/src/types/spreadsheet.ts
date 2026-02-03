export interface CellData {
  [key: string]: string
}

export interface Spreadsheet {
  id: string
  title: string
  data: CellData
  rows: number
  cols: number
  createdAt: string
  updatedAt: string
}

export interface SpreadsheetState {
  sheets: Spreadsheet[]
  currentSheetId: string | null
  selectedCell: string | null
  addSheet: (sheet: Omit<Spreadsheet, 'id' | 'createdAt' | 'updatedAt'>) => string
  updateSheet: (id: string, updates: Partial<Pick<Spreadsheet, 'title' | 'data' | 'rows' | 'cols'>>) => void
  deleteSheet: (id: string) => void
  setCurrentSheet: (id: string | null) => void
  setSelectedCell: (cellId: string | null) => void
  getCurrentSheet: () => Spreadsheet | undefined
  updateCellData: (cellId: string, value: string) => void
}
