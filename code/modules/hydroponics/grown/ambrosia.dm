/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia //abstract type
	name = "ambrosia branch"
	desc = "This is a plant."
	icon_state = "ambrosiavulgaris"
	slot_flags = SLOT_HEAD
	filling_color = "#008000"
	reagents_add = list("nutriment" = 0)
	// It means 1 nutriment no matter how low or high potency is
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	seed = /obj/item/seeds/ambrosiavulgarisseed
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	reagents_add = list("space_drugs" = 0.15, "salglu_solution" = 0.25, "vitamin" = 0.04, "nutriment" = 0, "toxin" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus
	seed = /obj/item/seeds/ambrosiadeusseed
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	filling_color = "#008B8B"
	reagents_add = list("omnizine" = 0.15, "synaptizine" = 0.15, "space_drugs" = 0.1, "vitamin" = 0.04, "nutriment" = 0)