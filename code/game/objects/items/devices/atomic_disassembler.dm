/obj/item/device/atomic_disassembler
	name = "P.A.D.D."
	desc = "The Portable Atomic Disassembly Device (patent pending) is a revolutionary device in breaking down objects at the atomic level. To use, you must attach a condensed matter canister and a power \
	cell. Then, simply feed an object through its atomization field. It will then be broken down into raw condensed matter and placed into the canister, which can be utilized in many ways!"
	hitsound = 'sound/weapons/genhit1.ogg'
	w_class = 3 //Maybe make bulky sometime?
	force = 4
	slot_flags = SLOT_BACK
	origin_tech = "programming=4;materials=4;magnets=4;bluespace=4"
	throw_range = 1
	throw_speed = 1
	icon_state = "atom_inactive"
	mouse_opacity = 2
	var/obj/item/weapon/stock_parts/cell/power_cell = null
	var/emagged = 0
	var/list/blacklisted_items = list()

/obj/item/device/atomic_disassembler/New()
	..()
	src.assign_items()

/obj/item/device/atomic_disassembler/emag_act(mob/user)
	..()
	if(!emagged)
		user << "<span class='warning'>You disable the safety restrictions on the P.A.D.D.!</span>"
		force = 20 //Disassembling them... ATOMICALLY!
		damtype = "clone"
		hitsound = 'sound/weapons/blade1.ogg'
		emagged = 1

/obj/item/device/atomic_disassembler/examine(mob/user)
	..()
	if(src.emagged)
		user << "<span class='danger'>The atomization field is flickering randomly.</span>"

/obj/item/device/atomic_disassembler/proc/assign_items()
	blacklisted_items = list(/obj/item/weapon/stock_parts/cell, \
							 /obj/item/weapon/reagent_containers/glass/)
	return 1

/obj/item/device/atomic_disassembler/attackby(var/obj/item/W as obj,var/mob/living/user as mob, params)
	..()
	if(istype(W, /obj/item/weapon/stock_parts/cell) && !power_cell)
		user << "<span class='notice'>You place \the [W] into \the [src]'s battery slot.</span>"
		src.power_cell = W
		user.drop_item()
		W.loc = src
		icon_state = "[!emagged ? "atom_active" : "atom_emagged"]"
		return
	if(!power_cell)
		user << "<span class='warning'>\The [src] requires a power cell.</span>"
		return
	if(is_type_in_list(W, blacklisted_items) && !emagged)
		user << "<span class='warning'>\The [src]'s atomization field does not accept \the [W].</span>"
	else
		user.visible_message("<span class='notice'>[user] feeds \the [W] into \the [src]'s atomization field.</span>", \
							 "<span class='info'>\The [W] has been broken down.</span>")
		playsound(src, 'sound/effects/EMPulse.ogg', 25, 1)
		qdel(W)

/obj/item/device/atomic_disassembler/verb/eject_power_cell()
	set name = "Eject Power Cell"
	set category = "Atomic Disassembler"
	set src in usr

	if(usr.canUseTopic(src))
		if(!power_cell)
			usr << "<span class='warning'>\The [src] doesn't have a power cell installed.</span>"
			return 0
		usr << "<span class='notice'>You eject \the [src]'s power cell.</span>"
		icon_state = "atom_inactive"
		src.power_cell.loc = usr.loc
		src.power_cell = null
