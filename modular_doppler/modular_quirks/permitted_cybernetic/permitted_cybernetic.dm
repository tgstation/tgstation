GLOBAL_LIST_INIT(possible_quirk_implants, list(
	"Engineering Toolset" = /obj/item/organ/cyberimp/arm/toolset,
	"Surgery Toolset" = /obj/item/organ/cyberimp/arm/surgery,
	"Hydroponics Toolset" = /obj/item/organ/cyberimp/arm/botany,
	"Sanitation Toolset" = /obj/item/organ/cyberimp/arm/janitor,
	"Razorclaw Arm" = /obj/item/organ/cyberimp/arm/razor_claws,
	"Excavator Arm" = /obj/item/organ/cyberimp/arm/mining_drill,
	"Nutriment Pump Implant" = /obj/item/organ/cyberimp/chest/nutriment,
	"Flash Shielded Eyes" = /obj/item/organ/eyes/robotic/shield,
))

/datum/quirk/permitted_cybernetic
	name = "Permitted Cybernetic"
	desc = "You're allowed a cybernetic implant aboard the station, though this is information is available for security."
	value = 8
	mob_trait = TRAIT_PERMITTED_CYBERNETIC
	icon = FA_ICON_WRENCH

/datum/quirk_constant_data/implanted
	associated_typepath = /datum/quirk/permitted_cybernetic
	customization_options = list(/datum/preference/choiced/permitted_cybernetic)

/datum/quirk/permitted_cybernetic/add_unique(client/client_source)
	var/obj/item/organ/desired_implant = GLOB.possible_quirk_implants[client_source?.prefs?.read_preference(/datum/preference/choiced/permitted_cybernetic)]
	if(isnull(desired_implant))  //Client gone or they chose a random implant
		desired_implant = GLOB.possible_quirk_implants[pick(GLOB.possible_quirk_implants)]

	var/mob/living/carbon/human/human_holder = quirk_holder
	if(desired_implant.zone in GLOB.arm_zones)
		if(HAS_TRAIT(human_holder, TRAIT_LEFT_HANDED)) //Left handed person? Give them a leftie implant
			desired_implant = text2path("[desired_implant]/l")

	if(human_holder.dna.species.type in GLOB.species_blacklist_no_humanoid)
		to_chat(human_holder, span_warning("Due to your species type, the [name] quirk has been disabled."))
		return
	if(human_holder.mind?.assigned_role.title == JOB_PRISONER)
		to_chat(human_holder, span_warning("Due to your job, the [name] quirk has been disabled."))
		return

	var/obj/item/organ/cybernetic = new desired_implant()
	cybernetic.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	medical_record_text = "Patient has a company approved [cybernetic.name] installed within their body."

/datum/quirk/permitted_cybernetic/add(client/client_source)
	. = ..()
	quirk_holder.update_implanted_hud()

/datum/quirk/permitted_cybernetic/remove()
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

	var/datum/universal_icon/temporary_icon = uni_icon(icon, icon_state, dir)
	quirk_holder.pixel_y = temporary_icon.scale(32, -world.icon_size)

	if(ishuman(src))
		var/mob/living/carbon/human/target = src
		if(target.dna.species.type in GLOB.species_blacklist_no_humanoid)
			return
	if(HAS_TRAIT(src, TRAIT_PERMITTED_CYBERNETIC))
		set_hud_image_active(SEC_IMPLANT_HUD)
		quirk_holder.icon = 'modular_doppler/overwrites/huds/hud.dmi'
		quirk_holder.icon_state = "hud_imp_quirk"
	else
		set_hud_image_inactive(SEC_IMPLANT_HUD)
