class_name ImageLoader
extends RefCounted


static func load_texture(path: String) -> Texture2D:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var ext := path.get_extension().to_lower()
	var image := Image.new()
	var err: Error
	if ext == "svg":
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return null
		err = image.load_svg_from_string(file.get_as_text(), 4.0)
	else:
		err = image.load(path)
	if err != OK:
		push_warning("Failed to load image: %s (%s)" % [path, error_string(err)])
		return null
	return ImageTexture.create_from_image(image)
