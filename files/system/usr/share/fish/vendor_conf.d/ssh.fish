if test "$TERM" = 'xterm-kitty'
  function ssh --wraps='kitten ssh' --description 'SSH using kitten wrapper when in a kitty terminal'
    kitten ssh $argv
  end
end