// Base Sol rifle

/obj/item/gun/ballistic/automatic/sol_rifle
	name = "\improper Carwo 'd'Infanteria' Rifle"
	desc = "A heavy battle rifle commonly seen in the hands of SolFed military types. Accepts any standard SolFed rifle magazine."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns48x.dmi'
	icon_state = "infanterie"

	worn_icon = 'modular_skyrat/modules/modular_weapons/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "infanterie"

	lefthand_file = 'modular_skyrat/modules/modular_weapons/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/modular_weapons/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "infanterie"

	SET_BASE_PIXEL(-8, 0)

	special_mags = TRUE

	bolt_type = BOLT_TYPE_LOCKING

	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_OCLOTHING

	accepted_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle
	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle/standard

	fire_sound = 'modular_skyrat/modules/modular_weapons/sounds/rifle_heavy.ogg'
	suppressed_sound = 'modular_skyrat/modules/modular_weapons/sounds/suppressed_rifle.ogg'
	can_suppress = TRUE

	can_bayonet = FALSE

	suppressor_x_offset = 12

	burst_size = 1
	fire_delay = 0.45 SECONDS
	actions_types = list()

	spread = 7.5
	projectile_wound_bonus = -10

/obj/item/gun/ballistic/automatic/sol_rifle/Initialize(mapload)
	. = ..()

	give_autofire()

/// Separate proc for handling auto fire just because one of these subtypes isn't otomatica
/obj/item/gun/ballistic/automatic/sol_rifle/proc/give_autofire()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/sol_rifle/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/automatic/sol_rifle/examine_more(mob/user)
	. = ..()

	. += "The d'Infanterie rifles are, as the name may imply, built by Carwo for \
		use by SolFed's various infantry branches. Following the rather reasonable \
		military requirements of using the same few cartridges and magazines, \
		the lifespans of logistics coordinators and quartermasters everywhere \
		were lengthened by several years. While typically only for military sale \
		in the past, the recent collapse of certain unnamed weapons manufacturers \
		has caused Carwo to open many of its military weapons to civilian sale, \
		which includes this one."

	return .

/obj/item/gun/ballistic/automatic/sol_rifle/no_mag
	spawnwithmagazine = FALSE

// Sol marksman rifle

/obj/item/gun/ballistic/automatic/sol_rifle/marksman
	name = "\improper Carwo 'd'Elite' Marksman Rifle"
	desc = "A heavy marksman rifle commonly seen in the hands of SolFed military types. Accepts any standard SolFed rifle magazine."

	icon_state = "elite"
	worn_icon_state = "elite"
	inhand_icon_state = "elite"

	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle

	fire_delay = 0.75 SECONDS

	spread = 0
	projectile_damage_multiplier = 1.2
	projectile_wound_bonus = 10

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/scope, range_modifier = 2)

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/give_autofire()
	return

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/examine_more(mob/user)
	. = ..()

	. += "This particlar variant, often called 'd'Elite', is a marksman rifle. \
		Automatic fire was forsaken for a semi-automatic setup, a more fitting \
		stock, and more often than not a scope. Typically also seen with smaller \
		magazines for convenience for the shooter, but as with any other Sol \
		rifle, all standard magazine types will work."

	return .

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/no_mag
	spawnwithmagazine = FALSE

// Machinegun based on the base Sol rifle

/obj/item/gun/ballistic/automatic/sol_rifle/machinegun
	name = "\improper Carwo 'd'Outomaties' Machinegun"
	desc = "A hefty machinegun commonly seen in the hands of SolFed military types. Accepts any standard SolFed rifle magazine."

	icon_state = "outomaties"
	worn_icon_state = "outomaties"
	inhand_icon_state = "outomaties"

	bolt_type = BOLT_TYPE_OPEN

	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle/drum

	fire_delay = 0.1 SECONDS

	recoil = 1
	spread = 12.5
	projectile_wound_bonus = -20

/obj/item/gun/ballistic/automatic/sol_rifle/machinegun/examine_more(mob/user)
	. = ..()

	. += "The d'Outomaties variant of the rifle, what you are looking at now, \
		is a modification to turn the weapon into a passable, if sub-optimal \
		light machinegun. To support the machinegun role, the internals were \
		converted to make the gun into an open bolt, faster firing machine. These \
		additions, combined with a battle rifle not meant to be used fully auto \
		much to begin with, made for a relatively unwieldy weapon. A machinegun, \
		however, is still a machinegun, no matter how hard it is to keep on target."

	return .

/obj/item/gun/ballistic/automatic/sol_rifle/machinegun/no_mag
	spawnwithmagazine = FALSE

// Evil version of the rifle (nothing different its just black)

/obj/item/gun/ballistic/automatic/sol_rifle/evil
	desc = "A heavy battle rifle, this one seems to be painted tacticool black. Accepts any standard SolFed rifle magazine."

	icon_state = "infanterie_evil"
	worn_icon_state = "infanterie_evil"
	inhand_icon_state = "infanterie_evil"

/obj/item/gun/ballistic/automatic/sol_rifle/evil/no_mag
	spawnwithmagazine = FALSE
