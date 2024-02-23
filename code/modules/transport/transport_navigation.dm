/**
 * transport_controller landmarks. used to map specific destinations on the map.
 */
/obj/effect/landmark/transport/nav_beacon/tram
	name = "tram destination" //the tram buttons will mention this.
	icon_state = "tram"

	/// The ID of the tram we're linked to
	var/specific_transport_id = TRAMSTATION_LINE_1
	/// The ID of that particular destination
	var/platform_code = null
	/// Icons for the tgui console to list out for what is at this location
	var/list/tgui_icons = list()

/obj/effect/landmark/transport/nav_beacon/tram/Initialize(mapload)
	. = ..()
	LAZYADDASSOCLIST(SStransport.nav_beacons, specific_transport_id, src)

/obj/effect/landmark/transport/nav_beacon/tram/Destroy()
	LAZYREMOVEASSOC(SStransport.nav_beacons, specific_transport_id, src)
	return ..()

/obj/effect/landmark/transport/nav_beacon/tram/nav
	name = "tram nav beacon"
	invisibility = INVISIBILITY_MAXIMUM // nav aids can't be abstract since they stay with the tram

/**
 * transport_controller landmarks. used to map in specific_transport_id to trams and elevators. when the transport_controller encounters one on a tile
 * it sets its specific_transport_id to that landmark. allows you to have multiple trams and multiple objects linking to their specific tram
 */
/obj/effect/landmark/transport/transport_id
	name = "transport init landmark"
	icon_state = "lift_id"
	///what specific id we give to the tram we're placed on, should explicitely set this if its a subtype, or weird things might happen
	var/specific_transport_id

//tramstation

/obj/effect/landmark/transport/transport_id/tramstation/line_1
	specific_transport_id = TRAMSTATION_LINE_1

/obj/effect/landmark/transport/nav_beacon/tram/nav/tramstation/main
	name = TRAMSTATION_LINE_1
	specific_transport_id = TRAM_NAV_BEACONS
	dir = WEST

/obj/effect/landmark/transport/nav_beacon/tram/platform/tramstation/west
	name = "West Wing"
	platform_code = TRAMSTATION_WEST
	tgui_icons = list("Arrivals" = "plane-arrival", "Command" = "bullhorn", "Security" = "gavel")

/obj/effect/landmark/transport/nav_beacon/tram/platform/tramstation/central
	name = "Central Wing"
	platform_code = TRAMSTATION_CENTRAL
	tgui_icons = list("Service" = "cocktail", "Medical" = "plus", "Engineering" = "wrench")

/obj/effect/landmark/transport/nav_beacon/tram/platform/tramstation/east
	name = "East Wing"
	platform_code = TRAMSTATION_EAST
	tgui_icons = list("Departures" = "plane-departure", "Cargo" = "box", "Science" = "flask")

//birdshot

/obj/effect/landmark/transport/transport_id/birdshot/line_1
	specific_transport_id = BIRDSHOT_LINE_1

/obj/effect/landmark/transport/transport_id/birdshot/line_2
	specific_transport_id = BIRDSHOT_LINE_2

/obj/effect/landmark/transport/nav_beacon/tram/nav/birdshot/prison
	name = BIRDSHOT_LINE_1
	specific_transport_id = TRAM_NAV_BEACONS
	dir = NORTH

/obj/effect/landmark/transport/nav_beacon/tram/nav/birdshot/maint
	name = BIRDSHOT_LINE_2
	specific_transport_id = TRAM_NAV_BEACONS
	dir = WEST

/obj/effect/landmark/transport/nav_beacon/tram/platform/birdshot/sec_wing
	name = "Security Wing"
	specific_transport_id = BIRDSHOT_LINE_1
	platform_code = BIRDSHOT_SECURITY_WING
	tgui_icons = list("Security" = "gavel")

/obj/effect/landmark/transport/nav_beacon/tram/platform/birdshot/prison_wing
	name = "Prison Wing"
	specific_transport_id = BIRDSHOT_LINE_1
	platform_code = BIRDSHOT_PRISON_WING
	tgui_icons = list("Prison" = "box")

/obj/effect/landmark/transport/nav_beacon/tram/platform/birdshot/maint_left
	name = "Port Platform"
	specific_transport_id = BIRDSHOT_LINE_2
	platform_code = BIRDSHOT_MAINTENANCE_LEFT
	tgui_icons = list("Port Platform" = "plane-departure")

/obj/effect/landmark/transport/nav_beacon/tram/platform/birdshot/maint_right
	name = "Starboard Platform"
	specific_transport_id = BIRDSHOT_LINE_2
	platform_code = BRIDSHOT_MAINTENANCE_RIGHT
	tgui_icons = list("Starboard Platform" = "plane-arrival")

//map-agnostic landmarks

/obj/effect/landmark/transport/nav_beacon/tram/nav/immovable_rod
	name = "DESTINATION/NOT/FOUND"
	specific_transport_id = IMMOVABLE_ROD_DESTINATIONS
