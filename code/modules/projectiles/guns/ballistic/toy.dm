/obj/item/weapon/gun/ballistic/automatic/toy
	name = "foam force SMG"
	desc = "A prototype three-round burst toy submachine gun. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "saber"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/toy/smg
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	force = 0
	throwforce = 0
	burst_size = 3
	can_suppress = 0
	clumsy_check = 0
	needs_permit = 0
	casing_ejector = 0

/obj/item/weapon/gun/ballistic/automatic/toy/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/automatic/toy/pistol
	name = "foam force pistol"
	desc = "A small, easily concealable toy handgun. Ages 8 and up."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/toy/pistol
	fire_sound = 'sound/weapons/Gunshot.ogg'
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/weapon/gun/ballistic/automatic/toy/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/weapon/gun/ballistic/automatic/toy/pistol/riot
	mag_type = /obj/item/ammo_box/magazine/toy/pistol/riot

/obj/item/weapon/gun/ballistic/automatic/toy/pistol/riot/New()
	magazine = new /obj/item/ammo_box/magazine/toy/pistol/riot(src)
	..()

/obj/item/weapon/gun/ballistic/automatic/toy/pistol/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/automatic/toy/pistol/riot/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/shotgun/toy
	name = "foam force shotgun"
	desc = "A toy shotgun with wood furniture and a four-shell capacity underneath. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	force = 0
	throwforce = 0
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy
	clumsy_check = 0
	needs_permit = 0
	casing_ejector = 0

/obj/item/weapon/gun/ballistic/shotgun/toy/process_chamber(empty_chamber = 0)
	..()
	if(chambered && !chambered.BB)
		qdel(chambered)

/obj/item/weapon/gun/ballistic/shotgun/toy/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/shotgun/toy/crossbow
	name = "foam force crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamcrossbow"
	item_state = "crossbow"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	fire_sound = 'sound/items/syringeproj.ogg'
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/weapon/gun/ballistic/automatic/c20r/toy
	name = "donksoft SMG"
	desc = "A bullpup two-round burst toy SMG, designated 'C-20r'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = 0
	needs_permit = 0
	mag_type = /obj/item/ammo_box/magazine/toy/smgm45
	casing_ejector = 0

/obj/item/weapon/gun/ballistic/automatic/c20r/toy/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/automatic/l6_saw/toy
	name = "donksoft LMG"
	desc = "A heavily modified toy light machine gun, designated 'L6 SAW'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = 0
	needs_permit = 0
	mag_type = /obj/item/ammo_box/magazine/toy/m762
	casing_ejector = 0

/obj/item/weapon/gun/ballistic/automatic/l6_saw/toy/unrestricted
	pin = /obj/item/device/firing_pin