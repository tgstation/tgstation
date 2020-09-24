/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON
	var/list/signs
	var/max_signs = 10
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = /obj/structure/holosign/wetsign
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once

/obj/item/holosign_creator/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(!check_allowed_items(target, 1))
		return
	var/turf/target_turf = get_turf(target)
	var/obj/structure/holosign/target_holosign = locate(holosign_type) in target_turf
	if(target_holosign)
		to_chat(user, "<span class='notice'>You use [src] to deactivate [target_holosign].</span>")
		qdel(target_holosign)
		return
	if(target_turf.is_blocked_turf(TRUE)) //can't put holograms on a tile that has dense stuff
		return
	if(holocreator_busy)
		to_chat(user, "<span class='notice'>[src] is busy creating a hologram.</span>")
		return
	if(LAZYLEN(signs) >= max_signs)
		to_chat(user, "<span class='notice'>[src] is projecting at max capacity!</span>")
		return
	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)
	if(creation_time)
		holocreator_busy = TRUE
		if(!do_after(user, creation_time, target = target))
			holocreator_busy = FALSE
			return
		holocreator_busy = FALSE
		if(LAZYLEN(signs) >= max_signs)
			return
		if(target_turf.is_blocked_turf(TRUE)) //don't try to sneak dense stuff on our tile during the wait.
			return
	target_holosign = new holosign_type(get_turf(target), src)
	to_chat(user, "<span class='notice'>You create \a [target_holosign] with [src].</span>")

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/attack_self(mob/user)
	if(LAZYLEN(signs))
		for(var/H in signs)
			qdel(H)
		to_chat(user, "<span class='notice'>You clear all active holograms.</span>")

/obj/item/holosign_creator/janibarrier
	name = "custodial holobarrier projector"
	desc = "A holographic projector that creates hard light wet floor barriers."
	holosign_type = /obj/structure/holosign/barrier/wetsign
	creation_time = 20
	max_signs = 12

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	icon_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/atmos
	name = "ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_atmos"
	holosign_type = /obj/structure/holosign/barrier/atmos
	creation_time = 0
	max_signs = 6
	///Var to choose which cell to give to each creators
	var/cell_type = /obj/item/stock_parts/cell/high
	///Store the type of cell in the item
	var/obj/item/stock_parts/cell/cell
	///Check if the cell hatch is open
	var/open = FALSE
	///Base consumption for each barrier made
	var/base_consumption = 10
	///Check if the holosign creator is inside a holosign holder
	var/in_holder = FALSE

/obj/item/holosign_creator/atmos/get_cell()
	return cell

/obj/item/holosign_creator/atmos/proc/remove_from_holder()
	in_holder = FALSE
	return

/obj/item/holosign_creator/atmos/Initialize()
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type
	START_PROCESSING(SSobj, src)

/obj/item/holosign_creator/atmos/Destroy()
	if(LAZYLEN(signs))
		for(var/h in signs)
			qdel(h)
	if(cell)
		QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/holosign_creator/atmos/examine(mob/user)
	. = ..()
	. += "[src] is emitting a total of [LAZYLEN(signs)] signs out of [max_signs]"
	. += "The hatch is [open ? "open" : "closed"]."
	if(cell)
		. += "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%."
	else
		. += "There is no power cell installed."

/obj/item/holosign_creator/atmos/update_overlays()
	. = ..()
	if(open)
		. += "signmaker_open"

/obj/item/holosign_creator/atmos/process()
	if(open || !cell || in_holder)
		return
	var/cell_consumption = 0
	if(LAZYLEN(signs))
		for(var/h in signs)
			cell_consumption += base_consumption
	cell.use(cell_consumption)
	if(cell.charge <= 0)
		for(var/H in signs)
			qdel(H)

/obj/item/holosign_creator/atmos/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		if(!open)
			to_chat(user, "<span class='warning'>The hatch must be open to insert a power cell!</span>")
			return
		if(cell)
			to_chat(user, "<span class='warning'>There is already a power cell inside!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		cell = I
		user.visible_message("<span class='notice'>\The [user] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")

/obj/item/holosign_creator/atmos/attack_self(mob/user)
	if(open && cell)
		user.visible_message("<span class='notice'>[user] removes [cell] from [src]!</span>", "<span class='notice'>You remove [cell].</span>")
		user.put_in_hands(cell)
		cell = null
		return
	if(LAZYLEN(signs))
		for(var/H in signs)
			qdel(H)
		to_chat(user, "<span class='notice'>You clear all active holograms.</span>")

/obj/item/holosign_creator/atmos/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	open = !open
	if(LAZYLEN(signs))
		for(var/H in signs)
			qdel(H)
	update_icon()
	return TRUE

/obj/item/holosign_creator/atmos/afterattack(atom/target, mob/user, proximity_flag)
	if(open)
		to_chat(user, "<span class='warning'>You should close the hatch first!</span>")
		return
	if(!cell || cell.charge <= 0)
		to_chat(user, "<span class='warning'>There is no [cell ? "power" : "cell"] in the [src]!</span>")
		return
	. = ..()

/obj/item/holosign_creator/medical
	name = "\improper PENLITE barrier projector"
	desc = "A holographic projector that creates PENLITE holobarriers. Useful during quarantines since they halt those with malicious diseases."
	icon_state = "signmaker_med"
	holosign_type = /obj/structure/holosign/barrier/medical
	creation_time = 30
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "Energy Barrier Projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = 0

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			to_chat(user, "<span class='notice'>You clear all active holograms, and reset your projector to normal.</span>")
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 5
			for(var/sign in signs)
				qdel(sign)
			shock = 0
			return
		if(R.emagged&&!shock)
			to_chat(user, "<span class='warning'>You clear all active holograms, and overload your energy projector!</span>")
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			for(var/sign in signs)
				qdel(sign)
			shock = 1
			return
	for(var/sign in signs)
		qdel(sign)
		to_chat(user, "<span class='notice'>You clear all active holograms.</span>")
