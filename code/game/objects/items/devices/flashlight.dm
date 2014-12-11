/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = 2
	flags = CONDUCT
	slot_flags = SLOT_BELT
	m_amt = 50
	g_amt = 20
	action_button_name = "Toggle Light"
	var/on = 0
	var/brightness_on = 4 //luminosity when on
	var/req_cell = 1
	var/open = 0
	var/obj/item/weapon/stock_parts/cell/bcell = null

/obj/item/device/flashlight/New() //this one starts with a cell pre-installed.
	..()
	bcell = new(src)
	update_icon()
	return

/obj/item/device/flashlight/initialize()
	..()
	if(open)
		icon_state = "[initial(icon_state)]-open"
		SetLuminosity(0)
		return
	if(on)
		icon_state = "[initial(icon_state)]-on"
		SetLuminosity(brightness_on)
		return
	else
		icon_state = initial(icon_state)
		SetLuminosity(0)

/obj/item/device/flashlight/proc/update_brightness(var/mob/user = null)
	if(open)
		icon_state = "[initial(icon_state)]-open"
		if(loc == user)
			user.AddLuminosity(-brightness_on)
		else if(isturf(loc))
			SetLuminosity(0)
		return
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(loc == user)
			user.AddLuminosity(brightness_on)
		else if(isturf(loc))
			SetLuminosity(brightness_on)
		return
	else
		icon_state = initial(icon_state)
		if(loc == user)
			user.AddLuminosity(-brightness_on)
		else if(isturf(loc))
			SetLuminosity(0)

/obj/item/device/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]." //To prevent some lighting anomalities.
		return 0
	on = !on
	update_brightness(user)
	return 1

/obj/item/device/flashlight/attackby(obj/item/weapon/W, mob/user)
	if(req_cell)
		if(istype(W, /obj/item/weapon/stock_parts/cell))
			if(bcell)
				user << "<span class='notice'>[src] already has a cell.</span>"
			else
				user.drop_item()
				W.loc = src
				bcell = W
				user << "<span class='notice'>You install [W] in [src].</span>"
				open = 0
				update_brightness(user)
		else if(istype(W, /obj/item/weapon/screwdriver))
			if(bcell)
				bcell.updateicon()
				bcell.loc = get_turf(src.loc)
				bcell = null
				user << "<span class='notice'>You remove the cell from the [src].</span>"
				open = 1
				update_brightness(user)
				return
	..()
	return

/obj/item/device/flashlight/attack(mob/living/M as mob, mob/living/user as mob)
	add_fingerprint(user)
	if(on && user.zone_sel.selecting == "eyes")

		if(((CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		if(!user.IsAdvancedToolUser())
			user << "<span class='notice'>You don't have the dexterity to do this!</span>"
			return

		var/mob/living/carbon/human/H = M	//mob has protective eyewear
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			user << "<span class='notice'>You're going to need to remove that [(H.head && H.head.flags & HEADCOVERSEYES) ? "helmet" : (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) ? "mask": "glasses"] first.</span>"
			return

		if(M == user)	//they're using it on themselves
			if(!M.blinded)
				flick("flash", M.flash)
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
			else
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes.</span>")
			return

		user.visible_message("<span class='notice'>[user] directs [src] to [M]'s eyes.</span>", \
							 "<span class='notice'>You direct [src] to [M]'s eyes.</span>")

		if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))	//robots and aliens are unaffected
			if(M.stat == DEAD || M.sdisabilities & BLIND)	//mob is dead or fully blind
				user << "<span class='notice'>[M] pupils does not react to the light!</span>"
			else if(XRAY in M.mutations)	//mob has X-RAY vision
				user << "<span class='notice'>[M] pupils give an eerie glow!</span>"
			else	//they're okay!
				if(!M.blinded)
					flick("flash", M.flash)	//flash the affected mob
					user << "<span class='notice'>[M]'s pupils narrow.</span>"
	else
		return ..()


/obj/item/device/flashlight/pickup(mob/user)
	if(on)
		user.AddLuminosity(brightness_on)
		SetLuminosity(0)


/obj/item/device/flashlight/dropped(mob/user)
	if(on)
		user.AddLuminosity(-brightness_on)
		SetLuminosity(brightness_on)

/obj/item/device/flashlight/process()
	if(req_cell)
		if(bcell.charge < 50)
			on = 0
			update_icon()
		if(on)
			bcell.use(50)
			update_icon()

/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon_state = "penlight"
	item_state = ""
	flags = CONDUCT
	brightness_on = 2
	req_cell = 0

/obj/item/device/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	icon_state = "seclite"
	item_state = "seclite"
	force = 9 // Not as good as a stun baton.
	brightness_on = 5 // A little better than the standard flashlight.
	hitsound = 'sound/weapons/genhit1.ogg'

// the desk lamps are a bit special
/obj/item/device/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	brightness_on = 5
	w_class = 4
	flags = CONDUCT
	m_amt = 0
	g_amt = 0
	on = 1
	req_cell = 0

// green-shaded desk lamp
/obj/item/device/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"
	brightness_on = 5


/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

// FLARES

/obj/item/device/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	w_class = 2.0
	brightness_on = 7 // Pretty bright.
	icon_state = "flare"
	item_state = "flare"
	action_button_name = null	//just pull it manually, neckbeard.
	var/fuel = 0
	var/on_damage = 7
	var/produce_heat = 1500
	req_cell = 0

/obj/item/device/flashlight/flare/New()
	fuel = rand(800, 1000) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.
	..()

/obj/item/device/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos)
		pos.hotspot_expose(produce_heat, 5)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		if(!fuel)
			icon_state = "[initial(icon_state)]-empty"
		processing_objects -= src

/obj/item/device/flashlight/flare/proc/turn_off()
	on = 0
	force = initial(src.force)
	damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

/obj/item/device/flashlight/flare/update_brightness(var/mob/user = null)
	..()
	if(on)
		item_state = "[initial(item_state)]-on"
	else
		item_state = "[initial(item_state)]"

/obj/item/device/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		user << "<span class='notice'>It's out of fuel.</span>"
		return
	if(on)
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message("<span class='notice'>[user] lights the [src].</span>", "<span class='notice'>You light the [src]!</span>")
		force = on_damage
		damtype = "fire"
		processing_objects += src

/obj/item/device/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some leaves and a log."
	w_class = 4
	brightness_on = 7
	icon_state = "torch"
	item_state = "torch"
	on_damage = 10

/obj/item/device/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = "Extract from a yellow slime. It emits a strong light when squeezed."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "slime"
	item_state = "slime"
	w_class = 2
	slot_flags = SLOT_BELT
	m_amt = 0
	g_amt = 0
	brightness_on = 6 //luminosity when on

/obj/item/device/flashlight/emp
	origin_tech = "magnets=4;syndicate=5"

	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_tick = 0
	req_cell = 0

/obj/item/device/flashlight/emp/New()
		..()
		processing_objects.Add(src)

/obj/item/device/flashlight/emp/Destroy()
		processing_objects.Remove(src)
		..()

/obj/item/device/flashlight/emp/process()
		charge_tick++
		if(charge_tick < 10) return 0
		charge_tick = 0
		emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
		return 1

/obj/item/device/flashlight/emp/attack(mob/living/M as mob, mob/living/user as mob)
	if(on && user.zone_sel.selecting == "eyes") // call original attack proc only if aiming at the eyes
		..()
	return

/obj/item/device/flashlight/emp/afterattack(atom/A as mob|obj, mob/user, proximity)
	if(!proximity) return
	if (emp_cur_charges > 0)
		emp_cur_charges -= 1
		A.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].", \
											"<span class='userdanger'>[user] blinks \the [src] at \the [A].")
		if(ismob(A))
			var/mob/M = A
			add_logs(user, M, "attacked", object="EMP-light")
		user << "\The [src] now has [emp_cur_charges] charge\s."
		A.emp_act(1)
	else
		user << "<span class='warning'>\The [src] needs time to recharge!</span>"
	return