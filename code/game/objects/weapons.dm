/obj/item/weapon/
	name = "weapon"
	icon = 'icons/obj/weapons.dmi'
	var/twohanded = 0
	var/requiretwohanded = 0
	var/wielded = 0
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = null
	var/unwieldsound = null

/obj/item/weapon/New()
	..()
	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"

/obj/item/weapon/Bump(mob/M as mob)
	spawn(0)
		..()
	return

/obj/item/weapon/proc/unwield(mob/living/carbon/user)
	if(!twohanded) return
	if(!wielded) return
	wielded = 0
	force = force_unwielded
	name = "[initial(name)]"
	update_icon()
	user << "<span class='notice'>You are now carrying the [name] with one hand.</span>"
	if(unwieldsound)
		playsound(loc, unwieldsound, 50, 1)
	var/obj/item/weapon/offhand/O = user.get_inactive_hand()
	if(O && istype(O))
		O.unwield()
	return

/obj/item/weapon/proc/wield(mob/living/carbon/user)
	if(!twohanded) return
	if(wielded) return
	if(istype(user,/mob/living/carbon/monkey) )
		user << "<span class='warning'>It's too heavy for you to wield fully.</span>"
		return
	if(user.get_inactive_hand())
		user << "<span class='warning'>You need your other hand to be empty</span>"
		return
	wielded = 1
	force = force_wielded
	name = "[initial(name)] (Wielded)"
	update_icon()
	user << "<span class='notice'>You grab the [initial(name)] with both hands.</span>"
	if (wieldsound)
		playsound(loc, wieldsound, 50, 1)
	var/obj/item/weapon/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[initial(name)] - offhand"
	O.desc = "Your second grip on the [initial(name)]"
	user.put_in_inactive_hand(O)
	return

/obj/item/weapon/mob_can_equip(M as mob, slot)
	if(twohanded)//Cannot equip wielded items.
		if(wielded)
			if(requiretwohanded)
				M << "<span class='warning'>[src.name] is too cumbersome to carry with anything but your hands!</span>"
				return 0
			M << "<span class='warning'>Unwield the [initial(name)] first!</span>"
			return 0
		return ..()

/obj/item/weapon/dropped(mob/user as mob)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(twohanded)
		if(user)
			var/obj/item/weapon/O = user.get_inactive_hand()
			O.unwield(user)
		return	unwield(user)

/obj/item/weapon/attack_self(mob/user as mob)
	..()
	if(twohanded)
		if(requiretwohanded)
			return
		if(wielded) //Trying to unwield it
			unwield(user)
		else //Trying to wield it
			wield(user)

///////////OFFHAND///////////////
/obj/item/weapon/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = 5.0
	flags = ABSTRACT

/obj/item/weapon/offhand/unwield()
	qdel(src)

/obj/item/weapon/offhand/wield()
	qdel(src)

/obj/item/weapon/offhand/IsShield()//if the actual twohanded weapon is a shield, we count as a shield too!
	var/mob/user = loc
	if(!istype(user)) return 0
	var/obj/item/I = user.get_active_hand()
	if(I == src) I = user.get_inactive_hand()
	if(!I) return 0
	return I.IsShield()

/obj/item/weapon/attack_hand(mob/user)//Can't even pick it up without both hands empty
	if(requiretwohanded)
		var/obj/item/weapon/H = user.get_inactive_hand()
		if(H != null)
			user.visible_message("<span class='notice'>[src.name] is too cumbersome to carry in one hand!</span>")
			return
		var/obj/item/weapon/offhand/O = new(user)
		user.put_in_inactive_hand(O)
		..()
		wielded = 1
	..()

/*
 * Fireaxe
 */
/obj/item/weapon/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 5
	force_wielded = 24 // Was 18, Buffed - RobRichards/RR
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	twohanded = 1

/obj/item/weapon/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[wielded]"
	return

/obj/item/weapon/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	if(A && wielded && (istype(A,/obj/structure/window) || istype(A,/obj/structure/grille))) //destroys windows and grilles in one hit
		if(istype(A,/obj/structure/window)) //should just make a window.Break() proc but couldn't bother with it
			var/obj/structure/window/W = A

			new /obj/item/weapon/shard( W.loc )
			if(W.reinf) new /obj/item/stack/rods( W.loc)

			if (W.dir == SOUTHWEST)
				new /obj/item/weapon/shard( W.loc )
				if(W.reinf) new /obj/item/stack/rods( W.loc)
		qdel(A)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/dualsaber
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = 2.0
	force_unwielded = 3
	force_wielded = 34
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	hitsound = "swing_hit"
	flags = NOSHIELD
	origin_tech = "magnets=3;syndicate=4"
	item_color = "green"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/hacked = 0
	reflect_chance = 0
	twohanded = 1

/obj/item/weapon/dualsaber/New()
	item_color = pick("red", "blue", "green", "purple")

/obj/item/weapon/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[item_color][wielded]"
	else
		icon_state = "dualsaber0"
	clean_blood()//blood overlays get weird otherwise, because the sprite changes.
	return

/obj/item/weapon/dualsaber/attack(target as mob, mob/living/carbon/human/user as mob)
	..()
	if(user.disabilities & CLUMSY && (wielded) && prob(40))
		impale(user)
		return
	if((wielded) && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.dir = i
				sleep(1)

/obj/item/weapon/dualsaber/proc/impale(mob/living/user as mob)
	user << "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on \the [src].</span>"
	if (force_wielded)
		user.take_organ_damage(20,25)
	else
		user.adjustStaminaLoss(25)

/obj/item/weapon/dualsaber/IsShield()
	if(wielded)
		return 1
	else
		return 0

/obj/item/weapon/dualsaber/attack_hulk(mob/living/carbon/human/user)  //In case thats just so happens that it is still activated on the groud, prevents hulk from picking it up
	if(wielded)
		user << "<span class='warning'>You cant pick up such dangerous item with your meaty hands without losing fingers, better not to.</span>"
		return 1

/obj/item/weapon/dualsaber/wield(mob/living/carbon/M) //Specific wield () hulk checks due to reflect_chance var for balance issues and switches hitsounds.
	if(istype(M))
		if(M.dna.check_mutation(HULK))
			M << "<span class='warning'>You lack the grace to wield this.</span>"
			return
	..()
	hitsound = 'sound/weapons/blade1.ogg'

/obj/item/weapon/dualsaber/unwield() //Specific unwield () to switch hitsounds.
	..()
	hitsound = "swing_hit"

/obj/item/weapon/dualsaber/IsReflect()
	if(wielded)
		return 1

/obj/item/weapon/dualsaber/green
	New()
		item_color = "green"

/obj/item/weapon/dualsaber/red
	New()
		item_color = "red"

/obj/item/weapon/dualsaber/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			user << "<span class='warning'>2XRNBW_ENGAGE</span>"
			item_color = "rainbow"
			update_icon()
		else
			user << "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>"


//spears
/obj/item/weapon/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 18 // Was 13, Buffed - RR
	throwforce = 20
	throw_speed = 3
	flags = NOSHIELD
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	twohanded = 1

/obj/item/weapon/spear/update_icon()
	icon_state = "spearglass[wielded]"
	return