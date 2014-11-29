////////////////////////////////////////////SNACKS FROM VENDING MACHINES////////////////////////////////////////////
//in other words: junk food
//don't even bother looking for recipes for these

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy

/obj/item/weapon/reagent_containers/food/snacks/candy/New()
	..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky

/obj/item/weapon/reagent_containers/food/snacks/sosjerky/New()
	..()
	reagents.add_reagent("nutriment", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips

/obj/item/weapon/reagent_containers/food/snacks/chips/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins

/obj/item/weapon/reagent_containers/food/snacks/no_raisin/New()
	..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "space twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer than you will."

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie/New()
	..()
	reagents.add_reagent("sugar", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "cheesie honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	icon_state = "cheesie_honkers"
	trash = /obj/item/trash/cheesie

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/New()
	..()
	reagents.add_reagent("nutriment", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "syndi-cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash = /obj/item/trash/syndi_cakes

/obj/item/weapon/reagent_containers/food/snacks/syndicake/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("doctorsdelight", 5)
	bitesize = 3

