/mob/living/basic/paper_wizard
	name = "Mjor the Creative"
	desc = "A wizard with a taste for the arts."
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	faction = list(FACTION_HOSTILE, FACTION_STICKMAN)
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "paperwizard"
	gender = MALE

	response_help_continuous = "brushes"
	response_help_simple = "brush"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"

	maxHealth = 1000
	health = 1000
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_sound = 'sound/hallucinations/growl1.ogg'
	ai_controller = /datum/ai_controller/basic_controller/paper_wizard
	///the list of our clones
	var/list/copies = list()
	///spell to summon minions
	var/datum/action/cooldown/spell/wizard_summon_minions/summon
	///spell to summon clones
	var/datum/action/cooldown/spell/pointed/wizard_mimic/mimic


/mob/living/basic/paper_wizard/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, mob_spawn_path = /obj/effect/mob_spawn/corpse/human/wizard/paper)
	summon = new(src)
	summon.Grant(src)
	ai_controller.set_blackboard_key(BB_WIZARD_SUMMON_MINIONS, summon)
	mimic = new(src)
	mimic.Grant(src)
	ai_controller.set_blackboard_key(BB_WIZARD_MIMICS, mimic)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(animate_step))
	RegisterSignal(src, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(delete_copies))
	AddElement(/datum/element/death_drops, list(/obj/effect/temp_visual/paperwiz_dying))

/mob/living/basic/paper_wizard/proc/delete_copies()
	SIGNAL_HANDLER
	for(var/copy in copies)
		qdel(copy)

/mob/living/basic/paper_wizard/proc/animate_step()
	SIGNAL_HANDLER
	var/paper_effect = new /obj/effect/temp_visual/paper_scatter(get_turf(src))
	animate(paper_effect, alpha = 0, 1 SECONDS)

/mob/living/basic/paper_wizard/Destroy()
	QDEL_LIST(copies)
	return ..()

/datum/ai_controller/basic_controller/paper_wizard
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_WRITING_LIST = list(
			"I can turn the paper into gold and ink into diamonds!",
			"Your fate is written and sealed!",
			"You shall suffer the wrath of a thousand paper cuts!",
		)
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/find_paper_and_write,
		/datum/ai_planning_subtree/targeted_mob_ability/wizard_mimic,
		/datum/ai_planning_subtree/use_mob_ability/wizard_summon_minions,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/targeted_mob_ability/wizard_mimic
	ability_key = BB_WIZARD_MIMICS
	finish_planning = FALSE

/datum/ai_planning_subtree/use_mob_ability/wizard_summon_minions
	ability_key = BB_WIZARD_SUMMON_MINIONS
	finish_planning = FALSE

/datum/ai_behavior/find_and_set/empty_paper
	action_cooldown = 40 SECONDS

/datum/ai_behavior/find_and_set/empty_paper/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/empty_papers = list()

	for(var/obj/item/paper/target_paper in oview(search_range, controller.pawn))
		if(target_paper.is_empty())
			empty_papers += target_paper

	if(empty_papers.len)
		return pick(empty_papers)

/mob/living/basic/paper_wizard/copy
	desc = "'Tis a ruse!"
	health = 1
	maxHealth = 1
	alpha = 200
	faction = list(FACTION_STICKMAN)
	melee_damage_lower = 1
	melee_damage_upper = 5

	ai_controller = /datum/ai_controller/basic_controller/wizard_copy
	///the master that summoned us
	var/mob/living/basic/paper_wizard/original

/mob/living/basic/paper_wizard/copy/Initialize(mapload)
	. = ..()
	RegisterSignals(src, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(remove_copy))
	RegisterSignal(src, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(damage_nearby))

/mob/living/basic/paper_wizard/copy/proc/remove_copy()
	SIGNAL_HANDLER

	if(original)
		original.copies -= src
		original = null

//Hit a fake? eat pain!
/mob/living/basic/paper_wizard/copy/proc/damage_nearby(amount, updating_health = TRUE, forced = FALSE)
	SIGNAL_HANDLER

	for(var/mob/living/damaged in oview(5, src))
		if(faction_check_mob(damaged, exact_match = FALSE))
			continue
		damaged.adjustBruteLoss(50)


/mob/living/basic/paper_wizard/copy/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += span_notice("It's an illusion - what is it hiding?")
	else
		qdel(src) //I see through your ruse!

/datum/ai_controller/basic_controller/wizard_copy
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

//fancy effects
/obj/effect/temp_visual/paper_scatter
	name = "scattering paper"
	desc = "Pieces of paper scattering to the wind."
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "paper_scatter"
	anchored = TRUE
	duration = 5
	randomdir = FALSE

/obj/effect/temp_visual/paperwiz_dying
	name = "craft portal"
	desc = "A wormhole sucking the wizard into the void. Neat."
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "paperwiz_poof"
	anchored = TRUE
	duration = 18
	randomdir = FALSE

/obj/effect/temp_visual/paperwiz_dying/Initialize(mapload)
	. = ..()
	visible_message(span_boldannounce("The wizard cries out in pain as a gate appears behind him, sucking him in!"))
	playsound(get_turf(src), 'sound/magic/mandswap.ogg', 50, vary = TRUE, pressure_affected = TRUE)
	playsound(get_turf(src), 'sound/hallucinations/wail.ogg', 50, vary = TRUE, pressure_affected = TRUE)

/obj/effect/temp_visual/paperwiz_dying/Destroy()
	for(var/mob/nearby in range(7, src))
		shake_camera(nearby, duration = 7 SECONDS, strength = 1)
	var/turf/current_turf = get_turf(src)
	playsound(current_turf,'sound/magic/summon_magic.ogg', 50, vary = TRUE, vary = TRUE)
	new /obj/effect/temp_visual/paper_scatter(current_turf)
	new /obj/item/clothing/suit/wizrobe/paper(current_turf)
	new /obj/item/clothing/head/collectable/paper(current_turf)
	return ..()

