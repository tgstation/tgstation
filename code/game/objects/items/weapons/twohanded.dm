/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 *		High Energy Frequency Blade
 */

///////////OFFHAND///////////////
//what the mob gets when wielding something
/obj/item/offhand
	w_class = 5.0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "offhand"
	name = "offhand"
	var/obj/item/wielding = null

/obj/item/offhand/dropped(user)
	if(!wielding)
		returnToPool(src)
		return null
	return wielding.unwield(user)


/obj/item/offhand/unwield(user)
	if(!wielding)
		returnToPool(src)
		return null
	return wielding.unwield(user)

/obj/item/offhand/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag) return
	if(istype(target, /obj/item/weapon/storage)) //we place automatically
		return
	if(wielding)
		if(!target.attackby(wielding, user))
			wielding.afterattack(target, user, proximity_flag, click_parameters)
		return 1

/obj/item/offhand/attack_self(mob/user)
	if(!wielding)
		qdel(src)
		return null
	return wielding.unwield(user)

/obj/item/offhand/proc/attach_to(var/obj/item/I)
	I.wielded = src
	wielding = I
	name = wielding.name + " offhand"
	desc = "Your second grip on the [I.name]"

/obj/item/offhand/IsShield()//if the actual twohanded weapon is a shield, we count as a shield too!
	return wielding.IsShield()
/*
 * Fireaxe
 */
/obj/item/weapon/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	w_class = 4.0
	sharpness = 1.2
	slot_flags = SLOT_BACK
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	flags = FPRINT | TWOHANDABLE

/obj/item/weapon/fireaxe/update_wield(mob/user)
	..()
	item_state = "fireaxe[wielded ? 1 : 0]"
	force = wielded ? 40 : 10
	if(user)
		user.update_inv_l_hand()
		user.update_inv_r_hand()

/obj/item/weapon/fireaxe/suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is smashing \himself in the head with the [src.name]! It looks like \he's commit suicide!</span>")
		return (BRUTELOSS)

/obj/item/weapon/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	..()
	if(A && wielded && (istype(A,/obj/structure/window) || istype(A,/obj/structure/grille))) //destroys windows and grilles in one hit
		user.delayNextAttack(8)
		if(istype(A,/obj/structure/window))
			var/pdiff=performWallPressureCheck(A.loc)
			if(pdiff>0)
				message_admins("[A] with pdiff [pdiff] fire-axed by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(A.loc)]!")
				log_admin("[A] with pdiff [pdiff] fire-axed by [user.real_name] ([user.ckey]) at [A.loc]!")
			var/obj/structure/window/W = A
			W.Destroy(brokenup = 1)
		else
			del(A)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/dualsaber
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TWOHANDABLE
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/dualsaber/update_wield(mob/user)
	..()
	icon_state = "dualsaber[wielded ? 1 : 0]"
	item_state = "dualsaber[wielded ? 1 : 0]"
	force = wielded ? 30 : 3
	w_class = wielded ? 5 : 2
	if(user)
		user.update_inv_l_hand()
		user.update_inv_r_hand()
	playsound(get_turf(src), wielded ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 50, 1)
	return

/obj/item/weapon/dualsaber/attack(target as mob, mob/living/user as mob)
	..()
	if((M_CLUMSY in user.mutations) && (wielded) &&prob(40))
		to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on the [src].</span>")
		user.take_organ_damage(20,25)
		return
	if((wielded) && prob(50))
		spawn for(var/i=1, i<=8, i++)
			user.dir = turn(user.dir, 45)
			sleep(1)

/obj/item/weapon/dualsaber/IsShield()
	if(wielded)
		return 1
	else
		return 0



/*
 * High-Frequency Blade
 */
/obj/item/weapon/katana/hfrequency
	icon_state = "hfrequency0"
	item_state = "hfrequency0"
	name = "high-frequency blade"
	desc = "Keep hands off blade at all times."
	slot_flags = SLOT_BACK
	throwforce = 35
	throw_speed = 5
	throw_range = 10
	w_class = 4.0
	flags = FPRINT | TWOHANDABLE
	origin_tech = "magnets=4;combat=5"

/obj/item/weapon/katana/hfrequency/update_wield(mob/user)
	..()
	item_state = "hfrequency[wielded ? 1 : 0]"
	force = wielded ? 200 : 50
	if(user)
		user.update_inv_l_hand()
		user.update_inv_r_hand()
	return

/obj/item/weapon/katana/hfrequency/IsShield()
	if(wielded)
		return 1
	else
		return 0


//spears
/obj/item/weapon/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = 4.0
	slot_flags = SLOT_BACK
	throwforce = 15
	flags = TWOHANDABLE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")

/obj/item/weapon/spear/update_wield(mob/user)
	icon_state = "spearglass[wielded ? 1 : 0]"
	item_state = "spearglass[wielded ? 1 : 0]"
	force = wielded ? 18 : 10
	if(user)
		user.update_inv_l_hand()
		user.update_inv_r_hand()
	return
