# treesitter-context

A [context.vim](https://github.com/wellle/context.vim) clone using treesitter !

# Installation

Just install it as a regular plugin, it requires `nvim-treesitter` as a dependecy so, using
`packer.nvim` :

```lua
use {
  'vigoux/treesitter-context',
  requires = { 'nvim-treesitter/nvim-treesitter' }
}
```

# Usage

Just run :

```
TSBufEnable context
```
