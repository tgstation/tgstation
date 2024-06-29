/obj/item/ammo_casing/energy/ion
	projectile_type = /obj/projectile/ion
	select_name = "ion"
	fire_sound = 'sound/weapons/ionrifle.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/item/ammo_casing/energy/ion/hos
	projectile_type = /obj/projectile/ion/weak
	e_cost = LASER_SHOTS(4, STANDARD_CELL_CHARGE * 1.2)

/obj/item/ammo_casing/energy/radiation
	projectile_type = /obj/projectile/energy/radiation
	select_name = "declone"
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/ammo_casing/energy/radiation/weak
	projectile_type = /obj/projectile/energy/radiation/weak

/obj/item/ammo_casing/energy/flora
	fire_sound = 'sound/effects/stealthoff.ogg'
	harmful = FALSE

/obj/item/ammo_casing/energy/flora/yield
	projectile_type = /obj/projectile/energy/flora/yield
	select_name = "yield"

/obj/item/ammo_casing/energy/flora/mut
	projectile_type = /obj/projectile/energy/flora/mut
	select_name = "mutation"

/obj/item/ammo_casing/energy/flora/revolution
	projectile_type = /obj/projectile/energy/flora/evolution
	select_name = "revolution"
	e_cost = LASER_SHOTS(4, STANDARD_CELL_CHARGE)

/obj/item/ammo_casing/energy/temp
	projectile_type = /obj/projectile/temp
	select_name = "freeze"
	e_cost = LASER_SHOTS(40, STANDARD_CELL_CHARGE * 10)
	fire_sound = 'sound/weapons/pulse3.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/item/ammo_casing/energy/temp/hot
	projectile_type = /obj/projectile/temp/hot
	select_name = "bake"
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/red

/obj/item/ammo_casing/energy/meteor
	projectile_type = /obj/projectile/meteor
	select_name = "goddamn meteor"

/obj/item/ammo_casing/energy/net
	projectile_type = /obj/projectile/energy/net
	select_name = "netting"
	pellets = 6
	variance = 40
	harmful = FALSE

/obj/item/ammo_casing/energy/trap
	projectile_type = /obj/projectile/energy/trap
	select_name = "snare"
	harmful = FALSE

/obj/item/ammo_casing/energy/tesla_cannon
	fire_sound = 'sound/magic/lightningshock.ogg'
	e_cost = LASER_SHOTS(33, STANDARD_CELL_CHARGE)
	select_name = "shock"
	projectile_type = /obj/projectile/energy/tesla_cannon
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/item/ammo_casing/energy/shrink
	projectile_type = /obj/projectile/magic/shrink/alien
	select_name = "shrink ray"
	e_cost = LASER_SHOTS(5, STANDARD_CELL_CHARGE)

/obj/item/ammo_casing/energy/marksman
	projectile_type = /obj/projectile/bullet/marksman
	select_name = "marksman nanoshot"
	e_cost = 0 // Can't use the macro
	fire_sound = 'sound/weapons/gun/revolver/shot_alt.ogg'

/obj/item/ammo_casing/energy/fisher
	projectile_type = /obj/projectile/energy/fisher
	select_name = "light disruptor"
	harmful = FALSE
	e_cost = LASER_SHOTS(2, STANDARD_CELL_CHARGE * 0.5)
	fire_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg' // fwip fwip fwip fwip

// Used by /obj/item/gun/energy/photon
/obj/item/ammo_casing/energy/photon
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	e_cost = LASER_SHOTS(4, STANDARD_CELL_CHARGE)
	select_name = "flare"
	projectile_type = /obj/projectile/energy/photon
