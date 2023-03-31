/datum/species/ipc
	name = "IPC"
	id = SPECIES_IPC
	species_traits = list(
		AGENDER,
		NO_DNA_COPY,
		NOTRANSSTING,
		NO_UNDERWEAR,
	)
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_NOBLOOD,
	)
	bodypart_overrides = list(
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/robot/surplus,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/robot/surplus,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot/surplus,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot/surplus,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	mutantheart = /obj/item/organ/internal/lungs/cybernetic/tier2
	mutantliver = /obj/item/organ/internal/liver/cybernetic/tier2
	mutantears = /obj/item/organ/internal/ears/cybernetic
	mutanttongue = /obj/item/organ/internal/tongue/robot
	mutanteyes = /obj/item/organ/internal/eyes/robotic
	mutantstomach = /obj/item/organ/internal/stomach/ethereal
	siemens_coeff = 0.5
	payday_modifier = 0 // They're robots you don't need to pay them
	sexes = FALSE
	liked_food = NONE
	disliked_food = NONE
	toxic_food = NONE
	/// Our special head
	var/obj/item/clothing/head/costume/tv_head/head

/datum/species/ipc/on_species_gain(mob/living/carbon/new_ipc, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(new_ipc))
		return
	var/obj/item/clothing/head/current_hat = new_ipc.get_item_by_slot(ITEM_SLOT_HEAD)
	if (current_hat)
		new_ipc.dropItemToGround(current_hat, force = TRUE)
	head = new()
	new_ipc.equip_to_slot(head, ITEM_SLOT_HEAD)
	RegisterSignal(new_ipc, COMSIG_CARBON_UNEQUIP_HAT, PROC_REF(behead))

/// Oops, you took your head off
/datum/species/ipc/proc/behead(mob/living/carbon/user, obj/item/clothing)
	SIGNAL_HANDLER
	if (!istype(clothing, /obj/item/clothing/head/costume/tv_head))
		return
	var/obj/item/bodypart/head/head = user.get_bodypart(BODY_ZONE_HEAD)
	if (!head)
		return
	head.dismember()

/datum/species/ipc/on_species_loss(mob/living/carbon/human/former_ipc, datum/species/new_species, pref_load)
	UnregisterSignal(former_ipc, COMSIG_CARBON_UNEQUIP_HAT)
	former_ipc.dropItemToGround(head, force = TRUE)
	head = null
	return ..()

/datum/species/ipc/get_species_description()
	return "Developed by a now-bankrupt corporation to compete with Nanotrasen cyborgs, \
		IPCs provide budget synthetic labour and companionship across the system."

/datum/species/ipc/get_species_lore()
	return list(
		"Due to the legal assistance of Nanotrasen in bankrupting their original creating corporation \
		IPCs are commonplace across NT installations, though some newer models are starting to wonder \
		if the older generation has sold out to a different set of corporate overlords.",
	)

/datum/species/ipc/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shockingly Tasty",
			SPECIES_PERK_DESC = "IPCs can feed on electricity from APCs, and do not otherwise need to eat.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Mechanical",
			SPECIES_PERK_DESC = "IPCs have powerful machine bodies and organs, making them durable and easy to repair.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "gem",
			SPECIES_PERK_NAME = "TV Head",
			SPECIES_PERK_DESC = "IPCs have TVs for heads. Like anyone else, they hate it when their head is removed.",
		),
	)

	return to_add
