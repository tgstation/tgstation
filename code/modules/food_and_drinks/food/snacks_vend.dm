////////////////////////////////////////////SNACKS FROM VENDING MACHINES////////////////////////////////////////////
//in other words: junk food
//don't even bother looking for recipes for these

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	junkiness = 25
	filling_color = "#D2691E"
	tastes = list("candy" = 1)

/obj/item/weapon/reagent_containers/food/snacks/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	junkiness = 25
	filling_color = "#8B0000"
	tastes = list("dried meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/sosjerky/healthy
	name = "homemade beef jerky"
	desc = "Homemade beef jerky made from the finest space cows."
	list_reagents = list("nutriment" = 3, "vitamin" = 1)
	junkiness = 0

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips
	bitesize = 1
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	junkiness = 20
	filling_color = "#FFD700"
	tastes = list("salt" = 1, "crisps" = 1)

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	list_reagents = list("nutriment" = 2, "sugar" = 4)
	junkiness = 25
	filling_color = "#8B0000"
	tastes = list("dried raisins" = 1)

/obj/item/weapon/reagent_containers/food/snacks/no_raisin/healthy
	name = "homemade raisins"
	desc = "homemade raisins, the best in all of spess."
	list_reagents = list("nutriment" = 3, "vitamin" = 2)
	junkiness = 0

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "space twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer than you will."
	list_reagents = list("sugar" = 4)
	junkiness = 25
	filling_color = "#FFD700"

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "cheesie honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	icon_state = "cheesie_honkers"
	trash = /obj/item/trash/cheesie
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	junkiness = 25
	filling_color = "#FFD700"
	tastes = list("cheese" = 5, "crisps" = 2)

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "syndi-cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash = /obj/item/trash/syndi_cakes
	list_reagents = list("nutriment" = 4, "doctorsdelight" = 5)
	filling_color = "#F5F5DC"
	tastes = list("sweetness" = 3, "cake" = 1)
