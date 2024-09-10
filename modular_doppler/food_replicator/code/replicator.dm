#define RND_CATEGORY_COLONIAL_FOOD "Provision"
#define RND_CATEGORY_COLONIAL_MEDICAL "Medicine"
#define RND_CATEGORY_COLONIAL_CLOTHING "Apparel"

/obj/machinery/biogenerator/food_replicator
	name = "\improper Type 34 'Colonial Supply Core'"
	desc = "The Type 34 'Colonial Supply Core,' colloquially known as the 'Gencrate/CSC' is an ancient, boxy design first put in use by the pioneer colonists of what's now known \
		as the NRI. The Gencrate is at its core a matter resequencer, a highly specialized subtype of biogenerator which performs a sort of transmutation using organic \
		compounds; normally from large-scale crops or waste product. With sufficient supply, the machine is capable of making a wide variety of provisions, \
	from clothes to food to first-aid medical supplies."
	icon = 'modular_doppler/food_replicator/icons/biogenerator.dmi'
	circuit = /obj/item/circuitboard/machine/biogenerator/food_replicator
	efficiency = 0.75
	productivity = 0.75
	show_categories = list(
		RND_CATEGORY_COLONIAL_FOOD,
		RND_CATEGORY_COLONIAL_MEDICAL,
		RND_CATEGORY_COLONIAL_CLOTHING,
	)

/obj/item/circuitboard/machine/biogenerator/food_replicator
	name = "Colonial Supply Core"
	build_path = /obj/machinery/biogenerator/food_replicator
