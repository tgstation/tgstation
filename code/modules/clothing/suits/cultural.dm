/obj/item/clothing/suit/mothcoat/
	name = "mothic flightsuit"
	desc = "Standard issue for flight crews aboard the mothic fleet. This peculiar harness is favored by moth engineers thanks to its ability to fasten the wings to the body without impacting mobility, an absolute necessity when operating inside cramped engine rooms."
	icon_state = "mothcoat"
	greyscale_config = /datum/greyscale_config/mothcoat
	greyscale_config_worn = /datum/greyscale_config/mothcoat/worn
	flags_inv = HIDEMUTWINGS
	body_parts_covered = CHEST
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/flashlight/lantern) //lamp
	pocket_storage_component_path = /datum/component/storage/concrete/pockets

/obj/item/clothing/suit/mothcoat_winter
	name = "mothic mantella"
	desc = "A thick wool garment used to keep warm and protect those precious wings from harsh weather. It's a lot heavier than it looks. Considered a prized possession for many as it's typically used for planetside leisure activities or formal occasions, rare occurrences aboard the fleet."
	icon_state = "mothcoat_winter"
	greyscale_config = /datum/greyscale_config/mothcoat
	greyscale_config_worn = /datum/greyscale_config/mothcoat/worn
	flags_inv = HIDEMUTWINGS
	body_parts_covered = CHEST
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
