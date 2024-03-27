/obj/item/gun/energy/recharge/kinetic_accelerator/m79
	name = "proto-kinetic grenade launcher"
	desc = "Made in a drunk frenzy during the creation of the kinetic railgun, the kinetic grenade launcher fires the same bombs used by \
	the mining modsuit. Due to the technology needed to pack the bombs into this weapon, there is no space for modification."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "kineticglauncher"
	base_icon_state = "kineticglauncher"
	pin = /obj/item/firing_pin/wastes
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/m79)
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_HEAVY
	can_bayonet = FALSE
	max_mod_capacity = 0
	disablemodification = TRUE

/obj/item/ammo_casing/energy/kinetic/m79
	projectile_type = /obj/projectile/bullet/reusable/mining_bomb //uses the mining bomb projectile from the mining modsuit
	fire_sound = 'sound/weapons/gun/general/grenade_launch.ogg'
