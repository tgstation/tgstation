
////////////////////////////////////////////EGGS////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolateegg"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 4, "sugar" = 2, "cocoa" = 2)
	filling_color = "#A0522D"
	tastes = list("chocolate" = 4, "sweetness" = 1)
	foodtype = JUNKFOOD | SUGAR

/obj/item/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	list_reagents = list("eggyolk" = 5)
	cooked_type = /obj/item/reagent_containers/food/snacks/boiledegg
	filling_color = "#F0E68C"
	foodtype = MEAT
	grind_results = list()

/obj/item/reagent_containers/food/snacks/egg/gland
	desc = "An egg! It looks weird..."

/obj/item/reagent_containers/food/snacks/egg/gland/Initialize()
	. = ..()
	reagents.add_reagent(get_random_reagent_id(), 15)

	var/color = mix_color_from_reagents(reagents.reagent_list)
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

/obj/item/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		var/turf/T = get_turf(hit_atom)
		new/obj/effect/decal/cleanable/food/egg_smudge(T)
		reagents.reaction(hit_atom, TOUCH)
		qdel(src)

/obj/item/reagent_containers/food/snacks/egg/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		var/clr = C.item_color

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			to_chat(usr, "<span class='notice'>[src] refuses to take on this colour!</span>")
			return

		to_chat(usr, "<span class='notice'>You colour [src] with [W].</span>")
		icon_state = "egg-[clr]"
		item_color = clr
	else
		..()

/obj/item/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	item_color = "blue"

/obj/item/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	item_color = "green"

/obj/item/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	item_color = "mime"

/obj/item/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	item_color = "orange"

/obj/item/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	item_color = "purple"

/obj/item/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	item_color = "rainbow"

/obj/item/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	item_color = "red"

/obj/item/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	item_color = "yellow"

/obj/item/reagent_containers/food/snacks/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	bitesize = 1
	filling_color = "#FFFFF0"
	list_reagents = list("nutriment" = 3)
	tastes = list("egg" = 4, "salt" = 1, "pepper" = 1)
	foodtype = MEAT | FRIED

/obj/item/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	filling_color = "#FFFFF0"
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	tastes = list("egg" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/omelette	//FUCK THIS
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 8, "vitamin" = 1)
	bitesize = 1
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("egg" = 1, "cheese" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/omelette/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/kitchen/fork))
		var/obj/item/kitchen/fork/F = W
		if(F.forkload)
			to_chat(user, "<span class='warning'>You already have omelette on your fork!</span>")
		else
			F.icon_state = "forkloaded"
			user.visible_message("[user] takes a piece of omelette with [user.p_their()] fork!", \
				"<span class='notice'>You take a piece of omelette with your fork.</span>")

			var/datum/reagent/R = pick(reagents.reagent_list)
			reagents.remove_reagent(R.id, 1)
			F.forkload = R
			if(reagents.total_volume <= 0)
				qdel(src)
		return
	..()

/obj/item/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"
	bonus_reagents = list("vitamin" = 4)
	trash = /obj/item/trash/plate
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list("nutriment" = 6, "vitamin" = 4)
	tastes = list("egg" = 1, "bacon" = 1, "bun" = 1)

	foodtype = MEAT
