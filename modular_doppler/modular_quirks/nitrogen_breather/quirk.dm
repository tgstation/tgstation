/datum/quirk/equipping/lungs
	abstract_parent_type = /datum/quirk/equipping/lungs
	icon = FA_ICON_LUNGS
	var/obj/item/organ/internal/lungs/lungs_holding
	var/obj/item/organ/internal/lungs/lungs_added
	var/lungs_typepath = /obj/item/organ/internal/lungs
	items = list(/obj/item/clothing/accessory/breathing = list(ITEM_SLOT_BACKPACK))
	var/breath_type = "oxygen"

/datum/quirk/equipping/lungs/add(client/client_source)
	var/mob/living/carbon/human/carbon_holder = quirk_holder
	if (!istype(carbon_holder) || !lungs_typepath)
		return
	var/current_lungs = carbon_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (istype(current_lungs, lungs_typepath))
		return
	lungs_holding = current_lungs
	if(!isnull(lungs_holding))
		lungs_holding.organ_flags |= ORGAN_FROZEN // stop decay on the old lungs
	lungs_added = new lungs_typepath
	lungs_added.Insert(carbon_holder, special = TRUE)
	if(!isnull(lungs_holding))
		lungs_holding.moveToNullspace() // save them for later

/datum/quirk/equipping/lungs/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if (!istype(carbon_holder) || !istype(lungs_holding))
		return
	var/obj/item/organ/internal/lungs/lungs = carbon_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (lungs != lungs_added && lungs != lungs_holding)
		qdel(lungs_holding)
		return
	lungs_holding.Insert(carbon_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	lungs_holding.organ_flags &= ~ORGAN_FROZEN

/datum/quirk/equipping/lungs/on_equip_item(obj/item/equipped, success)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if (!istype(equipped, /obj/item/clothing/accessory/breathing))
		return
	var/obj/item/clothing/accessory/breathing/acc = equipped
	acc.breath_type = breath_type

	var/obj/item/clothing/under/attach_to = human_holder?.w_uniform
	if (attach_to && acc.can_attach_accessory(attach_to, human_holder))
		acc.attach(human_holder.w_uniform, human_holder)

/obj/item/clothing/accessory/breathing
	name = "breathing dogtag"
	desc = "Dogtag that lists what you breathe."
	icon_state = "allergy"
	above_suit = FALSE
	minimize_when_attached = TRUE
	attachment_slot = CHEST
	var/breath_type

/obj/item/clothing/accessory/breathing/examine(mob/user)
	. = ..()
	. += "The dogtag reads: I breathe [breath_type]."

/obj/item/clothing/accessory/breathing/accessory_equipped(obj/item/clothing/under/uniform, user)
	. = ..()
	RegisterSignal(uniform, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/obj/item/clothing/accessory/breathing/accessory_dropped(obj/item/clothing/under/uniform, user)
	. = ..()
	UnregisterSignal(uniform, COMSIG_ATOM_EXAMINE)

/obj/item/clothing/accessory/breathing/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "The dogtag reads: I breathe [breath_type]."

/datum/quirk/equipping/lungs/nitrogen
	name = "Nitrogen Breather"
	desc = "You breathe nitrogen, even if you might not normally breathe it. Oxygen is poisonous."
	icon = FA_ICON_LUNGS_VIRUS
	medical_record_text = "Patient can only breathe nitrogen."
	gain_text = "<span class='danger'>You suddenly have a hard time breathing anything but nitrogen."
	lose_text = "<span class='notice'>You suddenly feel like you aren't bound to nitrogen anymore."
	value = 0
	forced_items = list(
		/obj/item/clothing/mask/breath = list(ITEM_SLOT_MASK),
		/obj/item/tank/internals/nitrogen/belt/full = list(ITEM_SLOT_HANDS, ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET))
	lungs_typepath = /obj/item/organ/internal/lungs/nitrogen
	breath_type = "nitrogen"

/datum/quirk/equipping/lungs/nitrogen/on_equip_item(obj/item/equipped, success)
	. = ..()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if (!success || !istype(carbon_holder) || !istype(equipped, /obj/item/tank/internals))
		return
	carbon_holder.internal = equipped
