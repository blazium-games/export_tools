class_name SteamPlatform
extends ExportPlatform

const LANGUAGES: PackedStringArray = [
	"english", "arabic", "russian", "schinese", "tchinese",
	"turkish", "danish", "czech", "indonesian", "koreana",
	"finnish", "french", "greek", "hungarian", "norwegian",
	"italian", "german", "japanese", "bulgarian", "romanian",
	"spanish", "polish", "thai", "brazilian", "portuguese",
	"swedish", "latam", "ukrainian", "vietnamese", "dutch",
]

const LANGUAGE_LABELS: PackedStringArray = [
	"English", "Arabic", "Russian", "Chinese (Simplified)", "Chinese (Traditional)",
	"Turkish", "Danish", "Czech", "Indonesian", "Korean",
	"Finnish", "French", "Greek", "Hungarian", "Norwegian",
	"Italian", "German", "Japanese", "Bulgarian", "Romanian",
	"Spanish-Spain", "Polish", "Thai", "Brazilian", "Portuguese",
	"Swedish", "Spanish-Latin America", "Ukrainian", "Vietnamese", "Dutch",
]


func get_id() -> String:
	return "steam"


func get_display_name() -> String:
	return "Steam"


func get_languages() -> PackedStringArray:
	return LANGUAGES


func get_language_labels() -> PackedStringArray:
	return LANGUAGE_LABELS


func get_asset_defs() -> Array[Dictionary]:
	return [
		_def("main_capsule", "Main Capsule", Vector2i(1232, 706), false, true),
		_def("small_capsule", "Small Capsule", Vector2i(462, 174), true, true),
		_def("header_capsule", "Header Capsule", Vector2i(920, 430), true, true),
		_def("vertical_capsule", "Vertical Capsule", Vector2i(748, 896), true, true),
		_def("page_background", "Page Background", Vector2i(1438, 896), false, false),
		_def("library_capsule", "Library Capsule", Vector2i(600, 900), true, true),
		_def("library_header", "Library Header", Vector2i(920, 430), true, true),
		_def("library_hero", "Library Hero", Vector2i(3840, 1240), false, false),
		_def("library_logo", "Library Logo", Vector2i(1280, 720), true, true),
	]


func _def(id: String, label: String, size: Vector2i, localized: bool, uses_logo: bool) -> Dictionary:
	return {
		"id": id,
		"label": label,
		"size": size,
		"localized": localized,
		"uses_logo": uses_logo,
	}
