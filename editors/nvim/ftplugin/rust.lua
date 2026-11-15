local function cargo_root()
  return vim.fs.root(0, { "Cargo.toml", ".git" }) or vim.fn.getcwd()
end

vim.api.nvim_buf_create_user_command(0, "RustDoc", function(args)
  local crate = vim.trim(args.args)
  if crate == "" then
    crate = vim.fn.expand("<cword>")
  end
  if crate == "" then
    return
  end
  vim.ui.open(("https://docs.rs/%s"):format(crate))
end, { nargs = "?", desc = "Open docs.rs documentation for crate" })

vim.api.nvim_buf_create_user_command(0, "CargoExpand", function()
  if vim.fn.executable("cargo") ~= 1 then
    require("astrocore").notify("cargo executable not found on PATH", vim.log.levels.ERROR)
    return
  end
  local cwd = cargo_root()
  vim.system(
    { "cargo", "expand" },
    { cwd = cwd, text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        require("astrocore").notify(
          ("cargo expand failed:\n%s"):format(vim.trim(res.stderr or res.stdout or "")),
          vim.log.levels.ERROR
        )
        return
      end
      vim.cmd("botright vnew")
      local buf = vim.api.nvim_get_current_buf()
      vim.bo[buf].buftype = "nofile"
      vim.bo[buf].bufhidden = "wipe"
      vim.bo[buf].swapfile = false
      vim.bo[buf].filetype = "rust"
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(res.stdout or "", "\n", { plain = true }))
      vim.bo[buf].modifiable = false
    end)
  )
end, { desc = "Expand Rust macros into a scratch split via cargo-expand" })

vim.keymap.set("n", "<LocalLeader>d", "<Cmd>RustDoc<CR>", { buffer = 0, desc = "Open crate on docs.rs" })
vim.keymap.set("n", "<LocalLeader>e", "<Cmd>CargoExpand<CR>", { buffer = 0, desc = "Cargo expand macros" })
