function gac --description 'Run Git/gac.bash from the random-scripts repo'
    # This file is linked into ~/.config/fish/functions, so resolve the link to
    # find the repo wherever it was cloned.
    set -l here (dirname (realpath (status filename)))
    bash $here/../../../Git/gac.bash $argv
end
