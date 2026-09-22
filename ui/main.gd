extends Control

const TEMPLATE_SCENE := preload("res://export-tools.tscn")

@onready var platform_option: OptionButton = %PlatformOption
@onready var asset_list: ItemList = %AssetList
@onready var size_label: Label = %SizeLabel
@onready var preview_rect: TextureRect = %PreviewRect
@onready var preview_frame: Panel = %PreviewFrame
@onready var language_option: OptionButton = %LanguageOption
@onready var add_image_button: Button = %AddImageButton
@onready var clear_image_button: Button = %ClearImageButton
@onready var shared_logo_button: Button = %SharedLogoButton
@onready var clear_shared_logo_button: Button = %ClearSharedLogoButton
@onready var apply_shared_check: CheckBox = %ApplySharedCheck
@onready var export_button: Button = %ExportButton
@onready var open_folder_button: Button = %OpenFolderButton
@onready var status_label: Label = %StatusLabel
@onready var override_status: Label = %OverrideStatus

@onready var bg_color_picker: ColorPickerButton = %BgColorPicker
@onready var font_color_picker: ColorPickerButton = %FontColorPicker
@onready var font_outline_picker: ColorPickerButton = %FontOutlinePicker
@onready var icon_x_picker: ColorPickerButton = %IconXPicker
@onready var icon_o_picker: ColorPickerButton = %IconOPicker
@onready var bg_icon_picker: ColorPickerButton = %BgIconPicker

@onready var image_dialog: FileDialog = %ImageDialog
@onready var shared_logo_dialog: FileDialog = %SharedLogoDialog

var state := ProjectState.new()
var template: SteamRenderTemplate
var current_platform: ExportPlatform
var _exporting: bool = false
var _last_output_dir: String = ""


func _ready() -> void:
	state.load()
	await _setup_template()
	_populate_platforms()
	_bind_ui()
	_apply_state_to_ui()
	_refresh_asset_list()
	_select_asset(state.selected_asset_id)
	_update_preview()
	status_label.text = "Ready — add images or adjust branding, then Export."


func _setup_template() -> void:
	template = TEMPLATE_SCENE.instantiate() as SteamRenderTemplate
	add_child(template)
	await get_tree().process_frame
	await get_tree().process_frame
	template.apply_branding(state)
	template.sync_overrides_from_state(state)


func _bind_ui() -> void:
	platform_option.item_selected.connect(_on_platform_selected)
	asset_list.item_selected.connect(_on_asset_selected)
	language_option.item_selected.connect(_on_language_selected)
	add_image_button.pressed.connect(_on_add_image_pressed)
	clear_image_button.pressed.connect(_on_clear_image_pressed)
	shared_logo_button.pressed.connect(_on_shared_logo_pressed)
	clear_shared_logo_button.pressed.connect(_on_clear_shared_logo_pressed)
	apply_shared_check.toggled.connect(_on_apply_shared_toggled)
	export_button.pressed.connect(_on_export_pressed)
	open_folder_button.pressed.connect(_on_open_folder_pressed)
	open_folder_button.disabled = false

	bg_color_picker.color_changed.connect(_on_branding_changed)
	font_color_picker.color_changed.connect(_on_branding_changed)
	font_outline_picker.color_changed.connect(_on_branding_changed)
	icon_x_picker.color_changed.connect(_on_branding_changed)
	icon_o_picker.color_changed.connect(_on_branding_changed)
	bg_icon_picker.color_changed.connect(_on_branding_changed)

	image_dialog.file_selected.connect(_on_image_selected)
	shared_logo_dialog.file_selected.connect(_on_shared_logo_selected)

	for dialog in [image_dialog, shared_logo_dialog]:
		dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		dialog.access = FileDialog.ACCESS_FILESYSTEM
		dialog.use_native_dialog = true
		dialog.filters = PackedStringArray([
			"*.png,*.jpg,*.jpeg,*.webp,*.svg;Images",
		])


func _populate_platforms() -> void:
	platform_option.clear()
	var platforms := PlatformRegistry.all()
	var selected := 0
	for i in platforms.size():
		var platform: ExportPlatform = platforms[i]
		platform_option.add_item(platform.get_display_name(), i)
		platform_option.set_item_metadata(i, platform.get_id())
		if platform.get_id() == state.platform_id:
			selected = i
	platform_option.select(selected)
	current_platform = PlatformRegistry.get_by_id(str(platform_option.get_item_metadata(selected)))
	if current_platform == null:
		current_platform = PlatformRegistry.default_platform()
	_populate_languages()


func _populate_languages() -> void:
	language_option.clear()
	if current_platform == null:
		return
	var labels := current_platform.get_language_labels()
	for i in labels.size():
		language_option.add_item(labels[i], i)
	language_option.select(clampi(state.language_index, 0, maxi(labels.size() - 1, 0)))


func _apply_state_to_ui() -> void:
	bg_color_picker.color = state.bg_color
	font_color_picker.color = state.font_color
	font_outline_picker.color = state.font_outline_color
	icon_x_picker.color = state.icon_x_color
	icon_o_picker.color = state.icon_o_color
	bg_icon_picker.color = state.bg_icon_color
	apply_shared_check.button_pressed = state.apply_shared_logo_to_all
	_update_override_status()


func _refresh_asset_list() -> void:
	asset_list.clear()
	if current_platform == null:
		return
	var select_index := 0
	for i in current_platform.get_asset_defs().size():
		var asset: Dictionary = current_platform.get_asset_defs()[i]
		var mark := " ●" if state.asset_override_paths.has(asset["id"]) else ""
		asset_list.add_item("%s%s" % [asset["label"], mark])
		asset_list.set_item_metadata(i, asset["id"])
		if asset["id"] == state.selected_asset_id:
			select_index = i
	if asset_list.item_count > 0:
		asset_list.select(select_index)


func _select_asset(asset_id: String) -> void:
	state.selected_asset_id = asset_id
	var asset := _current_asset()
	if asset.is_empty():
		size_label.text = ""
		return
	var size: Vector2i = asset["size"]
	var loc := " · Localized" if asset.get("localized", false) else ""
	size_label.text = "%d × %d px%s" % [size.x, size.y, loc]
	_update_override_status()
	_update_preview()


func _current_asset() -> Dictionary:
	if current_platform == null:
		return {}
	for asset in current_platform.get_asset_defs():
		if asset["id"] == state.selected_asset_id:
			return asset
	var defs := current_platform.get_asset_defs()
	if defs.is_empty():
		return {}
	return defs[0]


func _update_preview() -> void:
	if template == null:
		return
	var vp := template.get_viewport_for_asset(state.selected_asset_id)
	if vp == null:
		preview_rect.texture = null
		return
	preview_rect.texture = vp.get_texture()


func _update_override_status() -> void:
	if state.asset_override_paths.has(state.selected_asset_id):
		var path: String = str(state.asset_override_paths[state.selected_asset_id])
		override_status.text = "Custom image: %s" % path.get_file()
		clear_image_button.disabled = false
	else:
		override_status.text = "Using template branding"
		clear_image_button.disabled = true
	clear_shared_logo_button.disabled = state.shared_logo_path.is_empty()


func _persist() -> void:
	state.save()


func _on_platform_selected(index: int) -> void:
	var id := str(platform_option.get_item_metadata(index))
	state.platform_id = id
	current_platform = PlatformRegistry.get_by_id(id)
	_populate_languages()
	_refresh_asset_list()
	var defs := current_platform.get_asset_defs() if current_platform else []
	if not defs.is_empty():
		_select_asset(defs[0]["id"])
	_persist()


func _on_asset_selected(index: int) -> void:
	_select_asset(str(asset_list.get_item_metadata(index)))
	_persist()


func _on_language_selected(index: int) -> void:
	state.language_index = index
	if template:
		template.set_language_index(index)
	_persist()
	_update_preview()


func _on_add_image_pressed() -> void:
	image_dialog.popup_centered_ratio(0.7)


func _on_shared_logo_pressed() -> void:
	shared_logo_dialog.popup_centered_ratio(0.7)


func _on_image_selected(path: String) -> void:
	var tex := ImageLoader.load_texture(path)
	if tex == null:
		status_label.text = "Could not load image."
		return
	state.asset_override_paths[state.selected_asset_id] = path
	if template:
		template.set_asset_override(state.selected_asset_id, tex)
	_refresh_asset_list()
	_update_override_status()
	_update_preview()
	_persist()
	status_label.text = "Image set for %s." % _current_asset().get("label", state.selected_asset_id)


func _on_shared_logo_selected(path: String) -> void:
	var tex := ImageLoader.load_texture(path)
	if tex == null:
		status_label.text = "Could not load logo."
		return
	state.shared_logo_path = path
	if template:
		template.set_shared_logo(tex, state.apply_shared_logo_to_all)
	_update_override_status()
	_update_preview()
	_persist()
	status_label.text = "Shared logo updated."


func _on_clear_image_pressed() -> void:
	state.asset_override_paths.erase(state.selected_asset_id)
	if template:
		template.clear_asset_override(state.selected_asset_id)
	_refresh_asset_list()
	_update_override_status()
	_update_preview()
	_persist()
	status_label.text = "Cleared custom image."


func _on_clear_shared_logo_pressed() -> void:
	state.shared_logo_path = ""
	if template:
		template.set_shared_logo(null, state.apply_shared_logo_to_all)
	_update_override_status()
	_update_preview()
	_persist()
	status_label.text = "Cleared shared logo."


func _on_apply_shared_toggled(pressed: bool) -> void:
	state.apply_shared_logo_to_all = pressed
	if template:
		var tex := ImageLoader.load_texture(state.shared_logo_path)
		template.set_shared_logo(tex, pressed)
	_update_preview()
	_persist()


func _on_branding_changed(_color: Color = Color.WHITE) -> void:
	state.bg_color = bg_color_picker.color
	state.font_color = font_color_picker.color
	state.font_outline_color = font_outline_picker.color
	state.icon_x_color = icon_x_picker.color
	state.icon_o_color = icon_o_picker.color
	state.bg_icon_color = bg_icon_picker.color
	if template:
		template.apply_branding(state)
	_update_preview()
	_persist()


func _on_export_pressed() -> void:
	if _exporting or template == null or current_platform == null:
		return
	_exporting = true
	export_button.disabled = true
	open_folder_button.disabled = true
	status_label.text = "Exporting…"
	var pipeline := ExportPipeline.new()
	pipeline.progress.connect(func(msg: String): status_label.text = msg)
	pipeline.failed.connect(_on_export_failed)
	pipeline.finished.connect(_on_export_finished)
	await pipeline.export_platform(current_platform, template)


func _on_export_failed(message: String) -> void:
	_exporting = false
	export_button.disabled = false
	status_label.text = message


func _on_export_finished(output_dir: String) -> void:
	_exporting = false
	export_button.disabled = false
	open_folder_button.disabled = false
	_last_output_dir = output_dir
	var abs_path := ProjectSettings.globalize_path(output_dir)
	status_label.text = "Exported to %s" % abs_path


func _on_open_folder_pressed() -> void:
	var path := _last_output_dir
	if path.is_empty() and current_platform:
		path = current_platform.get_output_dir()
	var abs_path := ProjectSettings.globalize_path(path)
	_ensure_dir(abs_path)
	OS.shell_show_in_file_manager(abs_path, true)


func _ensure_dir(absolute: String) -> void:
	if not DirAccess.dir_exists_absolute(absolute):
		DirAccess.make_dir_recursive_absolute(absolute)
