// 主应用程序
const App = {
    currentModule: 'dashboard',

    init() {
        this.setupNavigation();
        this.setupDashboardCards();

        // 初始化各模块
        DocumentEditor.init();
        Spreadsheet.init();
        TodoApp.init();

        // 更新仪表盘统计
        this.updateDashboardStats();

        console.log('办公套件已初始化');
    },

    setupNavigation() {
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', () => {
                const module = item.dataset.module;
                this.switchModule(module);
            });
        });
    },

    setupDashboardCards() {
        document.querySelectorAll('.dashboard-card').forEach(card => {
            card.addEventListener('click', () => {
                const target = card.dataset.target;
                if (target) {
                    this.switchModule(target);
                }
            });
        });
    },

    switchModule(moduleName) {
        // 更新导航状态
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.toggle('active', item.dataset.module === moduleName);
        });

        // 切换模块显示
        document.querySelectorAll('.module').forEach(module => {
            module.classList.toggle('active', module.id === moduleName);
        });

        this.currentModule = moduleName;

        // 如果切换到仪表盘，更新统计
        if (moduleName === 'dashboard') {
            this.updateDashboardStats();
        }
    },

    updateDashboardStats() {
        // 更新待办任务数
        const todoCount = document.getElementById('todo-count');
        if (todoCount) {
            const activeTasks = TodoApp.tasks ? TodoApp.tasks.filter(t => !t.completed).length : 0;
            todoCount.textContent = activeTasks;
        }

        // 更新文档数
        const docCount = document.getElementById('doc-count');
        if (docCount) {
            docCount.textContent = DocumentEditor.documents ? DocumentEditor.documents.length : 0;
        }

        // 更新表格数
        const sheetCount = document.getElementById('sheet-count');
        if (sheetCount) {
            sheetCount.textContent = Spreadsheet.sheets ? Spreadsheet.sheets.length : 0;
        }
    }
};

// 键盘快捷键
document.addEventListener('keydown', (e) => {
    // Ctrl/Cmd + S 保存
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
        e.preventDefault();
        if (App.currentModule === 'document') {
            DocumentEditor.save();
        } else if (App.currentModule === 'spreadsheet') {
            Spreadsheet.save();
        }
    }

    // Ctrl/Cmd + N 新建
    if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
        e.preventDefault();
        if (App.currentModule === 'document') {
            DocumentEditor.newDoc();
        } else if (App.currentModule === 'spreadsheet') {
            Spreadsheet.newSheet();
        }
    }

    // 数字键快速切换模块
    if (e.altKey) {
        switch (e.key) {
            case '1':
                App.switchModule('dashboard');
                break;
            case '2':
                App.switchModule('document');
                break;
            case '3':
                App.switchModule('spreadsheet');
                break;
            case '4':
                App.switchModule('todo');
                break;
        }
    }
});

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', () => {
    App.init();
});

// 页面关闭前自动保存
window.addEventListener('beforeunload', () => {
    // 自动保存当前编辑的文档
    if (DocumentEditor.currentDocId) {
        DocumentEditor.save();
    }
    // 自动保存当前编辑的表格
    if (Spreadsheet.currentSheetId) {
        Spreadsheet.save();
    }
});

// 添加欢迎提示
setTimeout(() => {
    if (!localStorage.getItem('office_welcomed')) {
        const tips = document.createElement('div');
        tips.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 30px 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            z-index: 10000;
            max-width: 500px;
            text-align: center;
        `;
        tips.innerHTML = `
            <h2 style="margin-bottom: 20px; color: #2c3e50;">欢迎使用办公套件！</h2>
            <p style="color: #666; margin-bottom: 20px; line-height: 1.8;">
                这是一个功能完整的网页版办公软件，包含：<br>
                📄 文档编辑器 - 支持富文本编辑<br>
                📊 电子表格 - 支持公式计算<br>
                ✅ 待办事项 - 任务管理
            </p>
            <p style="color: #999; font-size: 14px; margin-bottom: 20px;">
                快捷键: Ctrl+S 保存 | Ctrl+N 新建 | Alt+数字 切换模块
            </p>
            <button onclick="this.parentElement.remove(); localStorage.setItem('office_welcomed', 'true')"
                    style="padding: 12px 30px; background: #4a90d9; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px;">
                开始使用
            </button>
        `;
        document.body.appendChild(tips);
    }
}, 500);
