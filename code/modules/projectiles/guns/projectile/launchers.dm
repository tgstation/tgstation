//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika

/obj/item/weapon/gun/projectile/revolver/grenadelauncher//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
	desc = "A break-operated grenade launcher."
	name = "grenade launcher"
	icon_state = "dshotgun-sawn"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	w_class = 3

/obj/item/weapon/gun/projectile/revolver/grenadelauncher/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()

/obj/item/weapon/gun/projectile/revolver/grenadelauncher/cyborg
	desc = "A 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi

/obj/item/weapon/gun/projectile/revolver/grenadelauncher/cyborg/attack_self()
	return

/obj/item/weapon/gun/projectile/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A prototype pistol designed to fire self propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	origin_tech = "combat=3"
	mag_type = /obj/item/ammo_box/magazine/m75
	burst_size = 1
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/gyropistol/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/weapon/gun/projectile/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/speargun
	name = "kinetic speargun"
	desc = "A weapon favored by carp hunters. Fires specialized spears using kinetic energy."
	icon_state = "speargun"
	item_state = "speargun"
	w_class = 4
	force = 10
	can_suppress = 0
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/speargun
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	burst_size = 1
	fire_delay = 0
	select = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/speargun/update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/speargun/attack_self()
	return

/obj/item/weapon/gun/projectile/automatic/speargun/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/weapon/gun/projectile/automatic/speargun/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		user << "<span class='notice'>You load [num_loaded] spear\s into \the [src].</span>"
		update_icon()
		chamber_round()