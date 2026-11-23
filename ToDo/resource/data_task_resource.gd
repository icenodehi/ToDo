extends Resource
class_name DataTask

@export var text_task: String = ""
@export var is_complete: bool = false

func to_dict() -> Dictionary:
	return {"text_task": text_task, "is_complete": is_complete}

func from_dict(data: Dictionary) -> void:
	text_task = data.get("text_task", "")
	is_complete = data.get("is_complete", false)
