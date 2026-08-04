class_name PlatformRegistry
extends RefCounted

static var _platforms: Array[ExportPlatform] = []
static var _initialized: bool = false


static func ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	register(SteamPlatform.new())


static func register(platform: ExportPlatform) -> void:
	for existing in _platforms:
		if existing.get_id() == platform.get_id():
			return
	_platforms.append(platform)


static func all() -> Array[ExportPlatform]:
	ensure_initialized()
	return _platforms


static func get_by_id(id: String) -> ExportPlatform:
	ensure_initialized()
	for platform in _platforms:
		if platform.get_id() == id:
			return platform
	return null


static func default_platform() -> ExportPlatform:
	ensure_initialized()
	if _platforms.is_empty():
		return null
	return _platforms[0]
