extends Resource
class_name DataTitle

enum CompleteMode { INHERIT, STRIKE, DELETE}

@export var name_title: String = ""
@export var task_array: Array[DataTask] = []
@export var roll: bool = false
@export var complete_mode: CompleteMode = CompleteMode.INHERIT

func should_delete(global_delete: bool) -> bool:
	match complete_mode:
		CompleteMode.STRIKE:
			return false
		CompleteMode.DELETE:
			return true
	return global_delete

func to_dict() -> Dictionary:
	var task_data: Array = []
	for task in task_array:
		task_data.append(task.to_dict())
	return {"name": name_title, "roll": roll, "complete_mode": complete_mode, "tasks": task_data}

func from_dict(data: Dictionary) -> void:
	name_title = data.get("name", "")
	roll = data.get("roll", false)
	var mode := int(data.get("complete_mode", CompleteMode.INHERIT))
	@warning_ignore("int_as_enum_without_cast")
	complete_mode = mode if mode in CompleteMode.values() else CompleteMode.INHERIT
	task_array.clear()
	for task_data in data.get("tasks", []):
		var task = DataTask.new()
		task.from_dict(task_data)
		task_array.append(task)
