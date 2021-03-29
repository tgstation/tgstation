///Called when a mech melee attacks an atom
/atom/proc/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker)
	return

/turf/closed/wall/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker)
	mecha_attacker.do_attack_animation(src)
	switch(mecha_attacker.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			mecha_attacker.visible_message("<span class='danger'>[mecha_attacker.name] hits [src]!</span>", \
							"<span class='danger'>You hit [src]!</span>", null, COMBAT_MESSAGE_RANGE)
			if(prob(hardness + mecha_attacker.force) && mecha_attacker.force > 20)
				dismantle_wall(1)
				playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
			else
				add_dent(WALL_DENT_HIT)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		if(TOX)
			playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
			return FALSE

/obj/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker)
	mecha_attacker.do_attack_animation(src)
	var/play_soundeffect = 0
	var/mech_damtype = mecha_attacker.damtype
	if(mecha_attacker.selected)
		mech_damtype = mecha_attacker.selected.damtype
		play_soundeffect = 1
	else
		switch(mecha_attacker.damtype)
			if(BRUTE)
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if(BURN)
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if(TOX)
				playsound(src, 'sound/effects/spray2.ogg', 50, TRUE)
				return 0
			else
				return 0
	mecha_attacker.visible_message("<span class='danger'>[mecha_attacker.name] hits [src]!</span>", "<span class='danger'>You hit [src]!</span>", null, COMBAT_MESSAGE_RANGE)
	return take_damage(mecha_attacker.force * 3, mech_damtype, "melee", play_soundeffect, get_dir(src, mecha_attacker)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

/obj/structure/window/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker)
	if(!can_be_reached())
		return
	return ..()

/mob/living/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if(user.combat_mode)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		mecha_attacker.do_attack_animation(src)
		if(mecha_attacker.damtype == "brute")
			step_away(src, mecha_attacker, 15)
		switch(mecha_attacker.damtype)
			if(BRUTE)
				Unconscious(20)
				take_overall_damage(rand(mecha_attacker.force/2, mecha_attacker.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if(BURN)
				take_overall_damage(0, rand(mecha_attacker.force * 0.5, mecha_attacker.force))
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if(TOX)
				mecha_attacker.mech_toxin_damage(src)
			else
				return
		updatehealth()
		visible_message("<span class='danger'>[mecha_attacker.name] hits [src]!</span>", \
						"<span class='userdanger'>[mecha_attacker.name] hits you!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, mecha_attacker)
		to_chat(mecha_attacker, "<span class='danger'>You hit [src]!</span>")
		log_combat(user, src, "attacked", mecha_attacker, "(COMBAT MODE: [uppertext(user.combat_mode)]) (DAMTYPE: [uppertext(mecha_attacker.damtype)])")
	else
		step_away(src, mecha_attacker)
		log_combat(user, src, "pushed", mecha_attacker)
		visible_message("<span class='warning'>[mecha_attacker] pushes [src] out of the way.</span>", \
						"<span class='warning'>[mecha_attacker] pushes you out of the way.</span>", "<span class='hear'>You hear aggressive shuffling!</span>", 5, list(mecha_attacker))
		to_chat(mecha_attacker, "<span class='danger'>You push [src] out of the way.</span>")

/mob/living/carbon/human/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if(!isliving(user))
		return ..()
	var/mob/living/attacker = user
	if(attacker.combat_mode)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		mecha_attacker.do_attack_animation(src)
		if(mecha_attacker.damtype == BRUTE)
			step_away(src, mecha_attacker, 15)
		var/obj/item/bodypart/temp = get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_HEAD))
		if(temp)
			var/update = 0
			var/dmg = rand(mecha_attacker.force * 0.5, mecha_attacker.force)
			switch(mecha_attacker.damtype)
				if(BRUTE)
					if(mecha_attacker.force > 35) // durand and other heavy mechas
						Unconscious(20)
					else if(mecha_attacker.force > 20 && !IsKnockdown()) // lightweight mechas like gygax
						Knockdown(40)
					update |= temp.receive_damage(dmg, 0)
					playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
				if(FIRE)
					update |= temp.receive_damage(0, dmg)
					playsound(src, 'sound/items/welder.ogg', 50, TRUE)
				if(TOX)
					mecha_attacker.mech_toxin_damage(src)
				else
					return
			if(update)
				update_damage_overlays()
			updatehealth()

		visible_message("<span class='danger'>[mecha_attacker.name] hits [src]!</span>", \
						"<span class='userdanger'>[mecha_attacker.name] hits you!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, list(mecha_attacker))
		to_chat(mecha_attacker, "<span class='danger'>You hit [src]!</span>")
		log_combat(user, src, "attacked", mecha_attacker, "(COMBAT MODE: [uppertext(user.combat_mode)] (DAMTYPE: [uppertext(mecha_attacker.damtype)])")
	else
		return ..()
