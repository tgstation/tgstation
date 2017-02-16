

/obj/item/weapon/gun/energy/charge
	name = "energy cannon"
	desc = "IMMA FIRING MAH LAZOR"//swkittens pls change this
	canMouseDown = TRUE
	var/charging = FALSE
	var/chargeduration = 0
	var/chargesound = null
	var/dischargesound = null
	var/charge_duration_track = TRUE	//Do we need to keep track of how long we charged for continously?
	var/override_afterattack = FALSE
	var/autoface_atom = TRUE

/obj/item/weapon/gun/energy/charge/Initialize()
	. = ..()
	if(charge_duration_track)
		START_PROCESSING(SSflightpacks, src)	//Can I add another subsystem to process this if I said please?

/obj/item/weapon/gun/energy/charge/vv_edit_var(var_name, new_value)
	. = ..()
	if(var_name == "charge_duration_track")
		if(new_value)
			START_PROCESSING(SSflightpacks, src)
		else
			STOP_PROCESSING(SSflightpacks, src)

/obj/item/weapon/gun/energy/charge/SDQL_update(var_name, new_value)
	. = ..()
	if(var_name == "charge_duration_track")
		if(new_value)
			START_PROCESSING(SSflightpacks, src)
		else
			STOP_PROCESSING(SSflightpacks, src)

/obj/item/weapon/gun/energy/charge/process()
	if(charge_duration_track && charging)
		chargeduration++

/obj/item/weapon/gun/energy/charge/onMouseDown(object, location, params)
	charge(object, location, params)
	. = ..()

/obj/item/weapon/gun/energy/charge/proc/charge(object, location, params)
	charging = TRUE
	if(chargesound)
		playsound(get_turf(src), chargesound, 50, 1)

/obj/item/weapon/gun/energy/charge/onMouseUp(object, location, params)
	if(charging)
		release(object, location, params)
	. = ..()

/obj/item/weapon/gun/energy/charge/proc/release(object, location, params)
	charging = FALSE
	chargeduration = 0
	if(dischargesound)
		playsound(get_turf(src), dischargesound, 50, 1)

/obj/item/weapon/gun/energy/charge/onMouseDrag(src_object, over_object, src_location, over_location, params)
	if(isliving(loc))
		var/mob/living/L = loc
		if(autoface_atom)
			L.face_atom(over_object)
	. = ..()

/obj/item/weapon/gun/energy/charge/afterattack(atom/target, mob/living/user, flag, params, pass = FALSE)
	if(pass || !override_afterattack)
		. = ..(target, user, flag, params)

/obj/item/weapon/gun/energy/charge/disable
	name = "\improper disabler cannon"
	desc = "A more powerful version of the handheld disabler that requires a short charging cycle before firing."
	icon_state = ""	//REQUIRES SPRITES
	item_state = ""
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cannon)
	var/charge_min = 20
	var/charge_max = 40
	var/notified = FALSE
	override_afterattack = TRUE

/obj/item/weapon/gun/energy/charge/disable/borg
	name = "\improper cyborg disabler cannon"
	desc = "A more powerful version of the handheld disabler that is mounted on a cyborg equipment hardpoint. It requires a short charging cycle before firing."
	can_charge = FALSE
	use_cyborg_cell = TRUE

/obj/item/weapon/gun/energy/charge/disable/process()
	. = ..()
	if((chargeduration > charge_min) && notified)
		if(isliving(loc))
			var/mob/living/L = loc
			L.visible_message("<span class='danger'>[L]'s [src] emits a beep as its charge capacitors reach full charge!</span>")
	if(chargeduration > charge_max)
		if(isliving(loc))
			var/mob/living/L = loc
			L.visible_message("<span class='danger'>[L]'s [src] sparks and overloads, losing its charge!</span>")
			charging = FALSE
			chargeduration = 0

/obj/item/weapon/gun/energy/charge/disable/charge(object, location, params)
	if(isliving(loc))
		var/mob/living/L = loc
		L.visible_message("<span class='warning'>[L]'s [src] beeps as they start to charge its internal capacitors!</span>")
	. = ..()

/obj/item/weapon/gun/energy/charge/disable/release(object, location, params)
	notified = FALSE
	if(chargeduration > charge_min)
		if(isliving(loc))
			var/mob/living/L = loc
			afterattack(object, L, L.Adjacent(object), params, TRUE)
	. = ..()
