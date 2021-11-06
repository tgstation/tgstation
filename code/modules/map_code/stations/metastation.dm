//Special map items for Metastation

/obj/item/reagent_containers/food/drinks/bottle/beer/metastation
	name = "\improper Meta-Cider"
	desc = "Takes you to a whole new level of thinking."
	list_reagents = list(/datum/reagent/consumable/ethanol/hcider = 30)
	foodtype = FRUIT | ALCOHOL

// Corporate Showcase Items
/obj/item/paicard/corp_showcase
	name = "\improper Nanotrasen-brand personal AI device"
	desc = "A real Nanotrasen success, these personal AIs provide all of the companionship of an AI without any law related red-tape."

/obj/item/phone/centcom_line
	desc = "Supposedly a direct line to Central Command. It's not even plugged in..."

/obj/item/clothing/head/collectable/hop/novelty
	name = "novelty HoP hat"

/obj/item/clothing/head/collectable/hos/novelty
	name = "novelty HoS hat"

/obj/item/toy/plush/carpplushie/nt_wildlife
	name = "\improper Nanotrasen wildlife department space carp plushie"
	color = "red"

//Abandoned Medbay
/obj/structure/showcase/machinery/oldpod/decommissioned
	name = "decommissioned sleeper"
	desc = "An old Nanotrasen branded sleeper, decommissioned after the lead acetate incident. None of the functional machinery remains inside."

/obj/structure/showcase/machinery/cloning_pod/decommissioned
	name = "decommissioned cloning pod"
	desc = "An old prototype cloning pod, permanently decommissioned following the Felinid incident."

/obj/structure/showcase/machinery/cloning_pod/decommissioned/scanner
	name = "decommissioned cloning scanner"
	desc = "An old decommissioned scanner, permanently scuttled."
	icon_state = "scanner"
