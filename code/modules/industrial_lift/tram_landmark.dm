GLOBAL_LIST_EMPTY(tram_landmarks)

/obj/effect/landmark/tram
	name = "tram destination" //the tram buttons will mention this.
	icon_state = "tram"
	/// The ID of that particular destination.
	var/destination_id
	/// Icons for the tgui console to list out for what is at this location
	var/list/tgui_icons = list()

/obj/effect/landmark/tram/Initialize(mapload)
	. = ..()
	GLOB.tram_landmarks += src

/obj/effect/landmark/tram/Destroy()
	GLOB.tram_landmarks -= src
	return ..()


/obj/effect/landmark/tram/left_part
	name = "West Wing"
	destination_id = "left_part"
	tgui_icons = list("Arrivals" = "plane-arrival", "Command" = "bullhorn", "Security" = "gavel")

/obj/effect/landmark/tram/middle_part
	name = "Central Wing"
	destination_id = "middle_part"
	tgui_icons = list("Service" = "cocktail", "Medical" = "plus", "Engineering" = "wrench")

/obj/effect/landmark/tram/right_part
	name = "East Wing"
	destination_id = "right_part"
	tgui_icons = list("Departures" = "plane-departure", "Cargo" = "box", "Science" = "flask")
