/datum/action/bloodsucker/gangrel
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	background_icon_state = "gangrel_power_off"
	background_icon_state_on = "gangrel_power_on"
	background_icon_state_off = "gangrel_power_off"

/datum/action/bloodsucker/gangrel/transform
	name = "Transform"
	desc = "Allows you to unleash your inner form and turn into something greater."
	button_icon_state = "power_gangrel"
	power_explanation = "<b>Transform</b>:\n\
		A gangrel only power, will turn you into a feral being depending on your blood sucked.\n\
		May have unforseen consequences if used on low blood sucked, upgrades every 500 units.\n\
		Some forms have special abilites to them depending on what abilites you have.\n\
		Be wary of your blood status when using it, takes 10 seconds of standing still to transform!"
	power_flags = BP_AM_SINGLEUSE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = NONE
	bloodcost = 100
	cooldown = 10 SECONDS

/mob/living/simple_animal/hostile/bloodsucker
	var/mob/living/controller

/mob/living/simple_animal/hostile/bloodsucker/werewolf
	name = "werewolf"
	desc = "Who could imagine this things 'were' actually real?"
	icon = 'icons/mob/bloodsucker_mobs.dmi'
	icon_state = "wolfform"
	icon_living = "wolfform"
	icon_dead = "batform"
	icon_gib = "batform"
	speed = -2
	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	speak_chance = 0
	maxHealth = 800
	health = 800
	see_in_dark = 10
	harm_intent_damage = 20
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "violently mawls"
	attack_verb_simple = "violently mawl"
	butcher_results = list(/obj/item/food/meat/slab = 5)
	faction = list("hostile", "bloodhungry")
	attack_sound = 'sound/weapons/slash.ogg'
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_WALLS
	mob_size = MOB_SIZE_LARGE
	movement_type = GROUND
	gold_core_spawnable = FALSE
	speak_emote = list("gnashes")

/mob/living/simple_animal/hostile/bloodsucker/giantbat
	name = "giant bat"
	desc = "That's a fat ass bat."
	icon = 'icons/mob/bloodsucker_mobs.dmi'
	icon_state = "batform"
	icon_living = "batform"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	move_to_delay = 2
	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	speak_chance = 0
	maxHealth = 700
	health = 700
	see_in_dark = 10
	harm_intent_damage = 20
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	butcher_results = list(/obj/item/food/meat/slab = 3)
	faction = list("hostile", "bloodhungry")
	attack_sound = 'sound/weapons/bite.ogg'
	obj_damage = 35
	pass_flags = PASSTABLE | PASSMACHINE
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	mob_size = MOB_SIZE_LARGE
	movement_type = FLYING
	gold_core_spawnable = FALSE
	speak_emote = list("loudly squeaks")

/mob/living/simple_animal/hostile/bloodsucker/Destroy() //makes us alive again
	if(controller && mind)
		visible_message(span_warning("[src] rapidly transforms into a humanoid figure!"), span_warning("You forcefully return to your normal form."))
		playsound(src, 'sound/weapons/slash.ogg', 50, 1)
		if(mind)
			mind.transfer_to(controller)
		controller.forceMove(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/bloodsucker/death()
	if(controller)
		mind.transfer_to(controller)
		controller.death()
	addtimer(CALLBACK(src, .proc/gib), 20 SECONDS)
	..()

/datum/action/bloodsucker/gangrel/transform/ActivatePower()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/mob/living/carbon/human/user = owner
	var/datum/species/user_species = user.dna.species
	user.Immobilize(10 SECONDS)
	if(!do_mob(user, user, 10 SECONDS, 1))
		return
	switch(bloodsuckerdatum.total_blood_drank)
		if(0 to 1500)
			if(isfelinid(user))
				user.set_species(/datum/species/lizard)
				playsound(user.loc, 'sound/voice/lizard/hiss.ogg', 50)
			else
				user.set_species(/datum/species/human/felinid)
				playsound(user.loc, 'sound/effects/meow1.ogg', 50)
				if(DIGITIGRADE in user_species.species_traits)
					user_species.species_traits -= DIGITIGRADE
			user_species.punchdamagehigh += 5.0 //stronk
			user_species.armor += 30
			to_chat(user, span_notice("You aren't strong enough to morph into something stronger! But you do certainly feel more feral and stronger than before."))
		if(1500 to INFINITY)
			var/mob/living/simple_animal/hostile/bloodsucker/giantbat/gb
			if(!gb || gb.stat == DEAD)
				gb = new /mob/living/simple_animal/hostile/bloodsucker/giantbat(user.loc)
				user.forceMove(gb)
				gb.controller = user
				user.mind.transfer_to(gb)
				var/list/bat_powers = list(new /datum/action/bloodsucker/gangrel/transform_back,)
				for(var/datum/action/bloodsucker/power in bloodsuckerdatum.powers)
					if(istype(power, /datum/action/bloodsucker/targeted/haste))
						bat_powers += new /datum/action/bloodsucker/targeted/haste/batdash
					if(istype(power, /datum/action/bloodsucker/targeted/mesmerize))
						bat_powers += new /datum/action/bloodsucker/targeted/bloodbolt
					if(istype(power, /datum/action/bloodsucker/targeted/brawn))
						bat_powers += new /datum/action/bloodsucker/gangrel/wingslam
				for(var/datum/action/bloodsucker/power in bat_powers) 
					power.Grant(gb)
				QDEL_IN(gb, 2 MINUTES)
				playsound(gb.loc, 'sound/items/toysqueak1.ogg', 50, 1)
			to_chat(owner, span_notice("You transform into a fatty beast!"))
		/*if(2000 to INFINITY)
			var/mob/living/simple_animal/hostile/bloodsucker/werewolf/ww
			if(!ww || ww.stat == DEAD)
				ww = new /mob/living/simple_animal/hostile/bloodsucker/werewolf(user.loc)
				user.forceMove(ww)
				ww.controller = user
				user.mind.transfer_to(ww)
				var/datum/action/bloodsucker/gangrel/transform_back/E = new
				E.Grant(ww)
				playsound(ww.loc, 'sound/weapons/slash.ogg', 50, 1)
			to_chat(owner, span_notice("You transform into a feral beast!"))*/
	. = ..()

/datum/action/bloodsucker/gangrel/transform_back
	name = "Transform"
	desc = "Regress back into a human."
	button_icon_state = "power_gangrel"
	power_explanation = "<b>Transform</b>:\n\
		Regress back to your humanoid form early, requires you to stand still.\n\
		Beware you will not be able to transform again until the night passes!"
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = NONE
	cooldown = 10 SECONDS

/datum/action/bloodsucker/gangrel/transform_back/ActivatePower()
	var/mob/living/user = owner
	if(!do_mob(user, user, 10 SECONDS))
		return
	var/mob/living/simple_animal/hostile/bloodsucker/bs
	qdel(owner)
	qdel(bs)
	. = ..()

/datum/action/bloodsucker/targeted/haste/batdash
	name = "Flying Haste"
	desc = "Propulse yourself into a position of advantage."
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_baste"
	background_icon_state_on = "bat_power_on"
	background_icon_state_off = "bat_power_off"
	power_explanation = "<b>Flying Haste</b>:\n\
		Makes you dash into the air, creating a smoke cloud at the end.\n\
		Helpful in situations where you either need to run away or engage in a crowd of people, works over tables.\n\
		Created from your Immortal Haste ability."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 0
	cooldown = 15 SECONDS

/datum/action/bloodsucker/targeted/haste/batdash/CheckCanUse(mob/living/carbon/user)
	var/mob/living/L = user
	if(L.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/bloodsucker/targeted/haste/batdash/FireTargetedPower(atom/target_atom)
	. = ..()
	do_smoke(2, owner.loc, smoke_type = /obj/effect/particle_effect/smoke/transparent) //so you can attack people after hasting

/datum/action/bloodsucker/targeted/bloodbolt
	name = "Blood Bolt"
	desc = "Shoot a blood bolt to damage your foes."
	button_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_gangrel_bloodsucker.dmi'
	button_icon_state = "power_bolt"
	background_icon_state_on = "bat_power_on"
	background_icon_state_off = "bat_power_off"
	power_explanation = "<b>Blood Bolt</b>:\n\
		Shoots a blood bolt that does moderate damage to your foes.\n\
		Helpful in situations where you get outranged or just extra damage.\n\
		Created from your Mesmerize ability."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 0
	cooldown = 12.5 SECONDS

/datum/action/bloodsucker/targeted/bloodbolt/CheckCanUse(mob/living/carbon/user)
	var/mob/living/L = user
	if(L.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/bloodsucker/targeted/bloodbolt/FireTargetedPower(atom/target_atom)
	. = ..()

	var/mob/living/user = owner
	to_chat(user, span_warning("You fire a blood bolt!"))
	user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target_atom, user))
	var/obj/projectile/magic/bloodsucker/magic_9ball = new(user.loc)
	magic_9ball.bloodsucker_power = src
	magic_9ball.firer = user
	magic_9ball.def_zone = ran_zone(user.zone_selected)
	magic_9ball.preparePixelProjectile(target_atom, user)
	INVOKE_ASYNC(magic_9ball, /obj/projectile.proc/fire)
	playsound(user, 'sound/magic/wand_teleport.ogg', 60, TRUE)
	PowerActivatedSuccessfully()

/obj/projectile/magic/bloodsucker
	name = "blood bolt"
	icon_state = "bloodbolt"
	damage_type = BURN
	nodamage = FALSE
	damage = 30
	hitsound = 'sound/weapons/barragespellhit.ogg'
	var/datum/action/bloodsucker/targeted/bloodbolt/bloodsucker_power

/obj/projectile/magic/bloodsucker/on_hit(target)
	if(ismob(target))
		qdel(src)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.Knockdown(0.1)
		return BULLET_ACT_HIT
	. = ..()

/datum/action/bloodsucker/gangrel/wingslam
	name = "Wing Slam"
	desc = "Slams all foes next to you."
	button_icon_state = "power_wingslam"
	background_icon_state_on = "bat_power_on"
	background_icon_state_off = "bat_power_off"
	power_explanation = "<b>Wing Slam</b>:\n\
		Knocksback and immobilizes people adjacent to you.\n\
		Has a low recharge time and may be helpful in meelee situations!\n\
		Created from your Brawn ability."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 0
	cooldown = 10 SECONDS

/datum/action/bloodsucker/gangrel/wingslam/ActivatePower()
	var/mob/living/user = owner
	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1, user))
		choices += C

	if(!choices.len)
		return

	for(var/mob/living/carbon/M in range(1, user))
		if(!M || !M.Adjacent(user))
			return
		if(M.loc == user)
			continue
		M.visible_message(
			span_danger("[user] flaps their wings viciously, sending [M] flying away!"), \
			span_userdanger("You were sent flying by the flap of [user]'s wings!"),
		)
		to_chat(user, span_warning("You flap your wings, sending [M] flying!"))
		playsound(user.loc, 'sound/weapons/punch4.ogg', 60, 1, -1)
		M.adjustBruteLoss(10)
		M.Knockdown(40)
		user.do_attack_animation(M, ATTACK_EFFECT_SMASH)
		var/send_dir = get_dir(user, M)
		var/turf/turf_thrown_at = get_ranged_target_turf(M, send_dir, 5)
		M.throw_at(turf_thrown_at, 5, TRUE, user) 
