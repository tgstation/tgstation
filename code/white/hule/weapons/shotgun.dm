/obj/item/gun/ballistic/automatic/shotgun/small
	name = "netu"
	desc = "netu"
	icon = 'code/white/hule/weapons/weapons.dmi'
	icon_state = "smshotgun"
	item_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_MEDIUM
	mag_type = /obj/item/ammo_box/magazine/m4s12g
	fire_sound = 'sound/weapons/gunshot.ogg'
	can_suppress = FALSE
	pin = /obj/item/firing_pin
	burst_size = 1
	fire_delay = 1

/obj/item/gun/ballistic/automatic/shotgun/small/Initialize()
	. = ..()
	update_icon()

/obj/item/gun/ballistic/automatic/shotgun/small/update_icon()
	cut_overlays()
	if(magazine)
		add_overlay("[magazine.icon_state]")
	icon_state = "smshotgun"

/obj/item/gun/ballistic/automatic/shotgun/small/makeshift
	name = "Captain's bane"
	desc = "Гротескное изделие явно кустарного производства. Выглядит слегка ненадежно."
	spawnwithmagazine = FALSE
	var/jammed = FALSE
	var/jamchance = 5

/obj/item/ammo_box/magazine/m4s12g
	name = "shotgun magazine"
	desc = "A shotgun magazine."
	icon = 'code/white/hule/weapons/weapons.dmi'
	icon_state = "m4s12g"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 4
	start_empty = 1

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
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_COOKBOOK)
	time = 600
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/mshotgunmag
	name = "Makeshift Shotgun magazine"
	result = /obj/item/ammo_box/magazine/m4s12g
	reqs = list(/obj/item/stack/sheet/metal = 5,
				/obj/item/stack/rods = 4)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_COOKBOOK)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
