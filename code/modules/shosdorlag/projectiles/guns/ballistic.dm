/obj/item/gun/ballistic/shotgun/vz24
	name = "Vz. 24"
	desc = "A reliable Czechoslovakian bolt-action rifle."
	icon_state = "vz24"
	item_state = "vz24"
	icon = 'icons/shosdorlag/objects/guns/ballistic.dmi'
	slot_flags = 0 //no ITEM_SLOT_BACK sprite, alas
	mag_type = /obj/item/ammo_box/magazine/internal/vz24
	var/bolt_open = FALSE
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13

/obj/item/gun/ballistic/shotgun/vz24/pump(mob/M)
	playsound(M, 'sound/weapons/gun_slide_lock_4.ogg', 100, 1)
	if(bolt_open)
		pump_reload(M)
		to_chat(M, "You close the bolt!")
	else
		pump_unload(M)
		to_chat(M, "You open the bolt!")
	bolt_open = !bolt_open
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/gun/ballistic/shotgun/vz24/attackby(obj/item/A, mob/user, params)
	if(!bolt_open)
		to_chat(user, "<span class='notice'>The bolt is closed!</span>")
		return
	. = ..()

/obj/item/gun/ballistic/shotgun/vz24/examine(mob/user)
	..()
	to_chat(user, "The bolt is [bolt_open ? "open" : "closed"].")