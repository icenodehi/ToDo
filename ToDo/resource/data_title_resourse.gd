extends Resource
class_name DataTitle

@export var name_title: String = ""
@export var task_array: Array[DataTask] = []
@export var roll: bool = false

func to_dict() -> Dictionary:
	var task_data: Array = []
	for task in task_array:
		task_data.append(task.to_dict())
	return {"name": name_title, "roll": roll, "tasks": task_data}

func from_dict(data: Dictionary) -> void:
	name_title = data.get("name", "")
	roll = data.get("roll", false)
	task_array.clear()
	for task_data in data.get("tasks", []):
		var task = DataTask.new()
		task.from_dict(task_data)
		task_array.append(task)
