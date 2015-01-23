
/obj/item/weapon/reagent_containers/food/snacks/spaghetti
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon_state = "spaghetti"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/spaghetti/New()
	..()
	peakReagents = list("nutriment", 1, "vitamin", 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spaghettiboiled"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti/New()
	..()
	peakReagents = list("nutriment", 2, "vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/pastatomato/New()
	..()
	peakReagents = list("nutriment", 6, "tomatojuice", 10, "vitamin", 4)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/copypasta/New()
	..()
	peakReagents = list("nutriment", 12, "tomatojuice", 20, "vitamin", 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nic'e meatball!"
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti/New()
	..()
	peakReagents = list("nutriment", 8, "vitamin", 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/spesslaw/New()
	..()
	peakReagents = list("nutriment", 8, "vitamin", 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "eggplant parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm/New()
	..()
	peakReagents = list("nutriment", 6, "vitamin", 2)
	bitesize = 2
