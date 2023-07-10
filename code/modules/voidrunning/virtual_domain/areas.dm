/area/station/voidrunner_den
	name = "Voidrunner Den"
	desc = "Office of voidrunners, houses their equipment."
	icon_state = "void_den"

/area/station/voidrunner_den/receive
	name = "Void Receiving"
	desc = "Receives shipments from the virtual domain."
	icon_state = "void_receive"

/area/station/virtual_domain
	name = "Virtual Domain"
	area_flags = UNIQUE_AREA | FLORA_ALLOWED
	flags_1 = NONE
	has_gravity = STANDARD_GRAVITY
	static_lighting = TRUE

/area/station/virtual_domain/generated
	name = "Virtual Domain: Generated"
	icon_state = "void_gen"

/area/station/virtual_domain/outside
	name = "Virtual Domain: Outside"
	icon_state = "void_out"

/area/station/virtual_domain/safehouse
	name = "Safe House"
	icon_state = "void_safe"
	requires_power = FALSE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/virtual_domain/safehouse/exit
	name = "Spawn Point"
	icon_state = "void_exit"

/area/station/virtual_domain/safehouse/send
	name = "Transfer Point"
	icon_state = "void_send"
