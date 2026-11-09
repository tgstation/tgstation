/// Plans background controllers that are active when unwatched but not critical
AI_CONTROLLER_SUBSYSTEM_DEF(low_priority_ai_controllers)
	name = "AI Controller Ticker (Low)"
	ss_flags = parent_type::ss_flags | SS_BACKGROUND | SS_NO_INIT
	planning_status = AI_STATUS_ON_LOW
	priority = FIRE_PRIORITY_NPC_LOW
