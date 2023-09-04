/obj/item/petri_dish/oldstation
	name = "molly's biopsy"
	desc = "You can see a moldy piece of sandwich inside the dish. Maybe it helped to preserve the bacteria for that long."

/obj/item/petri_dish/oldstation/Initialize(mapload)
	. = ..()
	sample = new
	sample.GenerateSample(CELL_LINE_TABLE_COW, null, 1, 0)
	var/datum/biological_sample/contamination = new
	contamination.GenerateSample(CELL_LINE_TABLE_GRAPE, null, 1, 0)
	sample.Merge(contamination)
	sample.sample_color = COLOR_SAMPLE_BROWN
	update_appearance()

/obj/item/reagent_containers/cup/beaker/oldstation
	name = "cultivation broth"
	amount_per_transfer_from_this = 50
	list_reagents = list(
		// Required for CELL_LINE_TABLE_COW
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/cellulose = 5,
		// Required for CELL_LINE_TABLE_GRAPE
		/datum/reagent/toxin/slimejelly = 5,
		/datum/reagent/yuck = 5,
		/datum/reagent/consumable/vitfro = 5,
		// Supplementary for CELL_LINE_TABLE_GRAPE
		/datum/reagent/consumable/liquidgibs = 5
	)
