

/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 */

/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

//Rewrote TwoHanded weapons stuff and put it all here. Just copypasta fireaxe to make new ones ~Carn
//This rewrite means we don't have two variables for EVERY item which are used only by a few weapons.
//It also tidies stuff up elsewhere. also derp.



/*
 * Twohanded
 */



/obj/item/weapon/twohanded
	var/wielded = 0
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = null
	var/unwieldsound = null

/obj/item/weapon/twohanded/proc/unwield()
	wielded = 0
	force = force_unwielded
	name = "[initial(name)]"
	set_icon()


/obj/item/weapon/twohanded/proc/wield()
	wielded = 1
	force = force_wielded
	name = "[initial(name)] (Wielded)"
	set_icon()



/obj/item/weapon/twohanded/proc/set_icon()
	set src in usr

	if(findtext(icon_state, "fireaxe"))
		item_state = "fireaxe[wielded]"

	else if(findtext(icon_state, "dualsaber"))
		item_state = "dualsaber[wielded]"

	else if(findtext(icon_state, "hfrequency"))
		item_state = "hfrequency[wielded]"

	else if(findtext(icon_state, "Gibtonite Ore"))
	//Do nothing. Gibtonite ore has no wielded sprites

	else
		item_state = "spearglass[wielded]"


	usr.update_inv_l_hand()
	usr.update_inv_r_hand()
	update_icon()


/obj/item/weapon/twohanded/mob_can_equip(M as mob, slot)
	//Cannot equip wielded items.
	if(wielded)
		M << "<span class='warning'>Unwield the [initial(name)] first!</span>"
		return 0

	return ..()

/obj/item/weapon/twohanded/dropped(mob/user as mob)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/weapon/twohanded/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
	return	unwield()

//obj/item/weapon/twohanded/update_icon()
//	return

/obj/item/weapon/twohanded/pickup(mob/user)
	wielded = 0
	set_icon()
	wielded = 0

/obj/item/weapon/twohanded/attack_self(mob/user as mob)
	if( istype(user,/mob/living/carbon/monkey) )
		user << "<span class='warning'>It's too heavy for you to wield fully.</span>"
		return

	//..()
	if(wielded) //Trying to unwield it
		unwield()
		user << "<span class='notice'>You are now carrying the [name] with one hand.</span>"
		if (src.unwieldsound)
			playsound(get_turf(src), unwieldsound, 50, 1)

		var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
		if(O && istype(O))
			O.unwield()
		//world << "<span class='warning'>[icon_state]</span>" // debugging
		return

	else //Trying to wield it
		if(user.get_inactive_hand())
			user << "<span class='warning'>You need your other hand to be empty</span>"
			return
		wield()
		user << "<span class='notice'>You grab the [initial(name)] with both hands.</span>"
		if (src.wieldsound)
			playsound(get_turf(src), wieldsound, 50, 1)

		var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
		O.name = "[initial(name)] - offhand"
		O.desc = "Your second grip on the [initial(name)]"
		user.put_in_inactive_hand(O)
		//world << "<span class='warning'>[icon_state]</span>" // debugging
		return

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = 5.0
	icon_state = "offhand"
	name = "offhand"
	//flags = ABSTRACT

/obj/item/weapon/twohanded/offhand/unwield()
	del(src)

/obj/item/weapon/twohanded/offhand/wield()
	del(src)

/obj/item/weapon/twohanded/offhand/IsShield()//if the actual twohanded weapon is a shield, we count as a shield too!
	var/mob/user = loc
	if(!istype(user)) return 0
	var/obj/item/I = user.get_active_hand()
	if(I == src) I = user.get_inactive_hand()
	if(!I) return 0
	return I.IsShield()

///////////Two hand required objects///////////////
//This is for objects that require two hands to even pick up
/obj/item/weapon/twohanded/required/
	w_class = 5.0

/obj/item/weapon/twohanded/required/attack_self()
	return

/obj/item/weapon/twohanded/required/mob_can_equip(M as mob, slot)
	if(wielded)
		M << "<span class='warning'>[src.name] is too cumbersome to carry with anything but your hands!</span>"
		return 0
	return ..()

/obj/item/weapon/twohanded/required/attack_hand(mob/user)//Can't even pick it up without both hands empty
	var/obj/item/weapon/twohanded/required/H = user.get_inactive_hand()
	if(H != null)
		user.visible_message("<span class='notice'>[src.name] is too cumbersome to carry in one hand!</span>")
		return
	var/obj/item/weapon/twohanded/offhand/O = new(user)
	user.put_in_inactive_hand(O)
	..()
	wielded = 1


//obj/item/weapon/twohanded/

/*
 * Fireaxe
 */
/obj/item/weapon/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 40
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is smashing \himself in the head with the [src.name]! It looks like \he's commit suicide!</b>"
		return (BRUTELOSS)

/obj/item/weapon/twohanded/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	..()
	if(A && wielded && (istype(A,/obj/structure/window) || istype(A,/obj/structure/grille))) //destroys windows and grilles in one hit
		if(istype(A,/obj/structure/window))
			var/pdiff=performWallPressureCheck(A.loc)
			if(pdiff>0)
				message_admins("[A] with pdiff [pdiff] fire-axed by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(A.loc)]!")
				log_admin("[A] with pdiff [pdiff] fire-axed by [user.real_name] ([user.ckey]) at [A.loc]!")
			var/obj/structure/window/W = A
			W.destroy()
		else
			del(A)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/twohanded/dualsaber
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	force_unwielded = 3
	force_wielded = 30
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	flags = FPRINT | TABLEPASS | NOSHIELD
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/twohanded/dualsaber/update_icon()
	icon_state = "dualsaber[wielded]"
	return

/obj/item/weapon/twohanded/dualsaber/attack(target as mob, mob/living/user as mob)
	..()
	if((M_CLUMSY in user.mutations) && (wielded) &&prob(40))
		user << "\red You twirl around a bit before losing your balance and impaling yourself on the [src]."
		user.take_organ_damage(20,25)
		return
	if((wielded) && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.dir = i
				sleep(1)

/obj/item/weapon/twohanded/dualsaber/IsShield()
	if(wielded)
		return 1
	else
		return 0



/*
 * High-Frequency Blade
 */
/obj/item/weapon/twohanded/hfrequency
	icon_state = "hfrequency0"
	item_state = "hfrequency0"
	name = "high-frequency blade"
	desc = "Keep hands off blade at all times."
	slot_flags = SLOT_BACK
	force = 3
	throwforce = 35
	throw_speed = 5
	throw_range = 10
	w_class = 4.0
	force_unwielded = 40
	force_wielded = 120
	flags = FPRINT | TABLEPASS | NOSHIELD
	origin_tech = "magnets=4;combat=5"

/obj/item/weapon/twohanded/hfrequency/update_icon()
	icon_state = "hfrequency[wielded]"
	return


//spears
/obj/item/weapon/twohanded/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 18 // Was 13, Buffed - RR
	throwforce = 15
	flags = NOSHIELD
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")

/obj/item/weapon/twohanded/spear/update_icon()
	icon_state = "spearglass[wielded]"
	return
