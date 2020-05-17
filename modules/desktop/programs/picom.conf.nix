{
  # Performance related
  # Use OpenGL
  backend = "glx";

  glx-no-stencil = false;
  glx-copy-from-front =
    false; # When enbled on intel GPU: screen broken until compton is killed.
  glx-swap-method = 1;

  unredir-if-possible = true;

  # === Rules ===
  shadow-exclude = [
    "class_g ?= 'slop'"
    "class_g ?= 'Visualizer'"
    "class_g ?= 'rofi'"
    "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    "window_type *= 'menu'"
    "window_type = 'utility'"
    "window_type = 'dock'"
    "window_type = 'dropdown_menu'"
    "window_type = 'popup_menu'"
  ];

  opacity-rule = [ ];

  focus-exclude = [
    "class_g ?= 'slop'"
    "name = 'rofi'"
    "class_g ?= 'Steam'"
    "_NET_WM_WINDOW_TYPE@:a *= 'MENU'"
    "window_type *= 'menu'"
    "window_type = 'utility'"
    "window_type = 'dropdown_menu'"
    "window_type = 'popup_menu'"
  ];

  fade-exclude = [ ];

  # === Shadows ===
  # Enabled client-side shadows on windows.
  shadow = false;
  # Don't draw shadows on DND windows.
  no-dnd-shadow = true;
  # Avoid drawing shadows on dock/panel windows.
  no-dock-shadow = false;
  # Zero the part of the shadow's mask behind the window. Fix some weirdness with ARGB windows.
  clear-shadow = false;
  # Detect rounded corners
  # (it doesn't really do anything for shadows)
  detect-rounded-corners = false;

  # shadow-radius: The blur radius for shadows. (default 12)
  # shadow-offset-x: The left offset for shadows. (default -15)
  # shadow-offset-y: The top offset for shadows. (default -15)
  # shadow-opacity: The translucency for shadows. (default .75)
  shadow-radius = 14;
  shadow-offset-x = -12;
  shadow-offset-y = -12;
  shadow-opacity = 0.3;

  # === Fading ===
  # Fade windows during opacity changes.
  fading = true;
  # The time between steps in a fade in milliseconds. (default 10).
  fade-delta = 10;
  # Fade windows in/out when opening/closing
  no-fading-openclose = false;
}
