/obj/item/device/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	var/pointer_icon_state
	flags = CONDUCT
	slot_flags = SLOT_BELT
	m_amt = 500
	g_amt = 500
	w_class = 2 //Increased to 2, because diodes are w_class 2. Conservation of matter.
	origin_tech = "combat=1;magnets=2"
	var/turf/pointer_loc
	var/energy = 5
	var/max_energy = 5
	var/effectchance = 33
	var/recharging = 0
	var/recharge_locked = 0
	var/obj/item/weapon/stock_parts/micro_laser/diode //used for upgrading!


/obj/item/device/laser_pointer/red
	pointer_icon_state = "red_laser"
/obj/item/device/laser_pointer/green
	pointer_icon_state = "green_laser"
/obj/item/device/laser_pointer/blue
	pointer_icon_state = "blue_laser"
/obj/item/device/laser_pointer/purple
	pointer_icon_state = "purple_laser"

/obj/item/device/laser_pointer/New()
	..()
	diode = new(src)
	if(!pointer_icon_state)
		pointer_icon_state = pick("red_laser","green_laser","blue_laser","purple_laser")

/obj/item/device/laser_pointer/upgraded/New()
	..()
	diode = new /obj/item/weapon/stock_parts/micro_laser/ultra



/obj/item/device/laser_pointer/attack(mob/living/M, mob/user)
	laser_act(M, user)

/obj/item/device/laser_pointer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/stock_parts/micro_laser))
		if(!diode)
			if(!user.unEquip(W))
				return
			W.loc = src
			diode = W
			user << "<span class='notice'>You install a [diode.name] in [src].</span>"
		else
			user << "<span class='notice'>[src] already has a diode installed.</span>"
		return

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(diode)
			user << "<span class='notice'>You remove the [diode.name] from \the [src].</span>"
			diode.loc = get_turf(src.loc)
			diode = null
		return
	..()
	return

/obj/item/device/laser_pointer/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(flag)	//we're placing the object on a table or in backpack
		return
	laser_act(target, user)

/obj/item/device/laser_pointer/proc/laser_act(var/atom/target, var/mob/living/user)
	if( !(user in (viewers(7,target))) )
		return
	if (!diode)
		user << "<span class='notice'>You point [src] at [target], but nothing happens!</span>"
		return
	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna && (H.dna.check_mutation(HULK) || NOGUNS in H.dna.species.specflags))
			user << "<span class='warning'>Your fingers can't press the button!</span>"
			return

	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		user << "<span class='notice'>You point [src] at [target], but it's still charging.</span>"
		return

	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(user.zone_sel.selecting == "eyes")
			add_logs(user, C, "shone in the eyes", object="laser pointer")

			var/severity = 1
			if(prob(33))
				severity = 2
			else if(prob(50))
				severity = 0

			//20% chance to actually hit the eyes
			if(prob(effectchance * diode.rating) && C.flash_eyes(severity))
				outmsg = "<span class='notice'>You blind [C] by shining [src] in their eyes.</span>"
				if(C.weakeyes)
					C.Stun(1)
			else
				outmsg = "<span class='warning'>You fail to blind [C] by shining [src] at their eyes!</span>"

	//robots and AI
	else if(issilicon(target))
		var/mob/living/silicon/S = target
		//20% chance to actually hit the sensors
		if(prob(effectchance * diode.rating))
			flick("e_flash", S.flash)
			S.Weaken(rand(5,10))
			S << "<span class='danger'>Your sensors were overloaded by a laser!</span>"
			outmsg = "<span class='notice'>You overload [S] by shining [src] at their sensors.</span>"
			add_logs(user, S, "shone in the sensors", object="laser pointer")
		else
			outmsg = "<span class='warning'>You fail to overload [S] by shining [src] at their sensors!</span>"

	//cameras
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(effectchance * diode.rating))
			C.emp_act(1)
			outmsg = "<span class='notice'>You hit the lens of [C] with [src], temporarily disabling the camera!</span>"
			add_logs(user, C, "EMPed", object="laser pointer")
		else
			outmsg = "<span class='warning'>You miss the lens of [C] with [src]!</span>"

	//laser pointer image
	icon_state = "pointer_[pointer_icon_state]"
	var/list/showto = list()
	for(var/mob/M in range(7,targloc))
		if(M.client)
			showto.Add(M.client)
	var/image/I = image('icons/obj/projectiles.dmi',targloc,pointer_icon_state,10)
	I.pixel_x = target.pixel_x + rand(-5,5)
	I.pixel_y = target.pixel_y + rand(-5,5)

	if(outmsg)
		user << outmsg
	else
		user << "<span class='info'>You point [src] at [target].</span>"

	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = 1
			SSobj.processing |= src
		if(energy <= 0)
			user << "<span class='warning'>The [src]'s battery is overused, it needs time to recharge!</span>"
			recharge_locked = 1

	flick_overlay(I, showto, 10)
	icon_state = "pointer"

/obj/item/device/laser_pointer/process()
	if(prob(20 - recharge_locked*5))
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = 0
			recharge_locked = 0
			..()
