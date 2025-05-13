/// Station side

/area/station/cargo/bitrunning
	name = "Bitrunning"

/area/station/cargo/bitrunning/den
	name = "Bitrunning Den"
	desc = "Office of bitrunners, houses their equipment."
	icon_state = "bit_den"

/area/station/security/torment_nexus
	name = "Torment Nexus"
	desc = "Holding room for the Torment Nexus equipment."
	icon_state = "bit_den"

/// VDOM

/area/virtual_domain
	name = "Virtual Domain Ruins"
	icon_state = "bit_ruin"
	icon = 'icons/area/areas_station.dmi'
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING | BLOCK_SUICIDE
	default_gravity = STANDARD_GRAVITY
	requires_power = FALSE

/area/virtual_domain/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/// Safehouse

/area/virtual_domain/safehouse
	name = "Virtual Domain Safehouse"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | VIRTUAL_SAFE_AREA | UNLIMITED_FISHING | BLOCK_SUICIDE
	icon_state = "bit_safe"
	requires_power = FALSE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/// Custom subtypes

/area/lavaland/surface/outdoors/virtual_domain
	name = "Virtual Domain Lava Ruins"
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING | BLOCK_SUICIDE

/area/icemoon/underground/explored/virtual_domain
	name = "Virtual Domain Ice Ruins"
	icon_state = "bit_ice"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING | BLOCK_SUICIDE

/area/ruin/space/virtual_domain
	name = "Virtual Domain Unexplored Location"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING | BLOCK_SUICIDE

/area/space/virtual_domain
	name = "Virtual Domain Space"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_space"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING | BLOCK_SUICIDE

///Areas that virtual entities should not be in

/area/virtual_domain/protected_space
	name = "Virtual Domain Safe Zone"
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | VIRTUAL_SAFE_AREA | UNLIMITED_FISHING | BLOCK_SUICIDE
	icon_state = "bit_safe"

/area/virtual_domain/protected_space/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255
