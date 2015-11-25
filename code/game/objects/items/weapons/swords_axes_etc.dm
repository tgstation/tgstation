/* Weapons
 * Contains:
 *		Banhammer
 *		Sword
 *		Classic Baton
 *		Energy Blade
 *		Energy Axe
 *		Energy Shield
 */

/*
 * Banhammer
 */
/obj/item/weapon/banhammer/attack(mob/M as mob, mob/user as mob)
	to_chat(M, "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>")
	to_chat(user, "<font color='red'> You have <b>BANNED</b> [M]</font>")

/*
 * Classic Baton
 */
/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	item_state = "classic_baton"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 10

/obj/item/weapon/melee/classic_baton/attack(mob/M as mob, mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>You club yourself over the head.</span>")
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, "head")
		else
			user.take_organ_damage(2*force)
		return
/*this is already called in ..()
	src.add_fingerprint(user)
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
*/
	if (user.a_intent == I_HURT)
		if(!..()) return
		playsound(get_turf(src), "swing_hit", 50, 1, -1)
		if (M.stuttering < 8 && (!(M_HULK in M.mutations))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.stuttering = 8
		M.Stun(8)
		M.Weaken(8)
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("<span class='danger'>[M] has been beaten with \the [src] by [user]!</span>", 1, "<span class='warning'>You hear someone fall</span>", 2)
	else
		playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1, -1)
		M.Stun(5)
		M.Weaken(5)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user
		src.add_fingerprint(user)

		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("<span class='danger'>[M] has been stunned with \the [src] by [user]!</span>", 1, "<span class='warning'>You hear someone fall</span>", 2)

//Telescopic baton
/obj/item/weapon/melee/telebaton
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = "telebaton_0"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = 2
	force = 3
	var/on = 0


/obj/item/weapon/melee/telebaton/attack_self(mob/user as mob)
	on = !on
	if(on)
		user.visible_message("<span class='warning'>With a flick of their wrist, [user] extends their telescopic baton.</span>",\
		"<span class='warning'>You extend the baton.</span>",\
		"You hear an ominous click.",\
		"<span class='notice'>[user] extends their fishing rod.</span>",\
		"<span class='notice'>You extend the fishing rod.</span>",\
		"You hear a balloon exploding.")

		icon_state = "telebaton_1"
		item_state = "telebaton_1"
		w_class = 4
		force = 15//quite robust
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message("<span class='notice'>[user] collapses their telescopic baton.</span>",\
		"<span class='notice'>You collapse the baton.</span>",\
		"You hear a click.",\
		"<span class='warning'>[user] collapses their fishing rod.</span>",\
		"<span class='warning'>You collapse the fishing rod.</span>",\
		"You hear a balloon exploding.")

		icon_state = "telebaton_0"
		item_state = "telebaton_0"
		w_class = 2
		force = 3//not so robust now
		attack_verb = list("hit", "punched")
	playsound(get_turf(src), 'sound/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)

	if(!blood_overlays["[type][icon_state]"])
		generate_blood_overlay()
	if(blood_overlay)
		overlays -= blood_overlay
	blood_overlay = blood_overlays["[type][icon_state]"]
	blood_overlay.color = blood_color
	overlays += blood_overlay

/obj/item/weapon/melee/telebaton/generate_blood_overlay()
	if(blood_overlays["[type][icon_state]"]) //Unless someone makes a wicked typepath this will never cause a problem
		return
	var/icon/I = new /icon(icon, icon_state)
	I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
	I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
	blood_overlays["[type][icon_state]"] = image(I)

/obj/item/weapon/melee/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		if ((M_CLUMSY in user.mutations) && prob(50))
			user.simple_message("<span class='warning'>You club yourself over the head.</span>",
				"<span class='danger'>The fishing rod goes mad!</span>")

			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, "head")
			else
				user.take_organ_damage(2*force)
			return
		if (user.a_intent == I_HURT)
			if(!..()) return
			if(!isrobot(target))
				playsound(get_turf(src), "swing_hit", 50, 1, -1)
				//target.Stun(4)	//naaah
				target.Weaken(4)
		else
			playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1, -1)
			target.Weaken(2)
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [target.name] ([target.ckey])</font>")
			log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [target.name] ([target.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
			src.add_fingerprint(user)

			target.visible_message("<span class='danger'>[target] has been stunned with \the [src] by [user]!</span>",\
				drugged_message="<span class='notice'>[user] smacks [target] with the fishing rod!</span>")

			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = user
		return
	else
		return ..()


/*
 *Energy Blade
 */
//Most of the other special functions are handled in their own files.

/obj/item/weapon/melee/energy/sword/green/New()
	..()
	_color = "green"

/obj/item/weapon/melee/energy/sword/red/New()
	..()
	_color = "red"

/*
 * Energy Axe
 */
/obj/item/weapon/melee/energy/axe/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/melee/energy/axe/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "<span class='notice'>The axe is now energised.</span>")
		src.force = 150
		src.icon_state = "axe1"
		src.w_class = 5
	else
		to_chat(user, "<span class='notice'>The axe can now be concealed.</span>")
		src.force = 40
		src.icon_state = "axe0"
		src.w_class = 5
	src.add_fingerprint(user)
	return


