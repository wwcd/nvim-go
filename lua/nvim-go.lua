local utils = require('nvim-go.utils')

local M = {
  transform = 'camelcase'
}

M.imports = function()
  utils.codeaction(nil, 'source.organizeImports', 3000)
  -- vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
end

M.fillstruct = function()
  utils.codeaction('fill_struct', 'refactor.rewrite', 3000)
end

-- TODO
M.fix = function()
end

M.lint = function()
  local cmd = 'golangci-lint run ' .. vim.fn.expand('%:p:h')
  local callback = function(exitcode, lines)
    vim.fn.setqflist({}, ' ', {
      title = cmd,
      lines = lines,
      efm = [[%-G# %.%#,%A%f:%l:%c: %m,%A%f:%l: %m,%C%*\s%m,%-G%.%#]]
    })
    if exitcode ~= 0 then
      vim.cmd('copen')
      vim.api.nvim_echo({ { '[LINT] FAILED', 'ErrorMsg' } }, false, {})
    else
      vim.api.nvim_echo({ { '[LINT] SUCCESS', 'Function' } }, false, {})
    end
  end
  vim.fn.feedkeys(':', 'nx')
  utils.asynccmd(cmd, callback)
end

M.build = function()
  local cmd = 'go build ' .. vim.fn.expand('%:p:h')
  local callback = function(exitcode, lines)
    vim.fn.setqflist({}, ' ', {
      title = cmd,
      lines = lines,
      efm = [[%-G# %.%#,%A%f:%l:%c: %m,%A%f:%l: %m,%C%*\s%m,%-G%.%#]]
    })
    if exitcode ~= 0 then
      vim.cmd('copen')
      vim.api.nvim_echo({ { '[BUILD] FAILED', 'ErrorMsg' } }, false, {})
    else
      vim.api.nvim_echo({ { '[BUILD] SUCCESS', 'Function' } }, false, {})
    end
  end
  vim.fn.feedkeys(':', 'nx')
  utils.asynccmd(cmd, callback)
end

M.run = function()
  local origin_dir = vim.fn.chdir(vim.fn.expand('%:p:h'))
  vim.cmd('vs term://go run .')
  vim.fn.chdir(origin_dir)
end

M.test = function()
  local origin_dir = vim.fn.chdir(vim.fn.expand('%:p:h'))
  vim.cmd('vs term://go test -v -coverprofile ' .. vim.fn.tempname() .. ' .')
  vim.fn.chdir(origin_dir)
end

M.testfunc = function()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return
  end

  local expr = current_node
  while expr do
    if expr:type() == 'function_declaration' or expr:type() == 'method_declaration' then
      break
    end
    expr = expr:parent()
  end
  if not expr then
    return
  end

  if expr:type() == 'function_declaration' then
    local name = vim.treesitter.get_node_text(expr:child(1), 0)
    if name:find("Test") == 1 then
      local origin_dir = vim.fn.chdir(vim.fn.expand('%:p:h'))
      vim.cmd('vs term://go test -v -coverprofile ' .. vim.fn.tempname() .. ' -run ^' .. name .. '$ .')
      vim.fn.chdir(origin_dir)
    end
    return
  end

  if expr:type() == 'method_declaration' then
    local name = vim.treesitter.query.get_node_text(expr:child(2), 0)
    if name:find("Test") == 1 then
      local origin_dir = vim.fn.chdir(vim.fn.expand('%:p:h'))
      vim.cmd('vs term://go test -v -coverprofile ' .. vim.fn.tempname() .. ' -run . -testify.m ^' .. name .. '$')
      vim.fn.chdir(origin_dir)
    end
    return
  end
end

--TODO
M.cov = function()
  local tmpfile = vim.fn.tempname()
  local cmd = 'go test -v -coverprofile ' .. tmpfile .. ' ' .. vim.fn.fnamemodify('%', ':p:h')
  local callback = function(exitcode, _)
    if exitcode ~= 0 then
      vim.api.nvim_echo({ { '[COV] FAILED', 'ErrorMsg' } }, false, {})
      return
    end

    local matches = {}
    for l in io.lines(tmpfile) do
      local m = vim.fn.matchlist(l, [[\v([^:]+):(\d+)\.(\d+),(\d+)\.(\d+) (\d+) (\d+)]])
      if vim.tbl_isempty(m) then
        goto continue
      end
      local cov = {
        file = m[2],
        start_line = m[3],
        start_colume = m[4],
        end_line = m[5],
        end_colume = m[6],
        iscovered = m[8],
      }
      table.insert(matches, cov)
      ::continue::
    end
  end
  utils.asynccmd(cmd, callback)
end

M.iferr = function()
  local bpos = vim.fn.wordcount()['cursor_bytes']
  local out = vim.fn.systemlist('iferr -pos ' .. bpos, vim.fn.bufnr('%'))
  if #out == 1 then
    return
  end
  local pos = vim.fn.getcurpos()
  vim.fn.append(pos[2], out)
  vim.lsp.buf.format({ async = true })
  vim.fn.setpos('.', pos)
  vim.cmd('silent normal! 4j')
end

M.tag = function(s, e, a, t)
  local file = '-file ' .. vim.fn.fnamemodify(vim.fn.expand("%"), ':p:gs?\\?/?')
  local line = '-line ' .. s .. ',' .. e
  local action = '-' .. a .. '-tags ' .. (t ~= "" and t or 'json')
  local command = 'gomodifytags ' .. file .. ' ' .. line .. ' ' .. action .. ' -transform ' .. M.transform
  local handle = io.popen(command)
  if handle == nil then
    return
  end
  local i = 1
  for v in handle:lines() do
    if i >= s and i <= e then
      vim.fn.setline(i, v)
    end
    i = i + 1
  end
  handle:close()
end

M.impl = function(...)
  local args = { ... }
  if vim.tbl_count(args) ~= 3 then
    vim.api.nvim_echo({ { 'USAGE: GoImpl RECIEVER TYPE INTERFACE', 'ErrorMsg' } }, false, {})
    return
  end

  local command = 'impl "' .. args[1] .. ' ' .. args[2] .. '" ' .. args[3]
  local handle = io.popen(command)
  if handle == nil then
    return
  end
  local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = {}
  local i = 0
  for v in handle:lines() do
    i = i + 1
    buf[i] = v
  end
  vim.api.nvim_buf_set_lines(0, r, r, true, buf)
  handle:close()
end


M.install = function()
  local tools = {
    'golang.org/x/tools/gopls@latest',
    'github.com/fatih/gomodifytags@latest',
    'github.com/koron/iferr@latest',
    'github.com/golangci/golangci-lint/cmd/golangci-lint@latest',
    'github.com/josharian/impl@latest',
    'mvdan.cc/gofumpt@latest',
  }

  for _, v in pairs(tools) do
    local cmd = 'CGO_ENABLED=0 go install ' .. v
    local callback = function(exitcode, _)
      if exitcode ~= 0 then
        vim.api.nvim_echo({ { '[INSTALL] ' .. v .. ' FAILED', 'ErrorMsg' } }, true, {})
      else
        vim.api.nvim_echo({ { '[INSTALL] ' .. v .. ' SUCCESS', 'Function' } }, true, {})
      end
    end
    utils.asynccmd(cmd, callback)
    -- vim.fn.jobwait({utils.asynccmd(cmd, callback)})
  end
end

M.modtidy = function()
  local cmd = 'go mod tidy'
  local callback = function(exitcode, _)
    if exitcode ~= 0 then
      vim.api.nvim_echo({ { '[MODTIDY] FAILED', 'ErrorMsg' } }, false, {})
    else
      vim.cmd('LspRestart')
      vim.api.nvim_echo({ { '[MODTIDY] SUCCESS', 'Function' } }, false, {})
    end
  end
  vim.fn.feedkeys(':', 'nx')
  utils.asynccmd(cmd, callback)
end

M.newfile = function()
  local handle = io.popen("go list -f '{{.Name}}' " .. vim.fn.expand("%:p:h"))
  if handle == nil then
    return
  end
  local name = handle:read('*line')
  if name ~= nil then
    vim.fn.append(0, "package " .. name)
  else
    vim.fn.append(0, "package main")
  end
  handle:close()
end

M.setup = function(_)
  vim.api.nvim_create_user_command("GoInstall", M.install, { nargs = 0 })
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, { pattern = { '*.go' }, callback = M.imports })
  vim.api.nvim_create_autocmd({ 'BufNewFile' }, { pattern = { '*.go' }, callback = M.newfile })
end

return M
