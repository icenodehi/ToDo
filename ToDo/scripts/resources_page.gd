extends SettingsPage

const SELECTION: Array[Dictionary] = [
	{
		"title_key": "UI_SELECTION_CONTACT",
		"items": [
			{"text": "UI_COPY_EMAIL", "action": "copy", "value": "icenode.hi@gmail.com"},
		],
	},
	{
		"title_key": "UI_SELECTION_SUPPORT",
		"items": [
			{"text": "Boosty", "action": "link", "value": "https://boosty.to/icenode_hi"},
		],
	},
	{
		"title_key": "UI_SELECTION_RESOURCES",
		"items": [
			{"text": "UI_GITHUB", "action": "link", "value": "https://github.com/icenodehi/ToDo"},
		],
	},
]

@onready var version_label: Label = %VersionLabel
@onready var content: VBoxContainer = %Content

func _ready() -> void:
	build_content()
	update_version_label()

func build_content() -> void:
	for selection in SELECTION:
		var header := Label.new()
		content.add_child(header)
		header.text = selection["title_key"]
		header.modulate = Color(1,1,1,0.6)
		for item in selection["items"]:
			var button := Button.new()
			content.add_child(button)
			button.text = item["text"]
			if item["action"] == "copy":
				button.tooltip_text = item["value"]
			button.pressed.connect(_on_item_pressed.bind(button, item))
		content.add_child(HSeparator.new())

func _on_item_pressed(button: Button, item: Dictionary) -> void:
	match item["action"]:
		"link":
			open_link(item["value"])
		"copy":
			DisplayServer.clipboard_set(item["value"])
			show_copied(button, item["text"])

func show_copied(button: Button, original_text: String) -> void:
	button.text = "UI_COPIED"
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(button):
		button.text = original_text

func open_link(url: String) -> void:
	var err := OS.shell_open(url)
	if err != OK:
		push_error("Can't open link: %s" % error_string(err))

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		update_version_label()

func update_version_label() -> void:
	var version: String = ProjectSettings.get_setting("application/config/version", "?")
	var templete: String = tr("UI_VERSION")
	if "%s" in templete:
		version_label.text = templete % version
	else:
		version_label.text = "%s %s" % [templete, version]
