/*
*	LOADOUT ITEM DATUMS FOR THE EYE SLOT
*/

/// Glasses Slot Items (Moves overrided items to backpack)
GLOBAL_LIST_INIT(loadout_glasses, generate_loadout_items(/datum/loadout_item/glasses))

/datum/loadout_item/glasses
	category = LOADOUT_ITEM_GLASSES

/datum/loadout_item/glasses/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.glasses))
		.. ()
		return TRUE

/datum/loadout_item/glasses/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.glasses)
			LAZYADD(outfit.backpack_contents, outfit.glasses)
		outfit.glasses = item_path
	else
		outfit.glasses = item_path

/datum/loadout_item/glasses/post_equip_item(datum/preferences/preference_source, mob/living/carbon/human/equipper)
	var/obj/item/clothing/glasses/equipped_glasses = locate(item_path) in equipper.get_equipped_items()
	if (!equipped_glasses)
		return
	if(equipped_glasses.glass_colour_type)
		equipper.update_glasses_color(equipped_glasses, TRUE)
	if(equipped_glasses.tint)
		equipper.update_tint()
	if(equipped_glasses.vision_flags \
		|| equipped_glasses.invis_override \
		|| equipped_glasses.invis_view \
		|| !isnull(equipped_glasses.color_cutoffs))
		equipper.update_sight()
/*
*	PRESCRIPTION GLASSES
*/

/datum/loadout_item/glasses/prescription_glasses
	name = "Glasses"
	item_path = /obj/item/clothing/glasses/regular
	additional_tooltip_contents = list("PRESCRIPTION - This item functions with the 'nearsighted' quirk.")

/datum/loadout_item/glasses/prescription_glasses/circle_glasses
	name = "Circle Glasses"
	item_path = /obj/item/clothing/glasses/regular/circle

/datum/loadout_item/glasses/prescription_glasses/hipster_glasses
	name = "Hipster Glasses"
	item_path = /obj/item/clothing/glasses/regular/hipster

/datum/loadout_item/glasses/prescription_glasses/jamjar_glasses
	name = "Jamjar Glasses"
	item_path = /obj/item/clothing/glasses/regular/jamjar

/*
*	COSMETIC GLASSES
*/

/datum/loadout_item/glasses/cold_glasses
	name = "Cold Glasses"
	item_path = /obj/item/clothing/glasses/cold

/datum/loadout_item/glasses/heat_glasses
	name = "Heat Glasses"
	item_path = /obj/item/clothing/glasses/heat

/datum/loadout_item/glasses/geist_glasses
	name = "Geist Gazers"
	item_path = /obj/item/clothing/glasses/geist_gazers

/datum/loadout_item/glasses/orange_glasses
	name = "Orange Glasses"
	item_path = /obj/item/clothing/glasses/orange

/datum/loadout_item/glasses/psych_glasses
	name = "Psych Glasses"
	item_path = /obj/item/clothing/glasses/psych

/datum/loadout_item/glasses/red_glasses
	name = "Red Glasses"
	item_path = /obj/item/clothing/glasses/red

/*
*	MISC
*/

/datum/loadout_item/glasses/eyepatch
	name = "Eyepatch"
	item_path = /obj/item/clothing/glasses/

/datum/loadout_item/glasses/eyepatch_medical
	name = "Medical Eyepatch"
	item_path = /obj/item/clothing/glasses/eyepatch/medical

/datum/loadout_item/glasses/blindfold
	name = "Blindfold"
	item_path = /obj/item/clothing/glasses/blindfold

/datum/loadout_item/glasses/fakeblindfold
	name = "Fake Blindfold"
	item_path = /obj/item/clothing/glasses/trickblindfold

/datum/loadout_item/glasses/monocle
	name = "Monocle"
	item_path = /obj/item/clothing/glasses/monocle

/*
*	JOB-LOCKED
*/

/datum/loadout_item/glasses/sechud
	name = "Security HUD"
	item_path = /obj/item/clothing/glasses/hud/security
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_WARDEN, JOB_HEAD_OF_SECURITY)

/*
*	FAMILIES
*/

/datum/loadout_item/glasses/osi
	name = "OSI Glasses"
	item_path = /obj/item/clothing/glasses/osi

/datum/loadout_item/glasses/phantom
	name = "Phantom Glasses"
	item_path = /obj/item/clothing/glasses/phantom

/*
*	DONATOR
*/

/datum/loadout_item/glasses/donator
	donator_only = TRUE
	requires_purchase = FALSE
