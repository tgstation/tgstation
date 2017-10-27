
/obj/item/banner/engineering/atmos
	name = "Kazakhstan banner"
	desc = "Áàííåğ ïğîñëàâëÿşùèé âåëèêóş ìîùü Åëáàñû."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "banner_atmos"
	job_loyalties = list("Scientist", "Atmospheric Technician")
	warcry = "<b>ÊÀÇÀÕÑÒÀÍ ÓÃĞÎÆÀÅÒ ÂÀÌ ÁÎÌÁÀĞÄÈĞÎÂÊÎÉ!!</b>"


obj/item/banner/engineering/atmos/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/atmos_banner
	name = "Kazakhstan Banner"
	result = /obj/item/banner/engineering/atmos/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/atmospheric_technician = 1)
	category = CAT_MISC