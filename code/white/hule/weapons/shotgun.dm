/obj/item/gun/ballistic/automatic/shotgun/small
	name = "netu"
	desc = "netu"
	icon_state = "pistol"
	item_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_MEDIUM
	mag_type = /obj/item/ammo_box/magazine/m5s12g
	fire_sound = 'sound/weapons/gunshot.ogg'
	can_suppress = FALSE
	pin = /obj/item/device/firing_pin
	burst_size = 1
	fire_delay = 1

/obj/item/gun/ballistic/automatic/shotgun/small/update_icon()
	cut_overlays()
//	if(magazine)
//		icon_state = "shotmag"
	icon_state = "pistol"

/obj/item/gun/ballistic/automatic/shotgun/small/makeshift
	name = "Captain's bane"
	desc = "Гротескное изделие явно кустарного производства. Выглядит слегка ненадежно."
	icon_state = "pistol"
	item_state = "gun"
	spawnwithmagazine = FALSE
	var/jammed = FALSE
	var/jamchance = 5

/obj/item/ammo_box/magazine/m5s12g
	name = "shotgun magazine (12g buckshot slugs)"
	desc = "A drum magazine."
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 4

/obj/item/gun/ballistic/automatic/shotgun/small/makeshift/afterattack()
	..()
	if(prob(jamchance))
		jammed = TRUE

/obj/item/gun/ballistic/automatic/shotgun/small/makeshift/can_shoot()
	.=..()
	if(jammed)
		playsound(src, "gun_dry_fire", 30, 1)
		return FALSE

/obj/item/gun/ballistic/automatic/shotgun/small/makeshift/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/screwdriver))
		if(!magazine)
			jammed = FALSE
			to_chat(user, "<span class='notice'>fixed ebat'</span>")

/datum/crafting_recipe/mshotgun
	name = "Makeshift Shotgun"
	result = /obj/item/gun/ballistic/automatic/shotgun/small/makeshift
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/stack/sheet/metal = 20,
				/obj/item/stack/rods = 5)
//	parts = list()
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_COOKBOOK)
	time = 600
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
