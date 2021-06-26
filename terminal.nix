{pkgs, config, lib, ...}:

let


kitty_zoom = pkgs.writeText "zoom_toggle.py" ''
def main(args):
   pass

def handle_result(args, answer, target_window_id, boss):
   tab = boss.active_tab
   if tab is not None:
      if tab.current_layout.name == 'stack':
         tab.last_used_layout()
      else:
         tab.goto_layout('stack')

handle_result.no_ui = True
'';

# terminal.sexy tartan color scheme
# to create new default layout set your layout
# and press "save" under setttings->Profile->default
terminal_config = pkgs.writeText "config" ''


font_family      monospace
font_size        16.0
bold_font        auto
italic_font      auto
bold_italic_font auto

scrollback_lines 10000
scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
focus_follows_mouse yes

term xterm-256color
mouse_hide_wait 3.0

touch_scroll_multiplier 5.0
touch_scroll_multiplier 4.0

copy_on_select yes
draw_minimal_borders no
repaint_delay 10
input_delay 3
resize_draw_strategy static
sync_to_monitor yes
window_padding_width 0.1
inactive_text_alpha 0.8

active_border_color   #1a1919
inactive_border_color #1a1919

foreground #dedede
background #2b2b2b

color0 #2e3436
color1 #cc0000
color2 #4e9a06
color3 #c4a000
color4 #3465a4
color5 #75507b
color6 #06989a
color7 #d3d7cf
color8 #555753
color9 #ef2929
color10 #8ae234
color11 #fce94f
color12 #729fcf
color13 #ad7fa8
color14 #34e2e2
color15 #eeeeec

enabled_layouts *
enable_audio_bell no

map ctrl+shift+left resize_window narrower
map ctrl+plus change_font_size current + 1.0
map ctrl+minus change_font_size current - 1.0
map ctrl+0 change_font_size current 0
map ctrl+shift+right resize_window wider
map ctrl+shift+up resize_window taller
map ctrl+shift+down resize_window shorter 3
map f11 kitten zoom_toggle.py

map ctrl+down           next_window
map ctrl+up             previous_window
map ctrl+enter          new_window

  '';

in {

  environment.systemPackages = with pkgs; [
    kitty
    xdg_utils # Tool to query system defaults
  ];

  environment.variables = {
    TERM = [ "xterm-256color" ];
  };

  system.activationScripts.copyTermiteConfig = ''
      mkdir -p ${config.mainUserHome}/.config/kitty
      ln -f -s ${terminal_config} ${config.mainUserHome}/.config/kitty/kitty.conf
      cp -f ${kitty_zoom} ${config.mainUserHome}/.config/kitty/zoom_toggle.py
      chown -R ${config.mainUser}: ${config.mainUserHome}/.config/kitty/kitty.conf
  '';
}
