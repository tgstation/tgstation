
//phil235
/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return
	if(!(resistance_flags & INDESTRUCTIBLE))
		var/armor_protection = 0
		if(damage_flag)
			armor_protection = armor[damage_flag]
		damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
		if(damage_amount >= 1)
			. = damage_amount
			health = max(health - damage_amount, 0)
			if(health <= 0)
				if(damage_flag == "acid")
					acid_melt()
				else if(damage_flag == "fire")
					burn()
				else if(damage_flag == "bomb")
					obj_shred()
				else
					obj_destruction(damage_flag)
			else if(broken_health)
				if(health <= broken_health)
					obj_break(damage_flag)

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
			take_damage(rand(50, 100), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 30), BRUTE, "bomb", 0)

///obj/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	//phil235 need a max temperature above whitch the default obj takes damage

/obj/emp_act(severity)
	if(severity && !(resistance_flags & EMP_PROOF))
		take_damage(rand(80,120)/severity, BURN, "energy", 0)

/obj/bullet_act(obj/item/projectile/P)
	. = ..()
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>")
	playsound(src, P.hitsound, 50, 1)
	take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180))


/obj/attack_hulk(mob/living/carbon/human/user)
	..()
	take_damage(50, BRUTE, "melee", 1, get_dir(src, user))

/obj/blob_act(obj/structure/blob/B)
	take_damage(30, BRUTE, "melee", 1, get_dir(src, B))

/obj/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user))

/obj/attack_alien(mob/living/carbon/alien/humanoid/user)
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	attack_generic(user, 20, BRUTE, "melee", 0)

/obj/attack_animal(mob/living/simple_animal/M) //phil235 envir smash?
	if(!M.melee_damage_upper && !M.obj_damage)
		M.emote("[M.friendly] [src]")
		return 0
	else
		if(M.obj_damage)
			attack_generic(M, M.obj_damage, M.melee_damage_type, "melee", 1)
		else
			attack_generic(M, rand(M.melee_damage_lower,M.melee_damage_upper), M.melee_damage_type, "melee", 1)
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
	return take_damage(M.force*2, M.damtype, "melee", 0, get_dir(src, M)) // multiplied by 2 so we can hit machines hard but not be overpowered against mobs.



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

/obj/proc/acid_processing_effect()
	. = 1
	if(!(resistance_flags & ACID_PROOF))
		for(var/armour_value in armor)
			if(armour_value != "acid")
				armor[armour_value] = max(armor[armour_value] - round(sqrt(acid_level)*0.1), 0)
		if(prob(33))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		take_damage(min(5 + 2* round(sqrt(acid_level)), 300), BURN, "acid", 0)

	acid_level = max(acid_level - (5 + 2*round(sqrt(acid_level))), 0)
	if(!acid_level)
		return 0

/obj/proc/acid_melt()
	var/atom/loca = get_turf(src)
	if(isobj(loc)) //item melting inside a crate doesn't drop a decal outside of it.
		loca = loc //phil235 maybe don't drop anything?
	SSacid.processing -= src
	empty_object_contents(0, loca)
	if(!isobj(loc))
		var/obj/effect/decal/cleanable/molten_object/MO
		if(density)
			MO = new /obj/effect/decal/cleanable/molten_object/large(loca)
		else
			MO = new (loca)
		MO.pixel_x = rand(-16,16)
		MO.pixel_y = rand(-16,16)
		MO.desc = "Looks like this was \an [src] some time ago."
		for(var/atom/movable/AM in loca) //the acid that is still unused drops on the other things on the same turf.
			if(AM == src)
				continue
			AM.acid_act(10, 0.1 * acid_level/loca.contents.len)
	qdel(src)

/obj/fire_act(global_overlay=1)
	take_damage(20, BURN, "fire", 0)
	if(!(resistance_flags & (FIRE_PROOF|ON_FIRE)))
		resistance_flags |= ON_FIRE
		SSfire_burning.processing[src] = src
		if(global_overlay)
			add_overlay(fire_overlay)
		return 1

/obj/proc/burn()
	var/atom/loca = get_turf(src)
	if(isobj(loc))
		loca = loc
	SSfire_burning.processing -= src
	empty_object_contents(1, loca)
	if(!isobj(loc))
		drop_ashes(loca)
	qdel(src)

/obj/proc/drop_ashes(atom/location)
	var/obj/effect/decal/cleanable/ash/A
	if(density)
		A = new /obj/effect/decal/cleanable/ash/large(location)
	else
		A = new(location)
	A.desc = "Looks like this used to be a [name] some time ago."

/obj/proc/obj_shred()
	obj_destruction()

/obj/proc/extinguish()
	if(resistance_flags & ON_FIRE)
		resistance_flags &= ~ON_FIRE
		overlays -= fire_overlay
		SSfire_burning -= src

/obj/proc/empty_object_contents(burn = 0, new_loc = src.loc)
	for(var/obj/item/Item in contents) //Empty out the contents
		Item.loc = new_loc
		if(burn)
			Item.fire_act() //Set them on fire, too

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
	qdel(src)