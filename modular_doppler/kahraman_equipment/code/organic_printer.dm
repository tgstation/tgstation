/obj/machinery/biogenerator/organic_printer
	name = "organic materials printer"
	desc = "An advanced machine seen in frontier outposts and colonies capable of turning organic plant matter into \
		reagents and items of use that a fabricator can't typically make. While the exact designs these machines have differs from \
		location to location, and upon who designed them, this one should be able to at the very least provide you with \
		some clothing, basic food supplies, and whatever else you may require."
	icon = 'modular_doppler/kahraman_equipment/icons/biogenerator.dmi'
	circuit = null
	anchored = FALSE
	efficiency = 1
	productivity = 2
	max_items = 35
	show_categories = list(
		RND_CATEGORY_AKHTER_CLOTHING,
		RND_CATEGORY_AKHTER_EQUIPMENT,
		RND_CATEGORY_AKHTER_RESOURCES,
	)

/obj/machinery/biogenerator/organic_printer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/obj/machinery/biogenerator/organic_printer/RefreshParts()
	. = ..()
	efficiency = 1
	productivity = 2
	max_items = 35

/obj/machinery/biogenerator/organic_printer/default_deconstruction_crowbar()
	return

// Deployable item for cargo for the organics printer
/obj/item/flatpacked_machine/organics_printer
	name = "organic materials printer parts kit"
	icon = 'modular_doppler/kahraman_equipment/icons/biogenerator.dmi'
	icon_state = "biogenerator_parts"
	type_to_deploy = /obj/machinery/biogenerator/organic_printer

/obj/item/flatpacked_machine/organics_printer/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)
