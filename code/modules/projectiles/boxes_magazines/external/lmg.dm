/obj/item/ammo_box/magazine/m7mm
	name = "box magazine (7mm)"
	desc = "A sizeable 7mm box magazine, suitable for the L6 SAW."
	icon_state = "a7mm"
	ammo_band_icon = "+a7mmab"
	ammo_type = /obj/item/ammo_casing/m7mm
	caliber = CALIBER_A7MM
	max_ammo = 50

/obj/item/ammo_box/magazine/m7mm/hollow
	name = "box magazine (7mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/m7mm/hollow

/obj/item/ammo_box/magazine/m7mm/ap
	name = "box magazine (7mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/m7mm/ap

/obj/item/ammo_box/magazine/m7mm/incen
	name = "box magazine (7mm Incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/m7mm/incen

/obj/item/ammo_box/magazine/m7mm/match
	name = "box magazine (7mm Match)"
	ammo_band_color = COLOR_AMMO_MATCH
	desc = parent_type::desc + "<br>Carries match-grade rounds, which are designed to ricochet off walls in an exceedingly stylish, but possibly user-unfriendly manner."
	ammo_type = /obj/item/ammo_casing/m7mm/match

/obj/item/ammo_box/magazine/m7mm/bouncy
	name = "box magazine (7mm Rubber)"
	ammo_band_color = COLOR_AMMO_MATCH // this doesn't seem attainable in game (probably a good thing) so i guess it can get away with a color reuse
	desc = parent_type::desc + "<br>Carries lethal rubber rounds, which deal less damage and bounce off everything in an incredibly irresponsible, user-unfriendly manner."
	ammo_type = /obj/item/ammo_casing/m7mm/bouncy

/obj/item/ammo_box/magazine/m7mm/bouncy/hicap
	name = "hi-cap box magazine (7mm Rubber)"
	desc = "A very concerningly sizeable 7mm box magazine, suitable for the L6 SAW.<br>\
	Carries lethal rubber rounds, which deal less damage and bounce off everything in an incredibly irresponsible, user-unfriendly manner."
	max_ammo = 150

/obj/item/ammo_box/magazine/m7mm/update_icon_state()
	. = ..()
	icon_state = "a7mm-[min(round(ammo_count(), 10), 50)]" //Min is used to prevent high capacity magazines from attempting to get sprites with larger capacities
