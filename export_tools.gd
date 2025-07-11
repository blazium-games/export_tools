@tool
extends Control

var svg_string = FileAccess.open("res://assets/icon.svg", FileAccess.READ).get_as_text()

const STEAM_NAMES: PackedStringArray = [
	"library_logo", "main_capsule", "small_capsule",
	"header_capsule", "vertical_capsule", "page_background",
	"library_capsule", "library_header", "library_hero"
]

const LANGUAGES: PackedStringArray = [
	"english", "arabic", "russian", "schinese", "tchinese",
	"turkish", "danish",  "czech", "indonesian", "koreana", 
	"finnish", "french",  "greek", "hungarian", "norwegian",
	"italian", "german", "japanese","bulgarian", "romanian", 
	"spanish", "polish", "thai", "brazilian", "portuguese",
	"swedish", "latam",  "ukrainian", "vietnamese", "dutch"
]

var bg_stylebox: StyleBoxFlat = StyleBoxFlat.new()
var texture: ImageTexture

@export_enum(
	"English", "Arabic", "Russian", "Chinese (Simplified)", "Chinese (Traditional)",
	"Turkish", "Danish",  "Czech", "Indonesian", "Korean", 
	"Finnish", "French",  "Greek", "Hungarian", "Norwegian",
	"Italian", "German", "Japanese","Bulgarian", "Romanian", 
	"Spanish-Spain", "Polish", "Thai", "brazilian", "Portuguese",
	"Swedish", "Spanish-Latin America",  "Ukrainian", "Vietnamese", "Dutch"
) var lang: int = 0:
	set(v):
		lang = v
		for steam_name: String in STEAM_NAMES:
			var tabs: TabContainer = get("%s_tabs" % steam_name)
			if tabs:
				tabs.current_tab = lang

@export_color_no_alpha var bg_color = Color(0.05, 0.083, 0.12):
	set(v):
		bg_color = Color(v)
		bg_stylebox.bg_color = bg_color

@export var font_color: Color = Color(0.655, 0.812, 0.031):
	set(v):
		font_color = v
		ProjectSettings.set_setting("gui/theme/custom_font_color", font_color)

@export var font_outline_color: Color = Color(0.066, 0.093, 0.001):
	set(v):
		font_outline_color = v
		ProjectSettings.set_setting("gui/theme/font_outline_color", font_outline_color)

@export var bg_icon_color: Color = Color(1, 1, 1, 0.2):
	set(v):
		bg_icon_color = v
		update_bg_icon_color()

@export var icon_x_color: Color = Color(0.655, 0.812, 0.031):
	set(v):
		icon_x_color = v
		update_icon_colors()

@export var icon_x_outline_color: Color = Color(0.066, 0.093, 0.001):
	set(v):
		icon_x_outline_color = v
		update_icon_colors()

@export var icon_o_color: Color = Color(0.655, 0.812, 0.031):
	set(v):
		icon_o_color = v
		update_icon_colors()

@export var icon_o_outline_color: Color = Color(0.066, 0.093, 0.001):
	set(v):
		icon_o_outline_color = v
		update_icon_colors()

@export_range(0.0, 64.0) var font_outline_size: float = 16:
	set(v):
		font_outline_size = v
		ProjectSettings.set_setting("gui/theme/font_outline_size", font_outline_size)

@export_range(0.0, 64.0) var icon_x_outline_size: float = 4.0:
	set(v):
		icon_x_outline_size = v
		update_icon_colors()

@export_range(0.0, 64.0) var icon_o_outline_size: float = 4.0:
	set(v):
		icon_o_outline_size = v
		update_icon_colors()

@export_tool_button("Export") var export_images = export_callback

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

@onready var main_capsule_icon: IconRect = get_node("%MainCapsuleIcon")
@onready var small_capsule_icon: IconRect = get_node("%SmallCapsuleIcon")
@onready var header_capsule_icon: IconRect = get_node("%HeaderCapsuleIcon")
@onready var vertical_capsule_icon: IconRect = get_node("%VerticalCapsuleIcon")
@onready var library_capsule_icon: IconRect = get_node("%LibraryCapsuleIcon")
@onready var library_header_icon: IconRect = get_node("%LibraryHeaderIcon")
@onready var library_logo_icon: IconRect = get_node("%LibraryLogoIcon")


func _validate_property(property: Dictionary) -> void:
	if property["name"] == "texture":
		property["usage"] = PROPERTY_USAGE_NONE


func _ready() -> void:
	for steam_name: String in STEAM_NAMES:
		var bg_panel: Panel = get("%s_bg_panel" % steam_name)
		if bg_panel:
			bg_panel.add_theme_stylebox_override("panel", bg_stylebox)
		var icon: IconRect = get("%s_icon" % steam_name)
		if icon:
			icon.texture = texture
	update_icon_colors()
	update_bg_icon_color()
	ProjectSettings.set_setting("gui/theme/custom_font_color", font_color)
	ProjectSettings.set_setting("gui/theme/font_outline_color", font_outline_color)
	ProjectSettings.set_setting("gui/theme/font_outline_size", font_outline_size)


func update_icon_colors():
	var svg_str: String = svg_string
	svg_str = svg_str.replace("#fff", "#%s" % icon_x_color.to_html(false))
	svg_str = svg_str.replace("#000", "#%s" % icon_x_outline_color.to_html(false))
	svg_str = svg_str.replace("red", "#%s" % icon_o_color.to_html(false))
	svg_str = svg_str.replace("#00f", "#%s" % icon_o_outline_color.to_html(false))
	svg_str = svg_str.replace("stroke-width:4", "stroke-width:%s;stroke-opacity:%s;fill-opacity:%s" % [icon_x_outline_size, icon_x_outline_color.a, icon_x_color.a])
	svg_str = svg_str.replace("stroke-width:6", "stroke-width:%s;stroke-opacity:%s;fill-opacity:%s" % [icon_o_outline_size, icon_o_outline_color.a, icon_o_color.a])
	var img: Image = Image.new()
	img.load_svg_from_string(svg_str, 6)
	if not texture or not texture.get_image():
		texture = ImageTexture.create_from_image(img)
	else:
		texture.update(img)


func update_bg_icon_color():
	for steam_name: String in STEAM_NAMES:
		var icon_panel: Panel = get("%s_icon_panel" % steam_name)
		if icon_panel:
			icon_panel.self_modulate = bg_icon_color


func _init() -> void:
	bg_stylebox.bg_color = bg_color
	update_icon_colors()

func export_callback():
	if not DirAccess.dir_exists_absolute("res://exported"):
		DirAccess.make_dir_absolute("res://exported")
		var gdignore_file = FileAccess.open("res://exported/.gdignore", FileAccess.WRITE)
		gdignore_file.close()
	if not DirAccess.dir_exists_absolute("res://exported/steam"):
		DirAccess.make_dir_absolute("res://exported/steam")
	for steam_name: String in STEAM_NAMES:
		var vp: SubViewport = get("%s_viewport" % steam_name)
		if not vp:
			continue
		var tabs: TabContainer = get("%s_tabs" % steam_name)
		var _name: String = vp.get_parent().name.to_snake_case()
		if tabs:
			for i in LANGUAGES.size():
				var lang_name: String = LANGUAGES[i]
				tabs.current_tab = i
				await RenderingServer.frame_post_draw
				var image: Image = vp.get_texture().get_image()
				image.save_png("res://exported/steam/%s_%s.png" % [_name, lang_name.to_lower()])
		else:
			await RenderingServer.frame_post_draw
			var image: Image = vp.get_texture().get_image()
			image.save_png("res://exported/steam/%s.png" % _name)
	EditorInterface.get_resource_filesystem().scan()
