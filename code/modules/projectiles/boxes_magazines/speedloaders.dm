/obj/item/ammo_box/speedloader
	name = "speed loader (base type)"
	desc = "This shouldn't be here. Report this to a coder, thanks!"
	multiple_sprites = AMMO_BOX_PER_BULLET
	ammo_box_multiload = (AMMO_BOX_MULTILOAD_IN | AMMO_BOX_MULTILOAD_OUT_LOADED)

/obj/item/ammo_box/speedloader/c357
	name = "speed loader (.357)"
	desc = "Designed to quickly reload seven-chamber .357 revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/c357
	max_ammo = 7
	caliber = CALIBER_357
	multiple_sprites = AMMO_BOX_PER_BULLET
	item_flags = NO_MAT_REDEMPTION
	ammo_band_icon = "+357_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/speedloader/c357/match
	name = "speed loader (.357 Match)"
	desc = "Designed to quickly reload revolvers. These rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c357/match
	ammo_band_color = "#77828a"

/obj/item/ammo_box/speedloader/c357/phasic
	name = "speed loader (.357 Phasic)"
	desc = "Designed to quickly reload revolvers. Holds phasic ammo, also known as 'Ghost Lead', allowing it to pass through non-organic material."
	ammo_type = /obj/item/ammo_casing/c357/phasic
	ammo_band_color = "#693a6a"

/obj/item/ammo_box/speedloader/c357/heartseeker
	name = "speed loader (.357 Heartseeker)"
	desc = "Designed to quickly reload revolvers. Holds heartseeker ammo, which veers into targets with exceptional precision using \
		an unknown method. It apparently predicts movement using neural pulses in the brain, but that's less marketable. \
		As seen in the hit NTFlik horror-space western film, Forget-Me-Not! Brought to you by Roseus Galactic!"
	ammo_type = /obj/item/ammo_casing/c357/heartseeker
	ammo_band_color = "#a91e1e"

/obj/item/ammo_box/speedloader/c38
	name = "speed loader (.38)"
	desc = "Designed to quickly reload six-chamber .38 Special revolvers."
	icon_state = "38"
	base_icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	caliber = CALIBER_38
	multiple_sprites = AMMO_BOX_PER_BULLET
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	ammo_band_icon = "+38_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/speedloader/c38/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-base"

/obj/item/ammo_box/speedloader/c38/update_overlays()
	. = ..()
	if(!LAZYLEN(stored_ammo))
		return
	for(var/inserted_ammo in 1 to stored_ammo.len)
		var/obj/item/ammo_casing/c38/boolet = stored_ammo[inserted_ammo]
		. += "38-[boolet::lead_or_laser]-[inserted_ammo]"

/obj/item/ammo_box/speedloader/c38/trac
	name = "speed loader (.38 TRAC)"
	desc = "Designed to quickly reload revolvers. TRAC bullets embed a tracking implant within the target's body."
	ammo_type = /obj/item/ammo_casing/c38/trac
	ammo_band_color = COLOR_AMMO_TRACK

/obj/item/ammo_box/speedloader/c38/match
	name = "speed loader (.38 Match)"
	desc = "Designed to quickly reload revolvers. These rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match
	ammo_band_color = COLOR_AMMO_MATCH

/obj/item/ammo_box/speedloader/c38/match/bouncy
	name = "speed loader (.38 Rubber)"
	desc = "Designed to quickly reload revolvers. These rounds are incredibly bouncy and MOSTLY nonlethal, making them great to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/speedloader/c38/true
	name = "speed loader (.38 True Strike)"
	desc = "Designed to quickly reload revolvers. Bullets bounce towards new targets with surprising accuracy."
	ammo_type = /obj/item/ammo_casing/c38/match/true
	ammo_band_color = COLOR_AMMO_TRUESTRIKE

/obj/item/ammo_box/speedloader/c38/dumdum
	name = "speed loader (.38 DumDum)"
	desc = "Designed to quickly reload revolvers. These rounds expand on impact, allowing them to shred the target and cause massive bleeding. Very weak against armor and distant targets."
	ammo_type = /obj/item/ammo_casing/c38/dumdum
	ammo_band_color = COLOR_AMMO_DUMDUM

/obj/item/ammo_box/speedloader/c38/hotshot
	name = "speed loader (.38 Hot Shot)"
	desc = "Designed to quickly reload revolvers. Hot Shot bullets contain an incendiary payload."
	ammo_type = /obj/item/ammo_casing/c38/hotshot
	ammo_band_color = COLOR_AMMO_HOTSHOT

/obj/item/ammo_box/speedloader/c38/iceblox
	name = "speed loader (.38 Iceblox)"
	desc = "Designed to quickly reload revolvers. Iceblox bullets contain a cryogenic payload."
	ammo_type = /obj/item/ammo_casing/c38/iceblox
	ammo_band_color = COLOR_AMMO_ICEBLOX

/obj/item/ammo_box/speedloader/c38/flare
	name = "speed loader (.38 Flare)"
	desc = "Designed to quickly reload revolvers. Flare casings launch a concentrated particle beam towards a target, lighting them up for everyone to see."
	ammo_type = /obj/item/ammo_casing/c38/flare
	ammo_band_color = COLOR_AMMO_HELLFIRE
