// .585 Trappiste
// High caliber round used in large pistols and revolvers

/obj/item/ammo_casing/c585trappiste
	name = ".585 Trappiste lethal bullet casing"
	desc = "A white polymer cased high caliber round commonly used in handguns."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/trappiste_fabriek/ammo.dmi'
	icon_state = "585trappiste"

	caliber = CALIBER_585TRAPPISTE
	projectile_type = /obj/projectile/bullet/c585trappiste

/obj/projectile/bullet/c585trappiste
	name = ".585 Trappiste bullet"
	damage = 45
	wound_bonus = 0 // Normal bullets are 20

/obj/item/ammo_box/c585trappiste
	name = "ammo box (.585 Trappiste lethal)"
	desc = "A box of .585 Trappiste pistol rounds, holds twelve cartridges."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/trappiste_fabriek/ammo.dmi'
	icon_state = "585box"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_NORMAL

	caliber = CALIBER_585TRAPPISTE
	ammo_type = /obj/item/ammo_casing/c585trappiste
	max_ammo = 12

// .585 Trappiste equivalent to a rubber bullet

/obj/item/ammo_casing/c585trappiste/incapacitator
	name = ".585 Trappiste flathead bullet casing"
	desc = "A white polymer cased high caliber round with a relatively soft, flat tip. Designed to flatten against targets and usually not penetrate on impact."

	icon_state = "585trappiste_disabler"

	projectile_type = /obj/projectile/bullet/c585trappiste/incapacitator
	harmful = FALSE

/obj/projectile/bullet/c585trappiste/incapacitator
	name = ".585 Trappiste flathead bullet"
	damage = 20
	stamina = 40
	wound_bonus = 10

	weak_against_armour = TRUE

	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/item/ammo_box/c585trappiste/incapacitator
	name = "ammo box (.585 Trappiste flathead)"
	desc = "A box of .585 Trappiste pistol rounds, holds twelve cartridges. The blue stripe indicates that it should hold less lethal rounds."

	icon_state = "585box_disabler"

	ammo_type = /obj/item/ammo_casing/c585trappiste/incapacitator

// .585 hollowpoint, made to cause nasty wounds

/obj/item/ammo_casing/c585trappiste/hollowpoint
	name = ".585 Trappiste hollowhead bullet casing"
	desc = "A white polymer cased high caliber round with a hollowed tip. Designed to cause as much damage on impact to fleshy targets as possible."

	icon_state = "585trappiste_shrapnel"
	projectile_type = /obj/projectile/bullet/c585trappiste/hollowpoint

	advanced_print_req = TRUE

/obj/projectile/bullet/c585trappiste/hollowpoint
	name = ".585 Trappiste hollowhead bullet"
	damage = 35

	weak_against_armour = TRUE

	wound_bonus = 30
	bare_wound_bonus = 40

/obj/item/ammo_box/c585trappiste/hollowpoint
	name = "ammo box (.585 Trappiste hollowhead)"
	desc = "A box of .585 Trappiste pistol rounds, holds twelve cartridges. The purple stripe indicates that it should hold hollowpoint-like rounds."

	icon_state = "585box_shrapnel"

	ammo_type = /obj/item/ammo_casing/c585trappiste/hollowpoint
