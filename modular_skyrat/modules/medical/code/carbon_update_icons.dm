/mob/living/carbon/proc/update_bandage_overlays()
	remove_overlay(BANDAGE_LAYER)

	var/mutable_appearance/overlays = mutable_appearance('modular_skyrat/modules/medical/icons/on_limb_overlays.dmi', "", -BANDAGE_LAYER)
	overlays_standing[BANDAGE_LAYER] = overlays

	for(var/b in bodyparts)
		var/obj/item/bodypart/BP = b
		if(BP.current_gauze && BP.current_gauze.overlay_prefix)
			var/bp_suffix = BP.body_zone
			if(BP.use_digitigrade)
				bp_suffix += "_digitigrade"
			overlays.add_overlay("[BP.current_gauze.overlay_prefix]_[bp_suffix]")
		if(BP.current_splint && BP.current_splint.overlay_prefix)
			var/bp_suffix = BP.body_zone
			if(BP.use_digitigrade)
				bp_suffix += "_digitigrade"
			overlays.add_overlay("[BP.current_splint.overlay_prefix]_[bp_suffix]")

	apply_overlay(BANDAGE_LAYER)
