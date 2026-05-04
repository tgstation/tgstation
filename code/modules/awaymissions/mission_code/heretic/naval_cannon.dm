/obj/machinery/deployable_turret/naval_cannon
	name = "Bofors Naval Cannon"
	desc = "A naval cannon of some variety, it probably won't feel good to be on the other end of this thing."
	icon = 'icons/obj/weapons/naval_cannon.dmi'
	icon_state = "turret_bofors"
	max_integrity = 5000 //its a naval cannon, but its not unbreakable
	projectile_type = /obj/projectile/bullet/mm40
	anchored = TRUE //nobody should be bringing this back to station, this is a set piece.
	number_of_shots = 1
	firesound = 'sound/items/weapons/gun/general/cannon.ogg'
	overheatsound = 'sound/items/tools/ratchet_slow.ogg'
	can_be_undeployed = FALSE
	always_anchored = TRUE

/obj/item/ammo_casing/mm40
	name = "40mm shell"
	desc = "A 40mm shell."
	caliber = CALIBER_40MM_SHELL
	projectile_type = /obj/projectile/bullet/mm40
	icon_state = "40mm-shell"
	newtonian_force = 10
	slowdown = 2 //tank shells weigh a lot

/obj/projectile/bullet/mm40
	name ="40mm shell"
	icon_state = "40mm"
	speed = 2
	range = 400
	damage = 600
	paralyze = 5 SECONDS
	armour_penetration = 50

/obj/projectile/bullet/mm40/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 2, light_impact_range = 3, flame_range = 4, flash_range = 6, adminlog = FALSE)
	return BULLET_ACT_HIT
