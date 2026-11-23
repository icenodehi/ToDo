extends HBoxContainer

signal create_card
signal create_title

func _on_create_card_button_pressed() -> void:
	create_card.emit()

func _on_create_title_button_pressed() -> void:
	create_title.emit()
