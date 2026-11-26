extends PanelContainer

const limit_card: int = 10
const SAVE_PATH: String = "user://Eisbrise.json"
const TEMP_PATH: String = "user://Eisbrise.tmp"
const BACKUP_PATH: String = "user://Eisbrise.corrupted.json"
const SAVE_DALAY: float = 1.0
const ICON_FULLSCRENE: Texture2D = preload("res://maximize_icon.png")
const ICON_WINDOWED: Texture2D = preload("res://restore_icon.png")

var title_scene = preload("res://ToDo/scenes/title.tscn")
var card_scene = preload("res://ToDo/scenes/card.tscn")

var counter_created_cards: int = 1
var id_card: int
var edit_card: PanelContainer = null
var save_timer: Timer

var cards_storage: Dictionary[int, DataCardResource] = {}

@onready var list_cards: VBoxContainer = %ListCards
@onready var body_container: HBoxContainer = %BodyContainer
@onready var name_card_label: LineEdit = %NameCardLabel
@onready var list_title_container: VBoxContainer = %ListTitleContainer
@onready var welcom_label: Label = %WelcomLabel
@onready var scroll_card_data_container: ScrollContainer = %ScrollCardDataContainer
@onready var counter_card_label: Label = %CounterCardLabel
@onready var create_card_button: Button = %CreateCardButton
@onready var create_project_menu: ColorRect = %CreateProjectMenu
@onready var settings_menu: ColorRect = %SettingsMenu
@onready var full_screne_button: Button = %FullScreneButton

func _ready() -> void:
	save_timer = Timer.new()
	save_timer.one_shot = true
	save_timer.wait_time = SAVE_DALAY
	save_timer.timeout.connect(save_project)
	add_child(save_timer)
	
	body_container.create_card.connect(_open_menu_create)
	body_container.create_title.connect(_on_create_title)
	create_project_menu.create_project.connect(_on_create_project)
	
	load_project()
	hideShowWorkPanel(id_card)
	update_counter_card()

func request_save() -> void:
	save_timer.start()

func update_counter_card() -> void:
	counter_card_label.text = "%d/%d" % [cards_storage.size(),limit_card]
	create_card_button.disabled = cards_storage.size() >= limit_card

func _on_create_title() -> void:
	var current_card: DataCardResource = cards_storage.get(id_card)
	var data_tile: DataTitle = DataTitle.new()
	current_card.title_array.append(data_tile)
	var title = add_title_scene(data_tile)
	title.new_title()

func add_title_scene(data_tile) -> Control:
	var title = title_scene.instantiate()
	list_title_container.add_child(title)
	title.data_titles(data_tile)
	title.delete_title.connect(_on_delete_title)
	title.data_changed.connect(request_save)
	return title
	
func _on_delete_title(title) -> void:
	var current_card: DataCardResource = cards_storage.get(id_card)
	current_card.title_array.erase(title.data_title)
	title.queue_free()
	request_save()

func test() -> void:
	var current_card: DataCardResource = cards_storage.get(id_card)
	for i in current_card.title_array:
		add_title_scene(i)
	
func hideShowWorkPanel(id: int) -> void:
	if id == 0:
		welcom_label.visible = true
		scroll_card_data_container.visible = false
	else:
		welcom_label.visible = false
		scroll_card_data_container.visible = true

func check_list_title() -> void:
	for check_list in list_title_container.get_children():
		check_list.queue_free()
	test()

func _open_menu_create() -> void:
	_on_edit_menu(null)

func _on_create_project(name_project: String) -> void:
	if edit_card != null:
		var current_card: DataCardResource = cards_storage.get(edit_card.id)
		current_card.name_card = name_project
		edit_card.set_name_card(current_card.name_card)
		if edit_card.id == id_card:
			name_card_label.text = current_card.name_card
		edit_card = null
		request_save()
		return
		
	if cards_storage.size() >= limit_card:
		return
	var data_card: DataCardResource = DataCardResource.new()
	data_card.id = counter_created_cards
	data_card.name_card = name_project	
	cards_storage[data_card.id] = data_card
	counter_created_cards += 1
	add_card_scene(data_card)
	update_counter_card()
	request_save()
	
func _on_edit_menu(card) -> void:
	edit_card = card
	var text = ""
	if card != null:
		text = cards_storage[card.id].name_card
	create_project_menu.open_menu_edit(text)

func _on_delete_card(card) -> void:
	cards_storage.erase(card.id)
	if card.id == id_card:
		id_card = 0
		hideShowWorkPanel(id_card)
	card.queue_free()
	update_counter_card()
	request_save()
	
func _on_info_card(id: int) -> void:
	if not cards_storage.has(id):
		return
	var get_cards_storage: DataCardResource = cards_storage.get(id)
	name_card_label.text = get_cards_storage.name_card
	id_card = id
	hideShowWorkPanel(id_card)
	check_list_title()

func _on_wrap_button_pressed() -> void:
	get_window().mode = Window.MODE_MINIMIZED

func _on_full_screne_button_pressed() -> void:
	var window := get_window()
	if window.mode == Window.MODE_FULLSCREEN:
		window.mode = Window.MODE_WINDOWED
	else:
		window.mode = Window.MODE_FULLSCREEN
	update_window_button()

func update_window_button() -> void:
	var is_fullscreen := get_window().mode == Window.MODE_FULLSCREEN
	full_screne_button.icon = ICON_WINDOWED if is_fullscreen else ICON_FULLSCRENE
	full_screne_button.tooltip_text = "UI_WINDOWED" if is_fullscreen else "UI_FULLSCRENE"

func _on_close_button_pressed() -> void:
	save_project()
	get_tree().quit()

func save_project() -> void:
	save_timer.stop()
	var project_data: Array = []
	for card in cards_storage.values():
		project_data.append(card.to_dict())
	var data := {"version": 1, "next_card_id": counter_created_cards, "project_data": project_data}
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Save failed: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	
	var err := DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH)
	if err != OK:
		push_error("Raname failed: %s" % error_string(err))

func load_project() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Load failed: %s" % error_string(FileAccess.get_open_error()))
		return
	var text := file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Save fale is corrupted")
		DirAccess.copy_absolute(SAVE_PATH, BACKUP_PATH)
		return
	
	counter_created_cards = int(data.get("next_card_id", 1))
	for card_dict in data.get("project_data", []):
		if typeof(card_dict) != TYPE_DICTIONARY:
			continue
		var data_card := DataCardResource.new()
		data_card.from_dict(card_dict)
		cards_storage[data_card.id] = data_card
		counter_created_cards = maxi(counter_created_cards, data_card.id + 1)
		add_card_scene(data_card)

func add_card_scene(data_card: DataCardResource) -> void:
	var card = card_scene.instantiate()
	list_cards.add_child(card)
	card.id = data_card.id
	card.set_name_card(data_card.name_card)
	card.card_info.connect(_on_info_card)
	card.delete_card.connect(_on_delete_card)
	card.edit_menu.connect(_on_edit_menu)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_project()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("save"):
		save_project()

func _on_settings_button_pressed() -> void:
	settings_menu.open_menu()
