/mob/living/proc/run_armor_check(def_zone = null, attack_flag = "melee", absorb_text = null, soften_text = null, var/armour_penetration, var/penetrated_text)
	var/armor = getarmor(def_zone, attack_flag)

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armor && armour_penetration)
		armor = max(0, armor - armour_penetration)
		if(penetrated_text)
			src << "<span class='userdanger'>[penetrated_text]</span>"
		else
			src << "<span class='userdanger'>Your armor was penetrated!</span>"

	if(armor >= 100)
		if(absorb_text)
			src << "<span class='userdanger'>[absorb_text]</span>"
		else
			src << "<span class='userdanger'>Your armor absorbs the blow!</span>"
	else if(armor > 0)
		if(soften_text)
			src << "<span class='userdanger'>[soften_text]</span>"
		else
			src << "<span class='userdanger'>Your armor softens the blow!</span>"
	return armor


/mob/living/proc/getarmor(var/def_zone, var/type)
	return 0

/mob/living/proc/on_hit(var/obj/item/projectile/proj_type)
	return

/mob/living/bullet_act(obj/item/projectile/P, def_zone)
	var/armor = run_armor_check(def_zone, P.flag, "","",P.armour_penetration)
	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
	return P.on_hit(src, armor, def_zone)

/proc/vol_by_throwforce_and_or_w_class(var/obj/item/I)
		if(!I)
				return 0
		if(I.throwforce && I.w_class)
				return Clamp((I.throwforce + I.w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
		else if(I.w_class)
				return Clamp(I.w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
		else
				return 0

/mob/living/hitby(atom/movable/AM,mob/thrower)//Standardization and logging -Sieve
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		var/zone = ran_zone("chest", 65)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		var/volume = vol_by_throwforce_and_or_w_class(I)
		if(istype(I,/obj/item/weapon)) //If the item is a weapon...
			var/obj/item/weapon/W = I
			dtype = W.damtype

			if (W.throwforce > 0) //If the weapon's throwforce is greater than zero...
				if (W.throwhitsound) //...and throwhitsound is defined...
					playsound(loc, W.throwhitsound, volume, 1, -1) //...play the weapon's throwhitsound.
				else if(W.hitsound) //Otherwise, if the weapon's hitsound is defined...
					playsound(loc, W.hitsound, volume, 1, -1) //...play the weapon's hitsound.
				else if(!W.throwhitsound) //Otherwise, if throwhitsound isn't defined...
					playsound(loc, 'sound/weapons/genhit.ogg',volume, 1, -1) //...play genhit.ogg.

		else if(!I.throwhitsound && I.throwforce > 0) //Otherwise, if the item doesn't have a throwhitsound and has a throwforce greater than zero...
			playsound(loc, 'sound/weapons/genhit.ogg', volume, 1, -1)//...play genhit.ogg
		if(!I.throwforce)// Otherwise, if the item's throwforce is 0...
			playsound(loc, 'sound/weapons/throwtap.ogg', 1, volume, -1)//...play throwtap.ogg.

		visible_message("<span class='danger'>[src] has been hit by [I].</span>", \
						"<span class='userdanger'>[src] has been hit by [I].</span>")
		var/armor = run_armor_check(zone, "melee", "Your armor has protected your [parse_zone(zone)].", "Your armor has softened hit to your [parse_zone(zone)].",I.armour_penetration)
		apply_damage(I.throwforce, dtype, zone, armor, I)

		if(thrower)
			add_logs(thrower, src, "hit", I)

/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == "harm")
		if(M.damtype == "brute")
			step_away(src,M,15)
		switch(M.damtype)
			if("brute")
				Paralyse(1)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if("fire")
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/Welder.ogg', 50, 1)
			if("tox")
				M.mech_toxin_damage(src)
			else
				return
		updatehealth()
		visible_message("<span class='danger'>[M.name] has hit [src]!</span>", \
						"<span class='userdanger'>[M.name] has hit [src]!</span>")
		add_logs(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
	else
		step_away(src,M)
		add_logs(M.occupant, src, "pushed", M)
		visible_message("<span class='warning'>[M] pushes [src] out of the way.</span>")

		return


//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		src.AddLuminosity(3)
		update_fire()

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		src.AddLuminosity(-3)
		update_fire()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
    fire_stacks = Clamp(fire_stacks + add_fire_stacks, min = -20, max = 20)

/mob/living/proc/handle_fire()
	if(fire_stacks < 0)
		fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.oxygen < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

/mob/living/fire_act()
	adjust_fire_stacks(0.5)
	IgniteMob()


//Share fire evenly between the two mobs
//Called in MobBump() and Crossed()
/mob/living/proc/spreadFire(var/mob/living/L)
	if(!istype(L))
		return
	var/L_old_on_fire = L.on_fire

	if(on_fire) //Only spread fire stacks if we're on fire
		fire_stacks /= 2
		L.fire_stacks += fire_stacks
		L.IgniteMob()

	if(L_old_on_fire) //Only ignite us and gain their stacks if they were onfire before we bumped them
		L.fire_stacks /= 2
		fire_stacks += L.fire_stacks
		IgniteMob()

//Mobs on Fire end


/mob/living/acid_act(var/acidpwr, var/toxpwr, var/acid_volume)
	take_organ_damage(min(10*toxpwr, acid_volume * toxpwr))

/mob/living/proc/grabbedby(mob/living/carbon/user,var/supress_message = 0)
	if(user == src || anchored)
		return 0
	if(!(status_flags & CANPUSH))
		return 0

	add_logs(user, src, "grabbed", addition="passively")

	var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(user, src)
	if(buckled)
		user << "<span class='warning'>You cannot grab [src], \he is buckled in!</span>"
	if(!G)	//the grab will delete itself in New if src is anchored
		return 0
	user.put_in_active_hand(G)
	G.synch()
	LAssailant = user

	playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	if(!supress_message)
		visible_message("<span class='warning'>[user] has grabbed [src] passively!</span>")


/mob/living/attack_slime(mob/living/simple_animal/slime/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(M.Victim)
		return // can't attack while eating!

	if (stat != DEAD)
		add_logs(M, src, "attacked")
		M.do_attack_animation(src)
		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>")
		return 1

/mob/living/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>\The [M] [M.friendly] [src]!</span>")
		return 0
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>", \
						"<span class='userdanger'>\The [M] [M.attacktext] [src]!</span>")
		add_logs(M, src, "attacked")
		return 1


/mob/living/attack_paw(mob/living/carbon/monkey/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return 0

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return 0

	if (M.a_intent == "harm")
		if(M.is_muzzled() || (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSMOUTH))
			M << "<span class='warning'>You can't bite with your mouth covered!</span>"
			return 0
		M.do_attack_animation(src)
		if (prob(75))
			add_logs(M, src, "attacked")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
			visible_message("<span class='danger'>[M.name] bites [src]!</span>", \
					"<span class='userdanger'>[M.name] bites [src]!</span>")
			return 1
		else
			visible_message("<span class='danger'>[M.name] has attempted to bite [src]!</span>", \
				"<span class='userdanger'>[M.name] has attempted to bite [src]!</span>")
	return 0

/mob/living/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)
		if("help")
			visible_message("<span class='notice'>[L.name] rubs its head against [src].</span>")
			return 0

		else
			L.do_attack_animation(src)
			if(prob(90))
				add_logs(L, src, "attacked")
				visible_message("<span class='danger'>[L.name] bites [src]!</span>", \
						"<span class='userdanger'>[L.name] bites [src]!</span>")
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				return 1
			else
				visible_message("<span class='danger'>[L.name] has attempted to bite [src]!</span>", \
					"<span class='userdanger'>[L.name] has attempted to bite [src]!</span>")
	return 0

/mob/living/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return 0

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return 0

	switch(M.a_intent)
		if ("help")
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")
			return 0

		if ("grab")
			grabbedby(M)
			return 0
		else
			M.do_attack_animation(src)
			return 1

/mob/living/incapacitated()
	if(stat || paralysis || stunned || weakened || restrained())
		return 1

/mob/living/proc/irradiate(amount)
	if(amount)
		var/blocked = run_armor_check(null, "rad", "Your clothes feel warm", "Your clothes feel warm")
		apply_effect(amount, IRRADIATE, blocked)
