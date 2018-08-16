/*
// NEW TOYS GUNS GO HERE
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//HITSCAN EXPERIMENT

/obj/item/gun/energy/pumpaction/toy
	icon_state = "blastertoy"
	name = "pump-action plastic blaster"
	desc = "A fearsome toy of terrible power. It has the ability to fire beams of pure light in either dispersal mode or overdrive mode. Requires the operation of a 40KW power shunt between every shot to prepare the beam focusing chamber."
	item_state = "particleblaster"
	lefthand_file = 'modular_citadel/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_citadel/icons/mob/inhands/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/laser/dispersal, /obj/item/ammo_casing/energy/laser/wavemotion)
	ammo_x_offset = 2
	modifystate = 1
	selfcharge = TRUE
	item_flags = NONE
	clumsy_check = FALSE

//PROJECTILES

/obj/item/projectile/beam/lasertag/wavemotion
	tracer_type = /obj/effect/projectile/tracer/laser/wavemotion
	muzzle_type = /obj/effect/projectile/muzzle/laser/wavemotion
	impact_type = /obj/effect/projectile/impact/laser/wavemotion
	hitscan = TRUE

/obj/item/projectile/beam/lasertag/dispersal
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue
	hitscan = TRUE

//AMMO CASINGS

/obj/item/ammo_casing/energy/laser/wavemotion
	projectile_type = /obj/item/projectile/beam/lasertag/wavemotion
	select_name = "overdrive"
	e_cost = 300
	fire_sound = 'modular_citadel/sound/weapons/LaserSlugv3.ogg'

/obj/item/ammo_casing/energy/laser/dispersal
	projectile_type = /obj/item/projectile/beam/lasertag/dispersal
	select_name = "dispersal"
	pellets = 5
	variance = 25
	e_cost = 200
	fire_sound = 'modular_citadel/sound/weapons/ParticleBlaster.ogg'

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//TOY REVOLVER

/obj/item/toy/gun/justicar
	name = "\improper replica F3 Justicar"
	desc = "An authentic cap-firing reproduction of a F3 Justicar big-bore revolver! Pretend to blow your friend's brains out with this 100% safe toy! Satisfaction guaranteed!"
	icon_state = "justicar"
	icon = 'modular_citadel/icons/obj/guns/toys.dmi'
	materials = list(MAT_METAL=2000, MAT_GLASS=250)


/obj/item/toy/gun/m41
	name = "Toy M41A Pulse Rifle"
	desc = "A toy replica of the Corporate Mercenaries' standard issue rifle. For Avtomat is inscribed on the side."
	icon_state = "toym41"
	icon = 'modular_citadel/icons/obj/guns/toys.dmi'
	materials = list(MAT_METAL=2000, MAT_GLASS=250)
