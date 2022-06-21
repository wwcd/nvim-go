if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

setlocal formatoptions-=t

setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s

setlocal noexpandtab

command! -nargs=? -range GoAddTag call luaeval('require("nvim-go").gotag(unpack(_A))', [<line1>, <line2>, 'add', <f-args>])
command! -nargs=? -range GoRemoveTag call luaeval('require("nvim-go").gotag(unpack(_A))', [<line1>, <line2>, 'remove', <f-args>])
command! -nargs=0 -range GoModTidy call luaeval('require("nvim-go").gomodtidy(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoFillStruct call luaeval('require("nvim-go").gofillstruct(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoFix call luaeval('require("nvim-go").gofix(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoTest call luaeval('require("nvim-go").gotest(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoTestFunc call luaeval('require("nvim-go").gotestfunc(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoCov call luaeval('require("nvim-go").gocov(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoLint call luaeval('require("nvim-go").golint(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoBuild call luaeval('require("nvim-go").gobuild(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoIferr call luaeval('require("nvim-go").goiferr(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoRun call luaeval('require("nvim-go").gorun(unpack(_A))', [<f-args>])
command! -nargs=0 -range GoImports call luaeval('require("nvim-go").goimports(unpack(_A))', [<f-args>])

" compiler go

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save
