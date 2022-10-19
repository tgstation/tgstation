/// verb_manager subsystem just for handling say's
VERB_MANAGER_SUBSYSTEM_DEF(speech_controller)
	name = "Speech Controller"
	wait = 1
	priority = FIRE_PRIORITY_SPEECH_CONTROLLER//has to be high priority, second in priority ONLY to SSinput
