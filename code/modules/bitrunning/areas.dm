/// Station side

/area/station/bitrunning
	name = "Bitrunning"

/area/station/bitrunning/den
	name = "Bitrunning Den"
	desc = "Office of bitrunners, houses their equipment."
	icon_state = "bit_den"

/area/station/bitrunning/receiving
	name = "Bitrunning Receiving"
	desc = "Receives shipments from the virtual domain."
	icon_state = "bit_receive"

/// VDOM

/area/virtual_domain
	name = "Virtual Domain"
	icon = 'icons/area/areas_station.dmi'
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	has_gravity = STANDARD_GRAVITY

/area/virtual_domain/bottom_left
	icon_state = "bit_gen_map"

// Using this to get turfs on the z-level then deleting contents
/area/virtual_domain/to_delete
	icon_state = "bit_gen_del"

/// Safehouse

/area/virtual_domain/safehouse
	name = "Virtual Domain Safehouse"
	icon_state = "bit_safe"
	requires_power = FALSE
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/virtual_domain/safehouse/bottom_left
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	icon_state = "bit_gen_safe"

/area/virtual_domain/safehouse/exit
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	icon_state = "bit_exit"

/area/virtual_domain/safehouse/send
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	icon_state = "bit_send"

/// Custom subtypes

/area/lavaland/surface/outdoors/virtual_domain
	name = "Virtual Domain Lava Ruins"
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA

/area/icemoon/underground/explored/virtual_domain
	name = "Virtual Domain Ice Ruins"
	icon_state = "bit_ice"
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA

/area/ruin/space/has_grav/powered/virtual_domain
	name = "Virtual Domain Space Ruins"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_space"
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA

/area/virtual_domain/powered
	name = "Virtual Domain Ruins"
	icon_state = "bit_ruin"
	requires_power = FALSE
