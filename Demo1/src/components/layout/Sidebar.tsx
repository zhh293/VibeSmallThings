import { motion } from 'framer-motion'
import {
  LayoutDashboard,
  FileText,
  Table2,
  CheckSquare,
  Moon,
  Sun,
  Sparkles
} from 'lucide-react'
import { cn } from '../../utils/cn'
import { useThemeStore } from '../../stores/useThemeStore'

type Module = 'dashboard' | 'document' | 'spreadsheet' | 'todo'

interface SidebarProps {
  currentModule: Module
  onModuleChange: (module: Module) => void
}

const navItems = [
  { id: 'dashboard' as Module, label: '仪表盘', icon: LayoutDashboard },
  { id: 'document' as Module, label: '文档编辑器', icon: FileText },
  { id: 'spreadsheet' as Module, label: '电子表格', icon: Table2 },
  { id: 'todo' as Module, label: '待办事项', icon: CheckSquare }
]

export function Sidebar({ currentModule, onModuleChange }: SidebarProps) {
  const { theme, toggleTheme } = useThemeStore()

  return (
    <motion.aside
      initial={{ x: -20, opacity: 0 }}
      animate={{ x: 0, opacity: 1 }}
      className="fixed left-0 top-0 h-full w-60 glass-card rounded-none border-l-0 border-t-0 border-b-0 z-40 flex flex-col"
    >
      {/* Logo */}
      <div className="p-6 border-b border-white/[0.06]">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 flex items-center justify-center">
            <Sparkles className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="font-bold text-white">Office Suite</h1>
            <p className="text-xs text-white/40">办公套件</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map((item) => {
          const isActive = currentModule === item.id
          const Icon = item.icon

          return (
            <motion.button
              key={item.id}
              onClick={() => onModuleChange(item.id)}
              className={cn(
                'w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-all duration-200 relative group',
                isActive
                  ? 'text-white bg-white/10'
                  : 'text-white/60 hover:text-white hover:bg-white/5'
              )}
              whileHover={{ x: 4 }}
              whileTap={{ scale: 0.98 }}
            >
              {/* Active indicator */}
              {isActive && (
                <motion.div
                  layoutId="activeIndicator"
                  className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-8 rounded-r-full bg-gradient-to-b from-indigo-500 to-purple-500"
                  transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                />
              )}

              <Icon className={cn(
                'w-5 h-5 transition-colors',
                isActive ? 'text-purple-400' : 'text-white/40 group-hover:text-white/60'
              )} />
              <span className="font-medium">{item.label}</span>

              {/* Glow effect on hover */}
              {isActive && (
                <motion.div
                  className="absolute inset-0 rounded-xl bg-gradient-to-r from-indigo-500/10 to-purple-500/10 -z-10"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                />
              )}
            </motion.button>
          )
        })}
      </nav>

      {/* Theme Toggle */}
      <div className="p-4 border-t border-white/[0.06]">
        <motion.button
          onClick={toggleTheme}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-white/60 hover:text-white hover:bg-white/5 transition-all duration-200"
          whileHover={{ x: 4 }}
          whileTap={{ scale: 0.98 }}
        >
          {theme === 'dark' ? (
            <>
              <Moon className="w-5 h-5 text-white/40" />
              <span className="font-medium">深色模式</span>
            </>
          ) : (
            <>
              <Sun className="w-5 h-5 text-amber-400" />
              <span className="font-medium">浅色模式</span>
            </>
          )}
        </motion.button>
      </div>
    </motion.aside>
  )
}
