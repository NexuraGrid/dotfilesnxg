# Loads fnm only once it has a default Node, so an existing nvm setup keeps working.
if type -q fnm; and fnm list | string match -q '*default*'
    fnm env --use-on-cd --shell fish | source
end
