
#define INGREDIENTS_FILL 1
#define INGREDIENTS_SCATTER 2
#define INGREDIENTS_STACK 3
#define INGREDIENTS_LINE 4

//**************************************************************
//
// Customizable Food
// ---------------------------
// Did the best I could. Still tons of duplication.
// Part of it is due to shitty reagent system.
// Other part due to limitations of attackby().
//
//**************************************************************

// Bowl ////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/glass/bowl
	name = "bowl"
	icon_state	= "snack_bowl"
	name = "bowl"
	desc = "A simple bowl, used for soups and salads."
	icon = 'icons/obj/food.dmi'
	icon_state = "bowl"
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/bowl/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = I
		if(I.w_class > 2)
			user << "<span class='warning'>The ingredient is too big for [src].</span>"
		else if(contents.len >= 20)
			user << "<span class='warning'>You can't add more ingredients to [src].</span>"
		else
			if(reagents.has_reagent("water", 10)) //are we starting a soup or a salad?
				var/obj/item/weapon/reagent_containers/food/snacks/customizable/A = new/obj/item/weapon/reagent_containers/food/snacks/customizable/soup(get_turf(src))
				A.initialize_custom_food(src, S, user)
			else
				var/obj/item/weapon/reagent_containers/food/snacks/customizable/A = new/obj/item/weapon/reagent_containers/food/snacks/customizable/salad(get_turf(src))
				A.initialize_custom_food(src, S, user)
	else . = ..()
	return

/obj/item/weapon/reagent_containers/glass/bowl/on_reagent_change()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bowl/update_icon()
	overlays.Cut()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/food.dmi', src, "soupcustom_filling")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
		//if bad result, simply give it wishsoup icon

// Customizable Foods //////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable
	bitesize = 3
	w_class = 3

	var/ingMax = 12
	var/list/ingredients = list()
	var/Ingredientsplacement = INGREDIENTS_FILL
	var/special_top = null //icon for special top element, e.g. burger top (different icon than burger bottom)

/obj/item/weapon/reagent_containers/food/snacks/customizable/examine(mob/user)
	..()
	var/ingredients_listed = ""
	for(var/obj/item/weapon/reagent_containers/food/snacks/ING in ingredients)
		ingredients_listed += "[ING.name], "
	user << "It contains [ingredients_listed]making a [ingredients.len>5?"big":"standard"]-sized [initial(name)]."

/obj/item/weapon/reagent_containers/food/snacks/customizable/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = I
		if(I.w_class > 2)
			user << "<span class='warning'>The ingredient is too big for [src].</span>"
		else if((contents.len >= ingMax) || (reagents.total_volume >= volume))
			user << "<span class='warning'>You can't add more ingredients to [src].</span>"
		else
			user.drop_item()
			if(S.trash)
				new S.trash(get_turf(user))
				S.trash = null  //we remove the plate before adding the ingredient
			ingredients += S
			S.loc = src
			S.reagents.trans_to(src,S.reagents.total_volume)
			update_overlays(S)
			if(istype(S, /obj/item/weapon/reagent_containers/food/snacks/meat/human))
				var/obj/item/weapon/reagent_containers/food/snacks/meat/human/H
				if(H.subjectname)
					name = "[H.subjectname] [initial(name)]"
				else if(H.subjectjob)
					name = "[H.subjectjob] [initial(name)]"
			w_class = n_ceil(Clamp((ingredients.len/2),1,3))
			user << "<span class='notice'>You add the [I.name] to the [src.name].</span>"

	else . = ..()
	return

// Initialize custom food //////////////////////////////////////////////


/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/initialize_custom_food(obj/item/BASE, obj/item/I, mob/user)
	if(istype(BASE,/obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RC = BASE
		RC.reagents.trans_to(src,RC.reagents.total_volume)
	if(I && user)
		attackby(I, user)
	qdel(BASE)

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/initialize_custom_food(obj/item/weapon/reagent_containers/BASE, obj/item/I, mob/user)
	icon_state = BASE.icon_state
	..()


/obj/item/weapon/reagent_containers/food/snacks/customizable/update_overlays(obj/item/weapon/reagent_containers/food/snacks/S)

	var/image/I = new(src.icon, "[initial(icon_state)]_filling")

	if(S.filling_color == "#FFFFFF")
		I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
	else
		I.color = S.filling_color

	switch(Ingredientsplacement)

		if(INGREDIENTS_SCATTER)
			I.pixel_x = pick(list(-1,0,1))
			I.pixel_y = pick(list(-1,0,1))
		if(INGREDIENTS_STACK)
			I.pixel_y = ingredients.len
			overlays.Cut(ingredients.len)
			var/top_icon = "[icon_state]"
			if(special_top)
				top_icon = special_top
			var/image/TOP = new(icon, "[top_icon]")
			TOP.pixel_y = ingredients.len + 4
			overlays += I
			overlays += TOP
			return
		if(INGREDIENTS_FILL)
			overlays.Cut()
		if(INGREDIENTS_LINE)
			I.pixel_y = pick(list(-3,0,3))
			I.pixel_x = 2*I.pixel_y

	overlays += I

/obj/item/weapon/reagent_containers/food/snacks/customizable/create_slices(slices_lost)
	if(!slice_path || !slices_num)
		return
	var/reagents_per_slice = reagents.total_volume/slices_num
	for(var/i=1 to (slices_num-slices_lost))
		var/obj/item/weapon/reagent_containers/food/snacks/slice = new slice_path (loc)
		if(ingredients.len)
			var/obj/item/weapon/reagent_containers/food/snacks/S = pick(ingredients)
			slice.update_overlays(S)
		reagents.trans_to(slice,reagents_per_slice)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/customizable/Destroy()
	for(. in ingredients)
		qdel(.)
	return ..()





/////////////////////////////////////////////////////////////////////////////
//////////////      Customizable Food Types     /////////////////////////////
/////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable/burger
	name = "burger"
	desc = "A timeless classic."
	icon_state = "bun"
	Ingredientsplacement = INGREDIENTS_STACK
	special_top = "burger_top"

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich
	name = "sandwich"
	desc = "A timeless classic."
	icon_state = "breadslice"
	Ingredientsplacement = INGREDIENTS_STACK

/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	name = "personal pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"
	Ingredientsplacement = INGREDIENTS_SCATTER
	ingMax = 8

/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	name = "spagetti"
	desc = "Noodles. With stuff. Delicious."
	icon_state = "pasta_bot"
	Ingredientsplacement = INGREDIENTS_SCATTER
	ingMax = 6

/obj/item/weapon/reagent_containers/food/snacks/customizable/bread
	name = "bread"
	icon_state = "breadcustom"
	ingMax = 6
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/custom
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/customizable/pie
	name = "pie"
	icon_state = "piecustom"
	ingMax = 6

/obj/item/weapon/reagent_containers/food/snacks/customizable/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"
	ingMax = 6
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/custom
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/customizable/salad
	name = "salad"
	desc = "Very tasty."
	icon_state = "saladcustom"
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	ingMax = 6

/obj/item/weapon/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	icon_state = "soupcustom"
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	ingMax = 8

/obj/item/weapon/reagent_containers/food/snacks/customizable/kebab
	name = "kebab"
	icon_state = "kebabcustom"
	desc = "Delicious meat, on a stick."
	Ingredientsplacement = INGREDIENTS_LINE
	trash = /obj/item/stack/rods
	list_reagents = list("nutriment" = 1)
	ingMax = 6







/////////////////// New Food Ingredients ////////////////////////

// Flour + egg = dough
/obj/item/weapon/reagent_containers/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/egg))
		var/obj/item/weapon/reagent_containers/food/snacks/egg/E = W
		if(flags & OPENCONTAINER)
			if(reagents)
				if(reagents.get_reagent_amount("flour", 15))
					var/obj/item/weapon/reagent_containers/food/snacks/S = new /obj/item/weapon/reagent_containers/food/snacks/dough(get_turf(src))
					user << "<span class='notice'>You mix egg and flour to make some dough.</span>"
					if(E.reagents)
						E.reagents.trans_to(S,E.reagents.total_volume)
					qdel(E)
				else
					user << "<span class='notice'>Not enough flour to make dough.</span>"
			return
	..()

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/store/bread/plain
	bitesize = 2
	list_reagents = list("nutriment" = 3)


// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/weapon/reagent_containers/food/snacks/flatdough(loc)
			user << "<span class='notice'>You flatten [src].</span>"
			qdel(src)
		else
			user << "<span class='notice'>You need to put [src] on a surface to roll it out!</span>"
	else
		..()


// slicable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/pizzabread
	list_reagents = list("nutriment" = 3)

/obj/item/weapon/reagent_containers/food/snacks/pizzabread
	name = "pizza bread"
	desc = "Add ingredients to make a pizza"
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "pizzabread"
	bitesize = 2
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	list_reagents = list("nutriment" = 2)


/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/bun
	bitesize = 2
	list_reagents = list("nutriment" = 1)


/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food.dmi'
	icon_state = "bun"
	bitesize = 2
	list_reagents = list("nutriment" = 4)
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/burger


/obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A raw meat cutlet."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawcutlet"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/cutlet
	bitesize = 2
	list_reagents = list("nutriment" = 4)


/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A cooked meat cutlet."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list("nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/cakebatter
	name = "cake batter"
	desc = "Cook it to get a cake."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cakebatter"
	bitesize = 2
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/store/cake/plain
	list_reagents = list("nutriment" = 4)

// Cake batter + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/cakebatter/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/weapon/reagent_containers/food/snacks/piedough(loc)
			user << "<span class='notice'>You flatten [src].</span>"
			qdel(src)
		else
			user << "<span class='notice'>You need to put [src] on a surface to roll it out!</span>"
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/piedough
	name = "pie dough"
	desc = "Cook it to get a pie."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "piedough"
	bitesize = 2
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/pie/plain
	list_reagents = list("nutriment" = 4)

#undef INGREDIENTS_FILL
#undef INGREDIENTS_SCATTER
#undef INGREDIENTS_STACK
#undef INGREDIENTS_LINE
