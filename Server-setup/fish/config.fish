if status is-interactive
    # The login banner below replaces fish's own greeting.
    set -g fish_greeting

    # On ssh logins (not in tmux panes): show the machine banner.
    if status is-login; and set -q SSH_CONNECTION; and not set -q TMUX
        type -q fastfetch; and fastfetch
    end
end

### DOTFILES ALIASES ###

alias ll "ls -lathr"

alias g "git"
alias gst "git status"
alias gss "git status -sb"
alias gl "git pull"
alias glg "git log --stat"
alias glgp "git log --stat -p"
alias glo "git log --oneline --decorate"
alias glog "git log --oneline --decorate --graph"

alias ga "git add"
alias gaa "git add --all"
alias gc "git commit"
alias gcm "git commit -m"
alias gca "git commit --amend"
alias gcan "git commit --amend --no-edit"

alias gp "git push"
alias gpf "git push --force-with-lease"
alias gpoat "git push origin --all && git push origin --tags"
alias gup "git pull --rebase"

alias gb "git branch"
alias gba "git branch -a"
alias gbd "git branch -d"
alias gbD "git branch -D"
alias gco "git checkout"
alias gcb "git checkout -b"
alias gsw "git switch"
alias gswc "git switch -c"

alias gd "git diff"
alias gds "git diff --staged"

alias gsta "git stash push"
alias gstp "git stash pop"
alias gstl "git stash list"
alias gstc "git stash clear"

alias gf "git fetch"
alias gfa "git fetch --all --prune"
alias grh "git reset --hard"
alias grhh "git reset --hard HEAD"

alias gcl "git clone"
alias gclean "git clean -fd"

### END DOTFILES ALIASES ###
