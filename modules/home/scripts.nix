{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeShellScriptBin "toggle-mic" ''
      ${wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      if ${wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
          ${libnotify}/bin/notify-send "Microphone" "DISABLED"
      else
          ${libnotify}/bin/notify-send "Microphone" "ENABLED"
      fi
    '')

    (writeShellScriptBin "wallpicker" ''
      WALL_DIR="$HOME/nixconfig/Wallpapers"
      TMP_FILE="/tmp/wall_picker_target"
      CACHE_FILE="$HOME/.cache/current_wallpaper"

      ${kitty}/bin/kitty --class "wall-picker" -e ${yazi}/bin/yazi "$WALL_DIR" --chooser-file="$TMP_FILE"

      if [ -s "$TMP_FILE" ]; then
          SELECTED=$(cat "$TMP_FILE")
          echo "$SELECTED" > "$CACHE_FILE"

          ${psmisc}/bin/killall swaybg 2>/dev/null || true
          ${swaybg}/bin/swaybg -i "$SELECTED" -m fill &

          rm "$TMP_FILE"
      fi
    '')
  ];
}
