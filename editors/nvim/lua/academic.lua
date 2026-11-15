local M = {}

local function project_root(buf)
  return vim.fs.root(buf or 0, { ".latexmkrc", "latexmkrc", ".git" }) or vim.fn.getcwd()
end

local function resolve_doi2bib()
  if vim.fn.executable("doi2bib") == 1 then
    return vim.fn.exepath("doi2bib")
  end
  for _, candidate in ipairs({
    vim.fn.expand("~/.local/bin/doi2bib"),
    vim.fn.expand("~/.dotfiles/bin/doi2bib"),
  }) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

local function find_bib_files(root)
  return vim.fs.find(function(name, path)
    if path:find("/%.git/") or path:find("/build/") then
      return false
    end
    return name:match("%.bib$") ~= nil
  end, { path = root, type = "file", limit = 25 })
end

local function parse_bib_file(filepath)
  local entries = {}
  local ok, lines = pcall(vim.fn.readfile, filepath)
  if not ok or not lines then
    return entries
  end

  local current = nil
  for lnum, line in ipairs(lines) do
    local entry_type, key = line:match("^%s*@(%w+)%s*[{(]%s*([^,%s]+)%s*,")
    if
      entry_type
      and key
      and entry_type:lower() ~= "comment"
      and entry_type:lower() ~= "preamble"
      and entry_type:lower() ~= "string"
    then
      if current then
        table.insert(entries, current)
      end
      current = {
        key = key,
        type = entry_type:lower(),
        file = filepath,
        lnum = lnum,
        title = "",
        author = "",
        year = "",
      }
    elseif current then
      local field, val = line:match("^%s*(%w+)%s*=%s*[{\"'%s]*(.-)[}\"'%s,]*$")
      if field and val then
        local f = field:lower()
        if f == "title" and current.title == "" then
          current.title = val:gsub("[{}]", "")
        elseif f == "author" and current.author == "" then
          current.author = val:gsub("[{}]", "")
        elseif f == "year" and current.year == "" then
          current.year = val:match("%d%d%d%d") or val
        end
      end
    end
  end
  if current then
    table.insert(entries, current)
  end
  return entries
end

function M.doi2bib(raw_doi)
  local bin = resolve_doi2bib()
  if not bin then
    require("astrocore").notify("doi2bib executable not found on PATH", vim.log.levels.ERROR)
    return
  end

  local function run(input)
    if not input or vim.trim(input) == "" then
      return
    end
    local doi = vim.trim(input):gsub("^https?://[^/]*doi%.org/", "")
    local buf = vim.api.nvim_get_current_buf()
    local ft = vim.bo[buf].filetype
    local root = project_root(buf)

    vim.system(
      { bin, doi },
      { text = true },
      vim.schedule_wrap(function(res)
        if res.code ~= 0 or vim.trim(res.stdout or "") == "" then
          require("astrocore").notify(
            ("doi2bib failed for %s:\n%s"):format(doi, vim.trim(res.stderr or res.stdout or "unknown error")),
            vim.log.levels.ERROR
          )
          return
        end

        local bib = vim.trim(res.stdout)
        local key = bib:match("@%w+%s*[{(]%s*([^,%s]+)") or doi

        if ft == "bib" and vim.api.nvim_buf_is_valid(buf) then
          local row = vim.api.nvim_win_get_cursor(0)[1]
          local out_lines = vim.split("\n" .. bib, "\n", { plain = true })
          vim.api.nvim_buf_set_lines(buf, row, row, false, out_lines)
          require("astrocore").notify(("Inserted BibTeX entry `%s`"):format(key))
          return
        end

        local bib_files = find_bib_files(root)
        if #bib_files == 1 then
          local target = bib_files[1]
          local out_lines = vim.split("\n" .. bib .. "\n", "\n", { plain = true })
          vim.fn.writefile(out_lines, target, "a")
          vim.fn.setreg("+", key)
          require("astrocore").notify(
            ("Appended `%s` to %s (citekey copied to clipboard)"):format(key, vim.fn.fnamemodify(target, ":."))
          )
        else
          vim.fn.setreg("+", bib)
          require("astrocore").notify(("Copied BibTeX entry `%s` to clipboard"):format(key))
        end
      end)
    )
  end

  if raw_doi and vim.trim(raw_doi) ~= "" then
    run(raw_doi)
  else
    vim.ui.input({ prompt = "DOI (or doi.org URL): " }, run)
  end
end

function M.bib_cite()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local root = project_root(buf)
  local bib_files = find_bib_files(root)
  if #bib_files == 0 then
    require("astrocore").notify(("No .bib files found under %s"):format(root), vim.log.levels.WARN)
    return
  end

  local items = {}
  for _, file in ipairs(bib_files) do
    for _, entry in ipairs(parse_bib_file(file)) do
      local meta = {}
      if entry.author ~= "" then
        table.insert(meta, entry.author)
      end
      if entry.year ~= "" then
        table.insert(meta, entry.year)
      end
      if entry.title ~= "" then
        table.insert(meta, entry.title)
      end
      items[#items + 1] = {
        text = ("%s  %s"):format(entry.key, table.concat(meta, " - ")),
        key = entry.key,
        file = entry.file,
        pos = { entry.lnum, 0 },
      }
    end
  end

  if #items == 0 then
    require("astrocore").notify("No BibTeX entries found in project .bib files", vim.log.levels.WARN)
    return
  end

  require("snacks").picker.pick({
    title = "BibTeX Citations",
    items = items,
    format = "text",
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      if ft == "bib" then
        vim.cmd.edit(vim.fn.fnameescape(item.file))
        vim.api.nvim_win_set_cursor(0, { item.pos[1], 0 })
        return
      end
      local snippet = ft == "markdown" and ("[@%s]"):format(item.key) or ("\\cite{%s}"):format(item.key)
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if ft == "tex" and line:sub(1, col):match("\\cite%w*{[^}]*$") then
        snippet = item.key
      end
      vim.api.nvim_put({ snippet }, "c", true, true)
    end,
  })
end

function M.tex_word_count()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    require("astrocore").notify("Save buffer before running TexWordCount", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("texcount") == 1 then
    vim.system(
      { "texcount", "-brief", file },
      { text = true },
      vim.schedule_wrap(function(res)
        local msg = vim.trim((res.stdout or "") ~= "" and res.stdout or (res.stderr or ""))
        require("astrocore").notify(msg, res.code == 0 and vim.log.levels.INFO or vim.log.levels.WARN, {
          title = "TeX Word Count",
        })
      end)
    )
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local words = 0
  for _, line in ipairs(lines) do
    local stripped = line:gsub("%%.*$", ""):gsub("\\%a+%b{}", " "):gsub("\\%a+", " ")
    for _ in stripped:gmatch("%S+") do
      words = words + 1
    end
  end
  require("astrocore").notify(("Approx. words (texcount not installed): %d"):format(words), vim.log.levels.INFO, {
    title = "TeX Word Count",
  })
end

return M
