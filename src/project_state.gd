class_name ProjectState
extends RefCounted

const STATE_PATH := "user://project_state.cfg"

var platform_id: String = "steam"
var selected_asset_id: String = "main_capsule"
var language_index: int = 0
var apply_shared_logo_to_all: bool = false
var shared_logo_path: String = ""
var asset_override_paths: Dictionary = {} # asset_id -> path

var bg_color: Color = Color(0.1092, 0.11752, 0.13, 1)
var font_color: Color = Color(1, 0.960938, 0, 1)
var font_outline_color: Color = Color(0, 0, 0, 1)
var bg_icon_color: Color = Color(1, 0.83, 0.949, 0.0196078)
var icon_x_color: Color = Color(1, 0.246094, 0.246094, 1)
var icon_x_outline_color: Color = Color(0, 0, 0, 0.8)
var icon_o_color: Color = Color(1, 0.960784, 0, 1)
var icon_o_outline_color: Color = Color(0, 0, 0, 0.780392)
var font_outline_size: float = 16.0
var icon_x_outline_size: float = 10.0
var icon_o_outline_size: float = 10.0


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("session", "platform_id", platform_id)
	cfg.set_value("session", "selected_asset_id", selected_asset_id)
	cfg.set_value("session", "language_index", language_index)
	cfg.set_value("session", "apply_shared_logo_to_all", apply_shared_logo_to_all)
	cfg.set_value("session", "shared_logo_path", shared_logo_path)
	cfg.set_value("overrides", "paths", asset_override_paths)
	cfg.set_value("branding", "bg_color", bg_color)
	cfg.set_value("branding", "font_color", font_color)
	cfg.set_value("branding", "font_outline_color", font_outline_color)
	cfg.set_value("branding", "bg_icon_color", bg_icon_color)
	cfg.set_value("branding", "icon_x_color", icon_x_color)
	cfg.set_value("branding", "icon_x_outline_color", icon_x_outline_color)
	cfg.set_value("branding", "icon_o_color", icon_o_color)
	cfg.set_value("branding", "icon_o_outline_color", icon_o_outline_color)
	cfg.set_value("branding", "font_outline_size", font_outline_size)
	cfg.set_value("branding", "icon_x_outline_size", icon_x_outline_size)
	cfg.set_value("branding", "icon_o_outline_size", icon_o_outline_size)
	cfg.save(STATE_PATH)


func load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(STATE_PATH) != OK:
		return
	platform_id = cfg.get_value("session", "platform_id", platform_id)
	selected_asset_id = cfg.get_value("session", "selected_asset_id", selected_asset_id)
	language_index = int(cfg.get_value("session", "language_index", language_index))
	apply_shared_logo_to_all = bool(cfg.get_value("session", "apply_shared_logo_to_all", apply_shared_logo_to_all))
	shared_logo_path = str(cfg.get_value("session", "shared_logo_path", shared_logo_path))
	var paths = cfg.get_value("overrides", "paths", {})
	if typeof(paths) == TYPE_DICTIONARY:
		asset_override_paths = paths
	bg_color = cfg.get_value("branding", "bg_color", bg_color)
	font_color = cfg.get_value("branding", "font_color", font_color)
	font_outline_color = cfg.get_value("branding", "font_outline_color", font_outline_color)
	bg_icon_color = cfg.get_value("branding", "bg_icon_color", bg_icon_color)
	icon_x_color = cfg.get_value("branding", "icon_x_color", icon_x_color)
	icon_x_outline_color = cfg.get_value("branding", "icon_x_outline_color", icon_x_outline_color)
	icon_o_color = cfg.get_value("branding", "icon_o_color", icon_o_color)
	icon_o_outline_color = cfg.get_value("branding", "icon_o_outline_color", icon_o_outline_color)
	font_outline_size = float(cfg.get_value("branding", "font_outline_size", font_outline_size))
	icon_x_outline_size = float(cfg.get_value("branding", "icon_x_outline_size", icon_x_outline_size))
	icon_o_outline_size = float(cfg.get_value("branding", "icon_o_outline_size", icon_o_outline_size))
