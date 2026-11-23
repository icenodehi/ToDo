extends PanelContainer

signal card_info(id_card: int)
signal edit_menu(card)
signal delete_card(card)

var id: int = 0
var is_entered: bool = false

@onready var name_card_label: Label = %NameCardLabel
@onready var card_menu_button: MenuButton = %CardMenuButton

func _ready() -> void:
	var popup = card_menu_button.get_popup()
	popup.id_pressed.connect(_on_menu_pressed)

func _on_menu_pressed(id_card) -> void:
	if id_card == 0:
		delete_card.emit(self)
	elif id_card == 1:
		edit_menu.emit(self)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_info.emit(id)

func set_name_card(name_card: String) -> void:
	name_card_label.text = name_card
