extends SettingsPage

@onready var language_option_button: OptionButton = %LanguageOptionButton

func _ready() -> void:
	for code in AppSettings.SUPPORTED_LANGUAGES:
		language_option_button.add_item(AppSettings.LANGUAGE_NAMES[code])
		language_option_button.set_item_metadata(language_option_button.item_count - 1, code)

func on_opened() -> void:
	for i in language_option_button.item_count:
		if language_option_button.get_item_metadata(i) == AppSettings.language:
			language_option_button.select(i)

func _on_language_option_button_item_selected(index: int) -> void:
	AppSettings.set_language(language_option_button.get_item_metadata(index))
