SUBSYSTEM_DEF(security_level)
	name = "Security Level"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SECURITY_LEVEL
	var/security_level = SEC_LEVEL_GREEN

/datum/controller/subsystem/security_level/Initialize()
	set_security_level(security_level)
	return ..()
