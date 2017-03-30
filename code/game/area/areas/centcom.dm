
// CENTCOM

/area/centcom
	name = "Centcom"
	icon_state = "centcom"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0
	has_gravity = 1
	noteleport = 1
	blob_allowed = 0 //Should go without saying, no blobs should take over centcom as a win condition.
	flags = NONE

/area/centcom/control
	name = "Centcom Docks"

/area/centcom/evac
	name = "Centcom Recovery Ship"

/area/centcom/supply
	name = "Centcom Supply Shuttle Dock"

/area/centcom/ferry
	name = "Centcom Transport Shuttle Dock"

/area/centcom/prison
	name = "Admin Prison"

/area/centcom/holding
	name = "Holding Facility"

//THUNDERDOME

/area/tdome
	name = "Thunderdome"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0
	has_gravity = 1

/area/tdome/arena
	name = "Thunderdome Arena"
	icon_state = "thunder"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/tdome/arena_source
	name = "Thunderdome Arena Template"
	icon_state = "thunder"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "green"

/area/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"


//ENEMY

//Wizard
/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0
	has_gravity = 1
	noteleport = 1

//Abductors
/area/abductor_ship
	name = "Abductor Ship"
	icon_state = "yellow"
	requires_power = 0
	noteleport = 1
	has_gravity = 1

//Syndicates
/area/syndicate_mothership
	name = "Syndicate Mothership"
	icon_state = "syndie-ship"
	requires_power = 0
	has_gravity = 1
	noteleport = 1
	blob_allowed = 0 //Not... entirely sure this will ever come up... but if the bus makes blobs AND ops, it shouldn't aim for the ops to win.

/area/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"



//CAPTURE THE FLAG

/area/ctf
	name = "Capture the Flag"
	icon_state = "yellow"
	requires_power = 0
	has_gravity = 1
	flags = NO_DEATHRATTLE

/area/ctf/control_room
	name = "Control Room A"

/area/ctf/control_room2
	name = "Control Room B"

/area/ctf/central
	name = "Central"

/area/ctf/main_hall
	name = "Main Hall A"

/area/ctf/main_hall2
	name = "Main Hall B"

/area/ctf/corridor
	name = "Corridor A"

/area/ctf/corridor2
	name = "Corridor B"

/area/ctf/flag_room
	name = "Flag Room A"

/area/ctf/flag_room2
	name = "Flag Room B"
