class_name ExportPlatform
extends RefCounted

## One exportable asset type for a store/platform.
## Keys: id (String), label (String), size (Vector2i), localized (bool), uses_logo (bool)
func get_id() -> String:
	return ""


func get_display_name() -> String:
	return ""


func get_asset_defs() -> Array[Dictionary]:
	return []


func get_output_dir() -> String:
	return "user://exported/%s" % get_id()


func get_languages() -> PackedStringArray:
	return PackedStringArray()


func get_language_labels() -> PackedStringArray:
	return PackedStringArray()
