extends Resource
class_name DataCardResource

@export var id: int = 0
@export var name_card: String = ""
@export var title_array: Array[DataTitle] = []

func to_dict() -> Dictionary:
	var card_data: Array = []
	for card in title_array:
		card_data.append(card.to_dict())
	return {"id": id, "name": name_card, "titles": card_data}

func from_dict(data: Dictionary) -> void:
	id =  int(data.get("id", 0))
	name_card = data.get("name", "")
	title_array.clear()
	for card_data in data.get("titles", []):
		var card = DataTitle.new()
		card.from_dict(card_data)
		title_array.append(card)
		
