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
	w_class = WEIGHT_CLASS_SMALL
	///how many times can we climb with this rope
	var/uses = 5
	///climb time
	var/climb_time = 2.5 SECONDS

/obj/item/climbing_hook/examine(mob/user)
	. = ..()
	var/list/look_binds = user.client.prefs.key_bindings["look up"]
	. += span_notice("Firstly, look upwards by holding <b>[english_list(look_binds, nothing_text = "(nothing bound)", and_text = " or ", comma_text = ", or ")]!</b>")
	. += span_notice("Then, click solid ground (or lattice/catwalk) adjacent to the hole above you.")
	. += span_notice("The rope looks like you could use it [uses] times before it falls apart.")

/obj/item/climbing_hook/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/climbing_hook/ranged_interact_with_atom(turf/open/interacting_with, mob/living/user, list/modifiers)
	interacting_with = get_turf(interacting_with)
	if(interacting_with.z == user.z)
		return NONE
	if(!istype(interacting_with) || !isturf(user.loc)) //better safe than sorry
		return ITEM_INTERACT_BLOCKING

	var/turf/user_turf = get_turf(user)
	var/turf/above = GET_TURF_ABOVE(user_turf)
	if(target_blocked(interacting_with, above))
		balloon_alert(user, "cant get there!")
		return ITEM_INTERACT_BLOCKING
	if(!above.Adjacent(interacting_with)) //is the target adjacent to our hole
		balloon_alert(user, "too far!")
		return ITEM_INTERACT_BLOCKING

	var/away_dir = get_dir(above, interacting_with)
	user.visible_message(span_notice("[user] begins climbing upwards with [src]."), span_notice("You get to work on properly hooking [src] and going upwards."))
	playsound(interacting_with, 'sound/effects/pickaxe/picaxe1.ogg', 50) //plays twice so people above and below can hear
	playsound(user_turf, 'sound/effects/pickaxe/picaxe1.ogg', 50)
	var/list/effects = list(new /obj/effect/temp_visual/climbing_hook(interacting_with, away_dir), new /obj/effect/temp_visual/climbing_hook(user_turf, away_dir))

	// Our climbers athletics ability
	var/fitness_level = user.mind?.get_skill_level(/datum/skill/athletics)

	// Misc bonuses to the climb speed.
	var/misc_multiplier = 1

	var/obj/item/organ/cyberimp/chest/spine/potential_spine = user.get_organ_slot(ORGAN_SLOT_SPINE)
	if(istype(potential_spine))
		misc_multiplier *= potential_spine.athletics_boost_multiplier

	var/final_climb_time = (climb_time - fitness_level) * misc_multiplier

	if(do_after(user, final_climb_time, interacting_with))
		user.forceMove(interacting_with)
		uses--
		user.mind?.adjust_experience(/datum/skill/athletics, 50) //get some experience for our trouble, especially since this costs us a climbing rope use

	if(uses <= 0)
		user.visible_message(span_warning("[src] snaps and tears apart!"))
		qdel(src)

	QDEL_LIST(effects)
	return ITEM_INTERACT_SUCCESS

// didnt want to mess up is_blocked_turf_ignore_climbable
/// checks if our target is blocked, also checks for border objects facing the above turf and climbable stuff
/obj/item/climbing_hook/proc/target_blocked(turf/target, turf/above)
	if(target.density || (isopenspaceturf(target) && target.zPassOut(DOWN)) || !above.zPassOut(DOWN) || above.density) // we check if we would fall down from it additionally
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
