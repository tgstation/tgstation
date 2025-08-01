/*****************Marker Beacons**************************/
GLOBAL_LIST_INIT(marker_beacon_colors, sort_list(list(
"Random" = FALSE, //not a true color, will pick a random color
"Burgundy" = LIGHT_COLOR_FLARE,
"Bronze" = LIGHT_COLOR_ORANGE,
"Yellow" = LIGHT_COLOR_DIM_YELLOW,
"Lime" = LIGHT_COLOR_SLIME_LAMP,
"Olive" = LIGHT_COLOR_GREEN,
"Jade" = LIGHT_COLOR_BLUEGREEN,
"Teal" = LIGHT_COLOR_LIGHT_CYAN,
"Cerulean" = LIGHT_COLOR_BLUE,
"Indigo" = LIGHT_COLOR_DARK_BLUE,
"Purple" = LIGHT_COLOR_PURPLE,
"Violet" = LIGHT_COLOR_LAVENDER,
"Fuchsia" = LIGHT_COLOR_PINK)))

/obj/item/stack/marker_beacon
	name = "marker beacon"
	singular_name = "marker beacon"
	desc = "Prism-brand path illumination devices. Used by miners to mark paths and warn of danger."
	icon = 'icons/obj/mining.dmi'
	icon_state = "marker"
	merge_type = /obj/item/stack/marker_beacon
	max_amount = 100
	novariants = TRUE
	cost = 1
	source = /datum/robot_energy_storage/beacon
	var/picked_color = "Random"

/obj/item/stack/marker_beacon/ten //miners start with 10 of these
	amount = 10

/obj/item/stack/marker_beacon/thirty //and they're bought in stacks of 1, 10, or 30
	amount = 30

/obj/item/stack/marker_beacon/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	update_appearance()

/obj/item/stack/marker_beacon/examine(mob/user)
	. = ..()
	. += span_notice("Use in-hand to place a [singular_name].\nAlt-click to select a color. Current color is [picked_color].")

/obj/item/stack/marker_beacon/update_icon_state()
	icon_state = "[initial(icon_state)][LOWER_TEXT(picked_color)]"
	return ..()

/obj/item/stack/marker_beacon/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, span_warning("You need more space to place a [singular_name] here."))
		return
	if(locate(/obj/structure/marker_beacon) in user.loc)
		to_chat(user, span_warning("There is already a [singular_name] here."))
		return
	if(use(1))
		to_chat(user, span_notice("You activate and anchor [amount ? "a":"the"] [singular_name] in place."))
		playsound(user, 'sound/machines/click.ogg', 50, TRUE)
		var/obj/structure/marker_beacon/M = new(user.loc, picked_color)
		transfer_fingerprints_to(M)

/obj/item/stack/marker_beacon/click_alt(mob/living/user)
	var/input_color = tgui_input_list(user, "Choose a color", "Beacon Color", GLOB.marker_beacon_colors)
	if(isnull(input_color))
		return CLICK_ACTION_BLOCKING
	if(!user.can_perform_action(src))
		return CLICK_ACTION_BLOCKING
	picked_color = input_color
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/structure/marker_beacon
	name = "marker beacon"
	desc = "A Prism-brand path illumination device. It is anchored in place and glowing steadily."
	icon = 'icons/obj/mining.dmi'
	icon_state = "marker"
	layer = BELOW_OPEN_DOOR_LAYER
	armor_type = /datum/armor/structure_marker_beacon
	max_integrity = 50
	anchored = TRUE
	light_range = 2
	light_power = 3
	var/icon_prefix = "marker"
	var/remove_speed = 15
	var/picked_color

/datum/armor/structure_marker_beacon
	melee = 50
	bullet = 75
	laser = 75
	energy = 75
	bomb = 25
	fire = 25

/obj/structure/marker_beacon/Initialize(mapload, set_color)
	. = ..()
	if(set_color)
		picked_color = set_color
	update_appearance()

/obj/structure/marker_beacon/atom_deconstruct(disassembled = TRUE)
	var/obj/item/stack/marker_beacon/beacon = new(loc)
	beacon.picked_color = picked_color
	beacon.update_appearance()

/obj/structure/marker_beacon/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to select a color. Current color is [picked_color].")

/obj/structure/marker_beacon/update_appearance(updates)
	while(!picked_color || !GLOB.marker_beacon_colors[picked_color])
		picked_color = pick(GLOB.marker_beacon_colors)

	. = ..()
	set_light(light_range, light_power, GLOB.marker_beacon_colors[picked_color])

/obj/structure/marker_beacon/update_icon_state()
	icon_state = "[icon_prefix][LOWER_TEXT(picked_color)]-on"
	return ..()

/obj/structure/marker_beacon/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("You start picking [src] up..."))
	if(do_after(user, remove_speed, target = src))
		var/obj/item/stack/marker_beacon/M = new(loc)
		M.picked_color = picked_color
		M.update_appearance()
		transfer_fingerprints_to(M)
		if(user.put_in_hands(M, TRUE)) //delete the beacon if it fails
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			qdel(src) //otherwise delete us

/obj/structure/marker_beacon/attack_tk(mob/user)
	return

/obj/structure/marker_beacon/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(I, /obj/item/stack/marker_beacon))
		var/obj/item/stack/marker_beacon/M = I
		to_chat(user, span_notice("You start picking [src] up..."))
		if(do_after(user, remove_speed, target = src) && M.amount + 1 <= M.max_amount)
			M.add(1)
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			qdel(src)
			return
	if(istype(I, /obj/item/light_eater))
		var/obj/effect/decal/cleanable/ash/A = new /obj/effect/decal/cleanable/ash(drop_location())
		A.desc += "\nLooks like this used to be \a [src] some time ago."
		visible_message(span_danger("[src] is disintegrated by [I]!"))
		playsound(src, 'sound/items/tools/welder.ogg', 50, TRUE)
		qdel(src)
		return
	return ..()

/obj/structure/marker_beacon/click_alt(mob/living/user)
	var/input_color = tgui_input_list(user, "Choose a color", "Beacon Color", GLOB.marker_beacon_colors)
	if(isnull(input_color))
		return CLICK_ACTION_BLOCKING
	if(!user.can_perform_action(src))
		return NONE
	picked_color = input_color
	update_appearance()
	return CLICK_ACTION_SUCCESS


/* Preset marker beacon types, for mapping */
// Set the icon_state here to make it clear for mappers.

/obj/structure/marker_beacon/burgundy
	picked_color = "Burgundy"
	icon_state = "markerburgundy-on"

/obj/structure/marker_beacon/bronze
	picked_color = "Bronze"
	icon_state = "markerbronze-on"

/obj/structure/marker_beacon/yellow
	picked_color = "Yellow"
	icon_state = "markeryellow-on"

/obj/structure/marker_beacon/lime
	picked_color = "Lime"
	icon_state = "markerlime-on"

/obj/structure/marker_beacon/olive
	picked_color = "Olive"
	icon_state = "markerolive-on"

/obj/structure/marker_beacon/jade
	picked_color = "Jade"
	icon_state = "markerjade-on"

/obj/structure/marker_beacon/teal
	picked_color = "Teal"
	icon_state = "markerteal-on"

/obj/structure/marker_beacon/cerulean
	picked_color = "Cerulean"
	icon_state = "markercerulean-on"

/obj/structure/marker_beacon/indigo
	picked_color = "Indigo"
	icon_state = "markerindigo-on"

/obj/structure/marker_beacon/purple
	picked_color = "Purple"
	icon_state = "markerpurple-on"

/obj/structure/marker_beacon/violet
	picked_color = "Violet"
	icon_state = "markerviolet-on"

/obj/structure/marker_beacon/fuchsia
	picked_color = "Fuchsia"
	icon_state = "markerfuchsia-on"
