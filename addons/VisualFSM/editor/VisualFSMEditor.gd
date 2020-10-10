tool
extends MarginContainer


func _ready():
	$"/root/VisualFSMSingleton".connect("fsm_changed", self, "_on_fsm_changed")


func _on_fsm_changed(fsm) -> void:
	print("---------------------------- opening fsm resource ---------------")
	edit(fsm)


func edit(fsm: VisualFiniteStateMachine):
	if not is_inside_tree():
		yield(self, "tree_entered")
	$VisualFSMGraphEdit.edit(fsm as VisualFiniteStateMachine)
	
