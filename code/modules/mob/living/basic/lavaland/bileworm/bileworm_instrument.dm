/obj/item/instrument/bilehorn
	name = "bilehorn"
	desc = "Bits of bileworm anatomy rearranged to produce wonderful music, not bile. Keeps the name though, because for an instrument, it is quite vile."
	force = 5
	icon = 'icons/mob/simple/lavaland/bileworm.dmi'
	icon_state = "bilehorn"
	allowed_instrument_ids = "bilehorn"
	inhand_icon_state = null

/datum/crafting_recipe/bilehorn
	name = "Bilehorn"
	reqs = list(
		/obj/item/stack/sheet/animalhide/bileworm = 4,
		/obj/item/stack/sheet/bone = 2,
		/obj/item/crusher_trophy/bileworm_spewlet = 1,
	)
	result = /obj/item/instrument/bilehorn
	category = CAT_ENTERTAINMENT
