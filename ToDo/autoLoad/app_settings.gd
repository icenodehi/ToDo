extends Node

signal delete_completed_changed(value: bool)

const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_LANGUAGE: String = "en"
const LANGUAGE_NAMES: Dictionary = {"ru": "русский", "en": "English"}
const SUPPORTED_LANGUAGES: Array[String] = ["ru", "en"]

var language: String = DEFAULT_LANGUAGE
var delete_completed: bool = false

func _ready() -> void:
	load_settings()
	apply_language()

func load_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	language = str(config.get_value("general", "language", detect_system_language()))
	delete_completed = bool(config.get_value("general", "delete_completed", false))
	if language not in SUPPORTED_LANGUAGES:
		language = DEFAULT_LANGUAGE

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("general", "languare", language)
	config.set_value("general", "delete_completed", delete_completed)
	var err := config.save(SETTINGS_PATH)
	if err != OK:
		push_error("settings save failed: %s" % error_string(err))

func set_delete_completed(value: bool) -> void:
	if value == delete_completed:
		return
	delete_completed = value
	delete_completed_changed.emit(value)
	save_settings()

func detect_system_language() -> String:
	var system_language := OS.get_locale_language()
	if system_language in SUPPORTED_LANGUAGES:
		return system_language
	return DEFAULT_LANGUAGE
	
func apply_language() -> void:
	TranslationServer.set_locale(language)
	
func set_language(code: String) -> void:
	if code not in SUPPORTED_LANGUAGES or code == language:
		return
	language = code
	apply_language()
	save_settings()
