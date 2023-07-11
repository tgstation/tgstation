/area/station/bitminer_den
	name = "Bitmining Den"
	desc = "Office of bitminers, houses their equipment."
	icon_state = "bit_den"

/area/station/bitminer_den/receive
	name = "Bit Receiving"
	desc = "Receives shipments from the virtual domain."
	icon_state = "bit_receive"

/area/station/virtual_domain
	name = "Virtual Domain"
	area_flags = UNIQUE_AREA | FLORA_ALLOWED
	flags_1 = NONE
	has_gravity = STANDARD_GRAVITY
	static_lighting = TRUE

/area/station/virtual_domain/generated
	name = "Virtual Domain: Generated"
	icon_state = "bit_gen"

/area/station/virtual_domain/safehouse
	name = "Safe House"
	icon_state = "bit_safe"
	requires_power = FALSE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/virtual_domain/safehouse/exit
	name = "Spawn Point"
	icon_state = "bit_exit"

/area/station/virtual_domain/safehouse/send
	name = "Transfer Point"
	icon_state = "bit_send"
