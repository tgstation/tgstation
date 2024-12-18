/mob/living/silicon/robot/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(robot_resting)
		robot_resting = FALSE
		on_standing_up()
		update_icons()

/mob/living/silicon/robot/toggle_resting()
	robot_lay_down()

/mob/living/silicon/robot/on_lying_down(new_lying_angle)
	if(layer == initial(layer)) //to avoid things like hiding larvas.
		layer = LYING_MOB_LAYER //so mob lying always appear behind standing mobs
	density = FALSE // We lose density and stop bumping passable dense things.
	if(model && model.model_features && (TRAIT_R_TALL in model.model_features))
		maptext_height = 32 //Offset base chat-height value
		// Resting effects
		var/turf/sit_pos = get_turf(src)
		var/obj/structure/table/tabled = locate(/obj/structure/table) in sit_pos.contents
		if(!tabled)
			new /obj/effect/temp_visual/mook_dust/robot(get_turf(src))
			playsound(src, 'modular_doppler/big_borg_lmao/sounds/robot_sit.ogg', 25, TRUE)
			return
		else
			new /obj/effect/temp_visual/mook_dust/robot/table(get_turf(src))
			playsound(src, 'modular_doppler/big_borg_lmao/sounds/robot_bump.ogg', 50, TRUE)
		var/list/items_to_move = list()
		for(var/obj/item/gen_item in sit_pos.contents)
			if(!gen_item.anchored)
				items_to_move += gen_item
				if(items_to_move.len >= 8)
					break
		for(var/obj/item/table_contents in items_to_move)
			table_contents.throw_at(get_ranged_target_turf(table_contents, pick(GLOB.cardinals), range = 1), range = 1, speed = 1)

/mob/living/silicon/robot/on_standing_up()
	if(layer == LYING_MOB_LAYER)
		layer = initial(layer)
	density = initial(density) // We were prone before, so we become dense and things can bump into us again.
	if(model && model.model_features && (TRAIT_R_TALL in model.model_features))
		maptext_height = 48 //Offset value of tallborgs

/mob/living/silicon/robot/proc/rest_style()
	set name = "Switch Rest Style"
	set category = "AI Commands"
	set desc = "Select your resting pose."
	if(!can_rest())
		to_chat(src, span_warning("You can't do that!"))
		return
	robot_resting = ROBOT_REST_NORMAL
	on_lying_down()
	update_icons()

/mob/living/silicon/robot/proc/robot_lay_down()
	set name = "Lay down"
	set category = "AI Commands"
	if(!can_rest())
		to_chat(src, span_warning("You can't do that!"))
		return
	if(stat != CONSCIOUS) //Make sure we don't enable movement when not concious
		return
	if(robot_resting)
		to_chat(src, span_notice("You are now getting up."))
		robot_resting = FALSE
		mobility_flags = MOBILITY_FLAGS_DEFAULT
		on_standing_up()
	else
		to_chat(src, span_notice("You are now laying down."))
		robot_resting = robot_rest_style
		on_lying_down()
	update_icons()

/mob/living/silicon/robot/update_resting()
	. = ..()
	if(can_rest())
		robot_resting = FALSE
		update_icons()

/mob/living/silicon/robot/update_module_innate()
	..()
	if(hands)
		hands.icon = (model.model_select_alternate_icon ? model.model_select_alternate_icon : initial(hands.icon))

/**
 * Safe check of the cyborg's model_features list.
 *
 * model_features is defined in modular_nova\modules\altborgs\code\modules\mob\living\silicon\robot\robot_model.dm.
 */
/mob/living/silicon/robot/proc/can_rest()
	if(model && model.model_features && (TRAIT_R_TALL in model.model_features))
		if(TRAIT_IMMOBILIZED in _status_traits)
			return FALSE
		return TRUE
	return FALSE
