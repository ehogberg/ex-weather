// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  mode: 'jit',
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    fontFamily: {
      sans: ['Nunito','ui-sans-serif', 'system-ui']
    },
    extend: {
      keyframes: {
        wiggle: {
          '0%, 100%': {transform: 'rotate(-3deg)'},
          '50%': {transform: 'rotate(3deg)'}
        }
      },
      animation: {
        wiggle: 'wiggle 2s ease-in-out infinite'
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ],
  variants: {
    extend: {
      animation: ['group-hover']
    }
  }
}
