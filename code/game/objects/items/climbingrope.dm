/obj/item/climbing_hook
	name = "climbing hook"
	desc = "Standard hook with rope to scale up holes. The rope is of average quality, but due to your weight amongst other factors, may not withstand extreme use."
	icon = 'icons/obj/mining.dmi'
	icon_state = "climbingrope"
	inhand_icon_state = "crowbar_brass"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 5
	throwforce = 10
	reach = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("whacks", "flails", "bludgeons")
	attack_verb_simple = list("whack", "flail", "bludgeon")
	resistance_flags = FLAMMABLE
	///how many times can we climb with this rope
	var/uses = 5
	///climb time
	var/climb_time = 2.5 SECONDS

/obj/item/climbing_hook/examine(mob/user)
	. = ..()
	var/list/look_binds = user.client.prefs.key_bindings["look up"]
	. += span_notice("Firstly, look upwards by holding <b>[english_list(look_binds, nothing_text = "(nothing bound)", and_text = " or ", comma_text = ", or ")]!</b>")
	. += span_notice("Then, click solid ground adjacent to the hole above you.")
	. += span_notice("The rope looks like you could use it [uses] times before it falls apart.")

/obj/item/climbing_hook/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/climbing_hook/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with.z == user.z)
		return NONE
	var/turf/open/target = interacting_with
	if(!istype(target) || isopenspaceturf(target))
		return ITEM_INTERACT_BLOCKING

	var/turf/user_turf = get_turf(user)
	var/turf/above = GET_TURF_ABOVE(user_turf)
	if(target_blocked(target, above))
		return ITEM_INTERACT_BLOCKING
	if(!isopenspaceturf(above) || !above.Adjacent(target)) //are we below a hole, is the target blocked, is the target adjacent to our hole
		balloon_alert(user, "blocked!")
		return ITEM_INTERACT_BLOCKING

	var/away_dir = get_dir(above, target)
	user.visible_message(span_notice("[user] begins climbing upwards with [src]."), span_notice("You get to work on properly hooking [src] and going upwards."))
	playsound(target, 'sound/effects/picaxe1.ogg', 50) //plays twice so people above and below can hear
	playsound(user_turf, 'sound/effects/picaxe1.ogg', 50)
	var/list/effects = list(new /obj/effect/temp_visual/climbing_hook(target, away_dir), new /obj/effect/temp_visual/climbing_hook(user_turf, away_dir))

	if(do_after(user, climb_time, target))
		user.forceMove(target)
		uses--

	if(uses <= 0)
		user.visible_message(span_warning("[src] snaps and tears apart!"))
		qdel(src)

	QDEL_LIST(effects)
	return ITEM_INTERACT_SUCCESS

// didnt want to mess up is_blocked_turf_ignore_climbable
/// checks if our target is blocked, also checks for border objects facing the above turf and climbable stuff
/obj/item/climbing_hook/proc/target_blocked(turf/target, turf/above)
	if(target.density || above.density)
		return TRUE

	for(var/atom/movable/atom_content as anything in target.contents)
		if(isliving(atom_content))
			continue
		if(HAS_TRAIT(atom_content, TRAIT_CLIMBABLE))
			continue
		if((atom_content.flags_1 & ON_BORDER_1) && atom_content.dir != get_dir(target, above)) //if the border object is facing the hole then it is blocking us, likely
			continue
		if(atom_content.density)
			return TRUE
	return FALSE

/obj/item/climbing_hook/emergency
	name = "emergency climbing hook"
	desc = "An emergency climbing hook to scale up holes. The rope is EXTREMELY cheap and may not withstand extended use."
	uses = 2
	climb_time = 4 SECONDS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/climbing_hook/syndicate
	name = "suspicious climbing hook"
	desc = "REALLY suspicious climbing hook to scale up holes. The hook has a syndicate logo engraved on it, and the rope appears rather durable."
	icon_state = "climbingrope_s"
	uses = 10
	climb_time = 1.5 SECONDS

/obj/item/climbing_hook/infinite //debug stuff
	name = "infinite climbing hook"
	desc = "A plasteel hook, with rope. Upon closer inspection, the rope appears to be made out of plasteel woven into regular rope, amongst many other reinforcements."
	uses = INFINITY
	climb_time = 1 SECONDS

/obj/effect/temp_visual/climbing_hook
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "path_indicator"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	duration = 4 SECONDS

/obj/effect/temp_visual/climbing_hook/Initialize(mapload, direction)
	. = ..()
	dir = direction
