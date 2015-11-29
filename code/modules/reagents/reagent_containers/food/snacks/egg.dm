// Eat these

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"

/obj/item/weapon/reagent_containers/food/snacks/egg/New()
	..()
	reagents.add_reagent("nutriment", 4)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/egg_smudge(src.loc)
	src.reagents.reaction(hit_atom, TOUCH)
	src.visible_message("<span class='warning'>\The [src.name] has been squashed.</span>","<span class='warning'>You hear a smack.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	_color = "blue"

/obj/item/weapon/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	_color = "green"

/obj/item/weapon/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	_color = "mime"

/obj/item/weapon/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	_color = "orange"

/obj/item/weapon/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	_color = "purple"

/obj/item/weapon/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	_color = "rainbow"

/obj/item/weapon/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	_color = "red"

/obj/item/weapon/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	_color = "yellow"

/obj/item/weapon/reagent_containers/food/snacks/egg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(W.reagents.amount_cache.len == 1 && W.reagents.has_reagent("flour", 5))
			W.reagents.remove_reagent("flour",5)
			new /obj/item/weapon/reagent_containers/food/snacks/dough(src)
			to_chat(user, "You make some dough.")
			qdel(src)
			return 1
	else if (istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			to_chat(user, "<span class='notice'>[src] refuses to take on this colour!</span>")
			return

		to_chat(user, "<span class='notice'>You colour [src] [clr].</span>")
		icon_state = "egg-[clr]"
		_color = clr
	else
		..()
