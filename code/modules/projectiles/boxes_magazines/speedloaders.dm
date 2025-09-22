/obj/item/ammo_box/speedloader
	name = "speed loader (base type)"
	desc = "This shouldn't be here. Report this to a coder, thanks!"
	multiple_sprites = AMMO_BOX_PER_BULLET
	ammo_box_multiload = (AMMO_BOX_MULTILOAD_IN | AMMO_BOX_MULTILOAD_OUT_LOADED)
	// You can feed ammo in from a box (assuming someone ever codes a relevant ammo box),
	// you can feed ammo out to a revolver's cylinder,
	// but you can't use it to teleport six bullets into a detached rifle magazine.

/obj/item/ammo_box/speedloader/c357
	name = "speed loader (.357)"
	desc = "Designed to quickly reload seven-chamber .357 revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/c357
	max_ammo = 7
	caliber = CALIBER_357
	item_flags = NO_MAT_REDEMPTION
	ammo_band_icon = "+357_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/speedloader/c357/match
	name = "speed loader (.357 Match)"
	desc = parent_type::desc + " Match rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c357/match
	ammo_band_color = "#77828a"

/obj/item/ammo_box/speedloader/c357/phasic
	name = "speed loader (.357 Phasic)"
	desc = parent_type::desc + " Phasic rounds, also known as 'Ghost Lead', are specially manufactured to pass through non-organic material. Somehow."
	ammo_type = /obj/item/ammo_casing/c357/phasic
	ammo_band_color = "#693a6a"

/obj/item/ammo_box/speedloader/c357/heartseeker
	name = "speed loader (.357 Heartseeker)"
	desc = parent_type::desc + " Heartseeker rounds veer into targets with exceptional precision using an unknown method. \
		It apparently predicts movement using neural pulses in the brain, but that's less marketable. \
		As seen in the hit NTFlik horror-space western film, Forget-Me-Not, brought to you by Roseus Galactic!"
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
	desc = parent_type::desc + " TRAC bullets embed a tracking implant within the target's body."
	ammo_type = /obj/item/ammo_casing/c38/trac
	ammo_band_color = COLOR_AMMO_TRACK

/obj/item/ammo_box/speedloader/c38/match
	name = "speed loader (.38 Match)"
	desc = parent_type::desc + " Match bullets are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match
	ammo_band_color = COLOR_AMMO_MATCH

/obj/item/ammo_box/speedloader/c38/match/bouncy
	name = "speed loader (.38 Rubber)"
	desc = parent_type::desc + " Rubber rounds are incredibly bouncy and MOSTLY less-lethal, making them great to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/speedloader/c38/true
	name = "speed loader (.38 True Strike)"
	desc = parent_type::desc + " True Strike bullets bounce towards new targets with surprising accuracy after ricocheting."
	ammo_type = /obj/item/ammo_casing/c38/match/true
	ammo_band_color = COLOR_AMMO_TRUESTRIKE

/obj/item/ammo_box/speedloader/c38/dumdum
	name = "speed loader (.38 DumDum)"
	desc = parent_type::desc + " DumDum bullets expand on impact, reducing outright stopping power but \
		shredding targets and causing massive bleeding in close range, \
		at the cost of suffering greatly against armor and distant targets."
	ammo_type = /obj/item/ammo_casing/c38/dumdum
	ammo_band_color = COLOR_AMMO_DUMDUM

/obj/item/ammo_box/speedloader/c38/hotshot
	name = "speed loader (.38 Hot Shot)"
	desc = parent_type::desc + " Hot Shot bullets contain an incendiary payload that ignites struck targets."
	ammo_type = /obj/item/ammo_casing/c38/hotshot
	ammo_band_color = COLOR_AMMO_HOTSHOT

/obj/item/ammo_box/speedloader/c38/iceblox
	name = "speed loader (.38 Iceblox)"
	desc = parent_type::desc + " Iceblox bullets contain a cryogenic payload that lower the body temperature of struck targets."
	ammo_type = /obj/item/ammo_casing/c38/iceblox
	ammo_band_color = COLOR_AMMO_ICEBLOX

/obj/item/ammo_box/speedloader/c38/flare
	name = "speed loader (.38 Flare)"
	desc = parent_type::desc + " Flare casings launch a concentrated particle beam towards a target, lighting them up for everyone to see."
	ammo_type = /obj/item/ammo_casing/c38/flare
	ammo_band_color = COLOR_AMMO_HELLFIRE

/obj/item/ammo_box/speedloader/strilka310
	name = "stripper clip (.310 Strilka)"
	desc = "A five-round stripper clip for .310 Strilka rifles."
	icon_state = "310_strip"
	ammo_type = /obj/item/ammo_casing/strilka310
	max_ammo = 5
	ammo_box_multiload = AMMO_BOX_MULTILOAD_ALL
	caliber = CALIBER_STRILKA310

/obj/item/ammo_box/speedloader/strilka310/surplus
	name = "stripper clip (.310 Surplus)"
	desc = parent_type::desc + " This one has a few spots of rust where there's not excessive amounts of gun grease."
	ammo_type = /obj/item/ammo_casing/strilka310/surplus

/obj/item/ammo_box/speedloader/strilka310/phasic
	name = "stripper clip (.310 Phasic)"
	desc = parent_type::desc + " These should come with phasic bullets, \
		hastily developed after an incident where a misfire resulted in the destruction of Atrakor Silverscale's priceless Vigoxian Fabergé egg. \
		These fancy bullets pass right though valuables until they end up in a far less expensive human skull."
	ammo_type = /obj/item/ammo_casing/strilka310/phasic
