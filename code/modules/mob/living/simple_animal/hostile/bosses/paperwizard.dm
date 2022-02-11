//Paper Wizard Boss
/mob/living/simple_animal/hostile/boss/paper_wizard
	name = "Mjor the Creative"
	desc = "A wizard with a taste for the arts."
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	boss_abilities = list(/datum/action/boss/wizard_summon_minions, /datum/action/boss/wizard_mimic)
	faction = list("hostile","stickman")
	del_on_death = TRUE
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "paperwizard"
	ranged = 1
	environment_smash = ENVIRONMENT_SMASH_NONE
	minimum_distance = 3
	retreat_distance = 3
	obj_damage = 0
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 1000
	maxHealth = 1000
	loot = list(/obj/effect/temp_visual/paperwiz_dying)
	projectiletype = /obj/projectile/temp
	projectilesound = 'sound/weapons/emitter.ogg'
	attack_sound = 'sound/hallucinations/growl1.ogg'
	var/list/copies = list()

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/boss/paper_wizard/Destroy()
	QDEL_LIST(copies)
	return ..()

//Summon Ability
//Lets the wizard summon his art to fight for him
/datum/action/boss/wizard_summon_minions
	name = "Summon Minions"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "art_summon"
	usage_probability = 40
	boss_cost = 30
	boss_type = /mob/living/simple_animal/hostile/boss/paper_wizard
	needs_target = FALSE
	say_when_triggered = "Rise, my creations! Jump off your pages and into this realm!"
	///How many minions we summoned
	var/summoned_minions = 0
	///How many minions we can have at once
	var/max_minions = 6
	///How many minions we should spawn
	var/minions_to_summon = 3

/datum/action/boss/wizard_summon_minions/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(summoned_minions >= max_minions)
		return FALSE
	return TRUE

/datum/action/boss/wizard_summon_minions/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/list/minions = list(
		/mob/living/basic/stickman,
		/mob/living/basic/stickman/ranged,
		/mob/living/basic/stickman/dog)
	var/list/directions = GLOB.cardinals.Copy()
	var/summon_amount = min(minions_to_summon, max_minions - summoned_minions)
	for(var/i in 1 to summon_amount)
		var/atom/chosen_minion = pick_n_take(minions)
		chosen_minion = new chosen_minion(get_step(boss, pick_n_take(directions)))
		RegisterSignal(chosen_minion, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), .proc/lost_minion)
		summoned_minions++

/// Called when a minion is qdeleted or dies, removes it from our minion list
/datum/action/boss/wizard_summon_minions/proc/lost_minion(mob/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	summoned_minions--

//Mimic Ability
//Summons mimics of himself with magical papercraft
//Hitting a decoy hurts nearby people excluding the wizard himself
//Hitting the wizard himself destroys all decoys
/datum/action/boss/wizard_mimic
	name = "Craft Mimicry"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 30
	boss_cost = 40
	boss_type = /mob/living/simple_animal/hostile/boss/paper_wizard
	say_when_triggered = ""

/datum/action/boss/wizard_mimic/Trigger(trigger_flags)
	if(..())
		var/mob/living/target
		if(!boss.client) //AI's target
			target = boss.target
		else //random mob
			var/list/threats = boss.PossibleThreats()
			if(threats.len)
				target = pick(threats)
		if(target)
			var/mob/living/simple_animal/hostile/boss/paper_wizard/wiz = boss
			var/directions = GLOB.cardinals.Copy()
			for(var/i in 1 to 3)
				var/mob/living/simple_animal/hostile/boss/paper_wizard/copy/C = new (get_step(target,pick_n_take(directions)))
				wiz.copies += C
				C.original = wiz
				C.say("My craft defines me, you could even say it IS me!")
			wiz.say("My craft defines me, you could even say it IS me!")
			wiz.forceMove(get_step(target,pick_n_take(directions)))
			wiz.minimum_distance = 1 //so he doesn't run away and ruin everything
			wiz.retreat_distance = 0
		else
			boss.atb.refund(boss_cost)

/mob/living/simple_animal/hostile/boss/paper_wizard/copy
	desc = "'Tis a ruse!"
	health = 1
	maxHealth = 1
	alpha = 200
	boss_abilities = list()
	melee_damage_lower = 1
	melee_damage_upper = 5
	minimum_distance = 0
	retreat_distance = 0
	ranged = 0
	loot = list()
	var/mob/living/simple_animal/hostile/boss/paper_wizard/original

/mob/living/simple_animal/hostile/boss/paper_wizard/copy/Destroy()
	if(original)
		original.copies -= src
		original = null
	return ..()

//Hit a fake? eat pain!
/mob/living/simple_animal/hostile/boss/paper_wizard/copy/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0) //damage
		if(original)
			original.minimum_distance = 3
			original.retreat_distance = 3
			for(var/c in original.copies)
				qdel(c)
		for(var/mob/living/L in range(5,src))
			if(L == original || istype(L, type))
				continue
			L.adjustBruteLoss(50)
		qdel(src)
	else
		. = ..()

//Hit the real guy? copies go bai-bai
/mob/living/simple_animal/hostile/boss/paper_wizard/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0)//damage
		minimum_distance = 3
		retreat_distance = 3
		for(var/copy in copies)
			qdel(copy)

/mob/living/simple_animal/hostile/boss/paper_wizard/copy/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += span_notice("It's an illusion - what is it hiding?")
	else
		qdel(src) //I see through your ruse!

//fancy effects
/obj/effect/temp_visual/paper_scatter
	name = "scattering paper"
	desc = "Pieces of paper scattering to the wind."
	layer = ABOVE_OPEN_TURF_LAYER
	plane = GAME_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "paper_scatter"
	anchored = TRUE
	duration = 5
	randomdir = FALSE

/obj/effect/temp_visual/paperwiz_dying
	name = "craft portal"
	desc = "A wormhole sucking the wizard into the void. Neat."
	layer = ABOVE_OPEN_TURF_LAYER
	plane = GAME_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "paperwiz_poof"
	anchored = TRUE
	duration = 18
	randomdir = FALSE

/obj/effect/temp_visual/paperwiz_dying/Initialize(mapload)
	. = ..()
	visible_message(span_boldannounce("The wizard cries out in pain as a gate appears behind him, sucking him in!"))
	playsound(get_turf(src),'sound/magic/mandswap.ogg', 50, TRUE, TRUE)
	playsound(get_turf(src),'sound/hallucinations/wail.ogg', 50, TRUE, TRUE)

/obj/effect/temp_visual/paperwiz_dying/Destroy()
	for(var/mob/M in range(7,src))
		shake_camera(M, 7, 1)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/summon_magic.ogg', 50, TRUE, TRUE)
	new /obj/effect/temp_visual/paper_scatter(T)
	new /obj/item/clothing/suit/wizrobe/paper(T)
	new /obj/item/clothing/head/collectable/paper(T)
	return ..()
