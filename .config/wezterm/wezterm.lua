local wezterm = require("wezterm")
local config = wezterm.config_builder()
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

config.font = wezterm.font("CaskaydiaCove Nerd Font Mono")
config.tab_bar_at_bottom = false
config.max_fps = 200

local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end

config.color_scheme = scheme_for_appearance(get_appearance())
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30
config.native_macos_fullscreen_mode = true

local CTRL_OR_COMMAND_KEY = "CTRL"
if wezterm.target_triple == "aarch64-apple-darwin" then
	CTRL_OR_COMMAND_KEY = "SUPER"
end

tabline.setup({
	options = {
		icons_enabled = true,
		theme = config.color_scheme,
		tabs_enabled = true,
		theme_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = {
			"index",
			{ "parent", padding = 0 },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
		tabline_x = {},
		tabline_y = { "datetime", "battery" },
		tabline_z = { "domain" },
	},
	extensions = {},
})
tabline.apply_to_config(config)
local action = wezterm.action

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function is_vim(pane)
	-- This gsub is equivalent to POSIX basename(3)
	-- Given "/foo/bar" returns "bar"
	-- Given "c:\\foo\\bar" returns "bar"
	local process_name = string.gsub(pane:get_foreground_process_name(), "(.*[/\\])(.*)", "%2")
	return process_name == "nvim" or process_name == "vim"
end

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or CTRL_OR_COMMAND_KEY,
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "ALT" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

config.leader = { key = "e", mods = CTRL_OR_COMMAND_KEY, timeout_milliseconds = 2000 }
config.disable_default_key_bindings = true
config.keys = {
	{
		key = "c",
		mods = "LEADER",
		action = action.SpawnTab("CurrentPaneDomain"),
	},

	{
		key = "p",
		mods = "LEADER",
		action = action.ActivateTabRelative(-1),
	},
	{
		key = "n",
		mods = "LEADER",
		action = action.ActivateTabRelative(1),
	},
	{
		key = "s",
		mods = "LEADER",
		action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "LEADER",
		action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "x",
		mods = "LEADER",
		action = action.ActivateCopyMode,
	},
	{
		key = "f",
		mods = "LEADER",
		action = action.QuickSelect,
	},
	{
		key = "z",
		mods = "LEADER",
		action = action.TogglePaneZoomState,
	},
	{
		key = "w",
		mods = "LEADER",
		action = wezterm.action.ShowTabNavigator,
	},
	{
		key = ".",
		mods = "LEADER",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		key = ",",
		mods = "LEADER",
		action = wezterm.action.DecreaseFontSize,
	},
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
	{
		key = "P",
		mods = string.format("SHIFT|%s", CTRL_OR_COMMAND_KEY),
		action = wezterm.action.ActivateCommandPalette,
	},
	{
		key = "w",
		mods = "META",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "h",
		mods = string.format("META|%s", CTRL_OR_COMMAND_KEY),
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	{
		key = "l",
		mods = string.format("META|%s", CTRL_OR_COMMAND_KEY),
		action = wezterm.action.RotatePanes("CounterClockwise"),
	},
}

if wezterm.target_triple == "aarch64-apple-darwin" then
	table.insert(config.keys, {
		key = "c",
		mods = "SUPER",
		action = action.CopyTo("Clipboard"),
	})
	table.insert(config.keys, {
		key = "v",
		mods = "SUPER",
		action = action.PasteFrom("Clipboard"),
	})
end

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = action.ActivateTab(i - 1),
	})
end

return config
