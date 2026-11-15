local has_ui = #vim.api.nvim_list_uis() > 0

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    return require("astrocore").extend_tbl(opts, {
      image = {
        enabled = has_ui,
        doc = {
          enabled = has_ui,
          inline = false,
          float = true,
          max_width = 80,
          max_height = 40,
        },
      },
      picker = {
        sources = {
          gh_issue = {},
          gh_pr = {},
        },
      },
      scroll = {
        enabled = has_ui,
      },
    })
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>."] = {
              function()
                require("snacks").scratch()
              end,
              desc = "Toggle scratch buffer",
            },
            ["<Leader>fS"] = {
              function()
                require("snacks").scratch.select()
              end,
              desc = "Select scratch buffer",
            },
            ["<Leader>gi"] = {
              function()
                require("snacks").picker.gh_issue()
              end,
              desc = "GitHub issues",
            },
            ["<Leader>gP"] = {
              function()
                require("snacks").picker.gh_pr()
              end,
              desc = "GitHub pull requests",
            },
          },
        },
      },
    },
  },
}
