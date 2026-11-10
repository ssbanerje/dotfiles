-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Fix common Ex-command typos only at command-line position 0
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
  vim.keymap.set("ca", k, function()
    return vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == k and v or k
  end, { expr = true })
end
