tool
extends MarginContainer


func edit(fsm: VisualFiniteStateMachine):
	print_debug("---------------------------- editing fsm resource ---------------")
	if not is_inside_tree():
		yield(self, "tree_entered")
	$VisualFSMGraphEdit.edit(fsm as VisualFiniteStateMachine)

