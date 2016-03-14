/obj/item/device/blinder
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. The film chamber is filled with wire for some reason."
	icon_state = "polaroid"
	item_state = "polaroid"
	w_class = 2.0
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	origin_tech = "materials=1;engineering=1"
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_ELECTRONIC
	var/cell = null
	var/bulb = 1
	var/burnedout = 0
	var/powercost = 10000

/obj/item/device/blinder/Destroy()
	if(cell)
		qdel(cell)
		cell = null
	..()

/obj/item/device/blinder/New()
	..()
	update_verbs()

/obj/item/device/blinder/examine(mob/user)
	..()
	if(bulb && burnedout)
		to_chat(user, "<span class='warning'>\The [src]'s flash bulb is broken.</span>")
	else if (!bulb)
		to_chat(user, "<span class='info'>\The [src] appears to be missing a flash bulb.</span>")

/obj/item/device/blinder/attack_self(mob/user as mob)
	if(!bulb || burnedout || !cell)
		if (user)
			user.visible_message("*click click*", "<span class='danger'>*click*</span>")
			playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		else
			src.visible_message("*click click*")
			playsound(get_turf(src), 'sound/weapons/empty.ogg', 100, 1)
		return

	if(cell)
		var/obj/item/weapon/cell/C = cell
		if(C.charge < powercost)
			user.visible_message("[user] presses the button on \the [src], but the flash bulb merely flickers.","You press the button on \the [src], but the flash bulb merely flickers.")
			to_chat(user, "<span class='warning'>There's not enough energy in the cell to power the flash bulb!</span>")
			playsound(get_turf(src), 'sound/weapons/empty.ogg', 100, 1)
			return

		var/flash_turf = get_turf(src)
		if(!flash_turf)
			return
		for(var/mob/living/M in get_hearers_in_view(7, flash_turf))
			flash(get_turf(M), M)


		user.visible_message("<span class='danger'>[user] overloads \the [src]'s flash bulb!</span>","<span class='danger'>You overload \the [src]'s flash bulb!</span>")
		to_chat(user, "<span class='warning'>\The [src]'s flash bulb shatters!</span>")

		C.charge -= powercost

		burnedout = 1
		update_verbs()

/obj/item/device/blinder/proc/flash(var/turf/T , var/mob/living/M)
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1)

	var/eye_safety = 0
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		eye_safety = C.eyecheck()

	if(eye_safety < 1)
		flick("e_flash", M.flash)

	if(issilicon(M))
		M.Weaken(rand(5, 10))
		M.visible_message("<span class='warning'>[M]'s sensors are overloaded by the flash of light!</span>","<span class='warning'>Your sensors are overloaded by the flash of light!</span>")

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
		if (E && E.damage >= E.min_bruised_damage)
			to_chat(M, "<span class='warning'>Your eyes start to burn badly!</span>")
	M.update_icons()

/obj/item/device/blinder/proc/update_verbs()
	if(cell)
		verbs += /obj/item/device/blinder/verb/remove_cell
	else
		verbs -= /obj/item/device/blinder/verb/remove_cell
	if(bulb && burnedout)
		verbs += /obj/item/device/blinder/verb/remove_bulb
	else
		verbs -= /obj/item/device/blinder/verb/remove_bulb

/obj/item/device/blinder/verb/remove_cell()
	set name = "Remove power cell"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!cell)
		return
	else
		var/obj/item/weapon/cell/C = cell
		C.forceMove(usr.loc)
		usr.put_in_hands(C)
		cell = null
		desc = "A polaroid camera. The film chamber is filled with wire for some reason."
		to_chat(usr, "You remove \the [C] from \the [src].")
	update_verbs()

/obj/item/device/blinder/verb/remove_bulb()
	set name = "Remove broken bulb"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!bulb)
		return
	else
		var/obj/item/weapon/light/bulb/B = new (get_turf(usr))
		B.status = LIGHT_BROKEN
		B.update()
		usr.put_in_hands(B)
		bulb = 0
		burnedout = 0
		to_chat(usr, "You remove the broken [B.name] from \the [src].")
	update_verbs()

/obj/item/device/blinder/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There is already a power cell inside \the [src].</span>")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		cell = W
		user.visible_message("[user] inserts \the [W] into \the [src].","You insert \the [W] into \the [src].")
		desc = "A polaroid camera. There is a power cell in the film chamber for some reason."
		update_verbs()

	if(istype(W, /obj/item/weapon/light/bulb))
		if(bulb)
			if(burnedout)
				to_chat(user, "<span class='warning'>You need to remove the damaged bulb first.</span>")
				return
			else
				to_chat(user, "There is already a perfectly good bulb inside \the [src].")
				return
		var/obj/item/weapon/light/bulb/B = W
		if(B.status == LIGHT_BROKEN)
			to_chat(user, "<span class='warning'>That [B.name] is broken, it won't function in \the [src].</span>")
			return
		else if(B.status == LIGHT_BURNED)
			to_chat(user, "<span class='warning'>That [B.name] is burned out, it won't function in \the [src].</span>")
			return
		bulb = 1
		user.visible_message("[user] inserts \the [W] into \the [src].","You insert \the [W] into \the [src].")
		qdel(W)
		update_verbs()

	if(istype(W, /obj/item/device/camera_film))
		to_chat(user, "<span class='notice'>There's no room in \the [src]'s film chamber with the [cell ? "power cell" : "wire"] inside it.</span>")
		return

	if(iswirecutter(W))
		if(cell)
			to_chat(user, "<span class='warning'>You can't reach the wires with the power cell in the way.</span>")
			return
		to_chat(user, "You cut the wires out of the film chamber.")
		playsound(user, 'sound/items/Wirecutter.ogg', 50, 1)
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/device/camera/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/device/camera(get_turf(src.loc))
		var/obj/item/stack/cable_coil/C = new (get_turf(user))
		C.amount = 5
		qdel(src)