local M = {}

M.codeaction = function(action, only, wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {only}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit and not vim.tbl_isempty(r.edit) then
        vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
      else
        if r.command and not vim.tbl_isempty(r.command) then
          for _, arg in pairs(r.command.arguments) do
            if action == nil or arg["Fix"] == action then
              vim.lsp.buf.execute_command(r.command)
              return
            end
          end
        end
      end
    end
  end
  vim.lsp.buf.format({async = true})
end

M.asynccmd = function(cmd, callback)
  local lines = {}
  local onevent = function(_, d, e)
    if e == "exit" then
      callback(d, lines)
    else
      vim.list_extend(lines, d)
    end
  end
  return vim.fn.jobstart(cmd, {
    stdin = 'null',
    on_stdout = onevent,
    on_stderr = onevent,
    on_exit = onevent,
  })
end

return M
