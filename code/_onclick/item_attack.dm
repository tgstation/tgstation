
// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	return

/obj/attackby(obj/item/I, mob/living/user, params)
	return I.attack_obj(src, user)

/mob/living/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.a_intent == "harm" && stat == DEAD && butcher_results) //can we butcher it?
		var/sharpness = I.is_sharp()
		if(sharpness)
			user << "<span class='notice'>You begin to butcher [src]...</span>"
			playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
			if(do_mob(user, src, 80/sharpness))
				harvest(user)
			return 1
	return I.attack(src, user)


/obj/item/proc/attack(mob/living/M, mob/living/user, def_zone)
	if(flags & (NOBLUDGEON|ABSTRACT))
		return
	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	user.lastattacked = M
	M.lastattacker = user

	M.attacked_by(src, user, def_zone)

	add_logs(user, M, "attacked", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)


//the equivalent of the standard version of attack() but for object targets.
/obj/item/proc/attack_obj(obj/O, mob/living/user)
	if(flags & (NOBLUDGEON|ABSTRACT))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(O)
	O.attacked_by(src, user)



/atom/movable/proc/attacked_by()
	return

/obj/attacked_by(obj/item/I, mob/living/user)
	if(I.force)
		user.visible_message("<span class='danger'>[user] has hit [src] with [I]!</span>", "<span class='danger'>You hit [src] with [I]!</span>")

/mob/living/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(user != src)
		user.do_attack_animation(src)
	if(send_item_attack_message(I, user, def_zone))
		if(apply_damage(I.force, I.damtype, def_zone))
			if(I.damtype == BRUTE)
				if(prob(33))
					var/turf/location = get_turf(src)
					location.add_blood_floor(src)



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
	if(I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	else if(!I.force)
		return 0
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"

	var/attack_message = "[src] has been [message_verb][message_hit_area] with [I]."
	if(user in viewers(src, null))
		attack_message = "[user] has [message_verb] [src][message_hit_area] with [I]!"
	visible_message("<span class='danger'>[attack_message]</span>",
		"<span class='userdanger'>[attack_message]</span>")
	return 1

/mob/living/simple_animal/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	if(!I.force)
		user.visible_message("<span class='warning'>[user] gently taps [src] with [I].</span>",\
						"<span class='warning'>This weapon is ineffective, it does no damage!</span>")
	else if(I.force < force_threshold || I.damtype == STAMINA)
		visible_message("<span class='warning'>[I] bounces harmlessly off of [src].</span>",\
					"<span class='warning'>[I] bounces harmlessly off of [src]!</span>")
	else
		return ..()