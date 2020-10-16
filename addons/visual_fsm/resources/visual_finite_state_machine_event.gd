tool
class_name VisualFiniteStateMachineEvent
extends Resource

enum EventTypes {
	INPUT_ACTION,
	TIMER_TIMEOUT,
	SCRIPT
}

export(String) var event_name
export(String) var target_state

