/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20

	status_flags = CANPUSH

	var/icon_living = ""
	var/icon_dead = "" //icon when the animal is dead. Don't use animated icons for this.
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	var/list/speak = list()
	var/list/speak_emote = list()//	Emotes while speaking IE: Ian [emote], [text] -- Ian barks, "WOOF!". Spoken text is generated from the speak variable.
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/turns_per_move = 1
	var/turns_since_move = 0
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = 1	// Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = 1 //When set to 1 this stops the animal from moving when someone is pulling it.

	//Interaction
	var/response_help   = "pokes"
	var/response_disarm = "shoves"
	var/response_harm   = "hits"
	var/harm_intent_damage = 3
	var/force_threshold = 0 //Minimum force required to deal any damage

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350

	//Healable by medical stacks? Defaults to yes.
	var/healable = 1

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/list/atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0) //Leaving something at 0 means it's off - has no maximum
	var/unsuitable_atmos_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above

	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/armour_penetration = 0 //How much armour they ignore, as a flat reduction from the targets armour value
	var/melee_damage_type = BRUTE //Damage type of a simple mob's melee attack, should it do damage.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) // 1 for full damage , 0 for none , -1 for 1:1 heal from that source
	var/attacktext = "attacks"
	var/attack_sound = null
	var/friendly = "nuzzles" //If the mob does no damage with it's attack
	var/environment_smash = 0 //Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls

	var/speed = 1 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster

	//Hot simple_animal baby making vars
	var/list/childtype = null
	var/scan_ready = 1
	var/species //Sorry, no spider+corgi buttbabies.

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

	var/allow_movement_on_non_turfs = FALSE


/mob/living/simple_animal/New()
	..()
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

/mob/living/simple_animal/blind_eyes()
	return

/mob/living/simple_animal/blur_eyes()
	return

/mob/living/simple_animal/adjust_blindness()
	return

/mob/living/simple_animal/adjust_blurriness()
	return

/mob/living/simple_animal/set_blindness()
	return

/mob/living/simple_animal/set_blurriness()
	return

/mob/living/simple_animal/become_blind()
	return

/mob/living/simple_animal/setEarDamage()
	return

/mob/living/simple_animal/adjustEarDamage()
	return

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
							emote("me", 1, pick(emote_see))
						else
							emote("me", 2, pick(emote_hear))
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote("me", 1, pick(emote_see))
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote("me", 2, pick(emote_hear))
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote("me", 1, pick(emote_see))
					else
						emote("me", 2, pick(emote_hear))


/mob/living/simple_animal/handle_environment(datum/gas_mixture/environment)
	var/atmos_suitable = 1

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

/mob/living/simple_animal/gib(animation = 0)
	if(icon_gib)
		flick(icon_gib, src)
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1; i <= butcher_results[path];i++)
				new path(src.loc)
	..()


/mob/living/simple_animal/blob_act()
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
			playsound(loc, "punch", 25, 1, -1)
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


/mob/living/simple_animal/attackby(obj/item/O, mob/living/user, params) //Marker -Agouri
	if(O.flags & NOBLUDGEON)
		return

	..()

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
	if(deathmessage && !gibbed)
		visible_message("<span class='danger'>[deathmessage]</span>")
	else if(!del_on_death)
		visible_message("<span class='danger'>\the [src] stops moving...</span>")
	if(del_on_death)
		ghostize()
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		stat = DEAD
		density = 0
	..()

/mob/living/simple_animal/ex_act(severity, target)
	..()
	switch (severity)
		if (1)
			gib()
			return

		if (2)
			adjustBruteLoss(60)

		if(3)
			adjustBruteLoss(30)
	updatehealth()

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
	return

/mob/living/simple_animal/ExtinguishMob()
	return

/mob/living/simple_animal/revive(full_heal = 0, admin_revive = 0)
	if(..()) //successfully ressuscitated from death
		icon = initial(icon)
		icon_state = icon_living
		density = initial(density)
		. = 1

/mob/living/simple_animal/fully_heal(admin_revive = 0)
	health = maxHealth
	..()

/mob/living/simple_animal/proc/make_babies() // <3 <3 <3
	if(gender != FEMALE || stat || !scan_ready || !childtype || !species || ticker.current_state != GAME_STATE_PLAYING)
		return
	scan_ready = 0
	spawn(400)
		scan_ready = 1
	var/alone = 1
	var/mob/living/simple_animal/partner
	var/children = 0
	for(var/mob/M in view(7, src))
		if(M.stat != CONSCIOUS) //Check if it's concious FIRSTER.
			continue
		else if(istype(M, childtype)) //Check for children FIRST.
			children++
		else if(istype(M, species))
			if(M.ckey)
				continue
			else if(!istype(M, childtype) && M.gender == MALE) //Better safe than sorry ;_;
				partner = M
		else if(istype(M, /mob/))
			alone = 0
			continue
	if(alone && partner && children < 3)
		var/childspawn = pickweight(childtype)
		new childspawn(loc)

/mob/living/simple_animal/stripPanelUnequip(obj/item/what, mob/who, where, child_override)
	if(!child_override)
		src << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	else
		..()

/mob/living/simple_animal/stripPanelEquip(obj/item/what, mob/who, where, child_override)
	if(!child_override)
		src << "<span class='warning'>You don't have the dexterity to do this!</span>"
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
