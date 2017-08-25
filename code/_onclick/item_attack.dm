
/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	if(pre_attackby(target, user, params))
		// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
		var/resolved = target.attackby(src, user, params)
		if(!resolved && target && !QDELETED(src))
			afterattack(target, user, 1, params) // 1: clicking something Adjacent


// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

/obj/item/proc/pre_attackby(atom/A, mob/living/user, params) //do stuff before attackby!
	return TRUE //return FALSE to avoid calling attackby after this proc does stuff

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	return

/obj/attackby(obj/item/I, mob/living/user, params)
	return I.attack_obj(src, user)

/mob/living/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.a_intent == INTENT_HARM && stat == DEAD && butcher_results) //can we butcher it?
		var/sharpness = I.is_sharp()
		if(sharpness)
			to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
			if(do_mob(user, src, 80/sharpness) && Adjacent(I))
				harvest(user)
			return 1
	return I.attack(src, user)


/obj/item/proc/attack(mob/living/M, mob/living/user)
	if(flags_1 & NOBLUDGEON_1)
		return
	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	user.lastattacked = M
	M.lastattacker = user

	user.do_attack_animation(M)
	M.attacked_by(src, user)

	add_logs(user, M, "attacked", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)


//the equivalent of the standard version of attack() but for object targets.
/obj/item/proc/attack_obj(obj/O, mob/living/user)
	if(flags_1 & NOBLUDGEON_1)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(O)
	O.attacked_by(src, user)

/atom/movable/proc/attacked_by()
	return

/obj/attacked_by(obj/item/I, mob/living/user)
	if(I.force)
		visible_message("<span class='danger'>[user] has hit [src] with [I]!</span>", null, null, COMBAT_MESSAGE_RANGE)
		//only witnesses close by and the victim see a hit message.
	take_damage(I.force, I.damtype, "melee", 1)

/mob/living/attacked_by(obj/item/I, mob/living/user)
	send_item_attack_message(I, user)
	if(I.force)
		apply_damage(I.force, I.damtype)
		if(I.damtype == BRUTE)
			if(prob(33))
				I.add_mob_blood(src)
				var/turf/location = get_turf(src)
				add_splatter_floor(location)
				if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(src)
		return TRUE //successful attack

/mob/living/simple_animal/attacked_by(obj/item/I, mob/living/user)
	if(I.force < force_threshold || I.damtype == STAMINA)
		playsound(loc, 'sound/weapons/tap.ogg', I.get_clamped_volume(), 1, -1)
	else
		return ..()

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return


/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return Clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return Clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	var/message_verb = "attacked"
	if(I.attack_verb && I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	else if(!I.force)
		return
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message = "[src] has been [message_verb][message_hit_area] with [I]."
	if(user in viewers(src, null))
		attack_message = "[user] has [message_verb] [src][message_hit_area] with [I]!"
	visible_message("<span class='danger'>[attack_message]</span>", \
		"<span class='userdanger'>[attack_message]</span>", null, COMBAT_MESSAGE_RANGE)
	return 1

