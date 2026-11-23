extends ColorRect

var pages: Dictionary[Button,SettingsPage] = {}

@onready var tabs_container: VBoxContainer = %TabsContainer
@onready var pages_container: MarginContainer = %PagesContainer

func _ready() -> void:
	setup_tabs()

func setup_tabs() -> void:
	var group := ButtonGroup.new()
	for child in pages_container.get_children():
		var page := child as SettingsPage
		if page == null:
			continue
		if page.title_key.is_empty():
			push_warning("Page %s has no title_key" % page.name)
		var button := Button.new()
		button.text = page.title_key
		button.toggle_mode = true
		button.button_group = group
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		tabs_container.add_child(button)
		pages[button] = page
		page.visible = false
	group.pressed.connect(show_page)
		
func show_page(active_button: BaseButton) -> void:
	for button in pages:
		pages[button].visible = (button == active_button)

func open_menu() -> void:
	if pages.is_empty():
		return
	for page in pages.values():
		page.on_opened()
	var first_button: Button = pages.keys()[0]
	first_button.button_pressed = true
	show_page(first_button)
	visible = true

func _on_close_button_pressed() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
