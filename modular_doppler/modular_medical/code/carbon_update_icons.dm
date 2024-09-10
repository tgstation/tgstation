/mob/living/carbon/proc/update_bandage_overlays()
	remove_overlay(BANDAGE_LAYER)

	var/mutable_appearance/overlays = mutable_appearance('modular_doppler/modular_medical/icons/on_limb_overlays.dmi', "", -BANDAGE_LAYER)
	overlays_standing[BANDAGE_LAYER] = overlays

	for(var/b in bodyparts)
		var/obj/item/bodypart/BP = b
		var/obj/item/stack/medical/gauze/our_gauze = BP.current_gauze
		if (!our_gauze)
			continue
		overlays.add_overlay(our_gauze.get_overlay_prefix())

	apply_overlay(BANDAGE_LAYER)
