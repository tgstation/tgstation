/obj/item/clothing/mask/gas/sechailer
	flags_cover = MASKCOVERSMOUTH | PEPPERPROOF

/obj/item/clothing/mask/gas
	has_fov = FALSE

/datum/component/clothing_fov_visor/Initialize(fov_angle)
	. = ..()
	src.fov_angle = null
