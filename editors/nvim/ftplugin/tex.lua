local academic = require("academic")

vim.api.nvim_buf_create_user_command(0, "Doi2Bib", function(args)
  academic.doi2bib(args.args)
end, { nargs = "?", desc = "Fetch BibTeX entry from DOI via doi2bib" })

vim.api.nvim_buf_create_user_command(0, "BibCite", academic.bib_cite, {
  desc = "Insert citation from project .bib files",
})

vim.api.nvim_buf_create_user_command(0, "TexWordCount", academic.tex_word_count, {
  desc = "Count words in current LaTeX document",
})

vim.keymap.set("n", "<LocalLeader>d", "<Cmd>Doi2Bib<CR>", { buffer = 0, desc = "Fetch DOI to BibTeX" })
vim.keymap.set("n", "<LocalLeader>c", "<Cmd>BibCite<CR>", { buffer = 0, desc = "Insert BibTeX citation" })
vim.keymap.set("n", "<LocalLeader>w", "<Cmd>TexWordCount<CR>", { buffer = 0, desc = "Count LaTeX words" })
