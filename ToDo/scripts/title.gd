extends VBoxContainer

signal delete_title(title)
signal data_changed

var is_entered: bool
var task_scene = preload("res://ToDo/scenes/task.tscn")
var data_title: DataTitle
var not_confirmed: bool

@onready var name_title_lable: Label = %NameTitleLable
@onready var tasks_container: VBoxContainer = %TasksContainer
@onready var title_details_button: MenuButton = %TitleDetailsButton
@onready var edit_name_line_edit: LineEdit = %EditNameLineEdit
@onready var h_separator: HSeparator = %HSeparator
@onready var add_task_container: HBoxContainer = %AddTaskContainer
@onready var show_hide_details_button: Button = %ShowHideDetailsButton

func _ready() -> void:
	var popup = title_details_button.get_popup()
	popup.id_pressed.connect(_on_menu_pressed)
	switch_view()

func data_titles(data: DataTitle) -> void:
	data_title = data
	show_hide_details_button.button_pressed = data_title.roll
	applay_visible(data_title.roll)
	name_title_lable.text = data_title.name_title
	for i in data_title.task_array:
		create_node_task(i)

func _on_add_task_button_pressed() -> void:
	var data_task: DataTask = DataTask.new()
	data_title.task_array.append(data_task)
	var task = create_node_task(data_task)
	task.new_task()

func create_node_task(data_tesk) -> Control:
	var task = task_scene.instantiate()
	tasks_container.add_child(task)
	task.test(data_tesk)
	task.delete_task.connect(_on_delete_task)
	task.data_changed.connect(data_changed.emit)
	return task

func _on_delete_task(task) -> void:
	data_title.task_array.erase(task.data_task)
	task.queue_free()
	data_changed.emit()

func switch_view() -> void:
	name_title_lable.visible = not is_entered
	edit_name_line_edit.visible = is_entered

func title_editing() -> void:
	edit_name_line_edit.text = data_title.name_title
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
			name_title_lable.text = text_clear
			data_title.name_title = text_clear
			data_changed.emit()
	if not_confirmed:
		if data_title.name_title.is_empty():
			delete_title.emit(self)
		else:
			not_confirmed = false

func new_title() -> void:
	not_confirmed = true
	title_editing()

func _on_menu_pressed(id) -> void:
	if id == 0:
		delete_title.emit(self)
	elif id == 1:
		title_editing()

func _on_edit_name_line_edit_text_submitted(_new_text: String) -> void:
	input_complition(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		input_complition(false)
		
func _on_edit_name_line_edit_focus_exited() -> void:
	input_complition(true)

func _on_title_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		title_editing()

func applay_visible(turn: bool) -> void:
	add_task_container.visible = not turn
	h_separator.visible = not turn
	tasks_container.visible = not turn
	show_hide_details_button.text = "▸" if turn else "▾"

func _on_show_hide_details_button_toggled(toggled_on: bool) -> void:
	data_title.roll = toggled_on
	applay_visible(toggled_on)
	data_changed.emit()
