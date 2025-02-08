//	SMOKABLES FOR THE IMPORT VENDOR

//	TANGERINES

/obj/item/cigarette/tangerine
	name = "'Ward 5 Tangerine'"
	desc = "Low-nicotine Marsian 'fashion smokes'. These artisanal cigarettes burn orange and have a pleasant tangerine \
	and cream aroma. They have a reputation for being the first choice of the Grey's most affluent denizens. There's a \
	rumor that being given one means you're considered a snitch."
	list_reagents = list(
		/datum/reagent/drug/nicotine = 6,
		/datum/reagent/consumable/menthol = 5,
		/datum/reagent/consumable/orangejuice = 3,
		)

/obj/item/storage/fancy/cigarettes/tangerine
	name = "\improper Ward 5 Tangerines pack"
	desc = "Low-nicotine Marsian 'fashion smokes'. These artisanal cigarettes burn orange and have a pleasant tangerine \
	and cream aroma. They have a reputation for being the first choice of the Grey's most affluent denizens. There's a \
	rumor that being given one means you're considered a snitch."
	icon = 'modular_doppler/modular_vending/icons/imported_smokes.dmi'
	icon_state = "tangerine"
	base_icon_state = "tangerine"
	spawn_type = /obj/item/cigarette/tangerine
