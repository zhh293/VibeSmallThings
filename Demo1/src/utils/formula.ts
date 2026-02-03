import type { CellData } from '../types/spreadsheet'

export function getColumnName(index: number): string {
  let name = ''
  let idx = index
  while (idx >= 0) {
    name = String.fromCharCode((idx % 26) + 65) + name
    idx = Math.floor(idx / 26) - 1
  }
  return name
}

export function getColumnIndex(name: string): number {
  let index = 0
  for (let i = 0; i < name.length; i++) {
    index = index * 26 + (name.charCodeAt(i) - 64)
  }
  return index - 1
}

export function parseCellId(cellId: string): { col: string; row: number } {
  const match = cellId.match(/^([A-Z]+)(\d+)$/)
  if (!match) throw new Error('Invalid cell ID')
  return { col: match[1], row: parseInt(match[2], 10) }
}

export function getCellValue(cellId: string, data: CellData, evaluator: (formula: string) => number | string): number {
  const value = data[cellId]
  if (!value) return 0
  if (value.startsWith('=')) {
    const result = evaluator(value)
    return typeof result === 'number' ? result : parseFloat(result) || 0
  }
  return parseFloat(value) || 0
}

export function getRangeValues(
  start: string,
  end: string,
  data: CellData,
  evaluator: (formula: string) => number | string
): number[] {
  const values: number[] = []
  const startParsed = parseCellId(start)
  const endParsed = parseCellId(end)

  const startColIndex = getColumnIndex(startParsed.col)
  const endColIndex = getColumnIndex(endParsed.col)

  for (let r = startParsed.row; r <= endParsed.row; r++) {
    for (let c = startColIndex; c <= endColIndex; c++) {
      const cellId = `${getColumnName(c)}${r}`
      const value = getCellValue(cellId, data, evaluator)
      if (!isNaN(value)) {
        values.push(value)
      }
    }
  }
  return values
}

export function evaluateFormula(formula: string, data: CellData): number | string {
  try {
    const expression = formula.substring(1).toUpperCase()

    const evaluator = (f: string) => evaluateFormula(f, data)

    // SUM function
    let match = expression.match(/^SUM\(([A-Z]+\d+):([A-Z]+\d+)\)$/)
    if (match) {
      const values = getRangeValues(match[1], match[2], data, evaluator)
      return values.reduce((a, b) => a + b, 0)
    }

    // AVG/AVERAGE function
    match = expression.match(/^(?:AVG|AVERAGE)\(([A-Z]+\d+):([A-Z]+\d+)\)$/)
    if (match) {
      const values = getRangeValues(match[1], match[2], data, evaluator)
      if (values.length === 0) return 0
      return values.reduce((a, b) => a + b, 0) / values.length
    }

    // MAX function
    match = expression.match(/^MAX\(([A-Z]+\d+):([A-Z]+\d+)\)$/)
    if (match) {
      const values = getRangeValues(match[1], match[2], data, evaluator)
      if (values.length === 0) return 0
      return Math.max(...values)
    }

    // MIN function
    match = expression.match(/^MIN\(([A-Z]+\d+):([A-Z]+\d+)\)$/)
    if (match) {
      const values = getRangeValues(match[1], match[2], data, evaluator)
      if (values.length === 0) return 0
      return Math.min(...values)
    }

    // COUNT function
    match = expression.match(/^COUNT\(([A-Z]+\d+):([A-Z]+\d+)\)$/)
    if (match) {
      const values = getRangeValues(match[1], match[2], data, evaluator)
      return values.length
    }

    // Simple math expression with cell references
    let evalExpr = expression.replace(/([A-Z]+\d+)/g, (m) => {
      const val = getCellValue(m, data, evaluator)
      return isNaN(val) ? '0' : val.toString()
    })

    return safeEval(evalExpr)
  } catch {
    return '#ERROR'
  }
}

function safeEval(expr: string): number | string {
  // Only allow numbers and basic operators
  if (!/^[\d\s+\-*/().]+$/.test(expr)) {
    return '#ERROR'
  }
  try {
    const result = Function('"use strict"; return (' + expr + ')')()
    return typeof result === 'number' && !isNaN(result) ? result : '#ERROR'
  } catch {
    return '#ERROR'
  }
}

export function getDisplayValue(cellId: string, data: CellData): string {
  const value = data[cellId]
  if (!value) return ''
  if (value.startsWith('=')) {
    const result = evaluateFormula(value, data)
    return result.toString()
  }
  return value
}
