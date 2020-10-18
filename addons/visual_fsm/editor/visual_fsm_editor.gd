tool
extends MarginContainer


func edit(visual_fsm) -> void:
	if not is_inside_tree():
		yield(self, "tree_entered")
	$VisualFSMGraphEdit.edit(visual_fsm.finite_state_machine)

