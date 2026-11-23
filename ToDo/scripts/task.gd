extends VBoxContainer

signal delete_task(task)
signal data_changed

var data_task: DataTask
var is_entered: bool
var not_confirmed: bool

@onready var task_name_label: Label = %TaskNameLabel
@onready var task_check_box: CheckBox = $TaskContainer/TaskCheckBox
@onready var task_details_button: MenuButton = %TaskDetailsButton
@onready var edit_name_line_edit: LineEdit = %EditNameLineEdit

func _ready() -> void:
	var popup = task_details_button.get_popup()
	popup.id_pressed.connect(_on_menu_pressed)
	switch_view()

func test(task: DataTask) -> void:
	data_task = task
	task_name_label.text = data_task.text_task
	task_check_box.button_pressed = data_task.is_complete
	
func _on_task_check_box_toggled(toggled_on: bool) -> void:
	data_task.is_complete = toggled_on
	data_changed.emit()

func _on_menu_pressed(id: int) -> void:
	if id == 0:
		delete_task.emit(self)
	elif id == 1:
		title_editing()

func switch_view() -> void:
	task_name_label.visible = not is_entered
	edit_name_line_edit.visible = is_entered

func title_editing() -> void:
	edit_name_line_edit.text = data_task.text_task
	is_entered = true
	switch_view()
	edit_name_line_edit.grab_focus()
	edit_name_line_edit.select_all()

func input_complition(is_applay: bool) -> void:
	if not is_entered:
		return
	is_entered = false
	switch_view()
	if is_applay:
		var text_clear = edit_name_line_edit.text.strip_edges()
		if not text_clear.is_empty():
			task_name_label.text = text_clear
			data_task.text_task = text_clear
			data_changed.emit()
	if not_confirmed:
		if data_task.text_task.is_empty():
			delete_task.emit(self)
		else:
			not_confirmed = false

func new_task() -> void:
	not_confirmed = true
	title_editing()

func _on_edit_name_line_edit_text_submitted(_new_text: String) -> void:
	input_complition(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		input_complition(false)
		
func _on_edit_name_line_edit_focus_exited() -> void:
	input_complition(true)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		title_editing()
