#define MOOD_CATEGORY_PHOTOPHOBIA "photophobia"

/datum/quirk/photophobia
	name = "Photophobia"
	desc = "Bright lights seem to bother you more than others. Maybe it's a medical condition."
	icon = FA_ICON_ARROWS_TO_EYE
	value = -4
	gain_text = span_danger("The safety of light feels off...")
	lose_text = span_notice("Enlightening.")
	medical_record_text = "Patient has acute phobia of light, and insists it is physically harmful."
	hardcore_value = 4
	mail_goodies = list(
		/obj/item/flashlight/flashdark,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom,
		/obj/item/skillchip/light_remover,
	)

/datum/quirk/photophobia/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(check_eyes))
	RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(restore_eyes))
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	update_eyes(quirk_holder.get_organ_slot(ORGAN_SLOT_EYES))

/datum/quirk/photophobia/remove()
	UnregisterSignal(quirk_holder, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_MOVABLE_MOVED,))
	quirk_holder.clear_mood_event(MOOD_CATEGORY_PHOTOPHOBIA)
	var/obj/item/organ/eyes/normal_eyes = quirk_holder.get_organ_slot(ORGAN_SLOT_EYES)
	if(istype(normal_eyes))
		normal_eyes.flash_protect = initial(normal_eyes.flash_protect)

/datum/quirk/photophobia/proc/check_eyes(datum/source, obj/item/organ/eyes/sensitive_eyes)
	SIGNAL_HANDLER
	if(!istype(sensitive_eyes))
		return
	update_eyes(sensitive_eyes)

/datum/quirk/photophobia/proc/update_eyes(obj/item/organ/eyes/target_eyes)
	if(!istype(target_eyes))
		return
	target_eyes.flash_protect = max(target_eyes.flash_protect - 1, FLASH_PROTECTION_HYPER_SENSITIVE)

/datum/quirk/photophobia/proc/restore_eyes(datum/source, obj/item/organ/eyes/normal_eyes)
	SIGNAL_HANDLER
	if(!istype(normal_eyes))
		return
	normal_eyes.flash_protect = initial(normal_eyes.flash_protect)

/datum/quirk/photophobia/proc/on_holder_moved(mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(quirk_holder.stat != CONSCIOUS || quirk_holder.IsSleeping() || quirk_holder.IsUnconscious())
		return

	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return

	var/mob/living/carbon/human/human_holder = quirk_holder

	if(human_holder.sight & SEE_TURFS)
		return

	var/turf/holder_turf = get_turf(quirk_holder)

	var/lums = holder_turf.get_lumcount()

	var/eye_protection = quirk_holder.get_eye_protection()
	if(lums < LIGHTING_TILE_IS_DARK || eye_protection >= FLASH_PROTECTION_NONE)
		quirk_holder.clear_mood_event(MOOD_CATEGORY_PHOTOPHOBIA)
		return
	quirk_holder.add_mood_event(MOOD_CATEGORY_PHOTOPHOBIA, /datum/mood_event/photophobia)

	#undef MOOD_CATEGORY_PHOTOPHOBIA
