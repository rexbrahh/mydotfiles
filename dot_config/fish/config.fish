# ~/.config/fish/config.fish
# PATH & basics
if test -d /opt/homebrew/bin
    fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin
end

if set -q SSH_CONNECTION
    set -gx EDITOR vim
else
    set -gx EDITOR nvim
end

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

set -g fish_greeting
# Prompt (install tide later if you want)
# fisher install IlanCosman/tide@v6

# Load user aliases/abbrs
if test -f ~/.config/fish/conf.d/20-aliases.fish
    source ~/.config/fish/conf.d/20-aliases.fish
end

# ----- PATH / env (use fish_add_path so it dedups & prepends sensibly) -----
# Nix paths
fish_add_path $HOME/.nix-profile/bin /nix/var/nix/profiles/default/bin
set -gx NIX_PATH "$HOME/.nix-defexpr/channels":$NIX_PATH

# Homebrew common paths (brew usually sets these via /etc/paths; harmless to add)
fish_add_path /opt/homebrew/sbin /opt/homebrew/bin
fish_add_path /opt/homebrew/opt/llvm/bin /opt/homebrew/opt/llvm/sbin
fish_add_path $HOME/.cargo/bin $HOME/.local/bin
fish_add_path /opt/homebrew/bin/lua-language-server
# Zig (you had ~/opt/homebrew/bin/Zig — fix path case if needed)
fish_add_path $HOME/opt/homebrew/bin/Zig

# Node (pin to a specific Cellar version as in your zshrc)
fish_add_path /opt/homebrew/Cellar/node/24.6.0/bin

# vcpkg
set -gx VCPKG_ROOT $HOME/vcpkg
fish_add_path $VCPKG_ROOT

# Terminal type
set -gx TERM xterm-256color

# ----- fzf keybindings (fish) -----
# Your zsh did: `source <(fzf --zsh)`. In fish, do:
if type -q fzf
    fzf --fish | source
end


# ----- Docker completions (fish uses $fish_complete_path) -----
# Your zsh added ~/.docker/completions to fpath. In fish:
if test -d $HOME/.docker/completions
    set -U fish_complete_path $HOME/.docker/completions $fish_complete_path
end


# ----- conda initialization -----
# Your zsh had a long “conda init zsh” block. For fish, prefer:
if test -f /Users/rexliu/anaconda3/etc/fish/conf.d/conda.fish
    source /Users/rexliu/anaconda3/etc/fish/conf.d/conda.fish
else if type -q conda
    # Fallback: ask conda where its fish hook is (works for newer conda)
    set -l _conda_root (command conda info --root ^/dev/null)
    if test -n "$_conda_root" -a -f "$_conda_root/etc/fish/conf.d/conda.fish"
        source "$_conda_root/etc/fish/conf.d/conda.fish"
    else
        # Final fallback: prepend conda bin
        fish_add_path /Users/rexliu/anaconda3/bin
    end
end

# ----- zoxide & direnv -----
if type -q zoxide
    zoxide init fish | source
end
if type -q direnv
    direnv hook fish | source
end

starship init fish | source

# ----- alias / functions -----
# alias

# y() function (yazi cwd transfer) — translated to fish
function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if test -f "$tmp"
        set -l cwd (string collect < "$tmp")
        rm -f -- "$tmp"
        if test -n "$cwd" -a "$cwd" != "$PWD"
            cd "$cwd"
        end
    end
end

# ----- Auto-start tmux (like your zsh tail) -----
# In fish, guard on interactive shells and ensure not already in tmux.
if status is-interactive
    if not set -q TMUX
        # Use the Nix-managed fish inside tmux too (set in your tmux.conf as well)
        exec tmux -u new -s init -A -D
    end
end
# mkcd: create and enter a directory
function mkcd; mkdir -p $argv[1]; and cd $argv[1]; end

# extract: quick “tar/zip/rar/7z” extractor
function extract
    set file $argv[1]
    switch $file
        case '*.tar.bz2' 'tar xjf $file'
        case '*.tar.gz'  'tar xzf $file'
        case '*.tar.xz'  'tar xJf $file'
        case '*.bz2'     'bunzip2 $file'
        case '*.rar'     'unrar x $file'
        case '*.gz'      'gunzip $file'
        case '*.tar'     'tar xf $file'
        case '*.tbz2'    'tar xjf $file'
        case '*.tgz'     'tar xzf $file'
        case '*.zip'     'unzip $file'
        case '*.7z'      '7z x $file'
        case '*'         'echo "cannot extract $file"'
    end
end


#bass source ~/.zshrc
