import { motion } from 'framer-motion'

export function GradientBackground() {
  return (
    <div className="fixed inset-0 -z-10 overflow-hidden">
      {/* Base dark background */}
      <div className="absolute inset-0 bg-[#0a0a0b]" />

      {/* Aurora gradient blobs */}
      <motion.div
        className="absolute inset-0 opacity-30"
        animate={{
          background: [
            `radial-gradient(ellipse at 20% 20%, rgba(99, 102, 241, 0.15) 0%, transparent 50%),
             radial-gradient(ellipse at 80% 80%, rgba(168, 85, 247, 0.15) 0%, transparent 50%),
             radial-gradient(ellipse at 50% 50%, rgba(236, 72, 153, 0.1) 0%, transparent 50%)`,
            `radial-gradient(ellipse at 30% 30%, rgba(99, 102, 241, 0.18) 0%, transparent 50%),
             radial-gradient(ellipse at 70% 70%, rgba(168, 85, 247, 0.12) 0%, transparent 50%),
             radial-gradient(ellipse at 40% 60%, rgba(236, 72, 153, 0.12) 0%, transparent 50%)`,
            `radial-gradient(ellipse at 25% 25%, rgba(99, 102, 241, 0.12) 0%, transparent 50%),
             radial-gradient(ellipse at 75% 85%, rgba(168, 85, 247, 0.18) 0%, transparent 50%),
             radial-gradient(ellipse at 55% 45%, rgba(236, 72, 153, 0.08) 0%, transparent 50%)`,
          ]
        }}
        transition={{
          duration: 15,
          repeat: Infinity,
          repeatType: 'reverse',
          ease: 'easeInOut'
        }}
      />

      {/* Floating orbs */}
      <motion.div
        className="absolute w-[600px] h-[600px] rounded-full bg-indigo-500/10 blur-[100px]"
        style={{ top: '10%', left: '10%' }}
        animate={{
          x: [0, 50, 0],
          y: [0, 30, 0],
        }}
        transition={{
          duration: 20,
          repeat: Infinity,
          ease: 'easeInOut'
        }}
      />

      <motion.div
        className="absolute w-[500px] h-[500px] rounded-full bg-purple-500/10 blur-[100px]"
        style={{ bottom: '10%', right: '10%' }}
        animate={{
          x: [0, -40, 0],
          y: [0, -30, 0],
        }}
        transition={{
          duration: 18,
          repeat: Infinity,
          ease: 'easeInOut'
        }}
      />

      <motion.div
        className="absolute w-[400px] h-[400px] rounded-full bg-pink-500/10 blur-[100px]"
        style={{ top: '50%', left: '50%', transform: 'translate(-50%, -50%)' }}
        animate={{
          scale: [1, 1.1, 1],
          opacity: [0.3, 0.5, 0.3],
        }}
        transition={{
          duration: 12,
          repeat: Infinity,
          ease: 'easeInOut'
        }}
      />

      {/* Subtle noise texture */}
      <div
        className="absolute inset-0 opacity-[0.015]"
        style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E")`
        }}
      />
    </div>
  )
}
