local empty_key = '   '
return {
  --- Syntax highlighting ---
  {
    'codethread/qmk.nvim',
    ft = { 'c' },
    opts = {
      name = 'LAYOUT',
      layout = {
        '_ x x x x x x _ _ _ _ x x x x x x _',
        '_ x x x x x x _ _ _ _ x x x x x x _',
        '_ x x x x x x _ _ _ _ x x x x x x _',
        '_ x x x x x x x _ _ x x x x x x x _',
        '_ _ _ x x x x x _ _ x x x x x _ _ _',
      },
      comment_preview = {
        keymap_overrides = {
          ['MO%(_RAISE%)'] = 'RAISE',
          ['MO%(_LOWER%)'] = 'LOWER',
          XXXXXXX = empty_key,

          --Alphas
          KC_BSLS = '\\', --"bsls",
          KC_BSLASH = '\\', --Backslash(\|)
          KC_QUOT = "'",
          KC_QUOTE = "'",
          KC_SPC = 'Space',
          KC_SPACE = 'Space', --"spacebar",#Spacebar

          --Modifiers
          KC_RCTL = 'Ctrl',
          KC_RCTRL = 'Ctrl', --"rctrl",#RightCtrl
          KC_LCTL = 'Ctrl',
          KC_LCTRL = 'Ctrl', --"lctrl",#LeftCtrl
          KC_RSFT = 'Shift',
          KC_RSHIFT = 'Shift', --"rshift",#RightShift
          KC_LSFT = 'Shift',
          KC_LSHIFT = 'Shift', --"lshift",#LeftShift
          KC_LGUI = 'GUI',
          KC_LWIN = 'GUI', --"lwin",
          KC_LCMD = 'GUI', --LeftGUI/Win
          KC_RGUI = 'GUI',
          KC_RWIN = 'GUI', --"rwin",
          KC_RCMD = 'GUI', --RightGUI/Win
          KC_LALT = 'Alt', --LeftAlt
          KC_RALT = 'Alt', --RightAlt
          KC_BSPC = 'Backspace',
          KC_BSPACE = 'Backspace', --"backspace",#Backspace
          KC_ENT = 'Return',
          KC_ENTER = 'Return', --"enter",#Enter
          KC_TAB = 'Tab', --Tab
          KC_CAPS = 'Tab',
          KC_CLCK = 'Caps',
          KC_CAPSLOCK = 'Caps', --"caps_lock""kp_ent",,#CapsLock
          KC_RGHT = '→',
          KC_RIGHT = '→', --"right",#rightarrow
          KC_UP = '↑',
          KC_DOWN = '↓',
          KC_LEFT = '←',
          --Function
          KC_ESC = 'Esc',
          KC_ESCAPE = 'Esc', --"escape",#Escape
          KC_F1 = 'F1',
          KC_F2 = 'F2',
          KC_F3 = 'F3',
          KC_F4 = 'F4',
          KC_F5 = 'F5',
          KC_F6 = 'F6',
          KC_F7 = 'F7',
          KC_F8 = 'F8',
          KC_F9 = 'F9',
          KC_F10 = 'F10',
          KC_F11 = 'F11',
          KC_F12 = 'F12',
          KC_PSCR = 'PrScr',
          KC_PSCREEN = 'PrScr', --"print_screen",#PrintScreen
          KC_SLCK = 'S-Lock',
          KC_SCROLLLOCK = 'S-Lock', --"scroll_lock",#ScrollLock
          KC_PAUS = 'Ps/Brk',
          KC_BRK = 'Ps/Brk',
          KC_PAUSE = 'Ps/Brk', --"pause",#Pause/Break
          KC_INS = 'Ins',
          KC_INSERT = 'Ins', --"insert",#Insert
          KC_DEL = 'Del',
          KC_DELT = 'Del',
          KC_DELETE = 'Del', --"delete",#Delete
          KC_HOME = 'Home', --Home
          KC_END = 'End', --End
          KC_PGUP = 'PgUp', --PageUp
          KC_PGDN = 'PgDn',
          KC_PGDOWN = 'PgDn', --"page_down",#PageDown
          KC_F13 = 'F13',
          KC_F14 = 'F14',
          KC_F15 = 'F15',
          KC_F16 = 'F16',
          KC_F17 = 'F17',
          KC_F18 = 'F18',
          KC_F19 = 'F19',
          KC_F20 = 'F20',
          KC_F21 = 'F21',
          KC_F22 = 'F22',
          KC_F23 = 'F23',
          KC_F24 = 'F24',
          --Shifted
          KC_HASH = '#',

          --MiscFunctions
          KC_APP = 'App',
          KC_APPLICATION = 'App', --Application

          --MediaControls
          KC__MUTE = 'Mute',
          KC_MUTE = 'Mute',
          KC_AUDIO_MUTE = 'Mute', --"audio_mute",#AudioMute
          KC_VOLU = 'Vol Up',
          KC__VOLUP = 'Vol Up',
          KC_AUDIO_VOL_UP = 'Vol Up', --"audio_vol_up",#AudioVol.Up
          KC_VOLD = 'Vol Down',
          KC__VOLDOWN = 'Vol Down',
          KC_AUDIO_VOL_DOWN = 'Vol Down', --"audio_vol_down",#AudioVol.Down
          KC_MNXT = 'MediaNext',
          KC_MEDIA_NEXT_TRACK = 'MediaNext', --"media_next_track",#MediaNextTrack
          KC_MPRV = 'MediaPrev',
          KC_MEDIA_PREV_TRACK = 'MediaPrev', --"media_prev_track",#MediaPrevTrack
          KC_MSTP = 'Stop',
          KC_MEDIA_STOP = 'Stop', --"media_stop",#MediaStop
          KC_MPLY = 'Play',
          KC_MEDIA_PLAY_PAUSE = 'Play', --"media_play_pause",#MediaPlay/Pause
        },
      },
    },
  },
  { 'fladson/vim-kitty', ft = 'kitty' },
  { 'isobit/vim-caddyfile', ft = 'caddyfile' },
  { 'kovetskiy/sxhkd-vim', event = 'VeryLazy' },
  {
    'alker0/chezmoi.vim',
    event = 'VeryLazy',
    init = function()
      vim.g['chezmoi#use_tmp_buffer'] = true
    end,
  },
}
