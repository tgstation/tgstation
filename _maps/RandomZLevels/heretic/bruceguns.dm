/obj/item/gun/ballistic/automatic/wt550/p90
	name = "\improper FN P90"
	desc = "The FN P90 is a fast fire rate personal defense weapon, the bullets it shoots are small but what it lacks in damage it more than makes up for in penetration and fire rate."
	icon = 'modular_nova/modules/awaymissions_nova/heretic/p90.dmi'
	icon_state = "p90"
	w_class = WEIGHT_CLASS_NORMAL
	inhand_icon_state = "m90"
	accepted_magazine_type = /obj/item/ammo_box/magazine/p90_mag
	can_suppress = FALSE
	mag_display = FALSE
	mag_display_ammo = FALSE
	empty_indicator = TRUE
	var/rof = 0.05 SECONDS


/obj/item/gun/ballistic/automatic/wt550/p90/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, rof)

/obj/item/ammo_box/magazine/p90_mag
	name = "p90 toploader magazine"
	desc = "A 5.7x28mm magazine."
	icon_state = "46x30mmt-20"
	base_icon_state = "46x30mmt-20"
	ammo_type = /obj/item/ammo_casing/mm57x28
	max_ammo = 50
	caliber = CALIBER_46X30MM

/obj/item/ammo_casing/mm57x28
	name = "5.7x28mm bullet casing"
	desc = "A 5.7x28mmmm bullet casing."
	caliber = CALIBER_46X30MM
	projectile_type = /obj/projectile/bullet/mm57x28
	icon_state = "s-casing"
	base_icon_state = "ammo"
	newtonian_force = 0.1

/obj/projectile/bullet/mm57x28
	name ="5.7x28mm bullet"
	speed = 1.8
	range = 30
	damage = 6
	armour_penetration = 50

/obj/item/gun/energy/shrink_ray/one_shot
	name = "shrink ray blaster"
	desc = "This is a piece of frightening alien tech that enhances the magnetic pull of atoms in a localized space to temporarily make an object shrink. \
		That or it's just space magic. Either way, it shrinks stuff, This one is jerry-rigged to work with a non alien cell. It still recharges though."
	ammo_type = list(/obj/item/ammo_casing/energy/shrink/worse)

/obj/item/ammo_casing/energy/shrink/worse
	projectile_type = /obj/projectile/magic/shrink/alien
	select_name = "shrink ray"
	e_cost = LASER_SHOTS(1, STANDARD_CELL_CHARGE)
