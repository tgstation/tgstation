/obj/item/clothing/suit/mothcoat/
	name = "mothic flightsuit"
	desc = "This peculiar utility harness is a common sight among the fleet's crew due to its ability to fasten the wings to the body without impacting mobility, an necessity while operating inside sometimes cramped engine rooms."
	icon_state = "mothcoat"
	greyscale_config = /datum/greyscale_config/mothcoat
	greyscale_config_worn = /datum/greyscale_config/mothcoat_worn
	greyscale_colors = "#ee4242"
	flags_1 = IS_PLAYER_COLORABLE_1
	flags_inv = HIDEMUTWINGS
	body_parts_covered = CHEST
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/flashlight/lantern) //lamp

/obj/item/clothing/suit/mothcoat/original
	desc = "A genuine old-school flightsuit from the moth fleet. It looks rugged, yet it's surprisingly comfortable to wear. This particular style is often associated with smugglers to the point of occasionally being worn as a status symbol even by non-moths."
	pocket_storage_component_path = /datum/component/storage/concrete/pockets

/obj/item/clothing/suit/mothcoat/short
	name = "short mantella"
	desc = "This peculiar utility harness is a common sight among the fleet's crew due to its ability to fasten the wings to the body without impacting mobility, an necessity while operating inside sometimes cramped engine rooms."
	icon_state = "mothcoat_short"
	flags_inv = null

/obj/item/clothing/suit/mothcoat/winter/
	name = "heavy mantella"
	desc = "A thick wool garment used to keep warm and protect those precious wings from harsh weather. Feels heavier than it looks."
	icon_state = "mothcoat_winter"
	greyscale_colors = "#ee4242"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT