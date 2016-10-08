
//phil235
/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if(!(resistance_flags & INDESTRUCTIBLE) && health > 0)
		damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir)
		if(damage_amount >= 1)
			. = damage_amount
			health = max(health - damage_amount, 0)
			if(health <= 0)
				obj_destruction(damage_flag)
			else if(broken_health)
				if(health <= broken_health)
					obj_break(damage_flag)

//returns the damage value of the attack after processing the obj's various armor protections
/obj/proc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor[damage_flag]
	return round(damage_amount * (100 - armor_protection)*0.01, 0.1)

//phil235 maybe have it be in an override of take_damage() for each object.
/obj/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/hitby(atom/movable/AM) //phil235 remember to remove the hitby of the children
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else if(isobj(AM))
		var/obj/O = AM
		tforce = O.throwforce
	take_damage(tforce, BRUTE, "melee", 1, get_dir(src, AM))

/obj/ex_act(severity, target)
	..() //contents explosion
	if(target == src)
		qdel(src)
		return
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)

///obj/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	//phil235 need a max temperature above whitch the default obj takes damage

/*phil235 maybe not worth it, how many items are really harmed by EMPs ?
/obj/emp_act(severity)
	if(severity && !(resistance_flags & EMP_PROOF))
		take_damage(rand(80,120)/severity, BURN, "energy", 0)
*/
/obj/bullet_act(obj/item/projectile/P)
	. = ..()
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>")
	playsound(src, P.hitsound, 50, 1)
	take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180))


/obj/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == "harm")
		..(user, 1)
		visible_message("<span class='danger'>[user] smashes [src]!</span>")
		if(density)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		take_damage(150, BRUTE, "melee", 0, get_dir(src, user))
		return 1
	return 0

/obj/blob_act(obj/structure/blob/B)
	take_damage(400, BRUTE, "melee", 0, get_dir(src, B))

/obj/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user))

/obj/attack_alien(mob/living/carbon/alien/humanoid/user)
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	attack_generic(user, 60, BRUTE, "melee", 0)

/obj/attack_animal(mob/living/simple_animal/M) //phil235 envir smash?
	if(!M.melee_damage_upper && !M.obj_damage)
		M.emote("[M.friendly] [src]")
		return 0
	else
		var/play_soundeffect = 1
		if(M.environment_smash)
			play_soundeffect = 0
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		if(M.obj_damage)
			attack_generic(M, M.obj_damage, M.melee_damage_type, "melee", play_soundeffect)
		else
			attack_generic(M, rand(M.melee_damage_lower,M.melee_damage_upper), M.melee_damage_type, "melee", play_soundeffect)
		return 1

/obj/attack_slime(mob/living/simple_animal/slime/user)
	if(!user.is_adult)
		return
	attack_generic(user, rand(10, 15), "melee", 1)

/obj/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	switch(damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 50, 1)
		else
			return 0
	visible_message("<span class='danger'>[M.name] has hit [src].</span>")
	return take_damage(M.force*3, M.damtype, "melee", 0, get_dir(src, M)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.



/obj/item/mech_melee_attack(obj/mecha/M) //phil235
	return 0

/obj/effect/mech_melee_attack(obj/mecha/M)
	return 0


/* //phil235
/obj/emp_act()
*/


/obj/singularity_act() //phil235
	ex_act(1)
	if(src && !qdeleted(src))
		qdel(src)
	return 2


var/global/image/acid_overlay = image("icon" = 'icons/effects/effects.dmi', "icon_state" = "acid")

/obj/acid_act(acidpwr, acid_volume)
	if(!(resistance_flags & UNACIDABLE) && acid_volume)

		if(!acid_level)
			SSacid.processing[src] = src
			add_overlay(acid_overlay, 1)
		var/acid_cap = acidpwr * 300 //so we cannot use huge amounts of weak acids to do as well as strong acids.
		if(acid_level < acid_cap)
			acid_level = min(acid_level + acidpwr * acid_volume, acid_cap)
		return 1

/obj/proc/acid_processing()
	. = 1
	if(!(resistance_flags & ACID_PROOF))
		for(var/armour_value in armor)
			if(armour_value != "acid" && armour_value != "fire")
				armor[armour_value] = max(armor[armour_value] - round(sqrt(acid_level)*0.1), 0)
		if(prob(33))
			playsound(loc, 'sound/items/Welder.ogg', 150, 1)
		take_damage(min(1 + round(sqrt(acid_level)*0.3), 300), BURN, "acid", 0)

	acid_level = max(acid_level - (5 + 3*round(sqrt(acid_level))), 0)
	if(!acid_level)
		return 0

/obj/proc/acid_melt()
	var/location = loc
	SSacid.processing -= src
	var/remaining_acid = acid_level
	var/list/contained = contents
	deconstruct(FALSE)
	if(isturf(location))
		var/turf/T = location
		for(var/obj/item/I in contained)
			if(I.loc == T) //we acid the items that used to be inside src and ended up on the turf
				I.acid_act(10, 0.1 * remaining_acid/T.contents.len)

/obj/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(Clamp(0.02 * exposed_temperature, 0, 20), BURN, "fire", 0)
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE))
		resistance_flags |= ON_FIRE
		SSfire_burning.processing[src] = src
		add_overlay(fire_overlay)
		return 1

/obj/proc/burn()
	var/location = loc
	var/list/contained = contents
	if(resistance_flags & ON_FIRE)
		SSfire_burning.processing -= src
	deconstruct(FALSE)
	if(isturf(location))
		var/turf/T = location
		for(var/obj/item/I in contained)
			if(I.loc == T) //we burn the items that used to be inside src and ended up on the turf
				I.fire_act()

/obj/proc/extinguish()
	if(resistance_flags & ON_FIRE)
		resistance_flags &= ~ON_FIRE
		overlays -= fire_overlay
		SSfire_burning.processing -= src

/obj/proc/tesla_act(var/power)
	being_shocked = 1
	var/power_bounced = power / 2
	tesla_zap(src, 3, power_bounced)
	addtimer(src, "reset_shocked", 10)

/obj/proc/reset_shocked()
	being_shocked = 0


/obj/proc/deconstruct(disassembled = TRUE)
	qdel(src)

//what happens when the obj's health is below broken_health level.
/obj/proc/obj_break(damage_flag)
	return

//what happens when the obj's health reaches zero.
/obj/proc/obj_destruction(damage_flag)
	if(damage_flag == "acid")
		acid_melt()
	else if(damage_flag == "fire")
		burn()
	else
		deconstruct(FALSE)