extends Control
class_name SteamRenderTemplate

const STEAM_NAMES: PackedStringArray = [
	"library_logo", "main_capsule", "small_capsule",
	"header_capsule", "vertical_capsule", "page_background",
	"library_capsule", "library_header", "library_hero",
]

const OVERRIDE_LAYER_NAME := "ConsumerOverrideLayer"

var svg_string: String = ""
var bg_stylebox: StyleBoxFlat = StyleBoxFlat.new()
var texture: ImageTexture
var _shared_logo: Texture2D
var _apply_shared_logo_to_all: bool = false
var _asset_overrides: Dictionary = {} # asset_id -> Texture2D
var _language_index: int = 0

var bg_color: Color = Color(0.1092, 0.11752, 0.13, 1):
	set(v):
		bg_color = Color(v)
		bg_stylebox.bg_color = bg_color

var font_color: Color = Color(1, 0.960938, 0, 1):
	set(v):
		font_color = v
		ProjectSettings.set_setting("gui/theme/custom_font_color", font_color)

var font_outline_color: Color = Color(0, 0, 0, 1):
	set(v):
		font_outline_color = v
		ProjectSettings.set_setting("gui/theme/font_outline_color", font_outline_color)

var bg_icon_color: Color = Color(1, 0.83, 0.949, 0.0196078):
	set(v):
		bg_icon_color = v
		update_bg_icon_color()

var icon_x_color: Color = Color(1, 0.246094, 0.246094, 1):
	set(v):
		icon_x_color = v
		update_icon_colors()

var icon_x_outline_color: Color = Color(0, 0, 0, 0.8):
	set(v):
		icon_x_outline_color = v
		update_icon_colors()

var icon_o_color: Color = Color(1, 0.960784, 0, 1):
	set(v):
		icon_o_color = v
		update_icon_colors()

var icon_o_outline_color: Color = Color(0, 0, 0, 0.780392):
	set(v):
		icon_o_outline_color = v
		update_icon_colors()

var font_outline_size: float = 16.0:
	set(v):
		font_outline_size = v
		ProjectSettings.set_setting("gui/theme/font_outline_size", font_outline_size)

var icon_x_outline_size: float = 10.0:
	set(v):
		icon_x_outline_size = v
		update_icon_colors()

var icon_o_outline_size: float = 10.0:
	set(v):
		icon_o_outline_size = v
		update_icon_colors()

@onready var library_logo_viewport: SubViewport = get_node("%LibraryLogoViewport")
@onready var main_capsule_viewport: SubViewport = get_node("%MainCapsuleViewport")
@onready var small_capsule_viewport: SubViewport = get_node("%SmallCapsuleViewport")
@onready var header_capsule_viewport: SubViewport = get_node("%HeaderCapsuleViewport")
@onready var vertical_capsule_viewport: SubViewport = get_node("%VerticalCapsuleViewport")
@onready var page_background_viewport: SubViewport = get_node("%PageBackgroundViewport")
@onready var library_capsule_viewport: SubViewport = get_node("%LibraryCapsuleViewport")
@onready var library_header_viewport: SubViewport = get_node("%LibraryHeaderViewport")
@onready var library_hero_viewport: SubViewport = get_node("%LibraryHeroViewport")

@onready var small_capsule_tabs: TabContainer = get_node("%SmallCapsuleTabs")
@onready var header_capsule_tabs: TabContainer = get_node("%HeaderCapsuleTabs")
@onready var vertical_capsule_tabs: TabContainer = get_node("%VerticalCapsuleTabs")
@onready var library_capsule_tabs: TabContainer = get_node("%LibraryCapsuleTabs")
@onready var library_header_tabs: TabContainer = get_node("%LibraryHeaderTabs")
@onready var library_logo_tabs: TabContainer = get_node("%LibraryLogoTabs")

@onready var main_capsule_bg_panel: Panel = get_node("%MainCapsuleBgPanel")
@onready var small_capsule_bg_panel: Panel = get_node("%SmallCapsuleBgPanel")
@onready var header_capsule_bg_panel: Panel = get_node("%HeaderCapsuleBgPanel")
@onready var vertical_capsule_bg_panel: Panel = get_node("%VerticalCapsuleBgPanel")
@onready var page_background_bg_panel: Panel = get_node("%PageBackgroundBgPanel")
@onready var library_capsule_bg_panel: Panel = get_node("%LibraryCapsuleBgPanel")
@onready var library_header_bg_panel: Panel = get_node("%LibraryHeaderBgPanel")
@onready var library_hero_bg_panel: Panel = get_node("%LibraryHeroBgPanel")

@onready var main_capsule_icon_panel: Panel = get_node("%MainCapsuleIconPanel")
@onready var small_capsule_icon_panel: Panel = get_node("%SmallCapsuleIconPanel")
@onready var header_capsule_icon_panel: Panel = get_node("%HeaderCapsuleIconPanel")
@onready var vertical_capsule_icon_panel: Panel = get_node("%VerticalCapsuleIconPanel")
@onready var page_background_icon_panel: Panel = get_node("%PageBackgroundIconPanel")
@onready var library_capsule_icon_panel: Panel = get_node("%LibraryCapsuleIconPanel")
@onready var library_header_icon_panel: Panel = get_node("%LibraryHeaderIconPanel")
@onready var library_hero_icon_panel: Panel = get_node("%LibraryHeroIconPanel")

@onready var main_capsule_icon: TextureRect = get_node("%MainCapsuleIcon")
@onready var small_capsule_icon: TextureRect = get_node("%SmallCapsuleIcon")
@onready var header_capsule_icon: TextureRect = get_node("%HeaderCapsuleIcon")
@onready var vertical_capsule_icon: TextureRect = get_node("%VerticalCapsuleIcon")
@onready var library_capsule_icon: TextureRect = get_node("%LibraryCapsuleIcon")
@onready var library_header_icon: TextureRect = get_node("%LibraryHeaderIcon")
@onready var library_logo_icon: TextureRect = get_node("%LibraryLogoIcon")


func _init() -> void:
	bg_stylebox.bg_color = bg_color
	var file := FileAccess.open("res://assets/icon.svg", FileAccess.READ)
	if file:
		svg_string = file.get_as_text()
	update_icon_colors()


func _ready() -> void:
	_hide_developer_chrome()
	for steam_name: String in STEAM_NAMES:
		var bg_panel: Panel = get("%s_bg_panel" % steam_name)
		if bg_panel:
			bg_panel.add_theme_stylebox_override("panel", bg_stylebox)
		var vp: SubViewport = get("%s_viewport" % steam_name)
		if vp:
			vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_ensure_override_layer(steam_name)
	_refresh_icons()
	update_bg_icon_color()
	ProjectSettings.set_setting("gui/theme/custom_font_color", font_color)
	ProjectSettings.set_setting("gui/theme/font_outline_color", font_outline_color)
	ProjectSettings.set_setting("gui/theme/font_outline_size", font_outline_size)
	set_language_index(_language_index)


func _hide_developer_chrome() -> void:
	# Keep the developer board off-screen so SubViewportContainers stay in a
	# live tree (required for reliable viewport updates) without cluttering UI.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2.ZERO
	size = Vector2.ZERO
	position = Vector2(-100000, -100000)
	var steam_label := get_node_or_null("Steam/SteamPanel/SteamLabel")
	if steam_label is CanvasItem:
		(steam_label as CanvasItem).visible = false
	var steam_panel := get_node_or_null("Steam/SteamPanel")
	if steam_panel is Panel:
		(steam_panel as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())


func get_viewport_for_asset(asset_id: String) -> SubViewport:
	return get("%s_viewport" % asset_id) as SubViewport


func set_language_index(index: int) -> void:
	_language_index = maxi(index, 0)
	for steam_name: String in STEAM_NAMES:
		var tabs: TabContainer = get("%s_tabs" % steam_name)
		if tabs:
			tabs.current_tab = mini(_language_index, tabs.get_tab_count() - 1)


func apply_branding(state: ProjectState) -> void:
	bg_color = state.bg_color
	font_color = state.font_color
	font_outline_color = state.font_outline_color
	bg_icon_color = state.bg_icon_color
	icon_x_color = state.icon_x_color
	icon_x_outline_color = state.icon_x_outline_color
	icon_o_color = state.icon_o_color
	icon_o_outline_color = state.icon_o_outline_color
	font_outline_size = state.font_outline_size
	icon_x_outline_size = state.icon_x_outline_size
	icon_o_outline_size = state.icon_o_outline_size
	set_language_index(state.language_index)


func set_shared_logo(tex: Texture2D, apply_to_all: bool) -> void:
	_shared_logo = tex
	_apply_shared_logo_to_all = apply_to_all
	_refresh_icons()


func set_asset_override(asset_id: String, tex: Texture2D) -> void:
	if tex == null:
		_asset_overrides.erase(asset_id)
	else:
		_asset_overrides[asset_id] = tex
	_apply_override_layer(asset_id)


func clear_asset_override(asset_id: String) -> void:
	_asset_overrides.erase(asset_id)
	_apply_override_layer(asset_id)


func sync_overrides_from_state(state: ProjectState) -> void:
	_asset_overrides.clear()
	for asset_id in state.asset_override_paths.keys():
		var path: String = str(state.asset_override_paths[asset_id])
		var tex := ImageLoader.load_texture(path)
		if tex:
			_asset_overrides[asset_id] = tex
	var shared := ImageLoader.load_texture(state.shared_logo_path)
	set_shared_logo(shared, state.apply_shared_logo_to_all)
	for steam_name: String in STEAM_NAMES:
		_apply_override_layer(steam_name)


func update_icon_colors() -> void:
	if svg_string.is_empty():
		return
	var svg_str: String = svg_string
	svg_str = svg_str.replace("#fff", "#%s" % icon_x_color.to_html(false))
	svg_str = svg_str.replace("#000", "#%s" % icon_x_outline_color.to_html(false))
	svg_str = svg_str.replace("red", "#%s" % icon_o_color.to_html(false))
	svg_str = svg_str.replace("#00f", "#%s" % icon_o_outline_color.to_html(false))
	svg_str = svg_str.replace(
		"stroke-width:4",
		"stroke-width:%s;stroke-opacity:%s;fill-opacity:%s" % [
			icon_x_outline_size, icon_x_outline_color.a, icon_x_color.a
		]
	)
	svg_str = svg_str.replace(
		"stroke-width:6",
		"stroke-width:%s;stroke-opacity:%s;fill-opacity:%s" % [
			icon_o_outline_size, icon_o_outline_color.a, icon_o_color.a
		]
	)
	var img: Image = Image.new()
	img.load_svg_from_string(svg_str, 6)
	if texture == null or texture.get_image() == null:
		texture = ImageTexture.create_from_image(img)
	else:
		texture.update(img)
	_refresh_icons()


func update_bg_icon_color() -> void:
	for steam_name: String in STEAM_NAMES:
		var icon_panel: Panel = get("%s_icon_panel" % steam_name)
		if icon_panel:
			icon_panel.self_modulate = bg_icon_color


func _refresh_icons() -> void:
	for steam_name: String in STEAM_NAMES:
		var icon: TextureRect = get("%s_icon" % steam_name)
		if icon == null:
			continue
		if _apply_shared_logo_to_all and _shared_logo:
			icon.texture = _shared_logo
		elif _shared_logo and steam_name == "library_logo":
			icon.texture = _shared_logo
		else:
			icon.texture = texture


func _ensure_override_layer(asset_id: String) -> TextureRect:
	var host: Node = get("%s_bg_panel" % asset_id)
	if host == null:
		host = get_viewport_for_asset(asset_id)
	if host == null:
		return null
	var existing := host.get_node_or_null(OVERRIDE_LAYER_NAME)
	if existing is TextureRect:
		return existing
	var layer := TextureRect.new()
	layer.name = OVERRIDE_LAYER_NAME
	if host is Control:
		layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		var vp := host as SubViewport
		layer.size = Vector2(vp.size)
		layer.position = Vector2.ZERO
	layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.visible = false
	layer.z_index = 100
	host.add_child(layer)
	return layer


func _apply_override_layer(asset_id: String) -> void:
	var layer := _ensure_override_layer(asset_id)
	if layer == null:
		return
	if _asset_overrides.has(asset_id):
		layer.texture = _asset_overrides[asset_id]
		layer.visible = true
	else:
		layer.texture = null
		layer.visible = false
