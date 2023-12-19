// this file is for parrots that aren't poly

/// Parrot that will just randomly spawn with a headset. Nothing too special beyond that.
/mob/living/basic/parrot/headsetted

/mob/living/basic/parrot/headsetted/setup_headset()
	var/headset = pick(
		/obj/item/radio/headset/headset_cargo,
		/obj/item/radio/headset/headset_eng,
		/obj/item/radio/headset/headset_med,
		/obj/item/radio/headset/headset_sci,
		/obj/item/radio/headset/headset_sec,
	)
	ears = new headset(src)
