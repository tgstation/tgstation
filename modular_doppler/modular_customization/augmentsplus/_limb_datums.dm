/// An assoc list of [limb typepath] to [singleton limb datum]s used in the limb manager
GLOBAL_LIST_INIT(limb_loadout_options, init_loadout_limb_options())

/// Inits the limb manager global list
/proc/init_loadout_limb_options()
	var/list/created = list()
	for(var/datum/limb_option_datum/to_create as anything in typesof(/datum/limb_option_datum))
		var/obj/item/limb_path = initial(to_create.limb_path)
		if(isnull(limb_path))
			continue

		created[limb_path] = new to_create()

	return created

/**
 * Used as holders for paths to be used in the limb editor menu
 *
 * Similar to loadout datums but, for limbs and organs that one can start roundstart with
 *
 * I could've just tied this into loadout datums (they're pretty much the same thing)
 * but I would rather keep the typepaths separate for ease of use
 */
/datum/limb_option_datum
	/// Name shown up in UI
	var/name
	/// Used in UI tooltips
	var/desc
	/// The actual item that is created and equipped to the player
	var/obj/item/limb_path
	/// Determines what body zone this is slotted into in the UI
	/// Uses the following limb body zones:
	/// [BODY_ZONE_HEAD], [BODY_ZONE_CHEST], [BODY_ZONE_R_ARM], [BODY_ZONE_L_ARM], [BODY_ZONE_R_LEG], [BODY_ZONE_L_LEG]
	var/ui_zone
	/// Determines what key the path of this is slotted into in the assoc list of preferences
	/// A bodypart might use their body zone while an organ may use their organ slot
	/// This essently determines what other datums this datum is incompatible with
	var/pref_list_slot

/datum/limb_option_datum/New()
	. = ..()
	if(isnull(name))
		name = capitalize(initial(limb_path.name))
	if(isnull(desc))
		desc = initial(limb_path.desc)

/// Applies the datum to the mob.
/datum/limb_option_datum/proc/apply_limb(mob/living/carbon/human/apply_to)
	return

/datum/limb_option_datum/bodypart

/datum/limb_option_datum/bodypart/New()
	. = ..()
	var/obj/item/bodypart/part_path = limb_path
	if(isnull(ui_zone))
		ui_zone = initial(part_path.body_zone)
	if(isnull(pref_list_slot))
		pref_list_slot = initial(part_path.body_zone)

/datum/limb_option_datum/bodypart/apply_limb(mob/living/carbon/human/apply_to)
	apply_to.del_and_replace_bodypart(new limb_path(), special = TRUE)

/datum/limb_option_datum/bodypart/prosthetic_r_leg
	name = "Prosthetic Right Leg"
	limb_path = /obj/item/bodypart/leg/right/robot/surplus

/datum/limb_option_datum/bodypart/prosthetic_l_leg
	name = "Prosthetic Left Leg"
	limb_path = /obj/item/bodypart/leg/left/robot/surplus

/datum/limb_option_datum/bodypart/prosthetic_r_arm
	name = "Prosthetic Right Arm"
	limb_path = /obj/item/bodypart/arm/right/robot/surplus

/datum/limb_option_datum/bodypart/prosthetic_l_arm
	name = "Prosthetic Left Arm"
	limb_path = /obj/item/bodypart/arm/left/robot/surplus

/datum/limb_option_datum/organ

/datum/limb_option_datum/organ/New()
	. = ..()
	var/obj/item/organ/organ_path = limb_path
	if(isnull(ui_zone))
		ui_zone = deprecise_zone(initial(organ_path.zone))
	if(isnull(pref_list_slot))
		pref_list_slot = initial(organ_path.slot)

/datum/limb_option_datum/organ/apply_limb(mob/living/carbon/human/apply_to)
	if(istype(apply_to, /mob/living/carbon/human/dummy)) // thog don't caare
		return

	var/obj/item/organ/internal/new_organ = new limb_path()
	new_organ.Insert(apply_to, special = TRUE, drop_if_replaced = FALSE)

/datum/limb_option_datum/organ/cyberheart
	name = "Cybernetic Heart"
	limb_path = /obj/item/organ/internal/heart/cybernetic

/datum/limb_option_datum/organ/cyberliver
	name = "Cybernetic Liver"
	limb_path = /obj/item/organ/internal/liver/cybernetic

/datum/limb_option_datum/organ/cyberlungs
	name = "Cybernetic Lungs"
	limb_path = /obj/item/organ/internal/lungs/cybernetic

/datum/limb_option_datum/organ/cyberstomach
	name = "Cybernetic Stomach"
	limb_path = /obj/item/organ/internal/stomach/cybernetic

/datum/limb_option_datum/organ/eyes
	name = "Cybernetic Eyes"
	limb_path = /obj/item/organ/internal/eyes/robotic/basic

/datum/limb_option_datum/organ/ears
	name = "Cybernetic Ears"
	limb_path = /obj/item/organ/internal/ears/cybernetic

/datum/limb_option_datum/organ/robotongue
	name = "Voicebox"
	desc = "A voice synthesizer that is designed to replace a tongue. Makes you sound like a robot."
	limb_path = /obj/item/organ/internal/tongue/robot

/datum/limb_option_datum/organ/lighter_implant
	name = "Lighter Implant"
	desc = "A lighter that is implanted into the tip of your finger. Light it with a snap... like a badass."
	limb_path = /obj/item/organ/internal/cyberimp/arm/lighter
	ui_zone = BODY_ZONE_R_ARM
	pref_list_slot = ORGAN_SLOT_RIGHT_ARM_AUG

/datum/limb_option_datum/organ/lighter_implant/left
	limb_path = /obj/item/organ/internal/cyberimp/arm/lighter/left
	ui_zone = BODY_ZONE_L_ARM
	pref_list_slot = ORGAN_SLOT_LEFT_ARM_AUG
	// Yeah you can have one in both arms if you want, don't really care
