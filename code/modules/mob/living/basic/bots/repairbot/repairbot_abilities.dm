#define BUILDING_WALL_ABILITY "building wall ability"

/datum/action/cooldown/mob_cooldown/bot/build_girder
	name = "Build Girder"
	desc = "Use iron rods to build a girder!"
	button_icon = 'icons/obj/structures.dmi'
	button_icon_state = "girder"
	cooldown_time = 3 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/mob_cooldown/bot/build_girder/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/stack/rods/our_rods = locate() in owner
	if(isnull(our_rods) || our_rods.amount < 2)
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/bot/build_girder/Activate(atom/target)
	if(DOING_INTERACTION(owner, BUILDING_WALL_ABILITY))
		return TRUE
	if(!isopenturf(target) || isgroundlessturf(target))
		owner.balloon_alert(owner, "cant build here!")
		return TRUE
	var/obj/item/stack/rods/our_rods = locate() in owner
	var/turf/turf_target = target
	if(turf_target.is_blocked_turf())
		owner.balloon_alert(owner, "blocked!")
		return TRUE
	var/obj/effect/constructing_effect/effect = new(turf_target, 3 SECONDS)

	if(!do_after(owner, 3 SECONDS, target = turf_target, interaction_key = BUILDING_WALL_ABILITY) || isnull(turf_target) || turf_target.is_blocked_turf())
		qdel(effect)
		return TRUE

	playsound(turf_target, 'sound/machines/click.ogg', 50, TRUE)
	new /obj/structure/girder(turf_target)
	var/atom/stack_to_delete = our_rods.split_stack(owner, 2)
	qdel(stack_to_delete)
	StartCooldown()
	qdel(effect)
	return TRUE

#undef BUILDING_WALL_ABILITY
