// Icemoon Ruins

/area/ruin/powered/lizard_gas
	name = "\improper Lizard Gas Station"

/area/ruin/unpowered/buried_library
	name = "\improper Buried Library"

/area/ruin/powered/bathhouse
	name = "\improper Bath House"
	mood_bonus = 10
	mood_message = "I wish I could stay here forever."

/turf/closed/wall/bathhouse
	desc = "It's cool to the touch, pleasantly so."
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "block"
	base_icon_state = "block"
	smoothing_flags = NONE
	canSmoothWith = null
	rust_resistance = RUST_RESISTANCE_BASIC

/area/ruin/powered/mailroom
	name = "\improper Abandoned Post Office"

/area/ruin/comms_agent
	name = "\improper Listening Post"
	sound_environment = SOUND_ENVIRONMENT_CITY

/area/ruin/comms_agent/maint
	name = "\improper Listening Post Maintenance"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/ruin/plasma_facility/commons
	name = "\improper Abandoned Plasma Facility Commons"
	sound_environment = SOUND_AREA_STANDARD_STATION
	mood_bonus = -5
	mood_message = "I feel like I am being watched..."

/area/ruin/plasma_facility/operations
	name = "\improper Abandoned Plasma Facility Operations"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -5
	mood_message = "I feel like I am being watched..."

/area/ruin/bughabitat
	name = "\improper Entomology Outreach Center"
	mood_bonus = 1
	mood_message = "This place seems strangely serene."

/area/ruin/pizzeria
	name = "\improper Moffuchi's Pizzeria"

/area/ruin/pizzeria/kitchen
	name = "\improper Moffuchi's Kitchen"

/area/ruin/syndibiodome
	name = "\improper Syndicate Biodome"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	ambience_index = AMBIENCE_DANGER
	area_flags = NOTELEPORT
	mood_bonus = -10
	mood_message = "What the fuck."


/area/ruin/planetengi
	name = "\improper Engineering Outpost"

/area/ruin/huntinglodge
	name = "\improper Hunting Lodge"
	mood_bonus = -5
	mood_message = "Something feels off..."

/area/ruin/smoking_room/house
	name = "\improper Tobacco House"
	sound_environment = SOUND_ENVIRONMENT_CITY
	mood_bonus = -1
	mood_message = "Good lord, this place REEKS of cigarettes."

/area/ruin/smoking_room/room
	name = "\improper Smoking Room"
	sound_environment = SOUND_ENVIRONMENT_DIZZY
	mood_bonus = -8
	mood_message = "I can feel my lifespan shortening with every breath."

/area/ruin/powered/icemoon_phone_booth
	name = "\improper Phonebooth"

/area/ruin/powered/hermit
	name = "\improper Hermit's Cabin"

/area/ruin/syndielab
	name = "\improper Syndicate Lab"
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/ruin/outpost31
	name = "\improper Outpost 31"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -10
	mood_message = "Something very bad happened here..."

/area/ruin/outpost31/medical
	name = "\improper Outpost 31 Medical"

/area/ruin/outpost31/kitchendiningroom
	name = "\improper Outpost 31 Kitchen-Dining Room"

/area/ruin/outpost31/kennel
	name = "\improper Outpost 31 Kennel"

/area/ruin/outpost31/radiomap
	name = "\improper Outpost 31 Radio-Map Room"

/area/ruin/outpost31/lab
	name = "\improper Outpost 31 Lab"
	area_flags = NOTELEPORT //megafauna arena
	requires_power = FALSE

/area/ruin/outpost31/lootroom
	name = "\improper Outpost 31 Secondary Storage"
	area_flags = NOTELEPORT //megafauna loot room
	requires_power = FALSE

/area/ruin/outpost31/recroom
	name = "\improper Outpost 31 Rec Room"

/area/ruin/outpost31/crewquarters
	name = "\improper Outpost 31 Sleeping Quarters"

/area/ruin/outpost31/commander_room
	name = "\improper Outpost 31 Station Commander Office"
