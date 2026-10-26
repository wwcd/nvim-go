local M = {}

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
