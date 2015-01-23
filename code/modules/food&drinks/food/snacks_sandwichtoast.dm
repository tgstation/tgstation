
/obj/item/weapon/reagent_containers/food/snacks/sandwich
	name = "sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/sandwich/New()
	..()
	peakReagents = list("nutriment", 6, "vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
	name = "toasted sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich/New()
	..()
	peakReagents = list("nutriment", 6, "carbon", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	name = "grilled cheese sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese/New()
	..()
	peakReagents = list("nutriment", 7, "vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/New()
	..()
	peakReagents = list("nutriment", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime/New()
	..()
	peakReagents = list("slimejelly", 5, "vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry/New()
	..()
	peakReagents = list("cherryjelly", 5, "vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsandwich"

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich/New()
	..()
	peakReagents = list("nutriment", 2, "ice", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/notasandwich/New()
	..()
	peakReagents = list("nutriment", 6, "vitamin", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast
	name = "jellied toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/New()
	..()
	peakReagents = list("nutriment", 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry/New()
	..()
	peakReagents = list("cherryjelly", 5, "vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime/New()
	..()
	peakReagents = list("slimejelly", 5, "vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "two bread"
	desc = "This seems awfully bitter."
	icon_state = "twobread"

/obj/item/weapon/reagent_containers/food/snacks/twobread/New()
	..()
	peakReagents = list("nutriment", 2, "vitamin", 2)
	bitesize = 3
