/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon_state = "red"
	item_state = "toolbox_red"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 12
	throwforce = 12
	throw_speed = 2
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL = 500)
	origin_tech = "combat=1;engineering=1"
	attack_verb = list("robusted")
	hitsound = 'sound/weapons/smash.ogg'
	var/latches = "single_latch"
	var/has_latches = TRUE

/obj/item/storage/toolbox/Initialize()
	..()
	if(has_latches)
		if(prob(10))
			latches = "double_latch"
			if(prob(1))
				latches = "triple_latch"
	update_icon()

/obj/item/storage/toolbox/update_icon()
	..()
	cut_overlays()
	if(has_latches)
		add_overlay(latches)


/obj/item/storage/toolbox/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] robusts [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/storage/toolbox/emergency/PopulateContents()
	new /obj/item/crowbar/red(src)
	new /obj/item/weldingtool/mini(src)
	new /obj/item/extinguisher/mini(src)
	switch(rand(1,3))
		if(1)
			new /obj/item/device/flashlight(src)
		if(2)
			new /obj/item/device/flashlight/glowstick(src)
		if(3)
			new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/radio/off(src)

/obj/item/storage/toolbox/emergency/old
	name = "rusty red toolbox"
	icon_state = "toolbox_red_old"
	has_latches = FALSE

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/storage/toolbox/mechanical/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/mechanical/old
	name = "rusty blue toolbox"
	icon_state = "toolbox_blue_old"
	has_latches = FALSE

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/storage/toolbox/electrical/PopulateContents()
	var/pickedcolor = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,pickedcolor)
	new /obj/item/stack/cable_coil(src,30,pickedcolor)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	else
		new /obj/item/stack/cable_coil(src,30,pickedcolor)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = "combat=2;syndicate=1;engineering=2"
	silent = 1
	force = 15
	throwforce = 18

/obj/item/storage/toolbox/syndicate/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/device/multitool(src)
	new /obj/item/clothing/gloves/combat(src)

/obj/item/storage/toolbox/drone
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/storage/toolbox/drone/PopulateContents()
	var/pickedcolor = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,pickedcolor)
	new /obj/item/wirecutters(src)
	new /obj/item/device/multitool(src)

/obj/item/storage/toolbox/brass
	name = "brass box"
	desc = "A huge brass box with several indentations in its surface."
	icon_state = "brassbox"
	item_state = null
	has_latches = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 28
	storage_slots = 28
	attack_verb = list("robusted", "crushed", "smashed")
	var/fabricator_type = /obj/item/clockwork/replica_fabricator/scarab

/obj/item/storage/toolbox/brass/prefilled/PopulateContents()
	new fabricator_type(src)
	new /obj/item/screwdriver/brass(src)
	new /obj/item/wirecutters/brass(src)
	new /obj/item/wrench/brass(src)
	new /obj/item/crowbar/brass(src)
	new /obj/item/weldingtool/experimental/brass(src)

/obj/item/storage/toolbox/brass/prefilled/ratvar
	var/slab_type = /obj/item/clockwork/slab

/obj/item/storage/toolbox/brass/prefilled/ratvar/PopulateContents()
	..()
	new slab_type(src)

/obj/item/storage/toolbox/brass/prefilled/ratvar/admin
	slab_type = /obj/item/clockwork/slab/debug
	fabricator_type = /obj/item/clockwork/replica_fabricator/scarab/debug


/obj/item/storage/toolbox/artistic
	name = "artistic toolbox"
	desc = "A toolbox painted bright green. Why anyone would store art supplies in a toolbox is beyond you, but it has plenty of extra space."
	icon_state = "green"
	item_state = "artistic_toolbox"
	max_combined_w_class = 20
	storage_slots = 10
	w_class = WEIGHT_CLASS_GIGANTIC //Holds more than a regular toolbox!

/obj/item/storage/toolbox/artistic/PopulateContents()
	new/obj/item/storage/crayons(src)
	new/obj/item/crowbar(src)
	new/obj/item/stack/cable_coil/red(src)
	new/obj/item/stack/cable_coil/yellow(src)
	new/obj/item/stack/cable_coil/blue(src)
	new/obj/item/stack/cable_coil/green(src)
	new/obj/item/stack/cable_coil/pink(src)
	new/obj/item/stack/cable_coil/orange(src)
	new/obj/item/stack/cable_coil/cyan(src)
	new/obj/item/stack/cable_coil/white(src)
