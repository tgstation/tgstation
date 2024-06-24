// Base Sol rifle

/obj/item/gun/ballistic/automatic/sol_rifle
	name = "\improper Carwo-Cawil Battle Rifle"
	desc = "A heavy battle rifle firing .40 Sol. Commonly seen in the hands of SolFed military types. Accepts any standard SolFed rifle magazine."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns48x.dmi'
	icon_state = "infanterie"

	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "infanterie"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "infanterie"

	SET_BASE_PIXEL(-8, 0)

	special_mags = TRUE

	bolt_type = BOLT_TYPE_LOCKING

	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE

	accepted_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle
	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle/standard

	fire_sound = 'monkestation/code/modules/blueshift/sounds/rifle_heavy.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_rifle.ogg'
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

/obj/item/gun/ballistic/automatic/sol_rifle/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/sol_rifle/examine_more(mob/user)
	. = ..()

	. += "The Carwo-Cawil rifles are built by Carwo for \
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
	name = "\improper Cawil Marksman Rifle"
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

	. += "This particlar variant is a marksman rifle. \
		Automatic fire was forsaken for a semi-automatic setup, a more fitting \
		stock, and more often than not a scope. Typically also seen with smaller \
		magazines for convenience for the shooter, but as with any other Sol \
		rifle, all standard magazine types will work."

	return .

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/no_mag
	spawnwithmagazine = FALSE

// Machinegun based on the base Sol rifle

/obj/item/gun/ballistic/automatic/sol_rifle/machinegun
	name = "\improper Qarad Light Machinegun"
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

	. += "The 'Qarad' variant of the rifle, what you are looking at now, \
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

// SolFed shotgun (this was gonna be in a proprietary shotgun shell type outside of 12ga at some point, wild right?)

/obj/item/gun/ballistic/shotgun/riot/sol
	name = "\improper Renoster Shotgun"
	desc = "A twelve gauge shotgun with a six shell capacity underneath. Made for and used by SolFed's various military branches."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns48x.dmi'
	icon_state = "renoster"

	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "renoster"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "renoster"

	inhand_x_dimension = 32
	inhand_y_dimension = 32

	SET_BASE_PIXEL(-8, 0)

	fire_sound = 'monkestation/code/modules/blueshift/sounds/shotgun_heavy.ogg'
	rack_sound = 'monkestation/code/modules/blueshift/sounds/shotgun_rack.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_heavy.ogg'
	can_suppress = TRUE

	suppressor_x_offset = 9

	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE

/obj/item/gun/ballistic/shotgun/riot/sol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/shotgun/riot/sol/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/shotgun/riot/sol/examine_more(mob/user)
	. = ..()

	. += "The Renoster was designed at its core as a police shotgun. \
		As consequence, it holds all the qualities a police force would want \
		in one. Large shell capacity, sturdy frame, while holding enough \
		capacity for modification to satiate even the most overfunded of \
		peacekeeper forces. Inevitably, the weapon made its way into civilian \
		markets alongside its sale to several military branches that also \
		saw value in having a heavy shotgun."

	return .

/obj/item/gun/ballistic/shotgun/riot/sol/update_appearance(updates)
	if(sawn_off)
		suppressor_x_offset = 0
		SET_BASE_PIXEL(0, 0)

	. = ..()

// Shotgun but EVIL!

/obj/item/gun/ballistic/shotgun/riot/sol/evil
	desc = "A twleve guage shotgun with an eight shell capacity underneath. This one is painted in a tacticool black."

	icon_state = "renoster_evil"
	worn_icon_state = "renoster_evil"
	inhand_icon_state = "renoster_evil"

// Low caliber grenade launcher (fun & games)

/obj/item/gun/ballistic/automatic/sol_grenade_launcher
	name = "\improper Kiboko Grenade Launcher"
	desc = "A unique grenade launcher firing .980 grenades. A laser sight system allows its user to specify a range for the grenades it fires to detonate at."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns48x.dmi'
	icon_state = "kiboko"

	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "kiboko"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "kiboko"

	SET_BASE_PIXEL(-8, 0)

	special_mags = TRUE

	bolt_type = BOLT_TYPE_LOCKING

	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE

	accepted_magazine_type = /obj/item/ammo_box/magazine/c980_grenade

	fire_sound = 'monkestation/code/modules/blueshift/sounds/grenade_launcher.ogg'

	can_suppress = FALSE
	can_bayonet = FALSE

	burst_size = 1
	fire_delay = 5
	actions_types = list()

	/// The currently stored range to detonate shells at
	var/target_range = 14
	/// The maximum range we can set grenades to detonate at, just to be safe
	var/maximum_target_range = 14

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/examine_more(mob/user)
	. = ..()

	. += "The Kiboko is one of the strangest weapons Carwo offers. A grenade launcher, \
		though not in the standard grenade size. The much lighter .980 Tydhouer grenades \
		developed for the weapon offered many advantages over standard grenade launching \
		ammunition. For a start, it was significantly lighter, and easier to carry large \
		amounts of. What it also offered, however, and the reason SolFed funded the \
		project: Variable time fuze. Using the large and expensive ranging sight on the \
		launcher, its user can set an exact distance for the grenade to self detonate at. \
		The dream of militaries for decades, finally realized. The smaller shells do not, \
		however, make the weapon any more enjoyable to fire. The kick is only barely \
		manageable thanks to the massive muzzle brake at the front."

	return .

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/examine(mob/user)
	. = ..()

	. += span_notice("With <b>Right Click</b> you can set the range that shells will detonate at.")
	. += span_notice("A small indicator in the sight notes the current detonation range is: <b>[target_range]</b>.")

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/afterattack_secondary(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(!target || !user)
		return

	var/distance_ranged = get_dist(user, target)
	if(distance_ranged > maximum_target_range)
		user.balloon_alert(user, "out of range")
		return

	target_range = distance_ranged
	user.balloon_alert(user, "range set: [target_range]")

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/no_mag
	spawnwithmagazine = FALSE

// fun & games but evil this time

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/evil
	icon_state = "kiboko_evil"
	worn_icon_state = "kiboko_evil"
	inhand_icon_state = "kiboko_evil"

	spawn_magazine_type = /obj/item/ammo_box/magazine/c980_grenade/drum

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/evil/no_mag
	spawnwithmagazine = FALSE

/*
*	QM Sporter Rifle
*/

/obj/item/gun/ballistic/rifle/boltaction/sporterized
	name = "\improper Rengo Precision Rifle"
	desc = "A heavily modified Sakhno rifle, parts made by Xhihao light arms based around Jupiter herself. \
		Has a higher capacity than standard Sakhno rifles, fitting ten .310 cartridges."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/guns40x.dmi'
	icon_state = "rengo"
	inhand_icon_state = "moistnugget"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/bubba
	can_be_sawn_off = FALSE
	knife_x_offset = 35

/obj/item/gun/ballistic/rifle/boltaction/sporterized/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/rifle/boltaction/sporterized/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_XHIHAO)

/obj/item/gun/ballistic/rifle/boltaction/sporterized/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/rifle/boltaction/sporterized/examine_more(mob/user)
	. = ..()

	. += "The Xhihao 'Rengo' conversion rifle. Came as parts sold in a single kit by Xhihao Light Arms, \
		which can be swapped out with many of the outdated or simply old parts on a typical Sakhno rifle. \
		While not necessarily increasing performance in any way, the magazine is slightly longer. The weapon \
		is also overall a bit shorter, making it easier to handle for some people. Cannot be sawn off, cutting \
		really any part of this weapon off would make it non-functional."

	return .

/obj/item/gun/ballistic/rifle/boltaction/sporterized/empty
	bolt_locked = TRUE // so the bolt starts visibly open
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/bubba/empty

/obj/item/ammo_box/magazine/internal/boltaction/bubba
	name = "Sakhno extended internal magazine"
	desc = "How did you get it out?"
	ammo_type = /obj/item/ammo_casing/strilka310
	caliber = CALIBER_STRILKA310
	max_ammo = 8

/obj/item/ammo_box/magazine/internal/boltaction/bubba/empty
	start_empty = TRUE

/*
*	Box that contains Sakhno rifles, but less soviet union since we don't have one of those
*/

/obj/item/storage/toolbox/guncase/soviet/sakhno
	desc = "A weapon's case. This one is green and looks pretty old, but is otherwise in decent condition."
	icon = 'icons/obj/storage/case.dmi'
	material_flags = NONE // ????? Why do these have materials enabled??

// Evil .585 smg that blueshields spawn with that will throw your screen like hell but itll sure kill whoever threatens a head really good

/obj/item/gun/ballistic/automatic/xhihao_smg
	name = "\improper Bogseo Submachine Gun"
	desc = "A weapon that could hardly be called a 'sub' machinegun, firing the monstrous .585 cartridge. \
		It provides enough kick to bruise a shoulder pretty bad if used without protection."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/guns32x.dmi'
	icon_state = "bogseo"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/xhihao_light_arms/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/xhihao_light_arms/guns_righthand.dmi'
	inhand_icon_state = "bogseo"

	special_mags = FALSE

	bolt_type = BOLT_TYPE_STANDARD

	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT

	accepted_magazine_type = /obj/item/ammo_box/magazine/c585trappiste_pistol

	fire_sound = 'monkestation/code/modules/blueshift/sounds/smg_heavy.ogg'
	can_suppress = TRUE

	can_bayonet = FALSE

	suppressor_x_offset = 9

	burst_size = 1
	fire_delay = 0.15 SECONDS
	actions_types = list()

	// Because we're firing a lot of these really fast, we want a lot less wound chance
	projectile_wound_bonus = -20
	spread = 12.5
	// Hope you didn't need to see anytime soon
	recoil = 2

/obj/item/gun/ballistic/automatic/xhihao_smg/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_XHIHAO)
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/xhihao_smg/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/xhihao_smg/examine_more(mob/user)
	. = ..()

	. += "The Bogseo submachinegun is seen in highly different lights based on \
		who you ask. Ask a Jovian, and they'll go off all day about how they \
		love the thing so. A big weapon for shooting big targets, like the \
		fuel-stat raiders in their large suits of armor. Ask a space pirate, however \
		and you'll get a different story. That is thanks to many SolFed anti-piracy \
		units picking the Bogseo as their standard boarding weapon. What better \
		to ruin a brigand's day than a bullet large enough to turn them into \
		mist at full auto, after all?"

	return .

/obj/item/gun/ballistic/automatic/xhihao_smg/no_mag
	spawnwithmagazine = FALSE

// .35 Sol mini revolver

/obj/item/gun/ballistic/revolver/sol
	name = "\improper Eland Revolver"
	desc = "A small revolver with a comically short barrel and cylinder space for eight .35 Sol Short rounds."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "eland"

	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/c35sol

	suppressor_x_offset = 3

	w_class = WEIGHT_CLASS_SMALL

	can_suppress = TRUE

/obj/item/gun/ballistic/revolver/sol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/revolver/sol/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/revolver/sol/examine_more(mob/user)
	. = ..()

	. += "The Eland is one of the few Trappiste weapons not made for military contract. \
		Instead, the Eland started life as a police weapon, offered as a gun to finally \
		outmatch all others in the cheap police weapons market. Unfortunately, this \
		coincided with nearly every SolFed police force realising they are actually \
		comically overfunded. With military weapons bought for police forces taking \
		over the market, the Eland instead found home in the civilian personal defense \
		market. That is likely the reason you are looking at this one now."

	return .

/obj/item/ammo_box/magazine/internal/cylinder/c35sol
	ammo_type = /obj/item/ammo_casing/c35sol
	caliber = CALIBER_SOL35SHORT
	max_ammo = 8

// .585 super revolver

/obj/item/gun/ballistic/revolver/takbok
	name = "\improper Takbok Revolver"
	desc = "A hefty revolver with an equally large cylinder capable of holding five .585 Trappiste rounds."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "takbok"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/revolver_heavy.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_heavy.ogg'

	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/c585trappiste

	suppressor_x_offset = 5

	can_suppress = TRUE

	fire_delay = 1 SECONDS
	recoil = 3

/obj/item/gun/ballistic/revolver/takbok/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/revolver/takbok/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/revolver/takbok/examine_more(mob/user)
	. = ..()

	. += "The Takbok is a unique design for Trappiste for the sole reason that it \
		was made at first to be a one-off. Founder of partner company Carwo Defense, \
		Darmaan Khaali Carwo herself, requested a sporting revolver from Trappiste. \
		What was delivered wasn't a target revolver, it was a target crusher. The \
		weapon became popular as Carwo crushed many shooting competitions using \
		the Takbok, with the design going on several production runs up until \
		2523 when the popularity of the gun fell off. Due to the number of revolvers \
		made, they are still easy enough to find if you look despite production \
		having already ceased many years ago."

	return .

/obj/item/ammo_box/magazine/internal/cylinder/c585trappiste
	ammo_type = /obj/item/ammo_casing/c585trappiste
	caliber = CALIBER_585TRAPPISTE
	max_ammo = 5

// .35 Sol pistol

/obj/item/gun/ballistic/automatic/pistol/sol
	name = "\improper Wespe Pistol"
	desc = "The standard issue service pistol of SolFed's various military branches. Uses .35 Sol and comes with an attached light."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "wespe"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/pistol_light.ogg'

	w_class = WEIGHT_CLASS_NORMAL

	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	special_mags = TRUE

	suppressor_x_offset = 7
	suppressor_y_offset = 0

	fire_delay = 0.3 SECONDS

/obj/item/gun/ballistic/automatic/pistol/sol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/automatic/pistol/sol/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		starting_light = new /obj/item/flashlight/seclite(src), \
		is_light_removable = FALSE, \
		)

/obj/item/gun/ballistic/automatic/pistol/sol/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/pistol/sol/examine_more(mob/user)
	. = ..()

	. += "The Wespe is a pistol that was made entirely for military use. \
		Required to use a standard round, standard magazines, and be able \
		to function in all of the environments that SolFed operated in \
		commonly. These qualities just so happened to make the weapon \
		popular in frontier space and is likely why you are looking at \
		one now."

	return .

/obj/item/gun/ballistic/automatic/pistol/sol/no_mag
	spawnwithmagazine = FALSE

// Sol pistol evil gun

/obj/item/gun/ballistic/automatic/pistol/sol/evil
	desc = "The standard issue service pistol of SolFed's various military branches. Comes with attached light. This one is painted tacticool black."

	icon_state = "wespe_evil"

/obj/item/gun/ballistic/automatic/pistol/sol/evil/no_mag
	spawnwithmagazine = FALSE

// Trappiste high caliber pistol in .585

/obj/item/gun/ballistic/automatic/pistol/trappiste
	name = "\improper Skild Pistol"
	desc = "A somewhat rare to see Trappiste pistol firing the high caliber .585 developed by the same company. \
		Sees rare use mainly due to its tendency to cause severe wrist discomfort."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "skild"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/pistol_heavy.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_heavy.ogg'

	w_class = WEIGHT_CLASS_NORMAL

	accepted_magazine_type = /obj/item/ammo_box/magazine/c585trappiste_pistol

	suppressor_x_offset = 8
	suppressor_y_offset = 0

	fire_delay = 1 SECONDS

	recoil = 3

/obj/item/gun/ballistic/automatic/pistol/trappiste/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/automatic/pistol/sol/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/pistol/trappiste/examine_more(mob/user)
	. = ..()

	. += "The Skild only exists due to a widely known event that SolFed's military \
		would prefer wasn't anywhere near as popular. A general, name unknown as of now, \
		was recorded complaining about the lack of capability the Wespe provided to the \
		military, alongside several statements comparing the Wespe's lack of masculinity \
		to the, quote, 'unique lack of testosterone those NRI mongrels field'. While the \
		identities of both the general and people responsible for the leaking of the recording \
		are still classified, many high ranking SolFed military staff suspiciously have stopped \
		appearing in public, unlike the Skild. A lot of several thousand pistols, the first \
		of the weapons to ever exist, were not so silently shipped to SolFed's Plutonian \
		shipping hub from TRAPPIST. SolFed military command refuses to answer any \
		further questions about the incident to this day."

	return .

/obj/item/gun/ballistic/automatic/pistol/trappiste/no_mag
	spawnwithmagazine = FALSE

// Rapid firing submachinegun firing .27-54 Cesarzowa

/obj/item/gun/ballistic/automatic/miecz
	name = "\improper Miecz Submachine Gun"
	desc = "A short barrel, further compacted conversion of the 'Lanca' rifle to fire pistol caliber .27-54 cartridges. \
		Due to the intended purpose of the weapon, and less than optimal ranged performance of the projectile, it has \
		nothing more than basic glow-sights as opposed to the ranged scope Lanca users might be used to."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_48.dmi'
	icon_state = "miecz"

	inhand_icon_state = "c20r"
	worn_icon_state = "gun"

	SET_BASE_PIXEL(-8, 0)

	special_mags = FALSE

	bolt_type = BOLT_TYPE_STANDARD

	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_SUITSTORE

	accepted_magazine_type = /obj/item/ammo_box/magazine/miecz

	fire_sound = 'monkestation/code/modules/blueshift/sounds/smg_light.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 0
	suppressor_y_offset = 0

	can_bayonet = FALSE

	burst_size = 1
	fire_delay = 0.2 SECONDS
	actions_types = list()

	spread = 5

/obj/item/gun/ballistic/automatic/miecz/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/miecz/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/automatic/miecz/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/miecz/examine_more(mob/user)
	. = ..()

	. += "The Meicz is one of the newest weapons to come out of CIN member state hands and \
		into the wild, typically the frontier. It was built alongside the round it fires, the \
		.27-54 Cesarzawa pistol round. Based on the proven Lanca design, it seeks to bring that \
		same reliable weapon design into the factor of a submachinegun. While it is significantly \
		larger than many comparable weapons in SolFed use, it more than makes up for it with ease \
		of control and significant firerate."

	return .

/obj/item/gun/ballistic/automatic/miecz/no_mag
	spawnwithmagazine = FALSE

// Semi-automatic rifle firing .310 with reduced damage compared to a Sakhno

/obj/item/gun/ballistic/automatic/lanca
	name = "\improper Lanca Battle Rifle"
	desc = "A relatively compact, long barreled bullpup battle rifle chambered for .310 Strilka. Has an integrated sight with \
		a surprisingly functional amount of magnification, given its place of origin."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_48.dmi'
	icon_state = "lanca"

	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/guns_worn.dmi'
	worn_icon_state = "lanca"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/guns_righthand.dmi'
	inhand_icon_state = "lanca"

	SET_BASE_PIXEL(-8, 0)

	special_mags = FALSE

	bolt_type = BOLT_TYPE_STANDARD

	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE

	accepted_magazine_type = /obj/item/ammo_box/magazine/lanca

	fire_sound = 'monkestation/code/modules/blueshift/sounds/battle_rifle.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_heavy.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 0
	suppressor_y_offset = 0

	can_bayonet = FALSE

	burst_size = 1
	fire_delay = 1.2 SECONDS
	actions_types = list()

	recoil = 0.5
	spread = 2.5
	projectile_wound_bonus = -20

/obj/item/gun/ballistic/automatic/lanca/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/automatic/lanca/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/automatic/lanca/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/lanca/examine_more(mob/user)
	. = ..()

	. += "The Lanca is a now relatively dated replacement for Kalashnikov pattern rifles \
		adopted by states now combining to form the CIN. While the rifle that came before them \
		had its benefits, leadership of many armies started to realize that the Kalashnikov-based \
		rifles were really showing their age once the variants began reaching the thousands in serial. \
		The solution was presented by a then new company, Szot Dynamica. This new rifle, not too \
		unlike the one you are seeing now, adopted all of the latest technology of the time. Lightweight \
		caseless ammunition, well known for its use in Sakhno rifles, as well as various electronics and \
		other incredible technological advancements. These advancements may have already been around since \
		before the creation of even the Sakhno, but the fact you're seeing this now fifty year old design \
		must mean something, right?"

	return .

/obj/item/gun/ballistic/automatic/lanca/no_mag
	spawnwithmagazine = FALSE

// The AMR
// This sounds a lot scarier than it actually is, you'll just have to trust me here

/obj/item/gun/ballistic/automatic/wylom
	name = "\improper Wyłom Anti-Materiel Rifle"
	desc = "A massive, outdated beast of an anti materiel rifle that was once in use by CIN military forces. Fires the devastating .60 Strela caseless round, \
		the massively overperforming penetration of which being the reason this weapon was discontinued."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_64.dmi'
	base_pixel_x = -16 // This baby is 64 pixels wide
	pixel_x = -16
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/inhands_64_left.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/inhands_64_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/guns_worn.dmi'
	icon_state = "wylom"
	inhand_icon_state = "wylom"
	worn_icon_state = "wylom"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK

	accepted_magazine_type = /obj/item/ammo_box/magazine/wylom
	can_suppress = FALSE
	can_bayonet = FALSE

	fire_sound = 'monkestation/code/modules/blueshift/sounds/amr_fire.ogg'
	fire_sound_volume = 100 // BOOM BABY

	recoil = 4

	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	fire_delay = 2 SECONDS
	actions_types = list()

	force = 15 // I mean if you're gonna beat someone with the thing you might as well get damage appropriate for how big the fukken thing is

/obj/item/gun/ballistic/automatic/wylom/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)
	AddElement(/datum/element/gun_launches_little_guys, throwing_force = 3, throwing_range = 5)

/obj/item/gun/ballistic/automatic/wylom/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/wylom/examine_more(mob/user)
	. = ..()

	. += "The 'Wyłom' AMR was a weapon not originally made for unaided human hands. \
		The original rifle had mounting points for a specialized suit attachment system, \
		not too much unlike heavy smartguns that can be seen across the galaxy. CIN military \
		command, however, deemed that expensive exoskeletons and rigs for carrying an organic \
		anti material system were simply not needed, and that soldiers should simply 'deal with it'. \
		Unsurprisingly, soldiers assigned this weapon tend to not be a massive fan of that fact, \
		and smekalka within CIN ranks is common with troops finding novel ways to carry and use \
		their large rifles with as little effort as possible. Most of these novel methods, of course, \
		tend to shatter when the rifle is actually fired."

	return .

// Plasma spewing pistol
// Sprays a wall of plasma that sucks against armor but fucks against unarmored targets

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower
	name = "\improper Słońce Plasma Projector"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. \
		Uses plasma power packs. \
		Spews an inaccurate stream of searing plasma out the magnetic barrel so long as it has power and the trigger is pulled."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_32.dmi'
	icon_state = "slonce"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/incinerate.ogg'
	fire_sound_volume = 40 // This thing is comically loud otherwise

	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/plasma_battery
	can_suppress = FALSE
	show_bolt_icon = FALSE
	casing_ejector = FALSE
	empty_indicator = FALSE
	bolt_type = BOLT_TYPE_OPEN
	fire_delay = 0.1 SECONDS
	spread = 15

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/automatic_fire, autofire_shot_delay = fire_delay)

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower/examine_more(mob/user)
	. = ..()

	. += "The 'Słońce' started life as an experiment in advancing the field of accelerated \
		plasma weaponry. Despite the design's obvious shortcomings in terms of accuracy and \
		range, the CIN combined military command (which we'll call the CMC from now on) took \
		interest in the weapon as a means to counter Sol's more advanced armor technology. \
		As it would turn out, the plasma globules created by the weapon were really not \
		as effective against armor as the CMC had hoped, quite the opposite actually. \
		What the plasma did do well however was inflict grevious burns upon anyone unfortunate \
		enough to get hit by it unprotected. For this reason, the 'Słońce' saw frequent use by \
		army officers and ship crews who needed a backup weapon to incinerate the odd space \
		pirate or prisoner of war."

	return .

// Plasma sharpshooter pistol
// Shoots single, strong plasma blasts at a slow rate

/obj/item/gun/ballistic/automatic/pistol/plasma_marksman
	name = "\improper Gwiazda Plasma Sharpshooter"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. \
		Uses plasma power packs. \
		Fires relatively accurate globs of searing plasma."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_32.dmi'
	icon_state = "gwiazda"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/burn.ogg'
	fire_sound_volume = 40 // This thing is comically loud otherwise

	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/plasma_battery
	can_suppress = FALSE
	show_bolt_icon = FALSE
	casing_ejector = FALSE
	empty_indicator = FALSE
	bolt_type = BOLT_TYPE_OPEN
	fire_delay = 0.6 SECONDS
	spread = 2.5

	projectile_damage_multiplier = 3 // 30 damage a shot
	projectile_wound_bonus = 10 // +55 of the base projectile, burn baby burn

/obj/item/gun/ballistic/automatic/pistol/plasma_marksman/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/automatic/pistol/plasma_marksman/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/pistol/plasma_marksman/examine_more(mob/user)
	. = ..()

	. += "The 'Gwiazda' is a further refinement of the 'Słońce' design. with improved \
		energy cycling, magnetic launchers built to higher precision, and an overall more \
		ergonomic design. While it still fails to perform against armor, the weapon is \
		significantly more accurate and higher power, at expense of a much lower firerate. \
		Opinions on this weapon within military service were highly mixed, with many preferring \
		the sheer stopping power a spray of plasma could produce, with others loving the new ability \
		to hit something in front of you for once."

	return .

// A revolver, but it can hold shotgun shells
// Woe, buckshot be upon ye

/obj/item/gun/ballistic/revolver/shotgun_revolver
	name = "\improper Bóbr 12 GA revolver"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. A revolver type design with a four shell cylinder. That's right, shell, this one shoots twelve guage."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev12ga
	recoil = SAWN_OFF_RECOIL
	weapon_weight = WEAPON_MEDIUM
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_32.dmi'
	icon_state = "bobr"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/revolver_fire.ogg'
	spread = SAWN_OFF_ACC_PENALTY

/obj/item/gun/ballistic/revolver/shotgun_revolver/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/revolver/shotgun_revolver/examine_more(mob/user)
	. = ..()

	. += "The 'Bóbr' started development as a limited run sporting weapon before \
		the military took interest. The market quickly changed from sport shooting \
		targets, to sport shooting SolFed strike teams once the conflict broke out. \
		This pattern is different from the original civilian version, with a military \
		standard pistol grip and weather resistant finish. While the 'Bóbr' was not \
		a weapon standard issued to every CIN soldier, it was available for relatively \
		cheap, and thus became rather popular among the ranks."

	return .

// Base Sol SMG

/obj/item/gun/ballistic/automatic/sol_smg
	name = "\improper Sindano Submachine Gun"
	desc = "A small submachine gun firing .35 Sol. Commonly seen in the hands of PMCs and other unsavory corpos. Accepts any standard Sol pistol magazine."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns32x.dmi'
	icon_state = "sindano"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "sindano"

	special_mags = TRUE

	bolt_type = BOLT_TYPE_OPEN

	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT

	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	spawn_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol/stendo

	fire_sound = 'monkestation/code/modules/blueshift/sounds/smg_light.ogg'
	can_suppress = TRUE

	can_bayonet = FALSE

	suppressor_x_offset = 11

	burst_size = 3
	fire_delay = 0.2 SECONDS

	spread = 7.5

/obj/item/gun/ballistic/automatic/sol_smg/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/automatic/sol_smg/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/sol_smg/examine_more(mob/user)
	. = ..()

	. += "The Sindano submachinegun was originally produced for military contract. \
		These guns were seen in the hands of anyone from medics, ship techs, logistics officers, \
		and shuttle pilots often had several just to show off. Due to SolFed's quest to \
		extend the lifespans of their logistics officers and quartermasters, the weapon \
		uses the same standard pistol cartridge that most other miltiary weapons of \
		small caliber use. This results in interchangeable magazines between pistols \
		and submachineguns, neat!"

	return .

/obj/item/gun/ballistic/automatic/sol_smg/no_mag
	spawnwithmagazine = FALSE

// Sindano (evil)

/obj/item/gun/ballistic/automatic/sol_smg/evil
	desc = "A small submachinegun, this one is painted in tacticool black. Accepts any standard Sol pistol magazine."

	icon_state = "sindano_evil"
	inhand_icon_state = "sindano_evil"

/obj/item/gun/ballistic/automatic/sol_smg/evil/no_mag
	spawnwithmagazine = FALSE

/// File location for the long gun's speech
#define LONG_MOD_LASER_SPEECH "nova/long_modular_laser.json"
/// File location for the short gun's speech
#define SHORT_MOD_LASER_SPEECH "nova/short_modular_laser.json"
/// How long the gun should wait between speaking to lessen spam
#define MOD_LASER_SPEECH_COOLDOWN 2 SECONDS
/// What color is the default kill mode for these guns, used to make sure the chat colors are right at roundstart
#define DEFAULT_RUNECHAT_GUN_COLOR "#cd4456"

// Modular energy weapons, laser guns that can transform into different variants after a few seconds of waiting and animation
// Long version, takes both hands to use and doesn't fit in any bags out there
/obj/item/gun/energy/modular_laser_rifle
	name = "\improper Hyeseong modular laser rifle"
	desc = "A popular energy weapon system that can be reconfigured into many different variants on the fly. \
		Seen commonly amongst the Marsians who produce the weapon, with many different shapes and sizes to fit \
		the wide variety of modders the planet is home to."
	base_icon_state = "hyeseong"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/saibasan/guns48x.dmi'
	icon_state = "hyeseong_kill"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/saibasan/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/saibasan/guns_righthand.dmi'
	inhand_icon_state = "hyeseong_kill"
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/saibasan/guns_worn.dmi'
	worn_icon_state = "hyeseong_kill"
	cell_type = /obj/item/stock_parts/cell/hyeseong_internal_cell
	modifystate = FALSE
	ammo_type = list(/obj/item/ammo_casing/energy/cybersun_big_kill)
	can_select = FALSE
	ammo_x_offset = 0
	shaded_charge = TRUE
	slot_flags = ITEM_SLOT_BACK
	obj_flags = UNIQUE_RENAME
	SET_BASE_PIXEL(-8, 0)
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	actions_types = list(/datum/action/item_action/toggle_personality)
	fire_sound_volume = 50
	recoil = 0.25 // This isn't enough to mean ANYTHING aside from it jolting your screen the tiniest amount
	/// What datums of weapon modes can we use?
	var/list/weapon_mode_options = list(
		/datum/laser_weapon_mode,
		/datum/laser_weapon_mode/marksman,
		/datum/laser_weapon_mode/disabler_machinegun,
		/datum/laser_weapon_mode/launcher,
		/datum/laser_weapon_mode/shotgun,
	)
	/// Populates with a list of weapon mode names and their respective paths on init
	var/list/weapon_mode_name_to_path = list()
	/// Info for the radial menu for switching weapon mode
	var/list/radial_menu_data = list()
	/// Is the gun currently changing types? Prevents the gun from firing if yes
	var/currently_switching_types = FALSE
	/// How long transitioning takes before you're allowed to pick a weapon type
	var/transition_duration = 1 SECONDS
	/// What the currently selected weapon mode is, for quickly referencing for use in procs and whatnot
	var/datum/laser_weapon_mode/currently_selected_mode
	/// Name of the firing mode that is selected by default
	var/default_selected_mode = "Kill"
	/// Allows firing of the gun to be disabled for any reason, for example, if a gun has a melee mode
	var/disabled_for_other_reasons = FALSE
	/// The json file this gun pulls from when speaking
	var/speech_json_file = LONG_MOD_LASER_SPEECH
	/// Keeps track of the last processed charge, prevents message spam
	var/last_charge = 0
	/// If the gun's personality speech thing is on, defaults to on because just listen to her
	var/personality_mode = TRUE
	/// Keeps track of our soulcatcher component
	var/datum/component/soulcatcher/tracked_soulcatcher
	/// What is this gun's extended examine, we only have to do this because the carbine is a subtype
	var/expanded_examine_text = "The Hyeseong rifle is the first line of man-portable Marsian weapons platforms \
		from Cybersun Industries. Like her younger sister weapon, the Hoshi carbine, CI used funding aid provided \
		by SolFed to develop a portable weapon fueled by a proprietary generator rumored to be fueled by superstable plasma. \
		A rugged and hefty weapon, the Hyeseong stars in applications anywhere from medium to long ranges, though struggling \
		in CQB. Her onboard machine intelligence, at first devised to support the operator and manage the internal reactor, \
		is shipped with a more professional and understated personality-- since influenced by 'negligence' from users in \
		wiping the intelligence's memory before resale or transport."
	/// A cooldown for when the weapon has last spoken, prevents messages from getting turbo spammed
	COOLDOWN_DECLARE(last_speech)

/obj/item/gun/energy/modular_laser_rifle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CYBERSUN)
	chat_color = DEFAULT_RUNECHAT_GUN_COLOR
	chat_color_darkened = process_chat_color(DEFAULT_RUNECHAT_GUN_COLOR, sat_shift = 0.85, lum_shift = 0.85)
	last_charge = cell.charge
	tracked_soulcatcher = AddComponent(/datum/component/soulcatcher/modular_laser)
	create_weapon_mode_stuff()

/obj/item/gun/energy/modular_laser_rifle/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")
	. += span_notice("You can <b>Alt-Click</b> this gun to access the <b>internal soulcatcher</b>.")

/obj/item/gun/energy/modular_laser_rifle/examine_more(mob/user)
	. = ..()
	. += expanded_examine_text
	return .

/obj/item/gun/energy/modular_laser_rifle/Destroy()
	QDEL_NULL(tracked_soulcatcher)
	return ..()

/obj/item/gun/energy/modular_laser_rifle/AltClick(mob/user)
	tracked_soulcatcher?.ui_interact(user)
	return

/// Handles filling out all of the lists regarding weapon modes and radials around that
/obj/item/gun/energy/modular_laser_rifle/proc/create_weapon_mode_stuff()
	if(length(weapon_mode_name_to_path) || length(radial_menu_data))
		return // We don't need to worry about it if there's already stuff here
	for(var/datum/laser_weapon_mode/laser_mode as anything in weapon_mode_options)
		weapon_mode_name_to_path["[initial(laser_mode.name)]"] = new laser_mode()
		var/obj/projectile/mode_projectile = initial(laser_mode.casing.projectile_type)
		radial_menu_data["[initial(laser_mode.name)]"] = image(icon = mode_projectile.icon, icon_state = mode_projectile.icon_state)
	currently_selected_mode = weapon_mode_name_to_path["[default_selected_mode]"]
	transform_gun(currently_selected_mode, FALSE, TRUE)

/obj/item/gun/energy/modular_laser_rifle/attack_self(mob/living/user)
	if(!currently_switching_types)
		change_to_switch_mode(user)
	return ..()

/// Makes the gun inoperable, playing an animation and giving a prompt to switch gun modes after the transition_duration passes
/obj/item/gun/energy/modular_laser_rifle/proc/change_to_switch_mode(mob/living/user)
	currently_switching_types = TRUE
	flick("[base_icon_state]_switch_on", src)
	cut_overlays()
	playsound(src, 'sound/items/modsuit/ballin.ogg', 75, TRUE)
	var/new_icon_state = "[base_icon_state]_switch"
	icon_state = new_icon_state
	inhand_icon_state = new_icon_state
	worn_icon_state = new_icon_state
	addtimer(CALLBACK(src, PROC_REF(show_radial_choice_menu), user), transition_duration)

/// Shows the radial choice menu to the user, if the user doesnt exist or isnt holding the gun anymore, it reverts back to its last form
/obj/item/gun/energy/modular_laser_rifle/proc/show_radial_choice_menu(mob/living/user)
	if(!user?.is_holding(src))
		flick("[base_icon_state]_switch_off", src)
		transform_gun(currently_selected_mode, FALSE)
		playsound(src, 'sound/items/modsuit/ballout.ogg', 75, TRUE)
		return

	var/picked_choice = show_radial_menu(
		user,
		src,
		radial_menu_data,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice) || isnull(weapon_mode_name_to_path["[picked_choice]"]))
		flick("[base_icon_state]_switch_off", src)
		transform_gun(currently_selected_mode, FALSE)
		playsound(src, 'sound/items/modsuit/ballout.ogg', 75, TRUE)
		return

	var/new_weapon_mode = weapon_mode_name_to_path["[picked_choice]"]
	transform_gun(new_weapon_mode, TRUE)

/// Transforms the gun into a different type, if replacing is set to true then it'll make sure to remove any effects the prior gun type had
/obj/item/gun/energy/modular_laser_rifle/proc/transform_gun(datum/laser_weapon_mode/new_weapon_mode, replacing = TRUE, dont_speak = FALSE)
	if(!new_weapon_mode)
		stack_trace("transform_gun was called but didn't get a new weapon mode, meaning it couldn't work.")
		return
	if(replacing)
		currently_selected_mode.remove_from_weapon(src)
	currently_selected_mode = new_weapon_mode
	flick("[base_icon_state]_switch_off", src)
	currently_selected_mode.apply_stats(src)
	currently_selected_mode.apply_to_weapon(src)
	playsound(src, 'sound/items/modsuit/ballout.ogg', 75, TRUE)
	if(!dont_speak)
		speak_up(currently_selected_mode.json_speech_string, TRUE)
	currently_switching_types = FALSE

/obj/item/gun/energy/modular_laser_rifle/can_shoot()
	if(!length(ammo_type))
		return FALSE
	return ..()

/obj/item/gun/energy/modular_laser_rifle/can_trigger_gun(mob/living/user, akimbo_usage)
	. = ..()
	if(currently_switching_types || disabled_for_other_reasons)
		return FALSE

/// Makes the gun speak with a sound effect and colored runetext based on the mode the gun is in, reads the gun's speech json as defined through variables
/obj/item/gun/energy/modular_laser_rifle/proc/speak_up(json_string, ignores_cooldown = FALSE, ignores_personality_toggle = FALSE)
	if(!personality_mode && !ignores_personality_toggle)
		return
	if(!json_string)
		return
	if(!ignores_cooldown && !COOLDOWN_FINISHED(src, last_speech))
		return
	say(pick_list_replacements(speech_json_file, json_string))
	playsound(src, 'sound/creatures/tourist/tourist_talk.ogg', 15, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = rand(2, 2.2))
	Shake(2, 2, 1 SECONDS)
	COOLDOWN_START(src, last_speech, MOD_LASER_SPEECH_COOLDOWN)

/obj/item/gun/energy/modular_laser_rifle/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & (ITEM_SLOT_BELT|ITEM_SLOT_BACK|ITEM_SLOT_SUITSTORE))
		speak_up("worn")
	else if(slot & ITEM_SLOT_HANDS)
		speak_up("pickup")
		return

/obj/item/gun/energy/modular_laser_rifle/dropped(mob/user, silent)
	. = ..()
	if(src in user.contents)
		return // If they're still holding us or have us on them, dw about it
	speak_up("putdown")

/obj/item/gun/energy/modular_laser_rifle/process(seconds_per_tick)
	. = ..()
	var/cell_charge_quarter = cell.maxcharge / 4
	if((cell_charge_quarter > cell.charge) && !(last_charge < cell_charge_quarter))
		speak_up("lowcharge")
	else if((cell.maxcharge == cell.charge) && !(last_charge == cell.maxcharge))
		speak_up("fullcharge")
	last_charge = cell.charge


/obj/item/gun/energy/modular_laser_rifle/ui_action_click(mob/user, actiontype)
	if(!istype(actiontype, /datum/action/item_action/toggle_personality))
		return ..()
	playsound(src, 'sound/machines/beep.ogg', 30, TRUE)
	personality_mode = !personality_mode
	speak_up("[personality_mode ? "pickup" : "putdown"]", ignores_personality_toggle = TRUE)
	return ..()

// Power cell for the big rifle
/obj/item/stock_parts/cell/hyeseong_internal_cell
	name = "\improper Hyeseong modular laser rifle internal cell"
	desc = "These are usually supposed to be inside of the gun, you know."
	maxcharge = 1000 * 2

/datum/action/item_action/toggle_personality
	name = "Toggle Weapon Personality"
	desc = "Toggles the weapon's personality core. Studies find that turning them off makes them quite sad, however."
	background_icon_state = "bg_mod"

/datum/component/soulcatcher/modular_laser
	max_souls = 1
	communicate_as_parent = TRUE

//Short version of the above modular rifle, has less charge and different modes
/obj/item/gun/energy/modular_laser_rifle/carbine
	name = "\improper Hoshi modular laser carbine"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/saibasan/guns32x.dmi'
	icon_state = "hoshi_kill"
	inhand_icon_state = "hoshi_kill"
	worn_icon_state = "hoshi_kill"
	base_icon_state = "hoshi"
	charge_sections = 3
	cell_type = /obj/item/stock_parts/cell
	ammo_type = list(/obj/item/ammo_casing/energy/cybersun_small_hellfire)
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	SET_BASE_PIXEL(0, 0)
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_NORMAL
	weapon_mode_options = list(
		/datum/laser_weapon_mode/hellfire,
		/datum/laser_weapon_mode/sword,
		/datum/laser_weapon_mode/flare,
		/datum/laser_weapon_mode/shotgun_small,
		/datum/laser_weapon_mode/trickshot_disabler,
	)
	default_selected_mode = "Incinerate"
	speech_json_file = SHORT_MOD_LASER_SPEECH
	expanded_examine_text = "The Hoshi carbine is the latest line of man-portable Marsian weapons platforms from \
		Cybersun Industries. Like her older sister weapon, the Hyeseong rifle, CI used funding aid provided by SolFed \
		to develop a portable weapon fueled by a proprietary generator rumored to be fueled by superstable plasma. A \
		lithe and mobile weapon, the Hoshi stars in close-quarters battle, trickshots, and area-of-effect blasts; though \
		ineffective at ranged combat. Her onboard machine intelligence, at first devised to support the operator and \
		manage the internal reactor, was originally shipped with a more energetic personality-- since influenced by 'negligence' \
		from users in wiping the intelligence's memory before resale or transport."

/obj/item/gun/energy/modular_laser_rifle/carbine/emp_act(severity)
	. = ..()
	speak_up("emp", TRUE) // She gets very upset if you emp her

#undef LONG_MOD_LASER_SPEECH
#undef SHORT_MOD_LASER_SPEECH
#undef MOD_LASER_SPEECH_COOLDOWN
#undef DEFAULT_RUNECHAT_GUN_COLOR
