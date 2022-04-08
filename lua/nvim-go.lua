local utils = require('nvim-go.utils')

local M = {}

M.goimports = function(wait_ms)
  utils.codeaction(nil, "source.organizeImports", wait_ms)
end

M.gofillstruct = function(wait_ms)
  utils.codeaction("fill_struct", "refactor.rewrite", wait_ms)
end

-- TODO
M.gofix = function(wait_ms)
end

M.golint = function()
  local cmd = 'golangci-lint run ' .. vim.fn.expand('%:p:h')
  local callback = function(exitcode, lines)
    vim.fn.setqflist({}, ' ', {
      title = cmd,
      lines = lines,
      efm = vim.api.nvim_buf_get_option(0, "errorformat")
    })
    if exitcode ~= 0 then
      vim.cmd('copen')
      vim.api.nvim_echo({{'[LINT] FAILED', 'ErrorMsg'}}, false, {})
    else
      vim.api.nvim_echo({{'[LINT] SUCCESS', 'Function'}}, false, {})
    end
  end
  vim.fn.feedkeys(':', 'nx')
  utils.asynccmd(cmd, callback)
end

M.gobuild = function()
  local cmd = 'go build ' .. vim.fn.expand('%:p:h')
  local callback = function(exitcode, lines)
    vim.fn.setqflist({}, ' ', {
      title = cmd,
      lines = lines,
      efm = vim.api.nvim_buf_get_option(0, "errorformat")
    })
    if exitcode ~= 0 then
      vim.cmd('copen')
      vim.api.nvim_echo({{'[BUILD] FAILED', 'ErrorMsg'}}, false, {})
    else
      vim.api.nvim_echo({{'[BUILD] SUCCESS', 'Function'}}, false, {})
    end
  end
  vim.fn.feedkeys(':', 'nx')
  utils.asynccmd(cmd, callback)
end

M.gorun = function()
  local origin_dir = vim.fn.chdir(vim.fn.expand('%:p:h'))
  vim.cmd('vs term://go run .|startinsert')
  vim.fn.chdir(origin_dir)
end

M.gotest = function()
  local origin_dir = vim.fn.chdir(vim.fn.expand('%:p:h'))
  vim.cmd('vs term://go test -v -coverprofile ' .. os.tmpname() .. ' .|startinsert')
  vim.fn.chdir(origin_dir)
end

M.gotestfunc = function()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return
  end

  local expr = current_node
  while expr do
    if expr:type() == 'function_declaration' then
      break
    end
    expr = expr:parent()
  end
  if not expr then
    return
  end

  local fn_name = (ts_utils.get_node_text(expr:child(1)))[1]
  if fn_name:find("Test") == 1 then
    local origin_dir = vim.fn.chdir(vim.fn.expand('%:p:h'))
    vim.cmd('vs term://go test -v -coverprofile ' .. os.tmpname() .. ' -run ^' .. fn_name .. " .|startinsert")
    vim.fn.chdir(origin_dir)
  end
end

--TODO
M.gocov = function()
  M.gotest()
end

M.goiferr = function()
  local bpos = vim.fn.wordcount()['cursor_bytes']
  local out = vim.fn.systemlist('iferr -pos ' .. bpos, vim.fn.bufnr('%'))
  if #out == 1 then
    return
  end
  local pos = vim.fn.getcurpos()
  vim.fn.append(pos[2], out)
  vim.lsp.buf.formatting()
  vim.fn.setpos('.', pos)
  vim.cmd('silent normal! 4j')
end

M.gotag = function(s, e, a, ...)
  local file = '-file ' .. vim.fn.fnamemodify(vim.fn.expand("%"), ':p:gs?\\?/?')
  local line = '-line ' .. s .. ',' .. e
  local action = '-' .. a .. '-tags ' .. (next({...}) and select(1, ...) or 'json')
  local command = 'gomodifytags ' .. file .. ' ' .. line .. ' ' .. action
  local handle = io.popen(command)
  local i = 1
  for c in handle:lines() do
    if i >= s and i <= e then
      vim.fn.setline(i, c)
    end
    i = i + 1
  end
  handle:close()
end

M.goinstall = function()
  local tools = {
    'golang.org/x/tools/gopls@latest',
    'github.com/fatih/gomodifytags@latest',
    'github.com/koron/iferr@latest',
    'github.com/golangci/golangci-lint@latest',
  }

  for _, v in pairs(tools) do
    local cmd = 'go install ' .. v
    local callback = function(exitcode, _)
      if exitcode ~= 0 then
        vim.api.nvim_echo({{'[INSTALL] '..v..' FAILED', 'ErrorMsg'}}, true, {})
      else
        vim.api.nvim_echo({{'[INSTALL] '..v..' SUCCESS', 'Function'}}, true, {})
      end
    end
    utils.asynccmd(cmd, callback)
    -- vim.fn.jobwait({utils.asynccmd(cmd, callback)})
  end
end

M.gomodtidy = function()
  local cmd = 'go mod tidy'
  local callback = function(exitcode, _)
    if exitcode ~= 0 then
      vim.cmd('LspRestart')
      vim.api.nvim_echo({{'[MODTIDY] FAILED', 'ErrorMsg'}}, false, {})
    else
      vim.api.nvim_echo({{'[MODTIDY] SUCCESS', 'Function'}}, false, {})
    end
  end
  vim.fn.feedkeys(':', 'nx')
  utils.asynccmd(cmd, callback)
end

M.gonewfile = function()
  local handle = io.popen("go list -f '{{.Name}}' " .. vim.fn.expand("%:p:h"))
  local name = handle:read('*line')
  if handle:close() == true then
    vim.fn.append(0, "package "..name)
  end
end

M.setup = function(_)
  vim.cmd([[command! -nargs=0 -range GoInstall call luaeval('require("nvim-go").goinstall(unpack(_A))', [<f-args>])]])
  vim.api.nvim_create_autocmd({'BufWritePre'}, {pattern={'*.go'}, callback=M.goimports})
  vim.api.nvim_create_autocmd({'BufNewFile'}, {pattern={'*.go'}, callback=M.gonewfile})
end

return M
