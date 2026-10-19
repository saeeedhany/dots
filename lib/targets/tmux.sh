#!/usr/bin/env bash
# tmux bar flat on the theme bg; tmux.conf sources ~/.cache/theme/tmux.conf
# shellcheck disable=SC2154 # theme variables are set by theme_load

render_tmux() {
  cat > "$HOME/.cache/theme/tmux.conf" <<TMUX
set -g status-style "bg=$bg,fg=$fg1"
set -g window-status-format " #[fg=$fg2]#I:#W "
set -g window-status-current-format " #[fg=$fg,bold]#I:#W#[nobold] "
setw -g window-status-activity-style "bg=$bg,fg=$accent"
setw -g window-status-bell-style "bg=$bg,fg=$red"
set -g status-left " #[fg=$accent,bold]󰖲 #S#[nobold] #[fg=$fg1]󰅂 #(whoami) "
set -g status-right "#[fg=$fg2]󰃭 %a %d/%m  󰥔 %H:%M  #[fg=$fg1]󰌽 #h "
set -g pane-border-style "fg=$line"
set -g pane-active-border-style "fg=$fg1"
set -g message-style "bg=$bg1,fg=$fg"
set -g message-command-style "bg=$bg1,fg=$fg"
set -g mode-style "bg=$bg3,fg=$fg"
set -g clock-mode-colour "$fg"
set -g display-panes-active-colour "$fg"
set -g display-panes-colour "$line"
TMUX
}

reload_tmux() {
  tmux info >/dev/null 2>&1 || return 0
  tmux source-file "$HOME/.cache/theme/tmux.conf"
}
