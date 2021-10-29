/obj/item/seeds/poppy/opiumpoppy
	name = "pack of opium poppy seeds"
	desc = "These seeds grow into real opium poppies."
	icon = 'modular_skyrat/master_files/icons/obj/hydroponics/seeds.dmi'
	growing_icon = 'modular_skyrat/master_files/icons/obj/hydroponics/growing.dmi'
	icon_state = "seed-opiumpoppy"
	species = "opiumpoppy"
	icon_grow = "opiumpoppy-grow"
	icon_dead = "opiumpoppy-dead"
	plantname = "Opium Poppy Plants"
	product = /obj/item/food/grown/poppy/opiumpoppy
	reagents_add = list(/datum/reagent/drug/opium = 0.3, /datum/reagent/toxin/fentanyl = 0.075, /datum/reagent/consumable/nutriment = 0.05)
	slot_flags = null

/obj/item/food/grown/poppy/opiumpoppy
	seed = /obj/item/seeds/poppy/opiumpoppy
	name = "opium poppy seedpod"
	desc = "The seedpod of the opium poppy plant, which contain opium latex."
	icon = 'modular_skyrat/master_files/icons/obj/hydroponics/harvest.dmi'
	icon_state = "opiumpoppy"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null
	distill_reagent = /datum/reagent/consumable/ethanol/turbo //How can a slow drug make fast drink? Don't question it.
