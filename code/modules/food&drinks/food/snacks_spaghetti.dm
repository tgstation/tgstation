
/obj/item/weapon/reagent_containers/food/snacks/spaghetti
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon_state = "spaghetti"

/obj/item/weapon/reagent_containers/food/snacks/spaghetti/New()
	..()
	reagents.add_reagent("nutriment", 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spaghettiboiled"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti/New()
	..()
	reagents.add_reagent("nutriment", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/pastatomato/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("tomatojuice", 10)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/copypasta/New()
	..()
	reagents.add_reagent("nutriment", 12)
	reagents.add_reagent("tomatojuice", 20)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nic'e meatball!"
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"

/obj/item/weapon/reagent_containers/food/snacks/spesslaw/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "eggplant parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2
