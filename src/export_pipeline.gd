class_name ExportPipeline
extends RefCounted

signal progress(message: String)
signal finished(output_dir: String)
signal failed(message: String)


func export_platform(platform: ExportPlatform, template: Node) -> void:
	if platform == null:
		failed.emit("No platform selected.")
		return
	if template == null or not template.has_method("get_viewport_for_asset"):
		failed.emit("Render template is not ready.")
		return

	var output_dir := platform.get_output_dir()
	var err := _ensure_dir(output_dir)
	if err != OK:
		failed.emit("Could not create output folder: %s" % output_dir)
		return

	var languages := platform.get_languages()
	for asset in platform.get_asset_defs():
		var asset_id: String = asset["id"]
		var vp: SubViewport = template.get_viewport_for_asset(asset_id)
		if vp == null:
			progress.emit("Skipping missing asset: %s" % asset_id)
			continue

		var base_name: String = asset_id
		var parent := vp.get_parent()
		if parent:
			base_name = parent.name.to_snake_case()

		if asset.get("localized", false) and languages.size() > 0:
			for i in languages.size():
				var lang_name: String = languages[i]
				progress.emit("Exporting %s / %s…" % [asset["label"], lang_name])
				if template.has_method("set_language_index"):
					template.set_language_index(i)
				await RenderingServer.frame_post_draw
				await RenderingServer.frame_post_draw
				var image: Image = vp.get_texture().get_image()
				if image:
					image.save_png("%s/%s_%s.png" % [output_dir, base_name, lang_name.to_lower()])
		else:
			progress.emit("Exporting %s…" % asset["label"])
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			var image2: Image = vp.get_texture().get_image()
			if image2:
				image2.save_png("%s/%s.png" % [output_dir, base_name])

	progress.emit("Export complete.")
	finished.emit(output_dir)


func _ensure_dir(path: String) -> Error:
	var absolute := ProjectSettings.globalize_path(path)
	if DirAccess.dir_exists_absolute(absolute):
		return OK
	return DirAccess.make_dir_recursive_absolute(absolute)
