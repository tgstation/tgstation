/mob/living/simple_animal/bot/secbot/grievous //This bot is powerful. If you managed to get 4 eswords somehow, you deserve this horror. Emag him for best results.
	name = "General Beepsky"
	desc = "Is that a secbot with four eswords in its arms...?"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "grievous"
	health = 150
	maxHealth = 150

	baton_type = /obj/item/melee/energy/sword/saber
	base_speed = 4 //he's a fast fucker
	weapon_force = 30

	var/block_chance = 50

/mob/living/simple_animal/bot/secbot/grievous/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(block_bullets))

/mob/living/simple_animal/bot/secbot/grievous/toy //A toy version of general beepsky!
	name = "Genewul Bweepskee"
	desc = "An adorable looking secbot with four toy swords taped to its arms"
	health = 50
	maxHealth = 50
	baton_type = /obj/item/toy/sword
	weapon_force = 0

/mob/living/simple_animal/bot/secbot/grievous/proc/block_bullets(datum/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	if(stat != CONSCIOUS)
		return NONE

	visible_message(span_warning("[source] deflects [hitting_projectile] with its energy swords!"))
	playsound(source, 'sound/items/weapons/blade1.ogg', 50, TRUE)
	return COMPONENT_BULLET_BLOCKED

/mob/living/simple_animal/bot/secbot/grievous/on_entered(datum/source, atom/movable/AM)
	. = ..()
	if(ismob(AM) && AM == target)
		visible_message(span_warning("[src] flails his swords and cuts [AM]!"))
		playsound(src,'sound/mobs/non-humanoids/beepsky/beepskyspinsabre.ogg',100,TRUE,-1)
		INVOKE_ASYNC(src, PROC_REF(stun_attack), AM)

/mob/living/simple_animal/bot/secbot/grievous/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item, attack_self), src)

/mob/living/simple_animal/bot/secbot/grievous/Destroy()
	QDEL_NULL(weapon)
	return ..()

/mob/living/simple_animal/bot/secbot/grievous/special_retaliate_after_attack(mob/user)
	if(mode != BOT_HUNT)
		return
	if(prob(block_chance))
		visible_message(span_warning("[src] deflects [user]'s attack with his energy swords!"))
		playsound(src, 'sound/items/weapons/blade1.ogg', 50, TRUE, -1)
		return TRUE

/mob/living/simple_animal/bot/secbot/grievous/stun_attack(mob/living/carbon/C) //Criminals don't deserve to live
	weapon.attack(C, src)
	playsound(src, 'sound/items/weapons/blade1.ogg', 50, TRUE, -1)
	if(C.stat == DEAD)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_appearance)), 0.2 SECONDS)
		back_to_idle()


/mob/living/simple_animal/bot/secbot/grievous/handle_automated_action()
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	switch(mode)
		if(BOT_IDLE) // idle
			update_appearance()
			GLOB.move_manager.stop_looping(src)
			look_for_perp() // see if any criminals are in range
			if(!mode && bot_mode_flags & BOT_MODE_AUTOPATROL) // still idle, and set to patrol
				mode = BOT_START_PATROL // switch to patrol mode
		if(BOT_HUNT) // hunting for perp
			update_appearance()
			playsound(src,'sound/mobs/non-humanoids/beepsky/beepskyspinsabre.ogg',100,TRUE,-1)
			// general beepsky doesn't give up so easily, jedi scum
			if(frustration >= 20)
				GLOB.move_manager.stop_looping(src)
				back_to_idle()
				return
			if(target) // make sure target exists
				if(Adjacent(target) && isturf(target.loc)) // if right next to perp
					target_lastloc = target.loc //stun_attack() can clear the target if they're dead, so this needs to be set first
					stun_attack(target)
					set_anchored(TRUE)
					return
				else // not next to perp
					var/turf/olddist = get_dist(src, target)
					GLOB.move_manager.move_to(src, target, 1, 4)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()

/mob/living/simple_animal/bot/secbot/grievous/look_for_perp()
	set_anchored(FALSE)
	var/judgement_criteria = judgement_criteria()
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(judgement_criteria)

		if (threatlevel < THREAT_ASSESS_DANGEROUS)
			continue
		target = C
		oldtarget_name = C.name
		speak("Level [threatlevel] infraction alert!")
		playsound(src, pick(
			'sound/mobs/non-humanoids/beepsky/criminal.ogg',
			'sound/mobs/non-humanoids/beepsky/justice.ogg',
			'sound/mobs/non-humanoids/beepsky/freeze.ogg',
		), 50, FALSE)
		playsound(src,'sound/items/weapons/saberon.ogg',50,TRUE,-1)
		visible_message(span_warning("[src] ignites his energy swords!"))
		icon_state = "grievous-c"
		visible_message("<b>[src]</b> points at [C.name]!")
		mode = BOT_HUNT
		INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
		break

/mob/living/simple_animal/bot/secbot/grievous/explode()
	var/atom/Tsec = drop_location()
	//Parent is dropping the weapon, so let's drop 3 more to make up for it.
	for(var/dropped_weapons = 0 to 3)
		drop_part(weapon, Tsec)

	return ..()
