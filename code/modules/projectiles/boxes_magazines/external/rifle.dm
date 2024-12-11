/obj/item/ammo_box/magazine/m10mm/rifle
	name = "rifle magazine (10mm)"
	desc = "A well-worn magazine fitted for the surplus rifle."
	icon_state = "75-full"
	base_icon_state = "75"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 10

/obj/item/ammo_box/magazine/m10mm/rifle/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/m223
	name = "toploader magazine (.223)"
	icon_state = ".223"
	ammo_type = /obj/item/ammo_casing/a223
	caliber = CALIBER_A223
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/m223/phasic
	name = "toploader magazine (.223 Phasic)"
	ammo_type = /obj/item/ammo_casing/a223/phasic

// .38 (Battle Rifle) //

/obj/item/ammo_box/magazine/m38
	name = "battle rifle magazine (.38)"
	desc = "A magazine for a BR-38 battle rifle."
	icon_state = "38mag"
	base_icon_state = "38mag"
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/c38
	caliber = CALIBER_38
	max_ammo = 15
	ammo_band_icon = "+38mag_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/magazine/m38/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][ammo_count() ? "-ammo" : ""]"

/obj/item/ammo_box/magazine/m38/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/m38/trac
	name = "battle rifle magazine (.38 TRAC)"
	desc = "A magazine for a BR-38 battle rifle. TRAC bullets embed a tracking implant within the target's body and are entirely nonlethal."
	ammo_type = /obj/item/ammo_casing/c38/trac
	ammo_band_color = "#7b6383"

/obj/item/ammo_box/magazine/m38/match
	name = "battle rifle magazine (.38 Match)"
	desc = "A magazine for a BR-38 battle rifle. These rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match
	ammo_band_color = "#7b6383"

/obj/item/ammo_box/magazine/m38/match/bouncy
	name = "battle rifle magazine (.38 Rubber)"
	desc = "A magazine for a BR-38 battle rifle. These rounds are incredibly bouncy and MOSTLY nonlethal, making them great to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy
	ammo_band_color = "#556696"

/obj/item/ammo_box/magazine/m38/true
	name = "battle rifle magazine (.38 True Strike)"
	desc = "A magazine for a BR-38 battle rifle. Bullets bounce towards new targets with surprising accuracy."
	ammo_type = /obj/item/ammo_casing/c38/match/true
	ammo_band_color = "#d647b0"

/obj/item/ammo_box/magazine/m38/dumdum
	name = "battle rifle magazine (.38 DumDum)"
	desc = "A magazine for a BR-38 battle rifle. These rounds expand on impact, allowing them to shred the target and cause massive bleeding. Very weak against armor and distant targets."
	ammo_type = /obj/item/ammo_casing/c38/dumdum
	ammo_band_color = "#969578"

/obj/item/ammo_box/magazine/m38/hotshot
	name = "battle rifle magazine (.38 Hot Shot)"
	desc = "A magazine for a BR-38 battle rifle. Hot Shot bullets contain an incendiary payload."
	ammo_type = /obj/item/ammo_casing/c38/hotshot
	ammo_band_color = "#805a57"

/obj/item/ammo_box/magazine/m38/iceblox
	name = "battle rifle magazine (.38 Iceblox)"
	desc = "A magazine for a BR-38 battle rifle. Iceblox bullets contain a cryogenic payload."
	ammo_type = /obj/item/ammo_casing/c38/iceblox
	ammo_band_color = "#658e94"
