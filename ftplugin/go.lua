local go = require('nvim-go')

vim.bo.comments=[[s1:/*,mb:*,ex:*/,://]]
vim.bo.commentstring=[[// %s]]
vim.bo.expandtab = false

vim.api.nvim_buf_create_user_command(0, "GoAddTag", function(a) go.tag(a.line1, a.line2, "add", a.args) end, {nargs='?', range=true})
vim.api.nvim_buf_create_user_command(0, "GoRemoveTag", function(a) go.tag(a.line1, a.line2, "remove", a.args) end, {nargs='?', range=true})
vim.api.nvim_buf_create_user_command(0, "GoModTidy", go.modtidy, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoFillStruct", go.fillstruct, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoFix", go.fix, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoTest", go.test, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoTestFunc", go.testfunc, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoCov", go.cov, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoLint", go.lint, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoIferr", go.iferr, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoImports", go.imports, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoBuild", go.build, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoRun", go.run, {nargs=0})
vim.api.nvim_buf_create_user_command(0, "GoImpl", function(a) go.impl(unpack(a.fargs)) end, {nargs="*"})
