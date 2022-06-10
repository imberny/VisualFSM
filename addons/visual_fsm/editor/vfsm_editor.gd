tool
extends MarginContainer


func edit(visual_fsm : VFSM) -> void:
	if not is_inside_tree():
		yield(self, "tree_entered")
	$VFSMGraphEdit.edit(visual_fsm)

