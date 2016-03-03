/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	seed = /obj/item/seeds/potatoseed
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	filling_color = "#E9967A"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize = 100

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if (C.use(5))
			user << "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>"
			var/obj/item/weapon/stock_parts/cell/potato/pocell = new /obj/item/weapon/stock_parts/cell/potato(user.loc)
			pocell.maxcharge = src.potency * 20
			pocell.charge = pocell.maxcharge
			qdel(src)
			return
		else
			user << "<span class='warning'>You need five lengths of cable to make a potato battery!</span>"
			return

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/sweet
	seed = /obj/item/seeds/sweetpotatoseed
	name = "sweet potato"
	desc = "It's sweet."
	icon_state = "sweetpotato"
	reagents_add = list("vitamin" = 0.1, "sugar" = 0.1, "nutriment" = 0.1)