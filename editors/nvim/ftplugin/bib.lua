local academic = require("academic")

vim.api.nvim_buf_create_user_command(0, "Doi2Bib", function(args)
  academic.doi2bib(args.args)
end, { nargs = "?", desc = "Fetch and insert BibTeX entry from DOI" })

vim.api.nvim_buf_create_user_command(0, "BibCite", academic.bib_cite, {
  desc = "Jump to BibTeX entry across project .bib files",
})

vim.keymap.set("n", "<LocalLeader>d", "<Cmd>Doi2Bib<CR>", { buffer = 0, desc = "Insert BibTeX from DOI" })
vim.keymap.set("n", "<LocalLeader>c", "<Cmd>BibCite<CR>", { buffer = 0, desc = "Find BibTeX entry" })
