//his isn't a subtype of the syringe gun because the syringegun subtype is made to hold syringes
//this is meant to hold reagents/obj/item/gun/syringe
/obj/item/gun/chem
	name = "reagent gun"
	desc = "A Nanotrasen syringe gun, modified to automatically synthesise chemical darts, and instead hold reagents."
	icon_state = "chemgun"
	item_state = "chemgun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	force = 4
	materials = list(MAT_METAL=2000)
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	container_type = OPENCONTAINER
	var/time_per_syringe = 250
	var/syringes_left = 4
	var/max_syringes = 4
	var/last_synth = 0
	var/volume_to_create = 100

/obj/item/gun/chem/Initialize()
	. = ..()
	chambered = new /obj/item/ammo_casing/chemgun(src)
	START_PROCESSING(SSobj, src)
	create_reagents(volume_to_create)

/obj/item/gun/chem/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/gun/chem/can_shoot()
	return syringes_left

/obj/item/gun/chem/process_chamber()
	if(chambered && !chambered.BB && syringes_left)
		chambered.newshot()

/obj/item/gun/chem/process()
	if(syringes_left >= max_syringes)
		return
	if(world.time < last_synth+time_per_syringe)
		return
	to_chat(loc, "<span class='warning'>You hear a click as [src] synthesizes a new dart.</span>")
	syringes_left++
	if(chambered && !chambered.BB)
		chambered.newshot()
	last_synth = world.time

/obj/item/gun/chem/henchmen
	name = "dart gun"
	desc = "Standard issue henchmen dart gun. Comes pre-loaded with way too much morphine.\nOften immediately resold on the black market after assignment."
	icon_state = "dartgun"
	w_class = WEIGHT_CLASS_SMALL
	volume_to_create = 42069
	syringes_left = 20
	max_syringes = 20
	time_per_syringe = 100

/obj/item/gun/chem/henchmen/Initialize()
	..()
	reagents.add_reagent("morphine", 42069)