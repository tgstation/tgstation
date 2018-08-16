////////////Anti Tank Pistol////////////

/obj/item/gun/ballistic/automatic/pistol/antitank
	name = "Anti Tank Pistol"
	desc = "A massively impractical and silly monstrosity of a pistol that fires .50 calliber rounds. The recoil is likely to dislocate your wrist."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "atp"
	item_state = "pistol"
	recoil = 4
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	fire_delay = 50
	burst_size = 1
	can_suppress = 0
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list()
	fire_sound = 'sound/weapons/blastcannon.ogg'
	spread = 20		//damn thing has no rifling.

/obj/item/gun/ballistic/automatic/pistol/antitank/update_icon()
	..()
	if(magazine)
		cut_overlays()
		add_overlay("atp-mag")
	else
		cut_overlays()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/gun/ballistic/automatic/pistol/antitank/syndicate
	name = "Syndicate Anti Tank Pistol"
	desc = "A massively impractical and silly monstrosity of a pistol that fires .50 calliber rounds. The recoil is likely to dislocate a variety of joints without proper bracing."
	pin = /obj/item/firing_pin/implant/pindicate

///foam stealth pistol///

/obj/item/gun/ballistic/automatic/toy/pistol/stealth
	name = "foam force stealth pistol"
	desc = "A small, easily concealable toy bullpup handgun. Ages 8 and up."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "foamsp"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/toy/pistol
	can_suppress = FALSE
	fire_sound = 'sound/weapons/gunshot_silenced.ogg'
	suppressed = TRUE
	burst_size = 1
	fire_delay = 0
	spread = 20
	actions_types = list()

/obj/item/gun/ballistic/automatic/toy/pistol/stealth/update_icon()
	..()
	if(magazine)
		cut_overlays()
		add_overlay("foamsp-magazine")
	else
		cut_overlays()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

//////10mm soporific bullets//////

obj/item/projectile/bullet/c10mm/soporific
	name ="10mm soporific bullet"
	armour_penetration = 0
	nodamage = TRUE
	dismemberment = 0
	knockdown = 0

/obj/item/projectile/bullet/c10mm/soporific/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.blur_eyes(6)
		if(L.getStaminaLoss() >= 60)
			L.Sleeping(300)
		else
			L.adjustStaminaLoss(25)
	return 1

/obj/item/ammo_casing/c10mm/soporific
	name = ".10mm soporific bullet casing"
	desc = "A 10mm soporific bullet casing."
	projectile_type = /obj/item/projectile/bullet/c10mm/soporific

/obj/item/ammo_box/magazine/m10mm/soporific
	name = "pistol magazine (10mm soporific)"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "9x19pS"
	desc = "A gun magazine. Loaded with rounds which inject the target with a variety of illegal substances to induce sleep in the target."
	ammo_type = /obj/item/ammo_casing/c10mm/soporific

/obj/item/ammo_box/c10mm/soporific
	name = "ammo box (10mm soporific)"
	ammo_type = /obj/item/ammo_casing/c10mm/soporific
	max_ammo = 24

//////modular pistol////// (reskinnable stetchkins)

/obj/item/gun/ballistic/automatic/pistol/modular
	name = "modular pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "cde"
	can_unsuppress = TRUE
	obj_flags = UNIQUE_RENAME
	unique_reskin = list("Default" = "cde",
						"NT-99" = "n99",
						"Stealth" = "stealthpistol",
						"HKVP-78" = "vp78",
						"Luger" = "p08b",
						"Mk.58" = "secguncomp",
						"PX4 Storm" = "px4"
						)

/obj/item/gun/ballistic/automatic/pistol/modular/update_icon()
	..()
	if(current_skin)
		icon_state = "[unique_reskin[current_skin]][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	else
		icon_state = "[initial(icon_state)][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	if(magazine && suppressed)
		cut_overlays()
		add_overlay("[unique_reskin[current_skin]]-magazine-sup")	//Yes, this means the default iconstate can't have a magazine overlay
	else if (magazine)
		cut_overlays()
		add_overlay("[unique_reskin[current_skin]]-magazine")
	else
		cut_overlays()

/////////RAYGUN MEMES/////////

/obj/item/projectile/beam/lasertag/ray		//the projectile, compatible with regular laser tag armor
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "ray"
	name = "ray bolt"
	eyeblur = 0

/obj/item/ammo_casing/energy/laser/raytag
	projectile_type = /obj/item/projectile/beam/lasertag/ray
	select_name = "raytag"
	fire_sound = 'sound/weapons/raygun.ogg'

/obj/item/gun/energy/laser/practice/raygun
	name = "toy ray gun"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "raygun"
	desc = "A toy laser with a classic, retro feel and look. Compatible with existing laser tag systems."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/raytag)
	selfcharge = TRUE