/obj/item/ammo_casing/energy/laser/hardlight_bullet
	name = "hardlight bullet casing"
	projectile_type = /obj/projectile/beam/laser/hardlight_bullet
	e_cost = 83 // 12 shots with a normal cell.
	select_name = "hardlight bullet"
	fire_sound = 'sound/weapons/gun/pistol/shot.ogg'

 // Not a real bullet, but visually looks like one. For the aesthetic of bullets, while keeping the balance intact.
 // Every piece of armor in the game is currently balanced around "sec has lasers, syndies have bullets". This allows us to keep that balance
 // without sacrificing the bullet aesthetic.
/obj/projectile/beam/laser/hardlight_bullet
	icon = 'modular_skyrat/modules/sec_haul/icons/guns/projectiles.dmi'
	icon_state = "bullet"
	name = "hardlight bullet"
	pass_flags = PASSTABLE // All of the below is to not break kayfabe about it not being a bullet.
	hitsound ='sound/weapons/pierce.ogg'
	hitsound_wall = "ricochet"
	light_system = NO_LIGHT_SUPPORT
	light_range = 0
	light_power = 0
	damage_type = BRUTE // So they do brute damage but still hit laser armor!
	sharpness = SHARP_POINTY
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	shrapnel_type = /obj/item/shrapnel/bullet
	embedding = list(embed_chance=20, fall_chance=2, jostle_chance=0, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.5, pain_mult=3, rip_time=10)

// For calculating ammo, remember that these guns have 1000 unit power cells.

/// Vintorez
/obj/item/gun/energy/vintorez
	name = "\improper VKC 'Vintorez'"
	desc = "The VKC Vintorez is a lightweight integrally-suppressed scoped carbine usually employed in stealth operations from the long since past 20th century."
	icon = 'modular_skyrat/modules/goofsec/icons/gun_sprites.dmi'
	righthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/righthand.dmi'
	lefthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/lefthand.dmi'
	icon_state = "vintorez"
	worn_icon = 'modular_skyrat/modules/sec_haul/icons/guns/norwind.dmi'
	worn_icon_state = "norwind_worn"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_OCLOTHING
	inhand_icon_state = "vintorez"
	burst_size = 2
	fire_delay = 4
	zoomable = TRUE
	zoom_amt = 7
	zoom_out_amt = 5
	fire_sound = null
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hardlight_bullet/vintorez)
	shaded_charge = TRUE
	cell_type = /obj/item/stock_parts/cell/super

/obj/item/ammo_casing/energy/laser/hardlight_bullet/vintorez
	name = "hardlight bullet vintorez casing"
	projectile_type = /obj/projectile/beam/laser/hardlight_bullet/vintorez
	e_cost = 1666 // 27 damage so 12 shots.
	fire_sound = 'sound/weapons/gun/smg/shot_suppressed.ogg'

/obj/projectile/beam/laser/hardlight_bullet/vintorez
	damage = 27 // All security armory firearms need to do, at minimum, laser gun damage.

/obj/item/gun/energy/norwind
	name = "\improper M112 'Norwind'"
	desc = "A rare M112 DMR rechambered to 12.7x30mm for peacekeeping work, it comes with a scope for medium-long range engagements. A bayonet lug is visible."
	icon = 'modular_skyrat/modules/goofsec/icons/gun_sprites.dmi'
	righthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/righthand.dmi'
	lefthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/lefthand.dmi'
	worn_icon = 'modular_skyrat/modules/sec_haul/icons/guns/norwind.dmi'
	worn_icon_state = "norwind_worn"
	icon_state = "norwind"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_OCLOTHING
	inhand_icon_state = "norwind"
	worn_icon = 'modular_skyrat/modules/sec_haul/icons/guns/norwind.dmi'
	worn_icon_state = "norwind_worn"
	can_bayonet = TRUE
	can_flashlight = TRUE
	zoomable = TRUE
	zoom_amt = 7
	zoom_out_amt = 5
	fire_sound = null
	fire_select_modes = list(SELECT_SEMI_AUTOMATIC)
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hardlight_bullet/norwind)
	burst_size = 1
	fire_delay = 10
	shaded_charge = TRUE
	cell_type = /obj/item/stock_parts/cell/super

/obj/item/ammo_casing/energy/laser/hardlight_bullet/norwind
	name = "hardlight bullet norwind casing"
	projectile_type = /obj/projectile/beam/laser/hardlight_bullet/norwind
	e_cost = 2857 // 7 shots, does 1.6x damage normal laser so fire cost increased by 1.6x
	fire_sound = 'modular_skyrat/modules/sec_haul/sound/ltrifle_fire.ogg'

/obj/projectile/beam/laser/hardlight_bullet/norwind
	damage = 45

/obj/item/gun/energy/ostwind
	name = "\improper DTR-6 rifle"
	desc = "A 6.3mm special-purpose rifle designed for specific situations."
	icon = 'modular_skyrat/modules/goofsec/icons/gun_sprites.dmi'
	righthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/righthand.dmi'
	lefthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/lefthand.dmi'
	inhand_icon_state = "ostwind"
	icon_state = "ostwind"
	worn_icon = 'modular_skyrat/modules/sec_haul/icons/guns/ostwind.dmi'
	worn_icon_state = "ostwind_worn"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_OCLOTHING
	fire_delay = 2
	burst_size = 2
	fire_sound = null
	can_bayonet = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hardlight_bullet/ostwind)
	cell_type = /obj/item/stock_parts/cell/super
/obj/item/ammo_casing/energy/laser/hardlight_bullet/ostwind
	name = "hardlight bullet norostwindwind casing"
	projectile_type = /obj/projectile/beam/laser/hardlight_bullet/ostwind
	e_cost = 1666 // 27 damage so 12 shots.
	fire_sound = 'sound/weapons/gun/smg/shot.ogg'

/obj/projectile/beam/laser/hardlight_bullet/ostwind
	damage = 27 // Minimum damage increase to at least base /tg/ laser gun damage.
	embedding = list(embed_chance=10, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)

/obj/item/gun/energy/pitbull
	name = "\improper Pitbull PDW"
	desc = "A sturdy personal defense weapon designed to fire 10mm Auto rounds."
	icon = 'modular_skyrat/modules/goofsec/icons/gun_sprites.dmi'
	righthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/righthand.dmi'
	lefthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/lefthand.dmi'
	inhand_icon_state = "pitbull"
	icon_state = "pitbull"
	worn_icon = 'modular_skyrat/modules/sec_haul/icons/guns/ostwind.dmi'
	worn_icon_state = "ostwind_worn"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_OCLOTHING
	fire_delay = 4.20
	burst_size = 3
	fire_sound = null
	can_bayonet = TRUE
	can_flashlight = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hardlight_bullet/pitbull)
	shaded_charge = TRUE
	cell_type = /obj/item/stock_parts/cell/super

/obj/item/ammo_casing/energy/laser/hardlight_bullet/pitbull
	name = "hardlight bullet pitbull casing"
	projectile_type = /obj/projectile/beam/laser/hardlight_bullet/pitbull
	e_cost = 1666 // 27 damage so 12 shots.
	fire_sound = 'modular_skyrat/modules/sec_haul/sound/sfrifle_fire.ogg'

/obj/projectile/beam/laser/hardlight_bullet/pitbull
	damage = 27

/obj/item/gun/energy/pcr
	name = "\improper PCR-9 SMG"
	desc = "An accurate, fast-firing SMG chambered in 9x19mm."
	icon = 'modular_skyrat/modules/goofsec/icons/gun_sprites.dmi'
	righthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/righthand.dmi'
	lefthand_file = 'modular_skyrat/modules/sec_haul/icons/guns/inhands/lefthand.dmi'
	worn_icon = 'modular_skyrat/modules/sec_haul/icons/guns/ostwind.dmi'
	worn_icon_state = "ostwind_worn"
	inhand_icon_state = "pcr"
	icon_state = "pcr"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_OCLOTHING
	fire_delay = 1.80
	burst_size = 5
	can_flashlight = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hardlight_bullet/pcr)
	shaded_charge = TRUE
	cell_type = /obj/item/stock_parts/cell/super

/obj/item/ammo_casing/energy/laser/hardlight_bullet/pcr
	name = "hardlight bullet pcr casing"
	projectile_type = /obj/projectile/beam/laser/hardlight_bullet/pcr
	e_cost = 1666 // 27 damage so 12 shots.
	fire_sound = 'modular_skyrat/modules/sec_haul/sound/smg_fire.ogg'

/obj/projectile/beam/laser/hardlight_bullet/pcr
	damage = 27 // Minimum damage increase to at least base /tg/ laser gun damage.

/* TODO: Use for SolFed.
/obj/item/gun/energy/peacemaker
	name = "\improper Peacemaker"
	desc = "The gun that won the space frontier. Four shots, and with a long firing delay, but packs an extreme punch."
	icon = 'modular_skyrat/modules/goofsec/icons/gun_sprites.dmi'
	icon_state = "peacemaker"
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT | ITEM_SLOT_OCLOTHING
	fire_delay = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hardlight_bullet/peacemaker)
	shaded_charge = TRUE

/obj/item/ammo_casing/energy/laser/hardlight_bullet/peacemaker
	name = "hardlight bullet peacemaker casing"
	projectile_type = /obj/projectile/beam/laser/hardlight_bullet/peacemaker
	e_cost = 250 // 4 shots.
	fire_sound = 'sound/weapons/gun/revolver/shot_alt.ogg'

/obj/projectile/beam/laser/hardlight_bullet/peacemaker
	damage = 60
*/

