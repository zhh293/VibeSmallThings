// 文档编辑器模块
const DocumentEditor = {
    currentDocId: null,
    documents: [],

    init() {
        this.loadDocuments();
        this.renderDocList();
        this.setupAutoSave();
    },

    loadDocuments() {
        const saved = localStorage.getItem('office_documents');
        this.documents = saved ? JSON.parse(saved) : [];
    },

    saveDocuments() {
        localStorage.setItem('office_documents', JSON.stringify(this.documents));
        this.updateDashboardCount();
    },

    renderDocList() {
        const listEl = document.getElementById('doc-list');
        if (!listEl) return;

        if (this.documents.length === 0) {
            listEl.innerHTML = '<p style="color: #999; text-align: center;">暂无文档</p>';
            return;
        }

        listEl.innerHTML = this.documents.map(doc => `
            <div class="doc-item ${doc.id === this.currentDocId ? 'active' : ''}"
                 onclick="DocumentEditor.openDoc('${doc.id}')">
                <span>${doc.title || '未命名文档'}</span>
                <button class="delete-btn" onclick="event.stopPropagation(); DocumentEditor.deleteDoc('${doc.id}')">🗑️</button>
            </div>
        `).join('');
    },

    execCommand(command, value = null) {
        document.execCommand(command, false, value);
        document.getElementById('editor').focus();
    },

    newDoc() {
        const doc = {
            id: 'doc_' + Date.now(),
            title: '',
            content: '',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        this.documents.unshift(doc);
        this.currentDocId = doc.id;
        this.saveDocuments();
        this.renderDocList();

        document.getElementById('doc-title').value = '';
        document.getElementById('editor').innerHTML = '';
        document.getElementById('editor').focus();
    },

    openDoc(docId) {
        const doc = this.documents.find(d => d.id === docId);
        if (!doc) return;

        this.currentDocId = docId;
        document.getElementById('doc-title').value = doc.title;
        document.getElementById('editor').innerHTML = doc.content;
        this.renderDocList();
    },

    save() {
        if (!this.currentDocId) {
            this.newDoc();
        }

        const doc = this.documents.find(d => d.id === this.currentDocId);
        if (doc) {
            doc.title = document.getElementById('doc-title').value || '未命名文档';
            doc.content = document.getElementById('editor').innerHTML;
            doc.updatedAt = new Date().toISOString();
            this.saveDocuments();
            this.renderDocList();
            this.showNotification('文档已保存');
        }
    },

    deleteDoc(docId) {
        if (!confirm('确定要删除这个文档吗？')) return;

        this.documents = this.documents.filter(d => d.id !== docId);
        if (this.currentDocId === docId) {
            this.currentDocId = null;
            document.getElementById('doc-title').value = '';
            document.getElementById('editor').innerHTML = '';
        }
        this.saveDocuments();
        this.renderDocList();
        this.showNotification('文档已删除');
    },

    exportDoc() {
        const title = document.getElementById('doc-title').value || '未命名文档';
        const content = document.getElementById('editor').innerHTML;

        const blob = new Blob([`
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>${title}</title>
                <style>
                    body { font-family: 'Microsoft YaHei', sans-serif; padding: 40px; max-width: 800px; margin: 0 auto; }
                </style>
            </head>
            <body>
                <h1>${title}</h1>
                ${content}
            </body>
            </html>
        `], { type: 'text/html' });

        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${title}.html`;
        a.click();
        URL.revokeObjectURL(url);
        this.showNotification('文档已导出');
    },

    setupAutoSave() {
        setInterval(() => {
            if (this.currentDocId) {
                const doc = this.documents.find(d => d.id === this.currentDocId);
                if (doc) {
                    const currentContent = document.getElementById('editor').innerHTML;
                    const currentTitle = document.getElementById('doc-title').value;
                    if (doc.content !== currentContent || doc.title !== currentTitle) {
                        this.save();
                    }
                }
            }
        }, 30000); // 每30秒自动保存
    },

    updateDashboardCount() {
        const countEl = document.getElementById('doc-count');
        if (countEl) {
            countEl.textContent = this.documents.length;
        }
    },

    showNotification(message) {
        // 创建通知元素
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

// 添加动画样式
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);
