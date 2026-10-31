-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Configure formatoptions: + "c" + "j" + "n" + "q" + "r" + "l" + "v" - "2" - "a" - "o" - "t"
vim.opt.formatoptions:append("cjnqrlv")
vim.opt.formatoptions:remove("2aot")

-- Fix Typos
local abbreviations = {
  W1 = "W!",
  w1 = "w!",
  ["Q!"] = "q!",
  Q1 = "q!",
  q1 = "q!",
  ["Qa!"] = "qa!",
  ["Qall!"] = "qall!",
  Wa = "wa",
  Wq = "wq",
  wQ = "wq",
  WQ = "wq",
  wq1 = "wq!",
  Wq1 = "wq!",
  wQ1 = "wq!",
  WQ1 = "wq!",
  Q = "q",
  Qa = "qa",
  qA = "qa",
  Qall = "qall",
}

for k, v in pairs(abbreviations) do
  vim.cmd(string.format("cnoreabbrev %s %s", k, v))
end
