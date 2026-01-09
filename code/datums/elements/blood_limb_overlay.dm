/// An element which adds a blood overlay to limbs its attached to
/datum/element/blood_limb_overlay

/datum/element/blood_limb_overlay/Attach(datum/target)
	. = ..()
	if (!isbodypart(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_BODYPART_GET_LIMB_ICON, PROC_REF(on_limb_icon))
	RegisterSignal(target, COMSIG_BODYPART_GENERATE_ICON_KEY, PROC_REF(on_icon_key))

/datum/element/blood_limb_overlay/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_BODYPART_GET_LIMB_ICON, COMSIG_BODYPART_GENERATE_ICON_KEY))

/datum/element/blood_limb_overlay/proc/on_limb_icon(obj/item/bodypart/source, list/limb_icons, dropped, mob/living/carbon/update_on)
	SIGNAL_HANDLER

	if (!LAZYLEN(source.blood_dna_info) || source.is_invisible)
		return

	var/image/limb = limb_icons[1]
	var/image/blood_visual = image(limb.icon, "[limb.icon_state]_blood", dir = (dropped ? SOUTH : null))
	// We need to convert it to HSV and then adjust the colors to make them look brighter on the grayscale blood overlay
	var/list/target_color = rgb2num(get_color_from_blood_list(source.blood_dna_info), COLORSPACE_HSV)
	blood_visual.color = rgb(target_color[1], ceil(target_color[2] * 0.4), clamp(ceil(target_color[3] * 1.33), 0, 100), space = COLORSPACE_HSV)
	limb.overlays += blood_visual
	if (!source.aux_zone)
		return

	var/image/aux = limb_icons[2]
	var/image/aux_blood_visual = image(aux.icon, "[aux.icon_state]_blood", dir = (dropped ? SOUTH : null))
	aux_blood_visual.color = blood_visual.color
	aux.overlays += aux_blood_visual

/datum/element/blood_limb_overlay/proc/on_icon_key(obj/item/bodypart/source, list/icon_keys)
	SIGNAL_HANDLER

	if (LAZYLEN(source.blood_dna_info) && !source.is_invisible)
		icon_keys += "-blood-[get_color_from_blood_list(source.blood_dna_info)]"
