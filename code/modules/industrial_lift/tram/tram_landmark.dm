GLOBAL_LIST_EMPTY(tram_landmarks)

/obj/effect/landmark/tram
	name = "tram destination" //the tram buttons will mention this.
	icon_state = "tram"

	///the id of the tram we're linked to.
	var/specific_lift_id = MAIN_STATION_TRAM
	/// The ID of that particular destination.
	var/platform_code = null
	/// Icons for the tgui console to list out for what is at this location
	var/list/tgui_icons = list()

/obj/effect/landmark/tram/Initialize(mapload)
	. = ..()
	LAZYADDASSOCLIST(GLOB.tram_landmarks, specific_lift_id, src)

/obj/effect/landmark/tram/Destroy()
	LAZYREMOVEASSOC(GLOB.tram_landmarks, specific_lift_id, src)
	return ..()

/obj/effect/landmark/tram/nav
	name = "tram nav beacon"
	invisibility = INVISIBILITY_MAXIMUM // nav aids can't be abstract since they stay with the tram

/**
 * lift_id landmarks. used to map in specific_lift_id to trams. when the trams lift_master encounters one on a trams tile
 * it sets its specific_lift_id to that landmark. allows you to have multiple trams and multiple controls linking to their specific tram
 */
/obj/effect/landmark/lift_id
	name = "lift id setter"
	icon_state = "lift_id"
	///what specific id we give to the tram we're placed on, should explicitly set this if its a subtype, or weird things might happen
	var/specific_lift_id = MAIN_STATION_TRAM

//tramstation

/obj/effect/landmark/tram/nav/tramstation/main
	name = MAIN_STATION_TRAM
	specific_lift_id = TRAM_NAV_BEACONS
	dir = WEST

/obj/effect/landmark/tram/platform/tramstation/west
	name = "West Wing"
	platform_code = TRAMSTATION_WEST
	tgui_icons = list("Arrivals" = "plane-arrival", "Command" = "bullhorn", "Security" = "gavel")

/obj/effect/landmark/tram/platform/tramstation/central
	name = "Central Wing"
	platform_code = TRAMSTATION_CENTRAL
	tgui_icons = list("Service" = "cocktail", "Medical" = "plus", "Engineering" = "wrench")

/obj/effect/landmark/tram/platform/tramstation/east
	name = "East Wing"
	platform_code = TRAMSTATION_EAST
	tgui_icons = list("Departures" = "plane-departure", "Cargo" = "box", "Science" = "flask")

//map-agnostic landmarks

/obj/effect/landmark/tram/nav/immovable_rod
	name = "DESTINATION/NOT/FOUND"
	specific_lift_id = IMMOVABLE_ROD_DESTINATIONS

/obj/effect/landmark/tram/nav/hilbert/research
	name = HILBERT_TRAM
	specific_lift_id = TRAM_NAV_BEACONS
	dir = WEST

//birdshot

/obj/effect/landmark/lift_id/birdshot/prison
	specific_lift_id = PRISON_TRAM

/obj/effect/landmark/lift_id/birdshot/maint
	specific_lift_id = MAINTENANCE_TRAM

/obj/effect/landmark/tram/nav/birdshot/prison
	name = PRISON_TRAM
	specific_lift_id = TRAM_NAV_BEACONS
	dir = NORTH

/obj/effect/landmark/tram/nav/birdshot/maint
	name = MAINTENANCE_TRAM
	specific_lift_id = TRAM_NAV_BEACONS
	dir = WEST

/obj/effect/landmark/tram/platform/birdshot/sec_wing
	name = "Security Wing"
	specific_lift_id = PRISON_TRAM
	platform_code = BIRDSHOT_SECURITY_WING
	tgui_icons = list("Security" = "gavel")

/obj/effect/landmark/tram/platform/birdshot/prison_wing
	name = "Prison Wing"
	specific_lift_id = PRISON_TRAM
	platform_code = BIRDSHOT_PRISON_WING
	tgui_icons = list("Prison" = "box")

/obj/effect/landmark/tram/platform/birdshot/maint_left
	name = "Port Platform"
	specific_lift_id = MAINTENANCE_TRAM
	platform_code = BIRDSHOT_MAINTENANCE_LEFT
	tgui_icons = list("Port Platform" = "plane-departure")

/obj/effect/landmark/tram/platform/birdshot/maint_right
	name = "Starboard Platform"
	specific_lift_id = MAINTENANCE_TRAM
	platform_code = BRIDSHOT_MAINTENANCE_RIGHT
	tgui_icons = list("Starboard Platform" = "plane-arrival")
