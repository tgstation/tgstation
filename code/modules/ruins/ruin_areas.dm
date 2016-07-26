//Parent types

/area/ruin/
	name = "\improper Unexplored Location"
	icon_state = "away"
	has_gravity = 1


/area/ruin/unpowered
	always_unpowered = 0

/area/ruin/unpowered/no_grav
	has_gravity = 0

/area/ruin/powered
	requires_power = 0




//Areas

/area/ruin/unpowered/no_grav/way_home
	name = "\improper Salvation"
	icon_state = "away"

/area/ruin/powered/snow_biodome

/area/ruin/powered/golem_ship
	name = "Free Golem Ship"

// Ruins of "onehalf" ship
/area/ruin/onehalf/hallway
	name = "Hallway"
	icon_state = "hallC"


/area/ruin/onehalf/drone_bay
	name = "Mining Drone Bay"
	icon_state = "engine"

/area/ruin/onehalf/dorms_med
	name = "Crew Quarters"
	icon_state = "Sleep"

/area/ruin/onehalf/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/ruin/powered/dinner_for_two
	name = "Dinner for Two"

/area/ruin/powered/authorship
	name = "Authorship"

/area/ruin/powered/aesthetic
	name = "Aesthetic"
	ambientsounds = list('sound/ambience/ambivapor1.ogg')

/area/ruin/hotel
	name = "Hotel"

/area/ruin/hotel/guestroom
	name = "Hotel Guest Room"
	icon_state = "Sleep"

/area/ruin/hotel/security
	name = "Hotel Security Post"
	icon_state = "security"

/area/ruin/hotel/pool
	name = "Hotel Pool Room"
	icon_state = "fitness"

/area/ruin/hotel/bar
	name = "Hotel Bar"
	icon_state = "cafeteria"

/area/ruin/hotel/power
	name = "Hotel Power Room"
	icon_state = "engine_smes"

/area/ruin/hotel/custodial
	name = "Hotel Custodial Closet"
	icon_state = "janitor"

/area/ruin/hotel/shuttle
	name = "Hotel Shuttle"
	icon_state = "shuttle"
	requires_power = 0

/area/ruin/hotel/dock
	name = "Hotel Shuttle Dock"
	icon_state = "start"

/area/ruin/hotel/workroom
	name = "Hotel Staff Room"
	icon_state = "crew_quarters"