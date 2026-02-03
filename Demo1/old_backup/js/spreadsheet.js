// 电子表格模块
const Spreadsheet = {
    currentSheetId: null,
    sheets: [],
    rows: 20,
    cols: 10,
    selectedCell: null,
    data: {},

    init() {
        this.loadSheets();
        this.renderSheetList();
        this.createGrid();
        this.setupFormulaBar();
    },

    loadSheets() {
        const saved = localStorage.getItem('office_sheets');
        this.sheets = saved ? JSON.parse(saved) : [];
    },

    saveSheets() {
        localStorage.setItem('office_sheets', JSON.stringify(this.sheets));
        this.updateDashboardCount();
    },

    renderSheetList() {
        const listEl = document.getElementById('sheet-list');
        if (!listEl) return;

        if (this.sheets.length === 0) {
            listEl.innerHTML = '<p style="color: #999; text-align: center;">暂无表格</p>';
            return;
        }

        listEl.innerHTML = this.sheets.map(sheet => `
            <div class="sheet-item ${sheet.id === this.currentSheetId ? 'active' : ''}"
                 onclick="Spreadsheet.openSheet('${sheet.id}')">
                <span>${sheet.title || '未命名表格'}</span>
                <button class="delete-btn" onclick="event.stopPropagation(); Spreadsheet.deleteSheet('${sheet.id}')" style="background:none;border:none;cursor:pointer;">🗑️</button>
            </div>
        `).join('');
    },

    createGrid() {
        const container = document.getElementById('spreadsheet-grid');
        if (!container) return;

        let html = '<table><thead><tr><th class="row-header"></th>';

        // 列头 (A, B, C, ...)
        for (let c = 0; c < this.cols; c++) {
            html += `<th>${this.getColumnName(c)}</th>`;
        }
        html += '</tr></thead><tbody>';

        // 数据行
        for (let r = 0; r < this.rows; r++) {
            html += `<tr><td class="row-header">${r + 1}</td>`;
            for (let c = 0; c < this.cols; c++) {
                const cellId = `${this.getColumnName(c)}${r + 1}`;
                const value = this.data[cellId] || '';
                html += `<td>
                    <input type="text"
                           id="cell-${cellId}"
                           value="${value}"
                           data-cell="${cellId}"
                           onfocus="Spreadsheet.selectCell('${cellId}')"
                           onchange="Spreadsheet.updateCell('${cellId}', this.value)"
                           onkeydown="Spreadsheet.handleKeydown(event, '${cellId}', ${r}, ${c})">
                </td>`;
            }
            html += '</tr>';
        }

        html += '</tbody></table>';
        container.innerHTML = html;
    },

    getColumnName(index) {
        let name = '';
        while (index >= 0) {
            name = String.fromCharCode((index % 26) + 65) + name;
            index = Math.floor(index / 26) - 1;
        }
        return name;
    },

    getColumnIndex(name) {
        let index = 0;
        for (let i = 0; i < name.length; i++) {
            index = index * 26 + (name.charCodeAt(i) - 64);
        }
        return index - 1;
    },

    selectCell(cellId) {
        // 移除之前选中的样式
        document.querySelectorAll('.spreadsheet-grid td.selected').forEach(td => {
            td.classList.remove('selected');
        });

        this.selectedCell = cellId;
        const input = document.getElementById(`cell-${cellId}`);
        if (input) {
            input.parentElement.classList.add('selected');
            document.getElementById('formula-input').value = this.data[cellId] || '';
        }
    },

    updateCell(cellId, value) {
        this.data[cellId] = value;

        // 如果是公式，计算结果
        if (value.startsWith('=')) {
            const result = this.evaluateFormula(value);
            const input = document.getElementById(`cell-${cellId}`);
            if (input) {
                input.value = result;
            }
        }

        // 更新依赖此单元格的其他公式
        this.recalculateAll();
    },

    evaluateFormula(formula) {
        try {
            const expression = formula.substring(1).toUpperCase();

            // SUM 函数
            let match = expression.match(/^SUM\(([A-Z]+\d+):([A-Z]+\d+)\)$/);
            if (match) {
                return this.sumRange(match[1], match[2]);
            }

            // AVG/AVERAGE 函数
            match = expression.match(/^(?:AVG|AVERAGE)\(([A-Z]+\d+):([A-Z]+\d+)\)$/);
            if (match) {
                return this.avgRange(match[1], match[2]);
            }

            // MAX 函数
            match = expression.match(/^MAX\(([A-Z]+\d+):([A-Z]+\d+)\)$/);
            if (match) {
                return this.maxRange(match[1], match[2]);
            }

            // MIN 函数
            match = expression.match(/^MIN\(([A-Z]+\d+):([A-Z]+\d+)\)$/);
            if (match) {
                return this.minRange(match[1], match[2]);
            }

            // COUNT 函数
            match = expression.match(/^COUNT\(([A-Z]+\d+):([A-Z]+\d+)\)$/);
            if (match) {
                return this.countRange(match[1], match[2]);
            }

            // 简单数学表达式（支持单元格引用）
            let evalExpr = expression.replace(/([A-Z]+\d+)/g, (match) => {
                const val = this.getCellValue(match);
                return isNaN(val) ? 0 : val;
            });

            // 安全地计算数学表达式
            return this.safeEval(evalExpr);

        } catch (e) {
            return '#ERROR';
        }
    },

    getCellValue(cellId) {
        const value = this.data[cellId];
        if (!value) return 0;
        if (value.startsWith('=')) {
            return this.evaluateFormula(value);
        }
        return parseFloat(value) || 0;
    },

    getRangeValues(start, end) {
        const values = [];
        const startCol = start.match(/[A-Z]+/)[0];
        const startRow = parseInt(start.match(/\d+/)[0]);
        const endCol = end.match(/[A-Z]+/)[0];
        const endRow = parseInt(end.match(/\d+/)[0]);

        const startColIndex = this.getColumnIndex(startCol);
        const endColIndex = this.getColumnIndex(endCol);

        for (let r = startRow; r <= endRow; r++) {
            for (let c = startColIndex; c <= endColIndex; c++) {
                const cellId = `${this.getColumnName(c)}${r}`;
                const value = this.getCellValue(cellId);
                if (!isNaN(value)) {
                    values.push(value);
                }
            }
        }
        return values;
    },

    sumRange(start, end) {
        const values = this.getRangeValues(start, end);
        return values.reduce((a, b) => a + b, 0);
    },

    avgRange(start, end) {
        const values = this.getRangeValues(start, end);
        if (values.length === 0) return 0;
        return values.reduce((a, b) => a + b, 0) / values.length;
    },

    maxRange(start, end) {
        const values = this.getRangeValues(start, end);
        if (values.length === 0) return 0;
        return Math.max(...values);
    },

    minRange(start, end) {
        const values = this.getRangeValues(start, end);
        if (values.length === 0) return 0;
        return Math.min(...values);
    },

    countRange(start, end) {
        const values = this.getRangeValues(start, end);
        return values.length;
    },

    safeEval(expr) {
        // 只允许数字和基本运算符
        if (!/^[\d\s+\-*/().]+$/.test(expr)) {
            return '#ERROR';
        }
        try {
            return Function('"use strict"; return (' + expr + ')')();
        } catch (e) {
            return '#ERROR';
        }
    },

    recalculateAll() {
        for (const cellId in this.data) {
            if (this.data[cellId] && this.data[cellId].startsWith('=')) {
                const result = this.evaluateFormula(this.data[cellId]);
                const input = document.getElementById(`cell-${cellId}`);
                if (input) {
                    input.value = result;
                }
            }
        }
    },

    handleKeydown(event, cellId, row, col) {
        let newRow = row;
        let newCol = col;

        switch (event.key) {
            case 'ArrowUp':
                newRow = Math.max(0, row - 1);
                break;
            case 'ArrowDown':
            case 'Enter':
                newRow = Math.min(this.rows - 1, row + 1);
                break;
            case 'ArrowLeft':
                if (event.target.selectionStart === 0) {
                    newCol = Math.max(0, col - 1);
                } else return;
                break;
            case 'ArrowRight':
                if (event.target.selectionEnd === event.target.value.length) {
                    newCol = Math.min(this.cols - 1, col + 1);
                } else return;
                break;
            case 'Tab':
                event.preventDefault();
                newCol = event.shiftKey ? Math.max(0, col - 1) : Math.min(this.cols - 1, col + 1);
                break;
            default:
                return;
        }

        if (newRow !== row || newCol !== col) {
            event.preventDefault();
            const newCellId = `${this.getColumnName(newCol)}${newRow + 1}`;
            const newInput = document.getElementById(`cell-${newCellId}`);
            if (newInput) {
                newInput.focus();
                newInput.select();
            }
        }
    },

    setupFormulaBar() {
        const formulaInput = document.getElementById('formula-input');
        if (formulaInput) {
            formulaInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' && this.selectedCell) {
                    this.data[this.selectedCell] = formulaInput.value;
                    this.updateCell(this.selectedCell, formulaInput.value);
                    const cellInput = document.getElementById(`cell-${this.selectedCell}`);
                    if (cellInput) {
                        cellInput.focus();
                    }
                }
            });
        }
    },

    addRow() {
        this.rows++;
        this.createGrid();
        this.loadDataToGrid();
    },

    addColumn() {
        this.cols++;
        this.createGrid();
        this.loadDataToGrid();
    },

    deleteRow() {
        if (this.rows > 1) {
            // 删除最后一行的数据
            for (let c = 0; c < this.cols; c++) {
                const cellId = `${this.getColumnName(c)}${this.rows}`;
                delete this.data[cellId];
            }
            this.rows--;
            this.createGrid();
            this.loadDataToGrid();
        }
    },

    deleteColumn() {
        if (this.cols > 1) {
            // 删除最后一列的数据
            const colName = this.getColumnName(this.cols - 1);
            for (let r = 1; r <= this.rows; r++) {
                const cellId = `${colName}${r}`;
                delete this.data[cellId];
            }
            this.cols--;
            this.createGrid();
            this.loadDataToGrid();
        }
    },

    loadDataToGrid() {
        for (const cellId in this.data) {
            const input = document.getElementById(`cell-${cellId}`);
            if (input) {
                const value = this.data[cellId];
                if (value && value.startsWith('=')) {
                    input.value = this.evaluateFormula(value);
                } else {
                    input.value = value || '';
                }
            }
        }
    },

    newSheet() {
        const sheet = {
            id: 'sheet_' + Date.now(),
            title: '',
            data: {},
            rows: 20,
            cols: 10,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        this.sheets.unshift(sheet);
        this.currentSheetId = sheet.id;
        this.data = {};
        this.rows = 20;
        this.cols = 10;
        this.saveSheets();
        this.renderSheetList();
        this.createGrid();

        document.getElementById('sheet-title').value = '';
    },

    openSheet(sheetId) {
        const sheet = this.sheets.find(s => s.id === sheetId);
        if (!sheet) return;

        this.currentSheetId = sheetId;
        this.data = { ...sheet.data };
        this.rows = sheet.rows || 20;
        this.cols = sheet.cols || 10;

        document.getElementById('sheet-title').value = sheet.title;
        this.createGrid();
        this.loadDataToGrid();
        this.renderSheetList();
    },

    save() {
        if (!this.currentSheetId) {
            this.newSheet();
        }

        const sheet = this.sheets.find(s => s.id === this.currentSheetId);
        if (sheet) {
            sheet.title = document.getElementById('sheet-title').value || '未命名表格';
            sheet.data = { ...this.data };
            sheet.rows = this.rows;
            sheet.cols = this.cols;
            sheet.updatedAt = new Date().toISOString();
            this.saveSheets();
            this.renderSheetList();
            this.showNotification('表格已保存');
        }
    },

    deleteSheet(sheetId) {
        if (!confirm('确定要删除这个表格吗？')) return;

        this.sheets = this.sheets.filter(s => s.id !== sheetId);
        if (this.currentSheetId === sheetId) {
            this.currentSheetId = null;
            this.data = {};
            document.getElementById('sheet-title').value = '';
            this.createGrid();
        }
        this.saveSheets();
        this.renderSheetList();
        this.showNotification('表格已删除');
    },

    exportCSV() {
        let csv = '';

        // 表头
        for (let c = 0; c < this.cols; c++) {
            csv += this.getColumnName(c);
            if (c < this.cols - 1) csv += ',';
        }
        csv += '\n';

        // 数据行
        for (let r = 1; r <= this.rows; r++) {
            for (let c = 0; c < this.cols; c++) {
                const cellId = `${this.getColumnName(c)}${r}`;
                let value = this.data[cellId] || '';
                if (value.startsWith('=')) {
                    value = this.evaluateFormula(value);
                }
                // 转义包含逗号的值
                if (value.toString().includes(',')) {
                    value = `"${value}"`;
                }
                csv += value;
                if (c < this.cols - 1) csv += ',';
            }
            csv += '\n';
        }

        const title = document.getElementById('sheet-title').value || '未命名表格';
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${title}.csv`;
        a.click();
        URL.revokeObjectURL(url);
        this.showNotification('表格已导出为CSV');
    },

    updateDashboardCount() {
        const countEl = document.getElementById('sheet-count');
        if (countEl) {
            countEl.textContent = this.sheets.length;
        }
    },

    showNotification(message) {
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #28a745;
            color: white;
            padding: 12px 24px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            z-index: 9999;
            animation: slideIn 0.3s ease;
        `;
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 2000);
    }
};
