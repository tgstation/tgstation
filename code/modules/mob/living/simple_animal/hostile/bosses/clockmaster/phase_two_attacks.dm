//Bunkers up wherever standing, charging up an AoE attack to blast anyone who stays too close. Causes hallucations and brain damage to those affected.
/datum/action/boss/brain_blast
	name = "Sevtug's Wrath"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 15
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	say_when_triggered = "Let Sevtug consume you, feel his presence wipe your heretical conscious clear!"
	var/aoe_radius = 3

/datum/action/boss/brain_blast/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(boss.mid_ability)
		return FALSE
	return TRUE

/datum/action/boss/brain_blast/Trigger(trigger_flags)
	if(..())
		boss.mid_ability = TRUE
		boss.prevent_goto_movement = TRUE
		var/mob/living/simple_animal/armored_individual = boss
		armored_individual.damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5)
		for(var/turf/target_tile as anything in RANGE_TURFS(aoe_radius, boss))
			if(!(locate(/obj/effect/clockmaster_aoe_warning) in target_tile) && !(locate(/mob/living/simple_animal/hostile/boss/clockmaster/phase_two) in target_tile))
				new /obj/effect/clockmaster_aoe_warning(target_tile)
			addtimer(CALLBACK(src, .proc/BlastEm), 4 SECONDS)

/datum/action/boss/brain_blast/proc/BlastEm()
	var/mob/living/simple_animal/armored_individual = boss
	armored_individual.damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	boss.mid_ability = FALSE
	boss.prevent_goto_movement = FALSE
	playsound(boss, 'sound/misc/fart.ogg', 25)
	for(var/mob/living/nearby_mob in orange(2, boss))
		if(iscarbon(nearby_mob))
			var/mob/living/carbon/human/C = nearby_mob
			to_chat(C, span_warning("You feel a presence lash out violenty against your psyche as you're thrown back!"))
			C.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)
			C.adjustToxLoss(rand(10,15))
			C.set_timed_status_effect(30 SECONDS, /datum/status_effect/drugginess)	
		else
			to_chat(nearby_mob, span_warning("You're knocked back by a noxious blast!"))
			nearby_mob.adjustToxLoss(rand(30,35))
		var/atom/throw_target = get_edge_target_turf(nearby_mob, pick(GLOB.cardinals))
		nearby_mob.throw_at(throw_target, 4, 1)		

/obj/effect/clockmaster_aoe_warning
	name = "brain blast radius"
	desc = "brain hurty incoming"
	icon = 'icons/effects/effects.dmi'
	icon_state = "clockmaster_aoe"

/obj/effect/clockmaster_aoe_warning/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/DeleteMe), 4 SECONDS)

/obj/effect/clockmaster_aoe_warning/proc/DeleteMe()
	Destroy(src)

//Violently spin and move towards a random target. Walking into them causes severe damage and throws you back. Cannot be melee attacked during this, but also moves a bit slower
/datum/action/boss/spinning_bronze
	name = "Nzcrentr's Retribution"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 15
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	say_when_triggered = "Nzcrentr's power surges through me and it demands release!"
	var/mob/living/chosen_target = null

/datum/action/boss/spinning_bronze/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(boss.mid_ability)
		return FALSE
	return TRUE

/datum/action/boss/spinning_bronze/Trigger(trigger_flags)
	if(..())
		var/list/potential_targets = list()
		for(var/mob/living/nearby_mob in oview(9, boss))
			if(nearby_mob.stat != DEAD)
				nearby_mob += potential_targets
		chosen_target = pick(potential_targets)
		boss.point_at(chosen_target)
		boss.say("im bout to run ur ass over boy")
		boss.mid_ability = TRUE
		addtimer(CALLBACK(src, .proc/tackle_that_mfer), 2 SECONDS) //give the victim a moment to recognize they're about to be slammed before we slam

/datum/action/boss/spinning_bronze/proc/tackle_that_mfer()
	playsound(boss, 'sound/weapons/sonic_jackhammer.ogg', 50, TRUE)
	boss.throw_at(chosen_target, 7, 1.1, src, FALSE, FALSE, CALLBACK(GLOBAL_PROC, .proc/playsound, boss, 'sound/effects/meteorimpact.ogg', 50, TRUE, 2), INFINITY)
	sleep(4 SECONDS)
	boss.mid_ability = FALSE

//Summon 8 marauders from the nearby marauder spawn landmarks. Boss puts up a shield that lasts until all marauders are killed.
/datum/action/boss/marauder_swarm
	name = "Inath-Neq's Undying Legion"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 15
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	say_when_triggered = "Fallen warriors of the Resonant Cogs, arise and serve the will of the Justicar once more!"
	var/active_marauders = 0
	var/id = "clockmastermarauder"

/datum/action/boss/marauder_swarm/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(boss.mid_ability)
		return FALSE
	if(active_marauders > 1)
		return FALSE
	return TRUE

/datum/action/boss/marauder_swarm/Trigger(trigger_flags)
	if(..())
		boss.mid_ability = TRUE
		for(var/turf/target_tile as anything in RANGE_TURFS(1, boss))
			if(!(locate(/obj/structure/emergency_shield/clockmaster_plot_armor) in target_tile))
				new /obj/structure/emergency_shield/clockmaster_plot_armor(target_tile)
		for(var/obj/effect/landmark/clockworkmarauder_spawn/spawner in GLOB.landmarks_list)
			if(spawner.id == id)
				var/atom/marauder = new /mob/living/simple_animal/hostile/clockwork/marauder/weak(get_turf(spawner))
				RegisterSignal(marauder, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), .proc/lost_marauder)
				active_marauders = 8
	else
		boss.atb.refund(boss_cost)

/datum/action/boss/marauder_swarm/proc/lost_marauder(mob/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	active_marauders--
	if(active_marauders < 1)
		boss.mid_ability = FALSE
		for(var/obj/structure/emergency_shield/clockmaster_plot_armor/plot_armor in urange(1, boss))
			plot_armor.Destroy()

/obj/effect/landmark/clockworkmarauder_spawn
	name = "clockwork marauder spawn for the cool cult arena"
	var/id = "clockmastermarauder"

/mob/living/simple_animal/hostile/clockwork/marauder/weak //used for the ability spawn
	maxHealth = 45
	health = 45
