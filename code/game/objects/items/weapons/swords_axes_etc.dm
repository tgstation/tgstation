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
/obj/item/weapon/banhammer/attack(mob/M, mob/user)
	M << "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>"
	user << "<font color='red'> You have <b>BANNED</b> [M]</font>"

/*
 * Sword
 */
/obj/item/weapon/melee/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/New()
	color = pick("red", "blue", "green", "purple")

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>"
		user.take_organ_damage(5,5)
	active = !active
	if (active)
		force = 30
		throwforce = 20
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass1"
		else
			icon_state = "sword[color]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		user << "<span class='notice'>[src] is now active.</span>"
	else
		force = 3
		throwforce = 5.0
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass0"
		else
			icon_state = "sword0"
		w_class = 2
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		user << "<span class='notice'>[src] can now be concealed.</span>"
	add_fingerprint(user)
	return

/obj/item/weapon/melee/energy/sword/attackby(obj/item/weapon/W, mob/living/user)
	..()
	if(istype(W, /obj/item/weapon/melee/energy/sword))
		if(W == src)
			user << "<span class='notice'>You try to attach the end of the energy sword to... itself. You're not very smart, are you?</span>"
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else
			user << "<span class='notice'>You attach the ends of the two energy swords, making a single double-bladed weapon! You're cool.</span>"
			new /obj/item/weapon/twohanded/dualsaber(user.loc)
			del(W)
			del(src)

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

/obj/item/weapon/melee/classic_baton/attack(mob/M, mob/living/user)
	add_fingerprint(user)
	if((CLUMSY in user.mutations) && prob(50))
		user << "<span class='warning'>You club yourself over the head!</span>"
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2 * force, BRUTE, "head")
			H.forcesay(hit_appends)
		else
			user.take_organ_damage(2 * force)
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	if(user.a_intent == "harm")
		if(!..()) return
		playsound(loc, "swing_hit", 50, 1, -1)
		if(M.stuttering < 8 && !(HULK in M.mutations))
			M.stuttering = 8
		M.Stun(8)
		M.Weaken(8)
		M.visible_message("<span class='danger'>[M] has been beaten with [src] by [user]!</span>", \
							"<span class='userdanger'>[M] has been beaten with [src] by [user]!</span>")
	else
		playsound(loc, 'sound/weapons/Genhit.ogg', 50, 1, -1)
		M.Stun(5)
		M.Weaken(5)
		M.visible_message("<span class='danger'>[M] has been stunned with [src] by [user]!</span>", \
							"<span class='userdanger'>[M] has been stunned with [src] by [user]!</span>")

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.forcesay(hit_appends)


/*
 *Energy Blade
 */
//Most of the other special functions are handled in their own files.

/obj/item/weapon/melee/energy/sword/green
	New()
		color = "green"

/obj/item/weapon/melee/energy/sword/red
	New()
		color = "red"

/obj/item/weapon/melee/energy/blade/New()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/melee/energy/blade/dropped()
	del(src)

/obj/item/weapon/melee/energy/blade/proc/throw()
	del(src)


/*
 * Energy Axe
 */
/obj/item/weapon/melee/energy/axe/attack(target, mob/user)
	..()

/obj/item/weapon/melee/energy/axe/attack_self(mob/user)
	active = !active
	if(active)
		user << "<span class='notice'>[src] is now energised.</span>"
		force = 150
		icon_state = "axe1"
		w_class = 5
	else
		user << "<span class='notice'>[src] can now be concealed.</span>"
		force = 40
		icon_state = "axe0"
		w_class = 5
	add_fingerprint(user)


/*
 * Energy Shield
 */
/obj/item/weapon/shield/energy/IsShield()
	if(active)
		return 1
	else
		return 0

/obj/item/weapon/shield/energy/attack_self(mob/living/user)
	if((CLUMSY in user.mutations) && prob(50))
		user << "<span class='warning'>You beat yourself in the head with [src].</span>"
		user.take_organ_damage(5)
	active = !active

	if(active)
		force = 10
		icon_state = "eshield[active]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		user << "<span class='notice'>[src] is now active.</span>"
	else
		force = 3
		icon_state = "eshield[active]"
		w_class = 1
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		user << "<span class='notice'>[src] can now be concealed.</span>"
	add_fingerprint(user)