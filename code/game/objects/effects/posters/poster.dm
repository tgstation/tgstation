// This is synced up to the poster placing animation.
#define PLACE_SPEED 37

// The poster item

/**
 * The rolled up item form of a poster
 *
 * In order to create one of these for a specific poster, you must pass the structure form of the poster as an argument to /new().
 * This structure then gets moved into the contents of the item where it will stay until the poster is placed by a player.
 * The structure form is [obj/structure/sign/poster] and that's where all the specific posters are defined.
 * If you just want a random poster, see [/obj/item/poster/random_official] or [/obj/item/poster/random_contraband]
 */
/obj/item/poster
	name = "poorly coded poster"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/poster.dmi'
	force = 0
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	var/obj/structure/sign/poster/poster_type = /obj/structure/sign/poster/random
	var/obj/structure/sign/poster/poster_structure

/obj/item/poster/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()

	var/static/list/hovering_item_typechecks = list(
		/obj/item/shard = list(
			SCREENTIP_CONTEXT_LMB = "Booby trap poster",
		),
	)
	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)

	if(new_poster_structure && (new_poster_structure.loc != src))
		qdel(new_poster_structure.GetComponent(/datum/component/atom_mounted))
		new_poster_structure.forceMove(src)
	poster_structure = new_poster_structure
	if(!poster_type) // If we weren't already assigned a poster_type, we infer from the contained poster_structure
		if(istype(poster_structure, /obj/structure/sign/poster)) // Make sure our poster structure is valid
			poster_type = poster_structure.type
		else
			stack_trace("Rolled poster [type] was created without either a valid poster_type [poster_type] or poster_structure [poster_structure]")
			poster_type = /obj/structure/sign/poster/random // Panic, do something random
	if(ispath(poster_type, /obj/structure/sign/poster)) // Make sure we have a valid poster_type before using it
		name = "[poster_type::poster_item_name] - [poster_type::name]"
		desc = poster_type::poster_item_desc
		icon_state = poster_type::poster_item_icon_state
	else // We did not have a valid poster_type, light the beacons
		CRASH("Rolled poster [type] has an invalid or null poster_type [poster_type]")

/obj/item/poster/Destroy(force)
	QDEL_NULL(poster_structure)
	return ..()

/obj/item/poster/examine(mob/user)
	. = ..()
	. += span_notice("You can booby-trap the poster by using a glass shard on it before you put it up.")

/obj/item/poster/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(I, /obj/item/shard))
		return ..()

	if (locate(/obj/item/shard) in (poster_structure?.contents || contents))
		balloon_alert(user, "already trapped!")
		return

	if(!user.transferItemToLoc(I, src))
		return

	to_chat(user, span_notice("You conceal \the [I] inside the rolled up poster."))

/obj/item/poster/interact_with_atom(turf/closed/wall_structure, mob/living/user, list/modifiers)
	if(!isclosedturf(wall_structure))
		return NONE

	// Deny placing posters on currently-diagonal walls, although the wall may change in the future.
	if (wall_structure.smoothing_flags & SMOOTH_DIAGONAL_CORNERS)
		for(var/overlay in wall_structure.overlays)
			var/image/new_image = overlay
			if(copytext(new_image.icon_state, 1, 3) == "d-") //3 == length("d-") + 1
				to_chat(user, span_warning("Cannot place on diagonal wall!"))
				return ITEM_INTERACT_FAILURE

	var/stuff_on_wall = 0
	for(var/obj/contained_object in wall_structure.contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(contained_object, /obj/structure/sign/poster))
			balloon_alert(user, "no room!")
			return ITEM_INTERACT_FAILURE
		stuff_on_wall++
		if(stuff_on_wall == 3)
			balloon_alert(user, "no room!")
			return ITEM_INTERACT_FAILURE

	balloon_alert(user, "hanging poster...")
	var/obj/structure/sign/poster/placed_poster = poster_structure || new poster_type(src)
	placed_poster.poster_item_type = type
	placed_poster.forceMove(wall_structure)
	var/obj/item/shard/trap = locate() in contents
	if(trap)
		trap.forceMove(placed_poster)
	poster_structure = null
	flick("poster_being_set", placed_poster)
	playsound(src, 'sound/items/poster/poster_being_created.ogg', 100, TRUE)
	qdel(src)

	var/turf/user_drop_location = get_turf(user)
	if(!do_after(user, PLACE_SPEED, placed_poster, extra_checks = CALLBACK(placed_poster, TYPE_PROC_REF(/obj/structure/sign/poster, snowflake_closed_turf_check), wall_structure)))
		placed_poster.roll_and_drop(user_drop_location, user)
		return ITEM_INTERACT_FAILURE

	placed_poster.setDir(get_dir(user_drop_location, wall_structure))
	placed_poster.find_and_mount_on_atom()
	placed_poster.on_placed_poster(user)
	return ITEM_INTERACT_SUCCESS

/**
 * The structure form of a poster.
 * These are what get placed on maps as posters. They are also what gets created when a player places a poster on a wall.
 * For the item form that can be spawned for players, see [/obj/item/poster]
 */
/obj/structure/sign/poster
	name = "poster"
	var/original_name
	desc = "A large piece of space-resistant printed paper."
	icon = 'icons/obj/poster.dmi'
	anchored = TRUE
	buildable_sign = FALSE //Cannot be unwrenched from a wall.
	var/ruined = FALSE
	var/random_basetype
	var/never_random = FALSE // used for the 'random' subclasses.
	///Exclude posters of these types from being added to the random pool
	var/list/blacklisted_types = list()
	///Whether the poster should be printable from library management computer.
	var/printable = FALSE
	///What type should we put back in the rolled poster when we get cut down
	var/cutdown_type

	var/poster_item_name = "hypothetical poster"
	var/poster_item_desc = "This hypothetical poster item should not exist, let's be honest here."
	var/poster_item_icon_state = "rolled_poster"
	var/poster_item_type = /obj/item/poster

/obj/structure/sign/poster/Initialize(mapload)
	. = ..()
	cutdown_type = type
	if(random_basetype)
		randomise(random_basetype)
	if(!ruined)
		original_name = name // can't use initial because of random posters
		name = "poster - [name]"
		desc = "A large piece of space-resistant printed paper. [desc]"

	AddElement(/datum/element/beauty, 300)

/// Adds contextual screentips
/obj/structure/sign/poster/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if (!held_item)
		if (ruined)
			return .
		context[SCREENTIP_CONTEXT_LMB] = "Rip up poster"
		return CONTEXTUAL_SCREENTIP_SET

	if (held_item.tool_behaviour == TOOL_WIRECUTTER)
		if (ruined)
			context[SCREENTIP_CONTEXT_LMB] = "Clean up remnants"
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Take down poster"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/structure/sign/poster/proc/randomise(base_type)
	var/list/poster_types = subtypesof(base_type)
	if(length(blacklisted_types))
		for(var/iterated_type in blacklisted_types)
			poster_types -= typesof(iterated_type)
	var/list/approved_types = list()
	for(var/obj/structure/sign/poster/type_of_poster as anything in poster_types)
		// It must have an icon state, not be banned from the random pool, and not be pixel shifted (eliminates directional subtypes)
		if(initial(type_of_poster.icon_state) && !initial(type_of_poster.never_random) && !initial(type_of_poster.pixel_x) && !initial(type_of_poster.pixel_y))
			approved_types |= type_of_poster

	var/obj/structure/sign/poster/selected = pick(approved_types)

	name = initial(selected.name)
	desc = initial(selected.desc)
	icon_state = initial(selected.icon_state)
	icon = initial(selected.icon)
	poster_item_name = initial(selected.poster_item_name)
	poster_item_desc = initial(selected.poster_item_desc)
	poster_item_icon_state = initial(selected.poster_item_icon_state)
	ruined = initial(selected.ruined)
	cutdown_type = initial(selected.type)
	if(length(GLOB.holidays) && prob(30)) // its the holidays! lets get festive
		apply_holiday()
	update_appearance()

/// allows for posters to become festive posters during holidays
/obj/structure/sign/poster/proc/apply_holiday()
	if(!length(GLOB.holidays))
		return
	var/active_holiday = pick(GLOB.holidays)
	var/datum/holiday/holi_data = GLOB.holidays[active_holiday]

	if(holi_data.poster_name == "generic celebration poster")
		return
	name = holi_data.poster_name
	desc = holi_data.poster_desc
	icon_state = holi_data.poster_icon

/obj/structure/sign/poster/wirecutter_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 100)
	if(ruined)
		to_chat(user, span_notice("You remove the remnants of the poster."))
		qdel(src)
	else
		to_chat(user, span_notice("You carefully remove the poster from the wall."))
		roll_and_drop(Adjacent(user) ? get_turf(user) : loc, user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/sign/poster/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !check_tearability())
		return
	tear_poster(user)

/// Check to see if this poster is tearable and gives the user feedback if it is not.
/obj/structure/sign/poster/proc/check_tearability(mob/user)
	if(ruined)
		balloon_alert(user, "already ruined!")
		return FALSE
	return TRUE

// HO-HO-HOHOHO HU HU-HU HU-HU
/obj/structure/sign/poster/proc/spring_trap(mob/user)
	var/obj/item/shard/payload = locate() in contents
	if (!payload)
		return

	to_chat(user, span_warning("There's something sharp behind this! What the hell?"))
	if(!can_embed_trap(user) || !payload.force_embed(user, user.get_active_hand()))
		visible_message(span_notice("A [payload.name] falls from behind the poster.") )
		payload.forceMove(user.drop_location())

/obj/structure/sign/poster/proc/can_embed_trap(mob/living/carbon/human/user)
	if (!istype(user) || HAS_TRAIT(user, TRAIT_PIERCEIMMUNE))
		return FALSE
	return !user.gloves || !(user.gloves.body_parts_covered & HANDS) || HAS_TRAIT(user, TRAIT_FINGERPRINT_PASSTHROUGH) || HAS_TRAIT(user.gloves, TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/structure/sign/poster/proc/roll_and_drop(atom/location, mob/user)
	pixel_x = 0
	pixel_y = 0
	var/obj/item/poster/rolled_poster = return_to_poster_item(location, src)
	if(!user?.put_in_hands(rolled_poster))
		forceMove(rolled_poster)
	return rolled_poster


/// Re-creates the poster item from the poster structure
/obj/structure/sign/poster/proc/return_to_poster_item(atom/location)
	. = new poster_item_type(location, new cutdown_type)
	qdel(src)
	return .

/obj/structure/sign/poster/proc/snowflake_closed_turf_check(atom/hopefully_still_a_closed_turf) //since turfs never get deleted but instead change type, make sure we're still being placed on a wall.
	return isclosedturf(hopefully_still_a_closed_turf)

/obj/structure/sign/poster/proc/on_placed_poster(mob/user)
	to_chat(user, span_notice("You place the poster!"))

/obj/structure/sign/poster/proc/tear_poster(mob/user)
	visible_message(span_notice("[user] rips [src] in a single, decisive motion!") )
	playsound(src.loc, 'sound/items/poster/poster_ripped.ogg', 100, TRUE)
	spring_trap(user)

	var/obj/structure/sign/poster/ripped/torn_poster = new(loc)
	torn_poster.pixel_y = pixel_y
	torn_poster.pixel_x = pixel_x
	torn_poster.add_fingerprint(user)
	qdel(src)

// Various possible posters follow

/obj/structure/sign/poster/ripped
	ruined = TRUE
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/ripped, 32)

/obj/structure/sign/poster/random
	name = "random poster" // could even be ripped
	icon_state = "random_anything"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster
	blacklisted_types = list(
		/obj/structure/sign/poster/traitor,
		/obj/structure/sign/poster/abductor,
	)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/random, 32)

/obj/structure/sign/poster/greenscreen
	name = "greenscreen"
	desc = "Used to create a convincing illusion of a different background."
	icon_state = "greenscreen"
	poster_item_name = "greenscreen"
	poster_item_desc = "Used to create a convincing illusion of a different background."
	never_random = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/greenscreen, 32)

#undef PLACE_SPEED
