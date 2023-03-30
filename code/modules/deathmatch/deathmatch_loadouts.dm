/datum/deathmatch_loadout
	var/name = "Loadout"
	var/desc = ":KILL:"
	var/list/equipment
	// Just in case, make sure this doesn't have an ID.
	var/datum/outfit/outfit
	var/datum/species/default_species
	var/force_default = FALSE
	var/list/datum/species/blacklist = list(/datum/species/plasmaman)

/datum/deathmatch_loadout/proc/pre_equip(mob/living/carbon/human/player)
	return

/datum/deathmatch_loadout/proc/equip(mob/living/carbon/human/player)
	SHOULD_CALL_PARENT(TRUE)
	pre_equip(player)
	if (default_species && (force_default || (player.dna.species.type in blacklist)))
		player.set_species(default_species)
	if (outfit)
		player.equipOutfit(outfit, TRUE)
	for (var/E in equipment)
		var/S = equipment[E]
		if (ispath(E))
			player.equip_to_slot(new E, S, TRUE)
			continue
		for (var/P in E)
			var/count = E[P] ? E[P] : 1
			for (var/I in 1 to count)
				player.equip_to_slot(new P, S, TRUE)
	post_equip(player)

// For stuff you might want to do with the items after equiping.
/datum/deathmatch_loadout/proc/post_equip(mob/living/carbon/human/player)
	return

/datum/deathmatch_loadout/assistant
	name = "Assistant loadout"
	desc = "A simple assistant loadout: greyshirt and a toolbox"
	default_species = /datum/species/human
	equipment = list(
		/obj/item/storage/toolbox/mechanical/old/empty = ITEM_SLOT_HANDS
	)

/datum/deathmatch_loadout/assistant/pre_equip(mob/living/carbon/human/player)
	player.equip_to_slot(new /obj/item/clothing/under/color/grey, ITEM_SLOT_ICLOTHING)
	player.equip_to_slot(new /obj/item/clothing/shoes/sneakers/black, ITEM_SLOT_FEET)
	player.equip_to_slot(new /obj/item/storage/backpack, ITEM_SLOT_BACK)
	player.equip_to_slot(new /obj/item/storage/box/survival, ITEM_SLOT_BACKPACK)
	player.equip_to_slot(new /obj/item/pda, ITEM_SLOT_ID) // For the lamp.

/datum/deathmatch_loadout/assistant/weaponless
	name = "Assistant loadout (Weaponless)"
	desc = "What is an assistant without a toolbox? nothing"
	equipment = list()

/datum/deathmatch_loadout/operative
	name = "Operative"
	desc = "A syndicate operative."
	default_species = /datum/species/human

/datum/deathmatch_loadout/operative/pre_equip(mob/living/carbon/human/player)
	player.equip_to_slot(new /obj/item/clothing/under/syndicate, ITEM_SLOT_ICLOTHING)
	player.equip_to_slot(new /obj/item/clothing/gloves/tackler/combat/insulated, ITEM_SLOT_GLOVES)
	player.equip_to_slot(new /obj/item/clothing/shoes/combat, ITEM_SLOT_FEET)
	player.equip_to_slot(new /obj/item/storage/backpack, ITEM_SLOT_BACK)
	player.equip_to_slot(new /obj/item/card/id/chameleon, ITEM_SLOT_ID)

/datum/deathmatch_loadout/operative/ranged
	name = "Ranged Operative"
	desc = "A syndicate operative with a gun and a knife."
	default_species = /datum/species/human
	equipment = list(
		/obj/item/gun/ballistic/automatic/pistol = ITEM_SLOT_HANDS,
		list(/obj/item/ammo_box/magazine/m9mm = 5) = ITEM_SLOT_BACKPACK,
		/obj/item/kitchen/knife/combat = ITEM_SLOT_LPOCKET
	)

/datum/deathmatch_loadout/operative/ranged/pre_equip(mob/living/carbon/human/player)
	player.equip_to_slot(new /obj/item/clothing/gloves/combat, ITEM_SLOT_GLOVES)
	. = ..()

/datum/deathmatch_loadout/operative/melee
	name = "Melee Operative"
	desc = "A syndicate operative with multiple knives."
	default_species = /datum/species/human
	equipment = list(
		/obj/item/clothing/suit/armor/vest = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/head/helmet = ITEM_SLOT_HEAD,
		list(/obj/item/kitchen/knife/combat = 6) = ITEM_SLOT_BACKPACK,
		/obj/item/kitchen/knife/combat = ITEM_SLOT_HANDS,
		/obj/item/kitchen/knife/combat = ITEM_SLOT_LPOCKET
	)

/datum/deathmatch_loadout/securing_sec
	name = "Security Officer"
	desc = "A security officer."
	default_species = /datum/species/human
	outfit = /datum/outfit/job/security
	equipment = list(
		/obj/item/gun/energy/disabler = ITEM_SLOT_HANDS,
		/obj/item/flashlight/seclite = ITEM_SLOT_LPOCKET,
		/obj/item/kitchen/knife/combat/survival = ITEM_SLOT_RPOCKET
	)

/datum/deathmatch_loadout/instagib
	name = "Instagib"
	desc = "Assistant with an instakill rifle."
	default_species = /datum/species/human
	equipment = list(
		/obj/item/gun/energy/laser/instakill = ITEM_SLOT_HANDS
	)
