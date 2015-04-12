/obj/item/device/atomic_disassembler
	name = "P.A.D.D."
	desc = "The Portable Atomic Disassembly Device (patent pending) is a revolutionary device in breaking down objects at the atomic level. To use, you must attach a condensed matter canister and a power \
	cell. Then, simply feed an object through its atomization field. It will then be broken down into raw condensed matter and placed into the canister, which can be utilized in many ways!"
	hitsound = 'sound/weapons/genhit1.ogg'
	w_class = 3 //Maybe make bulky sometime?
	force = 4
	slot_flags = SLOT_BACK
	origin_tech = "programming=4;materials=4;magnets=4;bluespace=4"
	throw_range = 3
	throw_speed = 1
	icon_state = "atom_inactive"
	mouse_opacity = 2
	var/obj/item/weapon/stock_parts/cell/power_cell = null
	var/obj/item/device/compressed_matter_canister/canister = null
	var/emagged = 0
	var/list/blacklisted_items = list() //Things that would be considered 'bad' in the lore
	var/list/really_blacklisted_items = list() //Things that actually break the game

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
	if(canister)
		if(canister.stored_matter < canister.matter_cap)
			user << "<span class='notice'>A small digital display on the canister reads: \"[canister.stored_matter]UCM\".</span>"
		else
			user << "<span class='notice'>A small digital display on the canister reads: \"!![canister.stored_matter]UCM - CAPACITY REACHED\".</span>"

/obj/item/device/atomic_disassembler/proc/assign_items()
	blacklisted_items = list(/obj/item/weapon/stock_parts/cell)
	really_blacklisted_items = list(/obj/item/weapon/reagent_containers/glass)
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
	if(istype(W, /obj/item/device/compressed_matter_canister) && !canister)
		user << "<span class='notice'>You place \the [W] into its slot and connect it to \the [src]'s feeding hose.</span>"
		src.canister = W
		user.drop_item()
		W.loc = src
		return
	if(!power_cell)
		user << "<span class='warning'>\The [src] requires a power cell.</span>"
		return
	if(!canister)
		user << "<span class='warning'>\The [src] will not function without a compressed matter canister.</span>"
		return
	if(istype(W, /obj/item/device/atomic_disassembler))
		var/boom = alert(user, "This probably isn't wise...", "Ignore the warning labels?", "Yes", "No")

		if(boom == "No" || !user.canUseTopic(src) || !W)
			return

		user.visible_message("<span class='warning'>[user] feeds \the [W] into \the [src], and a screech erupts as they catastrophically malfunction!</span>", \
							 "<span class='boldannounce'>You feed \the [W] into \the [src]. <i>That wasn't a good idea.</i></span>")
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 100, 1)
		src.icon_state = "atom_emagged"
		qdel(W)
		sleep(20)
		explosion(src.loc, -1, 2, 4, flame_range = 2)
		qdel(src)
		return
	if((is_type_in_list(W, blacklisted_items) && !emagged) || is_type_in_list(W, really_blacklisted_items))
		user << "<span class='warning'>\The [src]'s atomization field does not accept \the [W].</span>"
		return
	else
		user.visible_message("<span class='notice'>[user] feeds \the [W] into \the [src]'s atomization field.</span>", \
							 "<span class='info'>\The [W] has been broken down.</span>")
		canister.update_matter(10 * W.w_class)
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

/obj/item/device/atomic_disassembler/verb/eject_canister()
	set name = "Eject Matter Canister"
	set category = "Atomic Disassembler"
	set src in usr

	if(usr.canUseTopic(src))
		if(!canister)
			usr << "<span class='warning'>\The [src] has no compressed matter canister hooked up.</span>"
			return 0
		usr << "<span class='notice'>You unhook the compressed matter canister from \the [src].</span>"
		src.canister.loc = usr.loc
		src.canister = null



/obj/item/device/compressed_matter_canister
	name = "compressed matter canister"
	desc = "A canister, used in conjunction with atomic disassembly apparatus, to store broken-down atoms for later use."
	w_class = 2
	throw_range = 7
	throw_speed = 2
	icon_state = "multitool" //Temporary until I make a sprite.
	var/stored_matter = 0
	var/matter_cap = 1000

/obj/item/device/compressed_matter_canister/examine(mob/user)
	..()
	if(stored_matter < matter_cap)
		user << "<span class='notice'>A small digital display reads: \"[stored_matter]UCM\".</span>"
	else
		user << "<span class='notice'>A small digital display reads: \"!![stored_matter]UCM - CAPACITY REACHED\".</span>"

/obj/item/device/compressed_matter_canister/proc/update_matter(var/matter_amt)
	stored_matter += matter_amt
	if(stored_matter > matter_cap)
		stored_matter = matter_cap
