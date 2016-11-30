// Potato
/obj/item/seeds/potato
	name = "pack of potato seeds"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "seed-potato"
	species = "potato"
	plantname = "Potato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
	lifespan = 30
	maturation = 10
	production = 1
	yield = 4
	oneharvest = 1
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "potato-grow"
	icon_dead = "potato-dead"
	mutatelist = list(/obj/item/seeds/potato/sweet)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	seed = /obj/item/seeds/potato
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	filling_color = "#E9967A"
	bitesize = 100


/obj/item/weapon/reagent_containers/food/snacks/grown/potato/wedges
	name = "potato wedges"
	desc = "a potato cut up into wedges"
	icon_state = "potato_wedge"
	filling_color = "#E9967A"
	bitesize = 100


/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if (C.use(5))
			user << "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>"
			var/obj/item/weapon/stock_parts/cell/potato/pocell = new /obj/item/weapon/stock_parts/cell/potato(user.loc)
			pocell.maxcharge = seed.potency * 20

			// The secret of potato supercells!
			var/datum/plant_gene/trait/cell_charge/G = seed.get_gene(/datum/plant_gene/trait/cell_charge)
			if(G) // 10x charge for deafult cell charge gene - 20 000 with 100 potency.
				pocell.maxcharge *= G.rate*1000
			pocell.charge = pocell.maxcharge
			pocell.desc = "A rechargable starch based power cell. This one has a power rating of [pocell.maxcharge], and you should not swallow it."

			if(reagents.has_reagent("plasma", 2))
				pocell.rigged = 1

			qdel(src)
			return
		else
			user << "<span class='warning'>You need five lengths of cable to make a potato battery!</span>"
			return
	if(W.is_sharp())
		user << "<span class='notice'>You cut the potato into wedges with [W].</span>"
		var/obj/item/weapon/reagent_containers/food/snacks/grown/potato/wedges/Wedges = new /obj/item/weapon/reagent_containers/food/snacks/grown/potato/wedges
		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.put_in_hands(Wedges)
		qdel(src)
	else
		return ..()


// Sweet Potato
/obj/item/seeds/potato/sweet
	name = "pack of sweet potato seeds"
	desc = "These seeds grow into sweet potato plants."
	icon_state = "seed-sweetpotato"
	species = "sweetpotato"
	plantname = "Sweet Potato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/potato/sweet
	mutatelist = list()
	reagents_add = list("vitamin" = 0.1, "sugar" = 0.1, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/sweet
	seed = /obj/item/seeds/potato/sweet
	name = "sweet potato"
	desc = "It's sweet."
	icon_state = "sweetpotato"