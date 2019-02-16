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
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/active = 0
	var/det_time = 50
	var/display_timer = 1
	var/clumsy_check = GRENADE_CLUMSY_FUMBLE

/obj/item/grenade/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] primes [src], then eats it! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, 1)
	preprime(user, det_time)
	user.transferItemToLoc(src, user, TRUE)//>eat a grenade set to 5 seconds >rush captain
	sleep(det_time)//so you dont die instantly
	return BRUTELOSS

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/proc/clown_check(mob/living/carbon/human/user)
	var/clumsy = user.has_trait(TRAIT_CLUMSY)
	if(clumsy && (clumsy_check == GRENADE_CLUMSY_FUMBLE))
		if(prob(50))
			to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")
			preprime(user, 5, FALSE)
			return FALSE
	else if(!clumsy && (clumsy_check == GRENADE_NONCLUMSY_FUMBLE))
		to_chat(user, "<span class='warning'>You pull the pin on [src]. Attached to it is a pink ribbon that says, \"<span class='clown'>HONK</span>\"</span>")
		preprime(user, 5, FALSE)
		return FALSE
	return TRUE


/obj/item/grenade/examine(mob/user)
	..()
	if(display_timer)
		if(det_time > 1)
			to_chat(user, "The timer is set to [DisplayTimeText(det_time)].")
		else
			to_chat(user, "\The [src] is set for instant detonation.")


/obj/item/grenade/attack_self(mob/user)
	if(!active)
		if(clown_check(user))
			preprime(user)

/obj/item/grenade/proc/log_grenade(mob/user, turf/T)
	log_bomber(user, "has primed a", src, "for detonation")

/obj/item/grenade/proc/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	var/turf/T = get_turf(src)
	log_grenade(user, T) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.throw_mode_on()
		if(msg)
			to_chat(user, "<span class='warning'>You prime [src]! [DisplayTimeText(det_time)]!</span>")
	playsound(src, 'sound/weapons/armbomb.ogg', volume, 1)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	addtimer(CALLBACK(src, .proc/prime), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/proc/prime()

/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)


/obj/item/grenade/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		switch(det_time)
			if (1)
				det_time = 10
				to_chat(user, "<span class='notice'>You set the [name] for 1 second detonation time.</span>")
			if (10)
				det_time = 30
				to_chat(user, "<span class='notice'>You set the [name] for 3 second detonation time.</span>")
			if (30)
				det_time = 50
				to_chat(user, "<span class='notice'>You set the [name] for 5 second detonation time.</span>")
			if (50)
				det_time = 1
				to_chat(user, "<span class='notice'>You set the [name] for instant detonation.</span>")
		add_fingerprint(user)
	else
		return ..()

/obj/item/grenade/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/grenade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits [owner]'s [src], setting it off! What a shot!</span>")
		prime()
		return TRUE //It hit the grenade, not them
