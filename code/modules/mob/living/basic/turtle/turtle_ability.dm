#define TREE_FIELD_DURATION_EFFECT 10 SECONDS
#define WARP_ANIMATE_TIME 0.35 SECONDS

/datum/action/cooldown/mob_cooldown/turtle_tree
	name = "Tree Ability"
	desc = "Invoke your tree's special ability."
	cooldown_time = 2 MINUTES
	click_to_activate = FALSE
	button_icon = 'icons/mob/simple/pets.dmi'
	button_icon_state = "turtle"
	///type of effect our tree releases
	var/effect_path
	///how many times our ability affects surroundings
	var/maximum_intervals = 5
	///time between each interval
	var/time_between_intervals = 3 SECONDS
	///range our tree affects
	var/tree_range = 5
	///warp effect to apply some distortion to our field
	var/atom/movable/warp_effect/turtle_field/warp

/datum/action/cooldown/mob_cooldown/turtle_tree/Activate(atom/target)
	. = ..()
	warp = new(owner)
	RegisterSignal(warp, COMSIG_QDELETING, PROC_REF(remove_warp))
	warp.alpha = 0
	owner.vis_contents += warp

	for(var/index in 0 to maximum_intervals)
		addtimer(CALLBACK(src, PROC_REF(tree_effect)), time_between_intervals * index)

	animate(warp, transform = matrix(), alpha = warp::alpha, time = WARP_ANIMATE_TIME)
	addtimer(CALLBACK(src, PROC_REF(warp_extinguish)), (time_between_intervals * maximum_intervals) + 3 SECONDS)

/datum/action/cooldown/mob_cooldown/turtle_tree/proc/warp_extinguish()
	if(QDELETED(warp))
		return
	animate(warp, alpha = 0, time = WARP_ANIMATE_TIME)
	addtimer(CALLBACK(src, PROC_REF(remove_warp)), WARP_ANIMATE_TIME)

/datum/action/cooldown/mob_cooldown/turtle_tree/proc/remove_warp()
	SIGNAL_HANDLER

	UnregisterSignal(warp, COMSIG_QDELETING)
	warp = null

///effect we apply on our trees
/datum/action/cooldown/mob_cooldown/turtle_tree/proc/tree_effect()
	SHOULD_CALL_PARENT(TRUE)
	return (pre_effect_apply())

///things we should check for before applying our effects
/datum/action/cooldown/mob_cooldown/turtle_tree/proc/pre_effect_apply()
	if(QDELETED(owner) || owner.stat == DEAD)
		return FALSE
	var/obj/effect/tree_effect = new effect_path
	owner.vis_contents += tree_effect
	return TRUE

///healer tree, heals nearby plants by small amounts
/datum/action/cooldown/mob_cooldown/turtle_tree/healer
	effect_path = /obj/effect/temp_visual/circle_wave/tree/healer
	///amount we heal plants by
	var/heal_amount = 5

/datum/action/cooldown/mob_cooldown/turtle_tree/healer/tree_effect()
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/hydroponics/hydro in oview(tree_range, owner))
		if(isnull(hydro.myseed))
			continue
		hydro.adjust_plant_health(heal_amount)

///killer tree, kills plant's pests and weeds, aswell as nearby vermin
/datum/action/cooldown/mob_cooldown/turtle_tree/killer
	effect_path = /obj/effect/temp_visual/circle_wave/tree/killer
	///amount we heal plants by
	var/vermin_damage_amount = 20
	///type of vermin our field affects
	var/static/list/vermin_mob_targets = typecacheof(list(
		/mob/living/basic/cockroach,
		/mob/living/basic/mouse/rat,
	))
	///how much we reduce weed levels
	var/weed_level_reduce = 2

/datum/action/cooldown/mob_cooldown/turtle_tree/killer/tree_effect()
	. = ..()
	if(!.)
		return

	for(var/atom/possible_target as anything in oview(tree_range, owner))

		if(is_type_in_typecache(possible_target, vermin_mob_targets))
			var/mob/living/living_target = possible_target
			living_target.apply_damage(vermin_damage_amount)
			continue

		if(!istype(possible_target, /obj/machinery/hydroponics))
			continue

		var/obj/machinery/hydroponics/hydro = possible_target
		if(isnull(hydro.myseed))
			continue
		hydro.set_weedlevel(hydro.weedlevel - weed_level_reduce)

///mutator tree, mutates nearby plants!
/datum/action/cooldown/mob_cooldown/turtle_tree/mutator
	effect_path = /obj/effect/temp_visual/circle_wave/tree/mutator
	///how much we mutate plants
	var/mutator_boost = 1

/datum/action/cooldown/mob_cooldown/turtle_tree/mutator/tree_effect()
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/hydroponics/hydro in oview(tree_range, owner))
		hydro.myseed?.adjust_instability(mutator_boost)

/atom/movable/warp_effect/turtle_field
	alpha = 75

///effects we give our tree abilities depending on their type
/obj/effect/temp_visual/circle_wave/tree
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	duration = 10 SECONDS
	amount_to_scale = 3

/obj/effect/temp_visual/circle_wave/tree/healer
	color = "#28a3bc"

/obj/effect/temp_visual/circle_wave/tree/killer
	color = "#ce3ebf"

/obj/effect/temp_visual/circle_wave/tree/mutator
	color = "#c49f26"

#undef TREE_FIELD_DURATION_EFFECT
#undef WARP_ANIMATE_TIME
