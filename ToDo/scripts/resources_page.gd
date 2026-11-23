extends SettingsPage

const CONTACT_URL: String = ""
const SUPPORT_URL: String = ""

func _on_contact_button_pressed() -> void:
	open_link(CONTACT_URL)

func _on_donate_button_pressed() -> void:
	open_link(SUPPORT_URL)

func open_link(url: String) -> void:
	var err := OS.shell_open(url)
	if err != OK:
		push_error("Can't open link: %s" % error_string(err))
