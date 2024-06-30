// Sidepaths for knowledge between Rust and Blade.
/datum/heretic_knowledge/armor
	name = "Armorer's Ritual"
	desc = "Allows you to transmute a table and a gas mask to create Eldritch Armor. \
		Eldritch Armor provides great protection while also acting as a focus when hooded."
	gain_text = "The Rusted Hills welcomed the Blacksmith in their generosity. And the Blacksmith \
		returned their generosity in kind."
	next_knowledge = list(
		/datum/heretic_knowledge/rust_regen,
		/datum/heretic_knowledge/blade_dance,
	)
	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask/gas = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/crucible
	name = "Mawed Crucible"
	desc = "Allows you to transmute a portable water tank and a table to create a Mawed Crucible. \
		The Mawed Crucible can brew powerful potions for combat and utility, but must be fed bodyparts and organs between uses."
	gain_text = "This is pure agony. I wasn't able to summon the figure of the Aristocrat, \
		but with the Priest's attention I stumbled upon a different recipe..."
	next_knowledge = list(
		/datum/heretic_knowledge/duel_stance,
		/datum/heretic_knowledge/spell/area_conversion,
	)
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/rifle
	name = "Lionhunter's Rifle"
	desc = "Allows you to transmute any ballistic weapon, such as a pipegun, with hide \
		from any animal, a plank of wood, and a camera to create the Lionhunter's rifle. \
		The Lionhunter's Rifle is a long ranged ballistic weapon with three shots. \
		These shots function as normal, albeit weak high caliber mutitions when fired from \
		close range or at inanimate objects. You can aim the rifle at distant foes, \
		causing the shot to deal massively increased damage and hone in on them."
	gain_text = "I met an old man in an antique shop who wielded a very unusual weapon. \
		I could not purchase it at the time, but they showed me how they made it ages ago."
	next_knowledge = list(
		/datum/heretic_knowledge/duel_stance,
		/datum/heretic_knowledge/spell/area_conversion,
		/datum/heretic_knowledge/rifle_ammo,
	)
	required_atoms = list(
		/obj/item/gun/ballistic = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/ballistic/rifle/lionhunter)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/rifle_ammo
	name = "Lionhunter Rifle Ammunition (free)"
	desc = "Allows you to transmute 3 ballistic ammo casings (used or unused) of any caliber, \
		including shotgun shot, with any animal hide to create an extra clip of ammunition for the Lionhunter Rifle."
	gain_text = "The weapon came with three rough iron balls, intended to be used as ammunition. \
		They were very effective, for simple iron, but used up quickly. I soon ran out. \
		No replacement munitions worked in their stead. It was peculiar in what it wanted."
	required_atoms = list(
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/ammo_casing = 3,
	)
	result_atoms = list(/obj/item/ammo_box/strilka310/lionhunter)
	cost = 0
	route = PATH_SIDE
	/// A list of calibers that the ritual will deny. Only ballistic calibers are allowed.
	var/static/list/caliber_blacklist = list(
		CALIBER_LASER,
		CALIBER_ENERGY,
		CALIBER_FOAM,
		CALIBER_ARROW,
		CALIBER_HARPOON,
		CALIBER_HOOK,
	)

/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/item/ammo_casing/casing in atoms)
		if(!(casing.caliber in caliber_blacklist))
			continue

		// Remove any casings in the caliber_blacklist list from atoms
		atoms -= casing

	// We removed any invalid casings from the atoms list,
	// return to allow the ritual to fill out selected atoms with the new list
	return TRUE

/datum/heretic_knowledge/spell/rust_charge
	name = "Rust Charge"
	desc = "A charge that must be started on a rusted tile and will destroy any rusted objects you come into contact with, will deal high damage to others and rust around you during the charge."
	gain_text = "The hills sparkled now, as I neared them my mind began to wander. I quickly regained my resolve and pushed forward, this last leg would be the most treacherous."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/furious_steel,
		/datum/heretic_knowledge/spell/entropic_plume,
	)
	spell_to_add = /datum/action/cooldown/mob_cooldown/charge/rust
	cost = 1
	route = PATH_SIDE
