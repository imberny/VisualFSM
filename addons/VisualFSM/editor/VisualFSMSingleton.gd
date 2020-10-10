extends Node


signal fsm_changed(fsm)


var FSM: VisualFiniteStateMachine setget _set_fsm


func _set_fsm(fsm_: VisualFiniteStateMachine):
	FSM = fsm_
	print("fsm_changed signal emitted")
	emit_signal("fsm_changed", fsm_)
	for connection in get_signal_connection_list("fsm_changed"):
		print("Connection to fsm_changed:" + str(connection))
	
