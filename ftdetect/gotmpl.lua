vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
})

vim.api.nvim_create_autocmd(
  {
    "BufNewFile",
    "BufRead",
  },
  {
    pattern = {'*.yaml','*.yml','*.json','*.tpl'},
    callback = function()
      if vim.fn.search("{{.\\+}}", "nw") ~= 0 then
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_option(buf, "filetype", "gotmpl")
      end
    end
  }
)
