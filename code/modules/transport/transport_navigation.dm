/**
 * transport_controller landmarks. used to map specific destinations on the map.
 */
/obj/effect/landmark/transport/nav_beacon/tram
	name = "tram destination" //the tram buttons will mention this.
	icon_state = "tram"
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"
	/// the looping sound effect that is played while moving
	var/datum/looping_sound/tram/tram_loop
	/// What sound do we play when we arrive at this station?
	var/arrival_sound = 'sound/machines/tram/other_line_processed.ogg'
	/// The ID of the tram we're linked to
	var/specific_transport_id = TRAMSTATION_LINE_1
	/// The ID of that particular destination
	var/platform_code = null
	/// Icons for the tgui console to list out for what is at this location
	var/list/tgui_icons = list()

/obj/effect/landmark/transport/nav_beacon/tram/Initialize(mapload)
	. = ..()
	tram_loop = new(src)
	LAZYADDASSOCLIST(SStransport.nav_beacons, specific_transport_id, src)

/obj/effect/landmark/transport/nav_beacon/tram/Destroy()
	LAZYREMOVEASSOC(SStransport.nav_beacons, specific_transport_id, src)
	QDEL_NULL(tram_loop)
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
	name = "Arrivals Station"
	platform_code = TRAMSTATION_WEST
	tgui_icons = list("Arrivals" = "plane-arrival", "Command" = "bullhorn", "Security" = "gavel")
	arrival_sound = 'sound/machines/tram/arrivals_line_processed.ogg'

/obj/effect/landmark/transport/nav_beacon/tram/platform/tramstation/central
	name = "Medical Station"
	platform_code = TRAMSTATION_CENTRAL
	tgui_icons = list("Service" = "cocktail", "Medical" = "plus", "Engineering" = "wrench")
	arrival_sound = 'sound/machines/tram/medical_line_processed.ogg'

/obj/effect/landmark/transport/nav_beacon/tram/platform/tramstation/east
	name = "Escape Station"
	platform_code = TRAMSTATION_EAST
	tgui_icons = list("Departures" = "plane-departure", "Cargo" = "box", "Science" = "flask")
	arrival_sound = 'sound/machines/tram/escape_line_processed.ogg'

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
	name = "Security Station"
	specific_transport_id = BIRDSHOT_LINE_1
	platform_code = BIRDSHOT_SECURITY_WING
	tgui_icons = list("Security" = "gavel")
	arrival_sound = 'sound/machines/tram/medical_line_processed.ogg'

/obj/effect/landmark/transport/nav_beacon/tram/platform/birdshot/prison_wing
	name = "Prison Station"
	specific_transport_id = BIRDSHOT_LINE_1
	platform_code = BIRDSHOT_PRISON_WING
	tgui_icons = list("Prison" = "box")
	arrival_sound = 'sound/machines/tram/other_line_processed.ogg'

/obj/effect/landmark/transport/nav_beacon/tram/platform/birdshot/maint_left
	name = "Escape Station"
	specific_transport_id = BIRDSHOT_LINE_2
	platform_code = BIRDSHOT_MAINTENANCE_LEFT
	tgui_icons = list("Port Platform" = "plane-departure")
	arrival_sound = 'sound/machines/tram/escape_line_processed.ogg'

/obj/effect/landmark/transport/nav_beacon/tram/platform/birdshot/maint_right
	name = "Arrivals Station"
	specific_transport_id = BIRDSHOT_LINE_2
	platform_code = BRIDSHOT_MAINTENANCE_RIGHT
	tgui_icons = list("Starboard Platform" = "plane-arrival")
	arrival_sound = 'sound/machines/tram/arrivals_line_processed.ogg'

//map-agnostic landmarks

/obj/effect/landmark/transport/nav_beacon/tram/nav/immovable_rod
	name = "DESTINATION/NOT/FOUND"
	specific_transport_id = IMMOVABLE_ROD_DESTINATIONS
