extends ColorRect

signal create_project(name_project: String)

@onready var name_project_line_edit: LineEdit = %NameProjectLineEdit
@onready var create_project_button: Button = %CreateProjectButton

func _ready() -> void:
	create_project_button.disabled = name_project_line_edit.text.strip_edges().is_empty()
		
func _on_create_project_button_pressed() -> void:
	try_create()

func _on_cancel_button_pressed() -> void:
	visible = false

func _on_name_project_line_edit_text_changed(new_text: String) -> void:
	create_project_button.disabled = new_text.strip_edges().is_empty()

func _on_name_project_line_edit_text_submitted(_new_text: String) -> void:
	try_create()

func try_create() -> void:
	if name_project_line_edit.text.strip_edges().is_empty():
		return
	create_project.emit(name_project_line_edit.text.strip_edges())
	visible = false

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false

func open_menu_edit(new_text: String) -> void:
	name_project_line_edit.text = new_text
	create_project_button.disabled = name_project_line_edit.text.strip_edges().is_empty()
	visible = true
	name_project_line_edit.grab_focus()
	name_project_line_edit.select_all()
