# nvim-go

requires at least Neovim 0.6.0.

## Features

* :GoAddTag
* :GoBuild
* :GoFillStruct
* :GoIferr
* :GoImports
* :GoInstall
* :GoLint
* :GoModTidy
* :GoRemoveTag
* :GoRun
* :GoTest
* :GoTestFunc


## Install

### packer.nvim

```lua
require('nvim-go').setup({})
autocmd('nvim-go', {
  'FileType go nmap <leader>b <cmd>GoBuild<cr>',
  'FileType go nmap <leader>r <cmd>GoRun<cr>',
  'FileType go nmap <leader><tab> <cmd>GoIferr<cr>',
}, true)
```

