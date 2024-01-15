/obj/structure/sign/poster/official/carwo_grenade
	name = "Tydhouer - Precision Timing"
	desc = "This poster depicts, alongside the prominent logo of Carwo Defense Systems, a variety of specialist .980 Tydhouer grenades for the Kiboko launcher."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/propaganda.dmi'
	icon_state = "grenadier"

/obj/structure/sign/poster/official/carwo_grenade/examine_more(mob/user)
	. = ..()

	. += "Small text details that certain types of grenades may not be available in your \
		region depending on local weapons regulations. Suspiciously, however, if you squint at \
		it a bit, the background colors of the image come together vaguely in the shape of \
		a computer board and a multitool. What did they mean by this?"

	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/carwo_grenade, 32)

/obj/structure/sign/poster/official/carwo_magazine
	name = "Standardisation - Magazines of the Future"
	desc = "This poster depicts, alongside the prominent logo of Carwo Defense Systems, the variety of magazine types the company has on offer for rifles. \
		It also goes into great deal to say, more or less, that any rifle can take any rifle magazine. Now this is technology like never seen before."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/propaganda.dmi'
	icon_state = "mag_size"

/obj/structure/sign/poster/official/carwo_magazine/examine_more(mob/user)
	. = ..()

	. += "Small text details that certain types of magazines may not be available in your \
		region depending on local weapons regulations. Suspiciously, however, if you squint at \
		it a bit, the background colors of the image come together vaguely in the shape of \
		a computer board and a multitool. What did they mean by this?"

	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/carwo_magazine, 32)
