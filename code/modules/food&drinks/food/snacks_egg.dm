
////////////////////////////////////////////EGGS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolateegg"

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("sugar", 2)
	reagents.add_reagent("coco", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"

/obj/item/weapon/reagent_containers/food/snacks/egg/New()
	..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/egg_smudge(src.loc)
	reagents.reaction(hit_atom, TOUCH)
	del(src) // Not qdel, because it'll hit other mobs then the floor for runtimes.

/obj/item/weapon/reagent_containers/food/snacks/egg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		var/obj/item/toy/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			usr << "<span class='notice'>[src] refuses to take on this colour!</span>"
			return

		usr << "<span class='notice'>You colour [src] [clr].</span>"
		icon_state = "egg-[clr]"
		item_color = clr
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	item_color = "blue"

/obj/item/weapon/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	item_color = "green"

/obj/item/weapon/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	item_color = "mime"

/obj/item/weapon/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	item_color = "orange"

/obj/item/weapon/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	item_color = "purple"

/obj/item/weapon/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	item_color = "rainbow"

/obj/item/weapon/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	item_color = "red"

/obj/item/weapon/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	item_color = "yellow"

/obj/item/weapon/reagent_containers/food/snacks/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"

/obj/item/weapon/reagent_containers/food/snacks/friedegg/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"

/obj/item/weapon/reagent_containers/food/snacks/boiledegg/New()
	..()
	reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/omelette	//FUCK THIS
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/omelette/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/omelette/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchen/utensil/fork))
		if(W.icon_state == "forkloaded")
			user << "<span class='notice'>You already have omelette on your fork.</span>"
			return
		W.icon_state = "forkloaded"
		user.visible_message( \
			"<span class='notice'>[user] takes a piece of omelette with their fork!</span>", \
			"<span class='notice'>You take a piece of omelette with your fork!</span>" \
		)
		reagents.remove_reagent("nutriment", 1)
		if(reagents.total_volume <= 0)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"

/obj/item/weapon/reagent_containers/food/snacks/benedict/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 4)
	bitesize = 3
