nnoremap <leader>rp :RainbowParenthesesToggle<CR>
augroup VIMRC_RAINBOW
  au!
  au Syntax * RainbowParenthesesToggle
  au Syntax * RainbowParenthesesLoadRound
  au Syntax * RainbowParenthesesLoadSquare
  au Syntax * RainbowParenthesesLoadBraces
  au Syntax * RainbowParenthesesLoadChevrons
augroup END
