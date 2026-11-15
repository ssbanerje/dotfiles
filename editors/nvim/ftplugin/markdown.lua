local academic = require("academic")

vim.api.nvim_buf_create_user_command(0, "BibCite", academic.bib_cite, {
  desc = "Insert [@citekey] from project .bib files",
})

vim.keymap.set("n", "<LocalLeader>c", "<Cmd>BibCite<CR>", { buffer = 0, desc = "Insert BibTeX citation" })
