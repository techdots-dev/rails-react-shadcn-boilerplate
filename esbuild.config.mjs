import fs from 'fs/promises'
import path from 'path'
import esbuild from 'esbuild'
import postcss from 'postcss'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

const watch = process.argv.includes('--watch')

const entryPoints = {
  application: path.resolve('app/assets/javascript/entrypoints/application.jsx'),
}

const loaders = {
  '.png': 'file',
  '.svg': 'file',
  '.jpg': 'file',
  '.jpeg': 'file',
  '.gif': 'file',
  '.webp': 'file',
  '.woff': 'file',
  '.woff2': 'file',
  '.ttf': 'file',
  '.eot': 'file',
}

const postCssPlugin = {
  name: 'postcss-tailwind',
  setup(build) {
    const processor = postcss([tailwindcss, autoprefixer])

    build.onLoad({ filter: /\.css$/ }, async (args) => {
      const source = await fs.readFile(args.path, 'utf8')
      const result = await processor.process(source, { from: args.path })

      return {
        contents: result.css,
        loader: 'css',
        resolveDir: path.dirname(args.path),
        warnings: result.warnings().map((warning) => ({
          text: warning.text,
          location: warning.node?.source && {
            file: warning.node.source.input.file,
            line: warning.node.source.start.line,
            column: warning.node.source.start.column,
          },
        })),
      }
    })
  },
}

const buildOptions = {
  entryPoints,
  bundle: true,
  splitting: true,
  format: 'esm',
  sourcemap: true,
  outdir: path.resolve('app/assets/builds'),
  entryNames: '[name]',
  chunkNames: 'chunks/[name]-[hash]',
  assetNames: 'assets/[name]-[hash]',
  publicPath: '/assets',
  logLevel: 'info',
  loader: loaders,
  plugins: [postCssPlugin],
  metafile: true,
}

async function run() {
  const ctx = await esbuild.context(buildOptions)

  if (watch) {
    await ctx.watch()
    console.log('esbuild is watching for changes...')
    await new Promise(() => {})
  } else {
    await ctx.rebuild()
    await ctx.dispose()
  }
}

run().catch((error) => {
  console.error(error)
  process.exit(1)
})
