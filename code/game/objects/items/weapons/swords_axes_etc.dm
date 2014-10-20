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
	M << "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>"
	user << "<font color='red'> You have <b>BANNED</b> [M]</font>"

/*
 * Classic Baton
 */
/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 10

/obj/item/weapon/melee/classic_baton/attack(mob/M as mob, mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50))
		user << "\red You club yourself over the head."
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
	if (user.a_intent == "hurt")
		if(!..()) return
		playsound(get_turf(src), "swing_hit", 50, 1, -1)
		if (M.stuttering < 8 && (!(M_HULK in M.mutations))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.stuttering = 8
		M.Stun(8)
		M.Weaken(8)
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been beaten with \the [src] by [user]!</B>", 1, "\red You hear someone fall", 2)
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
			if (O.client)	O.show_message("\red <B>[M] has been stunned with \the [src] by [user]!</B>", 1, "\red You hear someone fall", 2)

//Telescopic baton
/obj/item/weapon/melee/telebaton
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = "telebaton_0"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 2
	force = 3
	var/on = 0


/obj/item/weapon/melee/telebaton/attack_self(mob/user as mob)
	on = !on
	if(on)
		user.visible_message("\red With a flick of their wrist, [user] extends their telescopic baton.",\
		"\red You extend the baton.",\
		"You hear an ominous click.")
		icon_state = "telebaton_1"
		item_state = "telebaton_1"
		w_class = 4
		force = 15//quite robust
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message("\blue [user] collapses their telescopic baton.",\
		"\blue You collapse the baton.",\
		"You hear a click.")
		icon_state = "telebaton_0"
		item_state = "telebaton_0"
		w_class = 2
		force = 3//not so robust now
		attack_verb = list("hit", "punched")
	playsound(get_turf(src), 'sound/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)

	if(blood_overlay)							//updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay

	return

/obj/item/weapon/melee/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		if ((M_CLUMSY in user.mutations) && prob(50))
			user << "\red You club yourself over the head."
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, "head")
			else
				user.take_organ_damage(2*force)
			return
		if (user.a_intent == "hurt")
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
			target.visible_message("\red <B>[target] has been stunned with \the [src] by [user]!</B>")
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

/obj/item/weapon/melee/energy/sword/green
	New()
		_color = "green"

/obj/item/weapon/melee/energy/sword/red
	New()
		_color = "red"

/obj/item/weapon/melee/energy/blade/New()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return

/obj/item/weapon/melee/energy/blade/dropped()
	del(src)
	return

/obj/item/weapon/melee/energy/blade/proc/throw()
	del(src)
	return

/*
 * Energy Axe
 */
/obj/item/weapon/melee/energy/axe/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/melee/energy/axe/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The axe is now energised."
		src.force = 150
		src.icon_state = "axe1"
		src.w_class = 5
	else
		user << "\blue The axe can now be concealed."
		src.force = 40
		src.icon_state = "axe0"
		src.w_class = 5
	src.add_fingerprint(user)
	return


/*
 * Energy Shield
 */
/obj/item/weapon/shield/energy/IsShield()
	if(active)
		return 1
	else
		return 0

/obj/item/weapon/shield/energy/attack_self(mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50))
		user << "\red You beat yourself in the head with [src]."
		user.take_organ_damage(5)
	active = !active
	if (active)
		force = 10
		icon_state = "eshield[active]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		user << "\blue [src] is now active."
	else
		force = 3
		icon_state = "eshield[active]"
		w_class = 1
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		user << "\blue [src] can now be concealed."
	add_fingerprint(user)
	return