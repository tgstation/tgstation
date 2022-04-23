////////////////////////
//ID: MODULAR_WEAPONS //
////////////////////////

////////////////////////
//////   .32 ACP  //////

/obj/item/ammo_casing/c32
	name = ".32 bullet casing"
	desc = "A .32 bullet casing."
	caliber = "c32acp"
	projectile_type = /obj/projectile/bullet/c32

/obj/projectile/bullet/c32
	name = ".32 bullet"
	damage = 15
	wound_bonus = 0

/obj/item/ammo_casing/c32/rubber
	name = ".32 rubber bullet casing"
	desc = "A .32 rubber bullet casing."
	caliber = "c32acp"
	projectile_type = /obj/projectile/bullet/c32/rubber
	harmful = FALSE

/obj/projectile/bullet/c32/rubber
	name = ".32 rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -75
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/item/ammo_casing/c32/ap
	name = ".32 armor-piercing bullet"
	desc = "A .32 armor-piercing bullet casing."
	caliber = "c32acp"
	projectile_type = /obj/projectile/bullet/c32/ap

/obj/projectile/bullet/c32/ap
	name = ".32 armor-piercing bullet"
	damage = 15
	armour_penetration = 40
	wound_bonus = -75

/obj/item/ammo_casing/c32_incendiary
	name = ".32 incendiary bullet"
	desc = "A .32 incendiary bullet casing."
	caliber = "c32acp"
	projectile_type = /obj/projectile/bullet/incendiary/c32_incendiary

/obj/projectile/bullet/incendiary/c32_incendiary
	name = ".32 incendiary bullet"
	damage = 8
	fire_stacks = 1
	wound_bonus = -90

//////   .32 ACP  //////
////////////////////////
/////  10mm Magnum /////

/obj/item/ammo_casing/c10mm/rubber
	name = "10mm Magnum rubber bullet casing"
	desc = "A 10mm Magnum bullet casing. This fires a non-lethal projectile to cause compliance by pain and bruising. Don't aim for the head."
	caliber = CALIBER_10MM
	projectile_type = /obj/projectile/bullet/c10mm/rubber
	harmful = FALSE

/obj/projectile/bullet/c10mm/rubber
	name = "10mm Magnum rubber ball"
	damage = 10
	stamina = 40
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/////  10mm Magnum /////
////////////////////////
//////   .45 ACP  //////

/obj/item/ammo_casing/c45/rubber
	name = ".45 rubber bullet casing"
	desc = "A .45 bullet casing."
	projectile_type = /obj/projectile/bullet/c45/rubber

/obj/projectile/bullet/c45/rubber
	name = ".45 rubber ball"
	damage = 10
	stamina = 30
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null
	wound_bonus = -50

//////   .45 ACP  //////
////////////////////////
/////  HK 4.6x30mm /////

/obj/projectile/bullet/c46x30mm_rubber
	name = "4.6x30mm rubber bullet"
	damage = 3
	stamina = 17
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null
	wound_bonus = -50

/obj/item/ammo_casing/c46x30mm/rubber
	name = "4.6x30mm rubber bullet casing"
	desc = "A 4.6x30mm rubber bullet casing."
	projectile_type = /obj/projectile/bullet/c46x30mm_rubber
	harmful = FALSE

/////  HK 4.6x30mm /////
////////////////////////
//// 5.56x30mm MARS ////

/obj/item/ammo_casing/a556/rubber
	name = "5.56mm rubber bullet casing"
	desc = "A 5.56mm rubber bullet casing."
	caliber = CALIBER_A556
	projectile_type = /obj/projectile/bullet/a556/rubber
	harmful = FALSE

/obj/projectile/bullet/a556/rubber
	name = "5.56mm rubber bullet"
	damage = 10
	armour_penetration = 10
	stamina = 30
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null
	wound_bonus = -50

/obj/item/ammo_casing/a556/ap
	name = "5.56mm AP bullet casing"
	desc = "A 5.56mm AP bullet casing."
	caliber = CALIBER_A556
	projectile_type = /obj/projectile/bullet/a556/ap

/obj/projectile/bullet/a556/ap
	name = "5.56mm AP bullet"
	armour_penetration = 60

//// 5.56x30mm MARS ////
////////////////////////
//////    7.62    //////

/obj/item/ammo_casing/a762/rubber
	name = "7.62 rubber bullet casing"
	desc = "A 7.62 rubber bullet casing. <b>This is isn't exactly 'non-lethal'.</b>"
	icon_state = "762-casing"
	caliber = CALIBER_A762
	projectile_type = /obj/projectile/bullet/a762/rubber
	harmful = FALSE

/obj/projectile/bullet/a762/rubber
	name = "7.62mm rubber bullet"
	damage = 15
	stamina = 55
	ricochets_max = 5
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null

//////    7.62    //////
////////////////////////
/////  5.56x45mm   /////
// Very good at piercing armour at short range, not as good at going through armour at over 100m. But this is SS13...

/// The 5.56 you see pretty much everyone under NATO use.
#define CALIBER_A556x45 "a556x45"
/obj/item/ammo_casing/a556x45
	name = "5.56x45mm bullet casing"
	desc = "A 5.56mm rubber bullet casing."
	caliber = CALIBER_A556x45
	projectile_type = /obj/projectile/bullet/a556x45

/obj/projectile/bullet/a556x45
	name = "5.56x45mm bullet"
	damage = 50
	armour_penetration = 20
	stamina = 10
	speed = 0.2
	wound_bonus = 20
	bare_wound_bonus = 10

/////  5.56x45mm   /////
////////////////////////
//////   .34 ACP  //////
// Why? Blame CFA, they want their bullets to be *proprietary*
/obj/item/ammo_casing/c34
	name = ".34 bullet casing"
	desc = "A .34 bullet casing."
	caliber = "c32acp"
	projectile_type = /obj/projectile/bullet/c34

/obj/projectile/bullet/c34
	name = ".34 bullet"
	damage = 15
	wound_bonus = 0

/obj/item/ammo_casing/c34/rubber
	name = ".34 rubber bullet casing"
	desc = "A .34 rubber bullet casing."
	caliber = "c34acp"
	projectile_type = /obj/projectile/bullet/c34/rubber
	harmful = FALSE

/obj/projectile/bullet/c34/rubber
	name = ".34 rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -75
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/item/ammo_casing/c34/ap
	name = ".34 armor-piercing bullet"
	desc = "A .34 armor-piercing bullet casing."
	caliber = "c34acp"
	projectile_type = /obj/projectile/bullet/c34/ap

/obj/projectile/bullet/c34/ap
	name = ".34 armor-piercing bullet"
	damage = 15
	armour_penetration = 40
	wound_bonus = -75

/obj/item/ammo_casing/c34_incendiary
	name = ".34 incendiary bullet"
	desc = "A .34 incendiary bullet casing."
	caliber = "c34acp"
	projectile_type = /obj/projectile/bullet/incendiary/c34_incendiary

/obj/projectile/bullet/incendiary/c34_incendiary
	name = ".34 incendiary bullet"
	damage = 8
	fire_stacks = 1
	wound_bonus = -90

//////   .34 ACP  //////
////////////////////////
//////  4.2x30mm  //////

/obj/item/ammo_casing/c42x30mm
	name = "4.2x30mm bullet casing"
	desc = "A 4.2x30mm bullet casing."
	caliber = CALIBER_42X30MM
	projectile_type = /obj/projectile/bullet/c42x30mm

/obj/item/ammo_casing/c42x30mm/ap
	name = "4.2x30mm armor-piercing bullet casing"
	desc = "A 4.2x30mm armor-piercing bullet casing."
	projectile_type = /obj/projectile/bullet/c42x30mm/ap

/obj/item/ammo_casing/c42x30mm/inc
	name = "4.2x30mm incendiary bullet casing"
	desc = "A 4.2x30mm incendiary bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c42x30mm

/obj/projectile/bullet/c42x30mm
	name = "4.2x30mm bullet"
	damage = 20
	wound_bonus = -5
	bare_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c42x30mm/ap
	name = "4.2x30mm armor-piercing bullet"
	damage = 15
	armour_penetration = 40
	embedding = null

/obj/projectile/bullet/incendiary/c42x30mm
	name = "4.2x30mm incendiary bullet"
	damage = 10
	fire_stacks = 1

/obj/projectile/bullet/c42x30mm_rubber
	name = "4.2x30mm rubber bullet"
	damage = 3
	stamina = 17
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null
	wound_bonus = -50

/obj/item/ammo_casing/c42x30mm/rubber
	name = "4.2x30mm rubber bullet casing"
	desc = "A 4.2x30mm rubber bullet casing."
	projectile_type = /obj/projectile/bullet/c42x30mm_rubber
	harmful = FALSE

//////  4.2x30mm  //////
////////////////////////
//////    12mm    //////

/obj/item/ammo_casing/c12mm
	name = "12mm Magnum bullet casing"
	desc = "A 12mm Magnum bullet casing."
	caliber = CALIBER_12MM
	projectile_type = /obj/projectile/bullet/c12mm

/obj/item/ammo_casing/c12mm/ap
	name = "12mm Magnum armor-piercing bullet casing"
	desc = "A 12mm Magnum bullet casing with a tungsten core tip."
	projectile_type = /obj/projectile/bullet/c12mm/ap

/obj/item/ammo_casing/c12mm/hp
	name = "12mm Magnum hollow-point bullet casing"
	desc = "A 12mm Magnum bullet casing with a hollow tip that fragments on contact."
	projectile_type = /obj/projectile/bullet/c12mm/hp

/obj/item/ammo_casing/c12mm/fire
	name = "12mm Magnum incendiary bullet casing"
	desc = "A 12mm Magnum bullet casing with a magnesium coated tip meant for setting things on fire."
	projectile_type = /obj/projectile/bullet/incendiary/c12mm

/obj/item/ammo_casing/c12mm/rubber
	name = "12mm Magnum rubber bullet casing"
	desc = "A low powder load 12mm Magnum bullet casing with a flat rubber tip. Headshots heavily discouraged."
	projectile_type = /obj/projectile/bullet/c12mm/rubber
	harmful = FALSE

/obj/projectile/bullet/c12mm
	name = "12mm bullet"
	damage = 40

/obj/projectile/bullet/c12mm/ap
	name = "12mm armor-piercing bullet"
	damage = 37
	armour_penetration = 40

/obj/projectile/bullet/c12mm/hp
	name = "12mm hollow-point bullet"
	damage = 60
	weak_against_armour = TRUE

/obj/projectile/bullet/incendiary/c12mm
	name = "12mm incendiary bullet"
	damage = 20
	fire_stacks = 2

/obj/projectile/bullet/c12mm/rubber
	name = "12mm Magnum rubber ball"
	damage = 10
	stamina = 40
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null

//////    12mm    //////
////////////////////////
//////  6.8x43mm  //////


/obj/item/ammo_casing/a68
	name = "6.8mm bullet casing"
	desc = "A 6.8mm bullet casing."
	icon_state = "762-casing"
	caliber = CALIBER_A68
	projectile_type = /obj/projectile/bullet/a68

/obj/projectile/bullet/a68
	name = "6.8 bullet"
	damage = 55
	armour_penetration = 10
	wound_bonus = -45
	wound_falloff_tile = 0

//////  6.8x43mm  //////
