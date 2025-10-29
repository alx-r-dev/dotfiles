# ───────────────────────────────────────────────────────────

# 2) Homebrew env (Apple Silicon)
#    —————————————————————————————————————————————————
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3) Python versions
#    —————————————————————————————————————————————————
export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:/Library/Frameworks/Python.framework/Versions/3.8/bin:$PATH"

# 4) Postgres (Homebrew)
#    —————————————————————————————————————————————————
export PATH="/opt/homebrew/opt/postgresql@13/bin:$PATH"

# 5) pyenv
#    —————————————————————————————————————————————————
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# 6) Your personal bins
#    —————————————————————————————————————————————————
export PATH="$HOME/.console-ninja/.bin:$PATH"

# 7) Oh My Zsh bootstrap
#    —————————————————————————————————————————————————
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# 8) (Optional) Powerlevel10k, Z‑autocomplete, syntax highlighting
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# ───────────────────────────────────────────────────────────

PATH=~/.console-ninja/.bin:$PATH

# custom sociallydetermined script to get aws key value pairs

get_sd_keys() {
  # build the output and copy it at the same time
  {
    for key in aws_access_key_id aws_secret_access_key aws_session_token; do
      # uppercase the key name
      label=$(printf "%s" "$key" | tr '[:lower:]' '[:upper:]')
      printf "%-20s %s\n" "${label}=""$(aws configure get "$key")"
    done
  } | tee >(pbcopy)
}

# Update Ghostty/macOS tab and window titles
precmd() {
  # Tab title → last folder (project name)
  print -Pn '\e]1;%1~\a'

  # Window title → full path
  print -Pn '\e]2;%~\a'
}



# Created by `pipx` on 2025-09-02 21:01:04
export PATH="$PATH:/Users/Work/.local/bin"

# Launch Yabai if not already running
if ! pgrep -q yabai; then
    yabai --start-service
fi

# Launch skhd if not already running
if ! pgrep -q skhd; then
    skhd --start-service
fi

