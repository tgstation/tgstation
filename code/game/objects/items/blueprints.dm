///The area is a "Station" area, showing no special text.
#define AREA_STATION 1
///The area is in outdoors (lavaland/icemoon/jungle/space), therefore unclaimed territories.
#define AREA_OUTDOORS 2
///The area is special (shuttles/centcom), therefore can't be claimed.
#define AREA_SPECIAL 3

/**
 * Blueprints
 * Used to see the wires of machines on the station, the roundstart layout of pipes/cables/tubes,
 * as well as allowing you to rename existing areas and create new ones.
 * Used by the station, cyborgs, and golems.
 */
/obj/item/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "blueprints"
	inhand_icon_state = "blueprints"
	attack_verb_continuous = list("attacks", "baps", "hits")
	attack_verb_simple = list("attack", "bap", "hit")
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	var/fluffnotice = "Property of Nanotrasen. For heads of staff only. Store in high-secure storage."
	var/in_use = FALSE
	///When using it to create a new area, this will be its type.
	var/area/new_area_type = /area
	var/list/image/showing = list()
	var/client/viewing
	var/legend = FALSE //Viewing the wire legend

/obj/item/blueprints/attack_self(mob/user)
	add_fingerprint(user)
	. = "<BODY><HTML><head><title>[src]</title></head> \
				<h2>[station_name()] [src.name]</h2> \
				<small>[fluffnotice]</small><hr>"
	switch(get_area_type(user))
		if(AREA_OUTDOORS)
			. += "<p>According to the [src.name], you are now in an unclaimed territory.</p>"
		if(AREA_SPECIAL)
			. += "<p>This place is not noted on the [src.name].</p>"
	. += "<p><a href='?src=[REF(src)];create_area=1'>Create or modify an existing area</a></p>"

	if(!legend)
		var/area/A = get_area(user)
		if(get_area_type(user) == AREA_STATION)
			. += "<p>According to \the [src], you are now in <b>\"[html_encode(A.name)]\"</b>.</p>"
			. += "<p><a href='?src=[REF(src)];edit_area=1'>Change area name</a></p>"
		. += "<p><a href='?src=[REF(src)];view_legend=1'>View wire colour legend</a></p>"
		if(!viewing)
			. += "<p><a href='?src=[REF(src)];view_blueprints=1'>View structural data</a></p>"
		else
			. += "<p><a href='?src=[REF(src)];refresh=1'>Refresh structural data</a></p>"
			. += "<p><a href='?src=[REF(src)];hide_blueprints=1'>Hide structural data</a></p>"
	else
		if(legend == TRUE)
			. += "<a href='?src=[REF(src)];exit_legend=1'><< Back</a>"
			. += view_wire_devices(user);
		else
			//legend is a wireset
			. += "<a href='?src=[REF(src)];view_legend=1'><< Back</a>"
			. += view_wire_set(user, legend)
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")

/obj/item/blueprints/Topic(href, href_list)
	. = ..()
	if(.)
		return TRUE
	if(!usr.can_perform_action(src) || usr != loc)
		usr << browse(null, "window=blueprints")
		return TRUE
	if(href_list["create_area"])
		if(in_use)
			return
		var/area/A = get_area(usr)
		if(A.area_flags & NOTELEPORT)
			to_chat(usr, span_warning("You cannot edit restricted areas."))
			return
		in_use = TRUE
		create_area(usr, new_area_type)
		in_use = FALSE
	if(href_list["edit_area"])
		if(get_area_type(usr) != AREA_STATION)
			return
		if(in_use)
			return
		in_use = TRUE
		edit_area(usr)
		in_use = FALSE
	if(href_list["exit_legend"])
		legend = FALSE
	if(href_list["view_legend"])
		legend = TRUE
	if(href_list["view_wireset"])
		legend = href_list["view_wireset"]
	if(href_list["view_blueprints"])
		set_viewer(usr, span_notice("You flip the blueprints over to view the complex information diagram."))
	if(href_list["hide_blueprints"])
		clear_viewer(usr,span_notice("You flip the blueprints over to view the simple information diagram."))
	if(href_list["refresh"])
		clear_viewer(usr)
		set_viewer(usr)

	updateUsrDialog()

/obj/item/blueprints/Destroy()
	clear_viewer()
	return ..()

/obj/item/blueprints/proc/get_images(turf/central_turf, viewsize)
	. = list()
	var/list/dimensions = getviewsize(viewsize)
	var/horizontal_radius = dimensions[1] / 2
	var/vertical_radius = dimensions[2] / 2
	for(var/turf/nearby_turf as anything in RECT_TURFS(horizontal_radius, vertical_radius, central_turf))
		if(nearby_turf.blueprint_data)
			. += nearby_turf.blueprint_data

/obj/item/blueprints/proc/set_viewer(mob/user, message = "")
	if(user?.client)
		if(viewing)
			clear_viewer()
		viewing = user.client
		showing = get_images(get_turf(viewing.eye || user), viewing.view)
		viewing.images |= showing
		if(message)
			to_chat(user, message)

/obj/item/blueprints/proc/clear_viewer(mob/user, message = "")
	if(viewing)
		viewing.images -= showing
		viewing = null
	showing.Cut()
	if(message)
		to_chat(user, message)

/obj/item/blueprints/dropped(mob/user)
	..()
	clear_viewer()
	legend = FALSE

/obj/item/blueprints/proc/view_wire_devices(mob/user)
	var/message = "<br>You examine the wire legend.<br>"
	for(var/wireset in GLOB.wire_color_directory)
		message += "<br><a href='?src=[REF(src)];view_wireset=[wireset]'>[GLOB.wire_name_directory[wireset]]</a>"
	message += "</p>"
	return message

/obj/item/blueprints/proc/view_wire_set(mob/user, wireset)
	//for some reason you can't use wireset directly as a derefencer so this is the next best :/
	for(var/device in GLOB.wire_color_directory)
		if("[device]" == wireset) //I know... don't change it...
			var/message = "<p><b>[GLOB.wire_name_directory[device]]:</b>"
			for(var/Col in GLOB.wire_color_directory[device])
				var/wire_name = GLOB.wire_color_directory[device][Col]
				if(!findtext(wire_name, WIRE_DUD_PREFIX)) //don't show duds
					message += "<p><span style='color: [Col]'>[Col]</span>: [wire_name]</p>"
			message += "</p>"
			return message
	return ""

/**
 * Gets the area type the user is currently standing in.
 * Returns: AREA_STATION, AREA_OUTDOORS, or AREA_SPECIAL
 * Args:
 * - user: The person we're getting the area of to check if it's a special area.
 */
/obj/item/blueprints/proc/get_area_type(mob/user)
	var/area/area_checking = get_area(user)
	if(area_checking.outdoors)
		return AREA_OUTDOORS
	var/static/list/special_areas = typecacheof(list(
		/area/shuttle,
		/area/centcom,
		/area/centcom/asteroid,
		/area/centcom/tdome,
		/area/centcom/wizard_station,
		/area/misc/hilbertshotel,
		/area/misc/hilbertshotelstorage,
	))
	if(area_checking.type in special_areas)
		return AREA_SPECIAL
	return AREA_STATION

/**
 * edit_area
 * Takes input from the player and renames the area the blueprints are currently in.
 */
/obj/item/blueprints/proc/edit_area(mob/user)
	var/area/area_editing = get_area(src)
	var/prevname = "[area_editing.name]"
	var/new_name = tgui_input_text(user, "New area name", "Area Creation", max_length = MAX_NAME_LEN)
	if(!new_name || !length(new_name) || new_name == prevname) //cancel
		return

	rename_area(area_editing, new_name)
	user.balloon_alert(user, "area renamed to [new_name]")
	user.log_message("has renamed [prevname] to [new_name]", LOG_GAME)
	updateUsrDialog()
	return TRUE

/**
 * Cyborg blueprints
 * The same as regular but with a different fluff text.
 */
/obj/item/blueprints/cyborg
	name = "station schematics"
	desc = "A digital copy of the station blueprints stored in your memory."
	fluffnotice = "Intellectual Property of Nanotrasen. For use in engineering cyborgs only. Wipe from memory upon departure from the station."

/**
 * Golem blueprints
 * Used by golems to make new "golem" areas, which doesn't come with slowdown for their
 * hazard area debuff.
 */
/obj/item/blueprints/golem
	name = "land claim"
	desc = "Use it to build new structures in the wastes."
	fluffnotice = "In memory of the Liberator's brother, Delaminator, and his Scarlet Macaw-iathan, from which this artifact was stolen."
	new_area_type = /area/golem


#undef AREA_STATION
#undef AREA_OUTDOORS
#undef AREA_SPECIAL

