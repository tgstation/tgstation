GLOBAL_LIST_INIT(possible_quirk_implants, list(
	"Toolset" = /obj/item/organ/internal/cyberimp/arm/toolset,
))

/datum/quirk/implanted_quirk
	name = "Implanted"
	desc = "test"
	value = 8
	mob_trait = TRAIT_IMPLANTED
	gain_text = span_notice("test")
	lose_text = span_danger("test")
	icon = FA_ICON_WRENCH

/datum/quirk_constant_data/implanted
	associated_typepath = /datum/quirk/implanted_quirk
	customization_options = list(/datum/preference/choiced/implanted_quirk)

/datum/quirk/implanted_quirk/add_unique(client/client_source)
	var/desired_implant = GLOB.possible_quirk_implants[client_source?.prefs?.read_preference(/datum/preference/choiced/implanted_quirk)]
	if(isnull(desired_implant) || desired_implant == "Random")  //Client gone or they chose a random prosthetic
		desired_implant = GLOB.possible_quirk_implants[pick(GLOB.possible_quirk_implants)]
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/internal/cybernetic = new desired_implant()
	cybernetic.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	medical_record_text = "Patient has an approved [cybernetic.name] installed within their body."

/datum/quirk/implanted_quirk/add(client/client_source)
	. = ..()
	quirk_holder.update_implanted_hud()

/datum/quirk/implanted_quirk/remove()
	var/mob/living/old_holder = quirk_holder
	. = ..()
	old_holder.update_implanted_hud()

/mob/living/prepare_data_huds()
	. = ..()
	update_implanted_hud()

/// Adds the HUD element if src has its trait. Removes it otherwise.
/mob/living/proc/update_implanted_hud()
	var/image/quirk_holder = hud_list?[SEC_IMPLANT_HUD]
	if(isnull(quirk_holder))
		return

	var/icon/temporary_icon = icon(icon, icon_state, dir)
	quirk_holder.pixel_y = temporary_icon.Height() - world.icon_size

	if(HAS_TRAIT(src, TRAIT_IMPLANTED))
		set_hud_image_active(SEC_IMPLANT_HUD)
		quirk_holder.icon = 'modular_doppler/overwrites/huds/hud.dmi'
		quirk_holder.icon_state = "hud_imp_quirk"
	else
		set_hud_image_inactive(SEC_IMPLANT_HUD)
