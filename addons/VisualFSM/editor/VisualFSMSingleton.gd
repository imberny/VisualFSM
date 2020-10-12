extends Node

signal fsm_changed(fsm)

var _finite_state_machine: VisualFiniteStateMachine


func set_fsm(fsm: VisualFiniteStateMachine):
	_finite_state_machine = fsm
	print("fsm_changed signal emitted")
	emit_signal("fsm_changed", _finite_state_machine)
	for connection in get_signal_connection_list("fsm_changed"):
		print("Connection to fsm_changed:" + str(connection))
