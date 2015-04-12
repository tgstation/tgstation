/obj/item/device/atomic_disassembler
	name = "atomic disassembler"
	desc = "An incredibly advanced device that breaks many items down into their liquid components. It is not capable of reconstruction."
	force = 7 //Big enough to have a decent amount of oomph in it
	hitsound = 'sound/weapons/genhit1.ogg'
	w_class = 4
	slot_flags = SLOT_BACK
	origin_tech = "programming=4;materials=4;magnets=4;bluespace=4"
	throw_range = 1
	throw_speed = 1
	icon = 'icons/obj/objects.dmi'
	icon_state = "cube"
	var/obj/item/weapon/reagent_containers/beaker/attached_beaker = null
	var/obj/item/weapon/stock_parts/cell/power_cell = null
	var/emagged = 0
	var/list/valid_targets = list()

/obj/item/device/atomic_disassembler/New()
	..()
	src.assign_items()

/obj/item/device/atomic_disassembler/emag_act(mob/user)
	..()
	if(!emagged)
		user << "<span class='warning'>You disable the atomization field's object recognition.</span>"
		force = 20 //Disassembling them... ATOMICALLY!
		damtype = "clone"
		hitsound = 'sound/weapons/blade1.ogg'
		emagged = 1

/obj/item/device/atomic_disassembler/examine(mob/user)
	..()/*
	if(src.attached_beaker)
		var/obj/item/weapon/reagent_containers/beaker/B = attached_beaker
		for(var/datum/reagent/R in B.reagents)
			user << "<span class='notice'>Its beaker has [R.volume] units of [R.name] contained.</span>"
	if(src.power_cell)
		user << "<span class='notice'>It is powered by \the [power_cell].</span>"*/
	if(src.emagged)
		user << "<span class='danger'>The atomization field is flickering and sparking.</span>"

/obj/item/device/atomic_disassembler/proc/assign_items()
	//Assigns all items to the valid_targets() list
	//To assign an item, place its object path
	//You have to put a comma after every new item except for the last one
	//Reagents must be assigned in the attackby() proc for the specific item
	//i.e. /obj/item/stack/sheet/mineral/plasma),
	//	   /obj/item/weapon/salty_george,
	//	   /obj/item/weapon/acid_bomb
	valid_targets = list(/obj/item/weapon/stock_parts/cell)
	return 1

/obj/item/device/atomic_disassembler/attackby(var/obj/item/W as obj,var/mob/living/user as mob, params)
	..()
	/*if(istype(W, /obj/item/weapon/reagent_containers/beaker) && !attached_beaker)
		user << "<span class='info'>You attach \the [W] to \the [src].</span>"
		src.attached_beaker = W
		user.drop_item()
		W.loc = src*/
	if(istype(W, /obj/item/weapon/stock_parts/cell) && !power_cell)
		user << "<span class=;info'>You attach \the [W] to \the [src].</span>"
		src.power_cell = W
		user.drop_item()
		W.loc = src
		return
	/*if(!attached_beaker)
		user << "<span class='warning'>\The [src] has no beaker attached.</span>"
		return*/
	if(!power_cell)
		user << "<span class='warning'>\The [src] requires a power cell.</span>"
		return
	//var/obj/item/weapon/reagent_containers/beaker/B = attached_beaker
	if(is_type_in_list(W, valid_targets) || src.emagged)
		if(istype(W, /obj/item/weapon/stock_parts/cell))
			/*attached_beaker.reagents.add_reagent("sulfur" = 3)
			attached_beaker.reagents.add_reagent("iron", 5)
			attached_beaker.reagents.add_reagent("silicon", 1)*/
		user.visible_message("<span class='notice'>[user] feeds \the [W] into \the [src]'s atomization field.</span>", \
							 "<span class='info'>\The [W] has been broken down.</span>")
		if(prob(25) && emagged)
			src.audible_message("<span class='warning'>\The [src] whirs unhealthily.</span>")
		qdel(W)
	else
		user << "<span class='warning'>\The [src]'s atomization field does not accept \the [W].</span>"
