/obj/item/grenade
	name = "grenade"
	desc = "It has an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	slot_flags = SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/active = 0
	var/det_time = 50
	var/display_timer = 1

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/proc/clown_check(mob/living/carbon/human/user)
	if(user.disabilities & CLUMSY && prob(50))
		to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")
		preprime(user, 5, FALSE)
		return FALSE
	return TRUE


/obj/item/grenade/examine(mob/user)
	..()
	if(display_timer)
		if(det_time > 1)
			to_chat(user, "The timer is set to [det_time/10] second\s.")
		else
			to_chat(user, "\The [src] is set for instant detonation.")


/obj/item/grenade/attack_self(mob/user)
	if(!active)
		if(clown_check(user))
			preprime(user)

/obj/item/grenade/proc/log_grenade(mob/user, turf/T)
	var/area/A = get_area(T)
	var/message = "[ADMIN_LOOKUPFLW(user)]) has primed \a [src] for detonation at [ADMIN_COORDJMP(T)]"
	GLOB.bombers += message
	message_admins(message)
	log_game("[key_name(user)] has primed \a [src] for detonation at [A.name] [COORD(T)].")

/obj/item/grenade/proc/preprime(mob/user, delayoverride, msg = TRUE)
	var/turf/T = get_turf(src)
	log_grenade(user, T)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()
	if(msg)
		to_chat(user, "<span class='warning'>You prime \the [src]! [det_time/10] seconds!</span>")
	playsound(loc, 'sound/weapons/armbomb.ogg', 60, 1)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	add_fingerprint(user)
	addtimer(CALLBACK(src, .proc/prime), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/proc/prime()

/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)


/obj/item/grenade/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/screwdriver))
		switch(det_time)
			if ("1")
				det_time = 10
				to_chat(user, "<span class='notice'>You set the [name] for 1 second detonation time.</span>")
			if ("10")
				det_time = 30
				to_chat(user, "<span class='notice'>You set the [name] for 3 second detonation time.</span>")
			if ("30")
				det_time = 50
				to_chat(user, "<span class='notice'>You set the [name] for 5 second detonation time.</span>")
			if ("50")
				det_time = 1
				to_chat(user, "<span class='notice'>You set the [name] for instant detonation.</span>")
		add_fingerprint(user)
	else
		return ..()

/obj/item/grenade/attack_hand()
	walk(src, null, null)
	..()

/obj/item/grenade/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/grenade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits [owner]'s [src], setting it off! What a shot!</span>")
		prime()
		return TRUE //It hit the grenade, not them
