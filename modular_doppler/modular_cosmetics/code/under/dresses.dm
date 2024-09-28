/obj/item/clothing/under/dress/doppler
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/dresses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/dresses.dmi'

/obj/item/clothing/under/dress/doppler/pentagram
	name = "pentagram strapped dress"
	desc = "A soft dress with straps designed to rest as a pentragram. Isn't this against NT's whole \"Authorized Religion\" stuff?"
	icon_state = "dress_pentagram"
	icon_preview = 'modular_doppler/modular_cosmetics/GAGS/icons/obj/under.dmi'
	icon_state_preview = "penta_base"
	body_parts_covered = CHEST|GROIN|LEGS
	greyscale_config = /datum/greyscale_config/pentagram_dress
	greyscale_config_worn = /datum/greyscale_config/pentagram_dress/worn
	greyscale_colors = "#403c46"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/doppler/strapless
	name = "strapless dress"
	desc = "Typical formal wear with no straps, instead opting to be tied at the waist. Most likely will need constant adjustments."
	icon_state = "dress_strapless"
	icon_preview = 'modular_doppler/modular_cosmetics/GAGS/icons/obj/under.dmi'
	icon_state_preview = "strapless_base"
	body_parts_covered = CHEST|GROIN|LEGS
	greyscale_config = /datum/greyscale_config/strapless_dress
	greyscale_config_worn = /datum/greyscale_config/strapless_dress/worn
	greyscale_colors = "#cc0000#5f5f5f"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/doppler/flower
	name = "flower dress"
	desc = "Lovely dress. Colored like the autumn leaves."
	icon_state = "flower_dress"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/under/dress/doppler/pinktutu
	name = "pink tutu"
	desc = "A fluffy pink tutu."
	icon_state = "pinktutu"
