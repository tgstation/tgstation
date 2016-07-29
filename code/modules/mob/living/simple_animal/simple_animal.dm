<<<<<<< HEAD
=======
var/const/ANIMAL_CHILD_CAP = 50
var/global/list/animal_count = list() //Stores types, and amount of animals of that type associated with the type (example: /mob/living/simple_animal/dog = 10)
//Animals can't breed if amount of children exceeds 50

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
<<<<<<< HEAD

	status_flags = CANPUSH

	var/icon_living = ""
	var/icon_dead = "" //icon when the animal is dead. Don't use animated icons for this.
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	var/list/speak = list()
	var/list/speak_emote = list()//	Emotes while speaking IE: Ian [emote], [text] -- Ian barks, "WOOF!". Spoken text is generated from the speak variable.
=======
	treadmill_speed = 0.5 //Ian & pals aren't as good at powering a treadmill

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	var/list/speak = list()
	//var/list/speak_emote = list()//	Emotes while speaking IE: Ian [emote], [text] -- Ian barks, "WOOF!". Spoken text is generated from the speak variable.
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/turns_per_move = 1
	var/turns_since_move = 0
<<<<<<< HEAD
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = 1	// Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = 1 //When set to 1 this stops the animal from moving when someone is pulling it.

	//Interaction
	var/response_help   = "pokes"
	var/response_disarm = "shoves"
	var/response_harm   = "hits"
	var/harm_intent_damage = 3
<<<<<<< HEAD
	var/force_threshold = 0 //Minimum force required to deal any damage
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350
<<<<<<< HEAD

	//Healable by medical stacks? Defaults to yes.
	var/healable = 1

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/list/atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0) //Leaving something at 0 means it's off - has no maximum
	var/unsuitable_atmos_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above
=======
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	var/fire_alert = 0
	var/oxygen_alert = 0
	var/toxins_alert = 0

	var/show_stat_health = 1	//does the percentage health show in the stat panel for the mob

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5
	var/max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_atoms_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above


	mob_bump_flag = SIMPLE_ANIMAL
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
<<<<<<< HEAD
	var/armour_penetration = 0 //How much armour they ignore, as a flat reduction from the targets armour value
	var/melee_damage_type = BRUTE //Damage type of a simple mob's melee attack, should it do damage.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) // 1 for full damage , 0 for none , -1 for 1:1 heal from that source
=======
	var/melee_damage_type = BRUTE
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/attacktext = "attacks"
	var/attack_sound = null
	var/friendly = "nuzzles" //If the mob does no damage with it's attack
	var/environment_smash = 0 //Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls

<<<<<<< HEAD
	var/speed = 1 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster

	//Hot simple_animal baby making vars
	var/list/childtype = null
	var/scan_ready = 1
	var/animal_species //Sorry, no spider+corgi buttbabies.

	//simple_animal access
	var/obj/item/weapon/card/id/access_card = null	//innate access uses an internal ID card
	var/flying = 0 //whether it's flying or touching the ground.
	var/buffed = 0 //In the event that you want to have a buffing effect on the mob, but don't want it to stack with other effects, any outside force that applies a buff to a simple mob should at least set this to 1, so we have something to check against
	var/gold_core_spawnable = 0 //if 1 can be spawned by plasma with gold core, 2 are 'friendlies' spawned with blood

	var/mob/living/simple_animal/hostile/spawner/nest

	var/sentience_type = SENTIENCE_ORGANIC // Sentience type, for slime potions

	var/list/loot = list() //list of things spawned at mob's loc when it dies
	var/del_on_death = 0 //causes mob to be deleted on death, useful for mobs that spawn lootable corpses
	var/deathmessage = ""
	var/death_sound = null //The sound played on death

	var/allow_movement_on_non_turfs = FALSE

	var/attacked_sound = "punch" //Played when someone punches the creature

	var/dextrous = FALSE //If the creature has, and can use, hands
	var/dextrous_hud_type = /datum/hud/dextrous
	var/datum/personal_crafting/handcrafting


/mob/living/simple_animal/New()
	..()
	handcrafting = new()
	verbs -= /mob/verb/observe
	if(!real_name)
		real_name = name
	if(!loc)
		stack_trace("Simple animal being instantiated in nullspace")

/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = list()
		client.screen += client.void
	..()

/mob/living/simple_animal/updatehealth()
	..()
	health = Clamp(health, 0, maxHealth)

/mob/living/simple_animal/Life()
	if(..()) //alive
		if(!ckey)
			handle_automated_movement()
			handle_automated_action()
			handle_automated_speech()
		return 1

/mob/living/simple_animal/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			stat = CONSCIOUS
	med_hud_set_status()


/mob/living/simple_animal/handle_status_effects()
	..()
	if(stuttering)
		stuttering = 0

/mob/living/simple_animal/proc/handle_automated_action()
	return

/mob/living/simple_animal/proc/handle_automated_movement()
	if(!stop_automated_movement && wander)
		if((isturf(src.loc) || allow_movement_on_non_turfs) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Some animals don't move when pulled
					var/anydir = pick(cardinal)
					if(Process_Spacemove(anydir))
						Move(get_step(src, anydir), anydir)
						turns_since_move = 0
			return 1

/mob/living/simple_animal/proc/handle_automated_speech(var/override)
	if(speak_chance)
		if(prob(speak_chance) || override)
=======
	var/speed = 0 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster

	//Hot simple_animal baby making vars
	var/childtype = null
	var/child_amount = 1
	var/scan_ready = 1
	var/can_breed = 0

	//Null rod stuff
	var/supernatural = 0
	var/purge = 0

	//For those that we want to just pop back up a little while after they're killed
	var/canRegenerate = 0 //If 1, it qualifies for regeneration
	var/isRegenerating = 0 //To stop life calling the proc multiple times
	var/minRegenTime = 0
	var/maxRegenTime = 0

	universal_speak = 1
	universal_understand = 1

	var/life_tick = 0
	var/list/colourmatrix = list()

/mob/living/simple_animal/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]

	var/damage = ((world.time - lastcheck)/10)  * (B.get_damage()/2)

	// Actually apply damage
	health -= damage

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

/mob/living/simple_animal/rejuvenate(animation = 0)
	var/turf/T = get_turf(src)
	if(animation) T.turf_animation('icons/effects/64x64.dmi',"rejuvinate",-16,0,MOB_LAYER+1,'sound/effects/rejuvinate.ogg',anim_plane = PLANE_EFFECTS)
	src.health = src.maxHealth
	return 1
/mob/living/simple_animal/New()
	..()
	verbs -= /mob/verb/observe
	if(!real_name)
		real_name = name

	animal_count[src.type]++

/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.reset_screen()
	..()

/mob/living/simple_animal/updatehealth()
	return

/mob/living/simple_animal/airflow_stun()
	return

/mob/living/simple_animal/airflow_hit(atom/A)
	return

// For changing wander behavior
/mob/living/simple_animal/proc/wander_move(var/turf/dest)
	Move(dest)

/mob/living/simple_animal/Life()
	if(timestopped) return 0 //under effects of time magick
	..()

	//Health
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			src.resurrect()
			stat = CONSCIOUS
			density = 1
			update_canmove()
		if(canRegenerate && !isRegenerating)
			src.delayedRegen()
		return 0


	if(health < 1 && stat != DEAD)
		Die()
		return 0

	life_tick++

	health = min(health, maxHealth)

	if(stunned)
		AdjustStunned(-1)
	if(weakened)
		AdjustWeakened(-1)
	if(paralysis)
		AdjustParalysis(-1)

	//Eyes
	if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
		blinded = 1
	else if(eye_blind)			//blindness, heals slowly over time
		eye_blind = max(eye_blind-1,0)
		blinded = 1
	else if(eye_blurry)	//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)

	//Ears
	if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
		ear_deaf = max(ear_deaf, 1)
	else if(ear_deaf)			//deafness, heals slowly over time
		ear_deaf = max(ear_deaf-1, 0)
	else if(ear_damage < 25)	//ear damage heals slowly under this threshold.
		ear_damage = max(ear_damage-0.05, 0)

	confused = max(0, confused - 1)

	if(purge)
		purge -= 1

	isRegenerating = 0

	//Movement
	if((!client||deny_client_move) && !stop_automated_movement && wander && !anchored && (ckey == null) && !(flags & INVULNERABLE))
		if(isturf(src.loc) && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Some animals don't move when pulled
					var/destination = get_step(src, pick(cardinal))
					wander_move(destination)
					turns_since_move = 0

	//Speaking
	if(!client && speak_chance && (ckey == null))
		if(rand(0,200) < speak_chance)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
<<<<<<< HEAD
							emote("me", 1, pick(emote_see))
						else
							emote("me", 2, pick(emote_hear))
=======
							emote(pick(emote_see),1)
						else
							emote(pick(emote_hear),2)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
<<<<<<< HEAD
					emote("me", 1, pick(emote_see))
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote("me", 2, pick(emote_hear))
=======
					emote(pick(emote_see),1)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote(pick(emote_hear),2)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
<<<<<<< HEAD
						emote("me", 1, pick(emote_see))
					else
						emote("me", 2, pick(emote_hear))


/mob/living/simple_animal/handle_environment(datum/gas_mixture/environment)
	var/atmos_suitable = 1

	if(pulledby && pulledby.grab_state >= GRAB_KILL && atmos_requirements["min_oxy"])
		atmos_suitable = 0 //getting choked

	var/atom/A = src.loc
	if(isturf(A))
		var/turf/T = A
		var/areatemp = get_temperature(environment)
		if( abs(areatemp - bodytemperature) > 40 )
			var/diff = areatemp - bodytemperature
			diff = diff / 5
			//world << "changed from [bodytemperature] by [diff] to [bodytemperature + diff]"
			bodytemperature += diff

		if(istype(T,/turf/open))
			var/turf/open/ST = T
			if(ST.air)
				var/ST_gases = ST.air.gases
				ST.air.assert_gases(arglist(hardcoded_gases))

				var/tox = ST_gases["plasma"][MOLES]
				var/oxy = ST_gases["o2"][MOLES]
				var/n2  = ST_gases["n2"][MOLES]
				var/co2 = ST_gases["co2"][MOLES]

				ST.air.garbage_collect()

				if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
					atmos_suitable = 0
				else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
					atmos_suitable = 0
				else if(atmos_requirements["min_tox"] && tox < atmos_requirements["min_tox"])
					atmos_suitable = 0
				else if(atmos_requirements["max_tox"] && tox > atmos_requirements["max_tox"])
					atmos_suitable = 0
				else if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
					atmos_suitable = 0
				else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
					atmos_suitable = 0
				else if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
					atmos_suitable = 0
				else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
					atmos_suitable = 0

				if(!atmos_suitable)
					adjustBruteLoss(unsuitable_atmos_damage)

		else
			if(atmos_requirements["min_oxy"] || atmos_requirements["min_tox"] || atmos_requirements["min_n2"] || atmos_requirements["min_co2"])
				adjustBruteLoss(unsuitable_atmos_damage)

	handle_temperature_damage()

/mob/living/simple_animal/proc/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(2)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(3)

/mob/living/simple_animal/gib()
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1; i <= butcher_results[path];i++)
				new path(src.loc)
	..()

/mob/living/simple_animal/gib_animation()
	if(icon_gib)
		new /obj/effect/overlay/temp/gib_animation/animal(loc, icon_gib)

/mob/living/simple_animal/blob_act(obj/effect/blob/B)
	adjustBruteLoss(20)
	return

/mob/living/simple_animal/say_quote(input)
	var/ending = copytext(input, length(input))
	if(speak_emote && speak_emote.len && ending != "?" && ending != "!")
		var/emote = pick(speak_emote)
		if(emote)
			return "[emote], \"[input]\""
	return ..()

/mob/living/simple_animal/emote(act, m_type=1, message = null)
	if(stat)
		return
	if(act == "scream")
		message = "makes a loud and pained whimper." //ugly hack to stop animals screaming when crushed :P
		act = "me"
	..(act, m_type, message)

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M)
	if(..())
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		attack_threshold_check(damage,M.melee_damage_type)
		return 1

/mob/living/simple_animal/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return
	apply_damage(Proj.damage, Proj.damage_type)
	Proj.on_hit(src)
	return 0

/mob/living/simple_animal/proc/adjustHealth(amount)
	if(status_flags & GODMODE)
		return 0
	bruteloss = Clamp(bruteloss + amount, 0, maxHealth)
	updatehealth()
	return amount

/mob/living/simple_animal/adjustBruteLoss(amount)
	if(damage_coeff[BRUTE])
		. = adjustHealth(amount*damage_coeff[BRUTE])

/mob/living/simple_animal/adjustFireLoss(amount)
	if(damage_coeff[BURN])
		. = adjustHealth(amount*damage_coeff[BURN])

/mob/living/simple_animal/adjustOxyLoss(amount)
	if(damage_coeff[OXY])
		. = adjustHealth(amount*damage_coeff[OXY])

/mob/living/simple_animal/adjustToxLoss(amount)
	if(damage_coeff[TOX])
		. = adjustHealth(amount*damage_coeff[TOX])

/mob/living/simple_animal/adjustCloneLoss(amount)
	if(damage_coeff[CLONE])
		. = adjustHealth(amount*damage_coeff[CLONE])

/mob/living/simple_animal/adjustStaminaLoss(amount)
	return

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M)
	..()
	switch(M.a_intent)

		if("help")
			if (health > 0)
				visible_message("<span class='notice'>[M] [response_help] [src].</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if("grab")
			grabbedby(M)

		if("harm", "disarm")
			M.do_attack_animation(src)
			visible_message("<span class='danger'>[M] [response_harm] [src]!</span>")
			playsound(loc, attacked_sound, 25, 1, -1)
			attack_threshold_check(harm_intent_damage)
			add_logs(M, src, "attacked")
			updatehealth()
			return 1

/mob/living/simple_animal/attack_paw(mob/living/carbon/monkey/M)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			var/damage = rand(1, 3)
			attack_threshold_check(damage)
			return 1
	if (M.a_intent == "help")
		if (health > 0)
			visible_message("<span class='notice'>[M.name] [response_help] [src].</span>")
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

	return

/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		if(M.a_intent == "disarm")
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] [response_disarm] [name]!</span>", \
					"<span class='userdanger'>[M] [response_disarm] [name]!</span>")
			add_logs(M, src, "disarmed")
		else
			var/damage = rand(15, 30)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
					"<span class='userdanger'>[M] has slashed at [src]!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			attack_threshold_check(damage)
			add_logs(M, src, "attacked")
		return 1

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite
		var/damage = rand(5, 10)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			attack_threshold_check(damage)
		return 1

/mob/living/simple_animal/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(15, 25)
		if(M.is_adult)
			damage = rand(20, 35)
		attack_threshold_check(damage)
		return 1

/mob/living/simple_animal/proc/attack_threshold_check(damage, damagetype = BRUTE)
	if(damage <= force_threshold || !damage_coeff[damagetype])
		visible_message("<span class='warning'>[src] looks unharmed.</span>")
	else
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/simple_animal/movement_delay()
	. = ..()

	. = speed

	. += config.animal_delay

/mob/living/simple_animal/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Health: [round((health / maxHealth) * 100)]%")
		return 1

/mob/living/simple_animal/death(gibbed)
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	if(loot.len)
		for(var/i in loot)
			new i(loc)
	if(dextrous)
		unEquip(r_hand)
		unEquip(l_hand)
	if(!gibbed)
		if(death_sound)
			playsound(get_turf(src),death_sound, 200, 1)
		if(deathmessage)
			visible_message("<span class='danger'>\The [src] [deathmessage]</span>")
		else if(!del_on_death)
			visible_message("<span class='danger'>\The [src] stops moving...</span>")
	if(del_on_death)
		ghostize()
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		stat = DEAD
		density = 0
		lying = 1
	..()

/mob/living/simple_animal/ex_act(severity, target)
	..()
	var/bomb_armor = getarmor(null, "bomb")
	switch (severity)
		if (1)
			if(prob(bomb_armor))
				adjustBruteLoss(500)
			else
				gib()
				return
		if (2)
			var/bloss = 60
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

		if(3)
			var/bloss = 30
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

/mob/living/simple_animal/proc/CanAttack(atom/the_target)
	if(see_invisible < the_target.invisibility)
		return 0
	if (isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS)
			return 0
	if (istype(the_target, /obj/mecha))
		var/obj/mecha/M = the_target
		if (M.occupant)
			return 0
	return 1

/mob/living/simple_animal/handle_fire()
	return

/mob/living/simple_animal/update_fire()
	return

/mob/living/simple_animal/IgniteMob()
	return FALSE

/mob/living/simple_animal/ExtinguishMob()
	return

/mob/living/simple_animal/revive(full_heal = 0, admin_revive = 0)
	if(..()) //successfully ressuscitated from death
		icon = initial(icon)
		icon_state = icon_living
		density = initial(density)
		lying = 0
		. = 1

/mob/living/simple_animal/fully_heal(admin_revive = 0)
	health = maxHealth
	..()

/mob/living/simple_animal/proc/make_babies() // <3 <3 <3
	if(gender != FEMALE || stat || !scan_ready || !childtype || !animal_species || ticker.current_state != GAME_STATE_PLAYING)
		return 0
=======
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)


	//Atmos
	if(flags & INVULNERABLE)
		return 1

	var/atmos_suitable = 1

	var/atom/A = loc

	if(isturf(A))
		var/turf/T = A
		var/datum/gas_mixture/Environment = T.return_air()

		if(Environment)
			if(abs(Environment.temperature - bodytemperature) > 40)
				bodytemperature += ((Environment.temperature - bodytemperature) / 5)

			if(min_oxy)
				if(Environment.oxygen < min_oxy)
					atmos_suitable = 0
					oxygen_alert = 1
				else
					oxygen_alert = 0

			if(max_oxy)
				if(Environment.oxygen > max_oxy)
					atmos_suitable = 0

			if(min_tox)
				if(Environment.toxins < min_tox)
					atmos_suitable = 0

			if(max_tox)
				if(Environment.toxins > max_tox)
					atmos_suitable = 0
					toxins_alert = 1
				else
					toxins_alert = 0

			if(min_n2)
				if(Environment.nitrogen < min_n2)
					atmos_suitable = 0

			if(max_n2)
				if(Environment.nitrogen > max_n2)
					atmos_suitable = 0

			if(min_co2)
				if(Environment.carbon_dioxide < min_co2)
					atmos_suitable = 0

			if(max_co2)
				if(Environment.carbon_dioxide > max_co2)
					atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		fire_alert = 2
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		fire_alert = 1
		adjustBruteLoss(heat_damage_per_tick)
	else
		fire_alert = 0

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atoms_damage)

	if(can_breed)
		make_babies()

	return 1

/mob/living/simple_animal/gib(var/animation = 0, var/meat = 1)
	if(icon_gib)
		flick(icon_gib, src)

	if(meat && meat_type)
		for(var/i = 0; i < (src.size - meat_taken); i++)
			drop_meat(get_turf(src))

	..()


/mob/living/simple_animal/blob_act()
	..()
	adjustBruteLoss(20)
	return

/mob/living/simple_animal/say_quote(var/text)
	if(speak_emote && speak_emote.len)
		var/emote = pick(speak_emote)
		if(emote)
			return "[emote], [text]"
	return "says, [text]";

/mob/living/simple_animal/emote(var/act, var/type, var/desc, var/auto)
	if(timestopped) return //under effects of time magick
	if(stat)
		return
	if(act == "scream")
		desc = "makes a loud and pained whimper"  //ugly hack to stop animals screaming when crushed :P
		act = "me"
	..(act, type, desc)

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>[M.attacktext] [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [M.attacktext] by [M.name] ([M.ckey])</font>")
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)

		visible_message("<span class='warning'><B>\The [M]</B> [M.attacktext] \the [src]!</span>")

		add_logs(M, src, "attacked", admin=0)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(M.melee_damage_type == "BRAIN") //because brain damage is apparently not a proper damage type like all the others
			adjustBrainLoss(damage)
		else
			adjustBruteLoss(damage,M.melee_damage_type)
		updatehealth()

/mob/living/simple_animal/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)	return
	// FUCK mice. - N3X
	if(ismouse(src) && (Proj.stun+Proj.weaken+Proj.paralyze+Proj.agony)>5)
		var/mob/living/simple_animal/mouse/M=src
		to_chat(M, "<span class='warning'>What would probably not kill a human completely overwhelms your tiny body.</span>")
		M.splat()
		return 0
	adjustBruteLoss(Proj.damage)
	Proj.on_hit(src, 0)
	return 0

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if(I_HELP)
			if (health > 0)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("<span class='notice'>[M] [response_help] [src].</span>")

		if(I_GRAB)
			if (M == src || anchored)
				return
			if (!(status_flags & CANPUSH))
				return

			var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab,M,src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()
			G.affecting = src
			LAssailant = M

			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")

		if(I_HURT, I_DISARM)
			adjustBruteLoss(harm_intent_damage)

			visible_message("<span class='warning'>[M] [response_harm] [src]!</span>")

	return

/mob/living/simple_animal/MouseDrop(mob/living/carbon/human/M)
	if(M != usr || !istype(M) || !Adjacent(M) || M.incapacitated())
		return

	if(locked_to) //Atom locking
		return

	var/strength_of_M = (M.size - 1) //Can only pick up mobs whose size is less or equal to this value. Normal human's size is 3, so his strength is 2 - he can pick up TINY and SMALL animals. Varediting human's size to 5 will allow him to pick up goliaths.

	if((M.a_intent != I_HELP) && (src.size <= strength_of_M) && (isturf(src.loc)) && (src.holder_type))
		scoop_up(M)
	else
		..()

/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/humanoid/M as mob)

	switch(M.a_intent)

		if (I_HELP)

			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>"), 1)
		if (I_GRAB)
			if(M == src || anchored)
				return
			if(!(status_flags & CANPUSH))
				return

			var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab,M,src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()
			G.affecting = src
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("<span class='warning'>[] has grabbed [] passively!</span>", M, src), 1)

		if(I_HURT, I_DISARM)
			var/damage = rand(15, 30)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>")
			adjustBruteLoss(damage)

	return

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[L] rubs it's head against [src]</span>")


		else

			var/damage = rand(5, 10)
			visible_message("<span class='danger'>[L] bites [src]!</span>")

			if(stat != DEAD)
				adjustBruteLoss(damage)
				L.amount_grown = min(L.amount_grown + damage, L.max_grown)


/mob/living/simple_animal/attack_slime(mob/living/carbon/slime/M as mob)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim) return // can't attack while eating!

	visible_message("<span class='danger'>[M.name] glomps [src]!</span>")
	add_logs(M, src, "glomped on", 0)

	var/damage = rand(1, 3)

	if(istype(M,/mob/living/carbon/slime/adult))
		damage = rand(20, 40)
	else
		damage = rand(5, 35)

	adjustBruteLoss(damage)


	return


/mob/living/simple_animal/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/stack/medical))
		user.delayNextAttack(4)
		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.use(1))
					adjustBruteLoss(-MED.heal_brute)
					src.visible_message("<span class='notice'>[user] applies \the [MED] to \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>This [src] is dead, medical items won't bring it back to life.</span>")
	else if((meat_type || butchering_drops) && (stat == DEAD))	//if the animal has a meat, and if it is dead.
		if(O.is_sharp())
			if(user.a_intent != I_HELP)
				to_chat(user, "<span class='info'>You must be on <b>help</b> intent to do this!</span>")
			else
				butcher()
				return 1
	else
		user.delayNextAttack(8)
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			if(supernatural && istype(O,/obj/item/weapon/nullrod))
				damage *= 2
				purge = 3
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='danger'>[src] has been attacked with the [O] by [user]. </span>")
		else
			to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='warning'>[user] gently taps [src] with the [O]. </span>")

/mob/living/simple_animal/movement_delay()
	var/tally = 0 //Incase I need to add stuff other than "speed" later

	tally = speed

	if(purge)//Purged creatures will move more slowly. The more time before their purge stops, the slower they'll move. (muh dotuh)
		if(tally <= 0)
			tally = 1
		tally *= purge

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

		if(tally == -1)
			return tally

	return tally+config.animal_delay

/mob/living/simple_animal/Stat()
	..()

	if(statpanel("Status") && show_stat_health)
		stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/proc/Die()
	health = 0 // so /mob/living/simple_animal/Life() doesn't magically revive them
	living_mob_list -= src
	dead_mob_list += src
	icon_state = icon_dead
	stat = DEAD
	density = 0

	animal_count[src.type]--
	if(!src.butchering_drops && animal_butchering_products[src.species_type]) //If we already created a list of butchering drops, don't create another one
		var/list/L = animal_butchering_products[src.species_type]
		src.butchering_drops = list()

		for(var/butchering_type in L)
			src.butchering_drops += new butchering_type

	verbs += /mob/living/proc/butcher

	return

/mob/living/simple_animal/death(gibbed)
	if(stat == DEAD)
		return

	if(!gibbed)
		visible_message("<span class='danger'>\the [src] stops moving...</span>")

	Die()

/mob/living/simple_animal/ex_act(severity)
	if(flags & INVULNERABLE)
		return
	..()
	switch (severity)
		if (1.0)
			adjustBruteLoss(500)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/adjustBruteLoss(damage)
	health = Clamp(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		Die()

/mob/living/simple_animal/adjustFireLoss(damage)
	health = Clamp(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		Die()

/mob/living/simple_animal/proc/SA_attackable(target)
	return CanAttack(target)

/mob/living/simple_animal/proc/CanAttack(var/atom/target)
	if(see_invisible < target.invisibility)
		return 0
	if (isliving(target))
		var/mob/living/L = target
		if(!L.stat && L.health >= 0)
			return (0)
	if (istype(target,/obj/mecha))
		var/obj/mecha/M = target
		if (M.occupant)
			return (0)
	if (istype(target,/obj/machinery/bot))
		var/obj/machinery/bot/B = target
		if(B.health > 0)
			return (0)
	return (1)

//Call when target overlay should be added/removed
/mob/living/simple_animal/update_targeted()
	if(!targeted_by && target_locked)
		del(target_locked)
	overlays = null
	if (targeted_by && target_locked)
		overlays += target_locked



/mob/living/simple_animal/update_fire()
	return
/mob/living/simple_animal/IgniteMob()
	return 0
/mob/living/simple_animal/ExtinguishMob()
	return

/mob/living/simple_animal/revive()
	health = maxHealth
	butchering_drops = null
	meat_taken = 0
	..()

/mob/living/simple_animal/proc/make_babies() // <3 <3 <3
	if(gender != FEMALE || stat || !scan_ready || !childtype || !species_type)
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	scan_ready = 0
	spawn(400)
		scan_ready = 1
	var/alone = 1
	var/mob/living/simple_animal/partner
	var/children = 0
<<<<<<< HEAD
	for(var/mob/M in view(7, src))
		if(M.stat != CONSCIOUS) //Check if it's conscious FIRST.
			continue
		else if(istype(M, childtype)) //Check for children SECOND.
			children++
		else if(istype(M, animal_species))
			if(M.ckey)
				continue
			else if(!istype(M, childtype) && M.gender == MALE) //Better safe than sorry ;_;
				partner = M

		else if(istype(M, /mob/living) && !faction_check(M)) //shyness check. we're not shy in front of things that share a faction with us.
			alone = 0
			continue
	if(alone && partner && children < 3)
		var/childspawn = pickweight(childtype)
		new childspawn(loc)
		return 1
	return 0

/mob/living/simple_animal/canUseTopic(atom/movable/M, be_close = 0, no_dextery = 0)
	if(incapacitated())
		return 0
	if(no_dextery || dextrous)
		if(be_close && !in_range(M, src))
			return 0
	else
		src << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 0
	return 1

/mob/living/simple_animal/stripPanelUnequip(obj/item/what, mob/who, where)
	if(!canUseTopic(who, TRUE))
		return
	else
		..()

/mob/living/simple_animal/stripPanelEquip(obj/item/what, mob/who, where)
	if(!canUseTopic(who, TRUE))
		return
	else
		..()

/mob/living/simple_animal/update_canmove()
	if(paralysis || stunned || weakened || stat || resting)
		drop_r_hand()
		drop_l_hand()
		canmove = 0
	else if(buckled)
		canmove = 0
	else
		canmove = 1
	update_transform()
	update_action_buttons_icon()
	return canmove

/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = 0

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)



/mob/living/simple_animal/Destroy()
	if(nest)
		nest.spawned_mobs -= src
	nest = null
	return ..()


/mob/living/simple_animal/proc/sentience_act() //Called when a simple animal gains sentience via gold slime potion
	return

/mob/living/simple_animal/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

/mob/living/simple_animal/get_idcard()
	return access_card

//Dextrous simple mobs can use hands!
/mob/living/simple_animal/create_mob_hud()
	if(client && !hud_used)
		if(dextrous)
			hud_used = new dextrous_hud_type(src, ui_style2icon(client.prefs.UI_style))
		else
			..()

/mob/living/simple_animal/OpenCraftingMenu()
	if(dextrous)
		handcrafting.ui_interact(src)

/mob/living/simple_animal/can_hold_items()
	return dextrous

/mob/living/simple_animal/IsAdvancedToolUser()
	return dextrous

/mob/living/simple_animal/activate_hand(selhand)
	if(!dextrous)
		return ..()
	if(istext(selhand))
		selhand = lowertext(selhand)
		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1
	if(selhand != src.hand)
		swap_hand()
	else
		mode()

/mob/living/simple_animal/swap_hand()
	if(!dextrous)
		return ..()
	var/obj/item/held_item = get_active_hand()
	if(held_item)
		if(istype(held_item, /obj/item/weapon/twohanded))
			var/obj/item/weapon/twohanded/T = held_item
			if(T.wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [T.name].</span>"
				return
	hand = !hand
	if(hud_used && hud_used.inv_slots[slot_l_hand] && hud_used.inv_slots[slot_r_hand])
		var/obj/screen/inventory/hand/H
		H = hud_used.inv_slots[slot_l_hand]
		H.update_icon()
		H = hud_used.inv_slots[slot_r_hand]
		H.update_icon()

/mob/living/simple_animal/UnarmedAttack(atom/A, proximity)
	if(!dextrous)
		return ..()
	if(!ismob(A))
		A.attack_hand(src)
		update_hand_icons()

/mob/living/simple_animal/put_in_hands(obj/item/I)
	..()
	update_hand_icons()

/mob/living/simple_animal/proc/update_hand_icons()
	if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
		if(r_hand)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.screen_loc = ui_rhand
			client.screen |= r_hand
		if(l_hand)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.screen_loc = ui_lhand
			client.screen |= l_hand

=======
	for(var/mob/living/M in oview(7, src))
		if(M.isUnconscious()) //Check if it's concious FIRSTER.
			continue
		else if(istype(M, childtype)) //Check for children FIRST.
			children++
		else if(istype(M, species_type))
			if(M.client)
				continue
			else if(!istype(M, childtype) && M.gender == MALE) //Better safe than sorry ;_;
				partner = M
		else if(istype(M, /mob/living))
			if(!istype(M, /mob/dead/observer) || M.stat != DEAD) //Make babies with ghosts or dead people nearby!
				alone = 0
				continue
	if(alone && partner && children < 3)
		give_birth()

/mob/living/simple_animal/proc/give_birth()
	for(var/i=1; i<=child_amount; i++)
		if(animal_count[childtype] > ANIMAL_CHILD_CAP)
			return 0

		var/mob/living/simple_animal/child = new childtype(loc)
		if(istype(child))
			child.inherit_mind(src)

	return 1

/mob/living/simple_animal/proc/grow_up()
	if(src.type == species_type) //Already grown up
		return

	var/mob/living/simple_animal/new_animal = new species_type(src.loc)

	if(locked_to) //Handle atom locking
		var/atom/movable/A = locked_to
		A.unlock_atom(src)
		A.lock_atom(new_animal, /datum/locking_category/simple_animal)

	new_animal.inherit_mind(src)
	new_animal.ckey = src.ckey
	new_animal.key = src.key

	forceMove(get_turf(src))
	qdel(src)

/mob/living/simple_animal/proc/inherit_mind(mob/living/simple_animal/from)
	src.faction = from.faction

/mob/living/simple_animal/say_understands(var/mob/other,var/datum/language/speaking = null)
	if(other) other = other.GetSource()
	if(issilicon(other))
		return 1
	return ..()

/mob/living/simple_animal/proc/reagent_act(id, method, volume)
	if(isDead()) return

	switch(id)
		if(SACID)
			if(!supernatural)
				adjustBruteLoss(volume * 0.5)
		if(PACID)
			if(!supernatural)
				adjustBruteLoss(volume * 0.5)

/mob/living/simple_animal/proc/delayedRegen()
	set waitfor = 0
	isRegenerating = 1
	sleep(rand(minRegenTime, maxRegenTime)) //Don't want it being predictable
	src.resurrect()
	src.revive()
	visible_message("<span class='warning'>[src] appears to wake from the dead, having healed all wounds.</span>")

/datum/locking_category/simple_animal
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
