// 待办事项模块
const TodoApp = {
    tasks: [],
    currentFilter: 'all',

    init() {
        this.loadTasks();
        this.renderTasks();
        this.setupFilters();
        this.setupDateInput();
    },

    loadTasks() {
        const saved = localStorage.getItem('office_todos');
        this.tasks = saved ? JSON.parse(saved) : [];
    },

    saveTasks() {
        localStorage.setItem('office_todos', JSON.stringify(this.tasks));
        this.updateDashboardCount();
        this.updateStats();
    },

    addTask() {
        const input = document.getElementById('todo-input');
        const prioritySelect = document.getElementById('todo-priority');
        const dateInput = document.getElementById('todo-date');

        const text = input.value.trim();
        if (!text) return;

        const task = {
            id: 'task_' + Date.now(),
            text: text,
            priority: prioritySelect.value,
            dueDate: dateInput.value || null,
            completed: false,
            createdAt: new Date().toISOString()
        };

        this.tasks.unshift(task);
        this.saveTasks();
        this.renderTasks();

        // 清空输入
        input.value = '';
        dateInput.value = '';
        input.focus();

        this.showNotification('任务已添加');
    },

    toggleTask(taskId) {
        const task = this.tasks.find(t => t.id === taskId);
        if (task) {
            task.completed = !task.completed;
            this.saveTasks();
            this.renderTasks();
        }
    },

    deleteTask(taskId) {
        this.tasks = this.tasks.filter(t => t.id !== taskId);
        this.saveTasks();
        this.renderTasks();
        this.showNotification('任务已删除');
    },

    editTask(taskId) {
        const task = this.tasks.find(t => t.id === taskId);
        if (!task) return;

        const newText = prompt('编辑任务:', task.text);
        if (newText !== null && newText.trim()) {
            task.text = newText.trim();
            this.saveTasks();
            this.renderTasks();
            this.showNotification('任务已更新');
        }
    },

    clearCompleted() {
        const completedCount = this.tasks.filter(t => t.completed).length;
        if (completedCount === 0) {
            this.showNotification('没有已完成的任务');
            return;
        }

        if (confirm(`确定要清除 ${completedCount} 个已完成的任务吗？`)) {
            this.tasks = this.tasks.filter(t => !t.completed);
            this.saveTasks();
            this.renderTasks();
            this.showNotification('已清除完成的任务');
        }
    },

    getFilteredTasks() {
        switch (this.currentFilter) {
            case 'active':
                return this.tasks.filter(t => !t.completed);
            case 'completed':
                return this.tasks.filter(t => t.completed);
            default:
                return this.tasks;
        }
    },

    renderTasks() {
        const listEl = document.getElementById('todo-list');
        if (!listEl) return;

        const filteredTasks = this.getFilteredTasks();

        if (filteredTasks.length === 0) {
            listEl.innerHTML = `
                <div style="text-align: center; padding: 40px; color: #999;">
                    <p style="font-size: 3rem; margin-bottom: 10px;">📝</p>
                    <p>${this.currentFilter === 'all' ? '暂无任务，添加一个吧！' :
                         this.currentFilter === 'active' ? '没有待完成的任务' : '没有已完成的任务'}</p>
                </div>
            `;
            return;
        }

        listEl.innerHTML = filteredTasks.map(task => `
            <div class="todo-item ${task.completed ? 'completed' : ''}" data-id="${task.id}">
                <input type="checkbox"
                       ${task.completed ? 'checked' : ''}
                       onchange="TodoApp.toggleTask('${task.id}')">
                <span class="todo-text" ondblclick="TodoApp.editTask('${task.id}')">${this.escapeHtml(task.text)}</span>
                <span class="todo-priority priority-${task.priority}">
                    ${task.priority === 'high' ? '高' : task.priority === 'medium' ? '中' : '低'}
                </span>
                ${task.dueDate ? `<span class="todo-date ${this.isOverdue(task) ? 'overdue' : ''}">${this.formatDate(task.dueDate)}</span>` : ''}
                <button class="todo-delete" onclick="TodoApp.deleteTask('${task.id}')">×</button>
            </div>
        `).join('');

        this.updateStats();
    },

    setupFilters() {
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                this.currentFilter = btn.dataset.filter;
                this.renderTasks();
            });
        });
    },

    setupDateInput() {
        const dateInput = document.getElementById('todo-date');
        if (dateInput) {
            // 设置最小日期为今天
            const today = new Date().toISOString().split('T')[0];
            dateInput.min = today;
        }
    },

    updateStats() {
        const totalEl = document.getElementById('total-tasks');
        const completedEl = document.getElementById('completed-tasks');

        if (totalEl) {
            totalEl.textContent = this.tasks.length;
        }
        if (completedEl) {
            completedEl.textContent = this.tasks.filter(t => t.completed).length;
        }
    },

    updateDashboardCount() {
        const countEl = document.getElementById('todo-count');
        if (countEl) {
            countEl.textContent = this.tasks.filter(t => !t.completed).length;
        }
    },

    formatDate(dateString) {
        const date = new Date(dateString);
        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        const dateStr = date.toISOString().split('T')[0];
        const todayStr = today.toISOString().split('T')[0];
        const tomorrowStr = tomorrow.toISOString().split('T')[0];

        if (dateStr === todayStr) {
            return '今天';
        } else if (dateStr === tomorrowStr) {
            return '明天';
        } else {
            return `${date.getMonth() + 1}/${date.getDate()}`;
        }
    },

    isOverdue(task) {
        if (!task.dueDate || task.completed) return false;
        const dueDate = new Date(task.dueDate);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        return dueDate < today;
    },

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
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
    },

    // 拖拽排序功能
    enableDragAndDrop() {
        const list = document.getElementById('todo-list');
        if (!list) return;

        let draggedItem = null;

        list.addEventListener('dragstart', (e) => {
            draggedItem = e.target.closest('.todo-item');
            if (draggedItem) {
                draggedItem.style.opacity = '0.5';
            }
        });

        list.addEventListener('dragend', (e) => {
            if (draggedItem) {
                draggedItem.style.opacity = '1';
                draggedItem = null;
            }
        });

        list.addEventListener('dragover', (e) => {
            e.preventDefault();
            const afterElement = this.getDragAfterElement(list, e.clientY);
            if (draggedItem) {
                if (afterElement) {
                    list.insertBefore(draggedItem, afterElement);
                } else {
                    list.appendChild(draggedItem);
                }
            }
        });
    },

    getDragAfterElement(container, y) {
        const draggableElements = [...container.querySelectorAll('.todo-item:not(.dragging)')];

        return draggableElements.reduce((closest, child) => {
            const box = child.getBoundingClientRect();
            const offset = y - box.top - box.height / 2;

            if (offset < 0 && offset > closest.offset) {
                return { offset: offset, element: child };
            } else {
                return closest;
            }
        }, { offset: Number.NEGATIVE_INFINITY }).element;
    }
};

// 添加逾期日期样式
const todoStyle = document.createElement('style');
todoStyle.textContent = `
    .todo-date.overdue {
        color: #dc3545 !important;
        font-weight: 600;
    }
`;
document.head.appendChild(todoStyle);
