/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	seed = /obj/item/seeds/carrotseed
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	filling_color = "#FFA500"
	bitesize_mod = 2
	reagents_add = list("oculine" = 0.25, "vitamin" = 0.04, "nutriment" = 0.05)

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchen/knife) || istype(I, /obj/item/weapon/hatchet))
		user << "<span class='notice'>You sharpen the carrot into a shiv with [I].</span>"
		var/obj/item/weapon/kitchen/knife/carrotshiv/Shiv = new /obj/item/weapon/kitchen/knife/carrotshiv
		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.put_in_hands(Shiv)
		qdel(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	seed = /obj/item/seeds/whitebeetseed
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	filling_color = "#F4A460"
	reagents_add = list("vitamin" = 0.04, "sugar" = 0.2, "nutriment" = 0.05)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/parsnip
	seed = /obj/item/seeds/parsnipseed
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"
	reagents_add = list("vitamin" = 0.05, "nutriment" = 0.05)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/redbeet
	seed = /obj/item/seeds/redbeetseed
	name = "red beet"
	desc = "You can't beat red beet."
	icon_state = "redbeet"
	reagents_add = list("vitamin" = 0.05, "nutriment" = 0.05)
	bitesize_mod = 2