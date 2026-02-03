import { forwardRef, InputHTMLAttributes } from 'react'
import { cn } from '../../utils/cn'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  glow?: boolean
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, glow = false, type = 'text', ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          'w-full px-4 py-3 bg-dark-card/50 border border-white/10 rounded-xl',
          'text-white placeholder-white/40 outline-none transition-all duration-200',
          'focus:border-accent-primary/50',
          glow && 'focus:shadow-glow-purple/20',
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)

Input.displayName = 'Input'

interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  glow?: boolean
}

const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ className, glow = false, ...props }, ref) => {
    return (
      <textarea
        className={cn(
          'w-full px-4 py-3 bg-dark-card/50 border border-white/10 rounded-xl',
          'text-white placeholder-white/40 outline-none transition-all duration-200',
          'focus:border-accent-primary/50 resize-none',
          glow && 'focus:shadow-glow-purple/20',
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)

Textarea.displayName = 'Textarea'

export { Input, Textarea }
