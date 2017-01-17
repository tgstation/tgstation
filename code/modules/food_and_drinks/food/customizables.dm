#define INGREDIENTS_FILL 1
#define INGREDIENTS_SCATTER 2
#define INGREDIENTS_STACK 3
#define INGREDIENTS_STACKPLUSTOP 4
#define INGREDIENTS_LINE 5

//**************************************************************
//
// Customizable Food
//
//**************************************************************


/obj/item/weapon/reagent_containers/food/snacks/customizable
	bitesize = 4
	w_class = WEIGHT_CLASS_SMALL
	volume = 80
	unique_rename = 1

	var/ingMax = 12
	var/list/ingredients = list()
	var/ingredients_placement = INGREDIENTS_FILL
	var/customname = "custom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/examine(mob/user)
	..()
	var/ingredients_listed = ""
	for(var/obj/item/weapon/reagent_containers/food/snacks/ING in ingredients)
		ingredients_listed += "[ING.name], "
	var/size = "standard"
	if(ingredients.len<2)
		size = "small"
	if(ingredients.len>5)
		size = "big"
	if(ingredients.len>8)
		size = "monster"
	user << "It contains [ingredients.len?"[ingredients_listed]":"no ingredient, "]making a [size]-sized [initial(name)]."

/obj/item/weapon/reagent_containers/food/snacks/customizable/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable) && istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = I
		if(I.w_class > WEIGHT_CLASS_SMALL)
			user << "<span class='warning'>The ingredient is too big for [src]!</span>"
		else if((ingredients.len >= ingMax) || (reagents.total_volume >= volume))
			user << "<span class='warning'>You can't add more ingredients to [src]!</span>"
		else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/custom) || istype(I, /obj/item/weapon/reagent_containers/food/snacks/cakeslice/custom))
			user << "<span class='warning'>Adding [I.name] to [src] would make a mess.</span>"
		else
			if(!user.unEquip(I))
				return
			if(S.trash)
				S.generate_trash(get_turf(user))
			ingredients += S
			S.loc = src
			mix_filling_color(S)
			S.reagents.trans_to(src,min(S.reagents.total_volume, 15)) //limit of 15, we don't want our custom food to be completely filled by just one ingredient with large reagent volume.
			update_overlays(S)
			user << "<span class='notice'>You add the [I.name] to the [name].</span>"
			update_name(S)
	else . = ..()


/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/update_name(obj/item/weapon/reagent_containers/food/snacks/S)
	for(var/obj/item/I in ingredients)
		if(!istype(S, I.type))
			customname = "custom"
			break
	if(ingredients.len == 1) //first ingredient
		if(istype(S, /obj/item/weapon/reagent_containers/food/snacks/meat))
			var/obj/item/weapon/reagent_containers/food/snacks/meat/M = S
			if(M.subjectname)
				customname = "[M.subjectname]"
			else if(M.subjectjob)
				customname = "[M.subjectjob]"
			else
				customname = S.name
		else
			customname = S.name
	name = "[customname] [initial(name)]"

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/initialize_custom_food(obj/item/BASE, obj/item/I, mob/user)
	if(istype(BASE,/obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RC = BASE
		RC.reagents.trans_to(src,RC.reagents.total_volume)
	for(var/obj/O in BASE.contents)
		contents += O
	if(I && user)
		attackby(I, user)
	user.unEquip(BASE)
	qdel(BASE)

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/mix_filling_color(obj/item/weapon/reagent_containers/food/snacks/S)
	if(ingredients.len == 1)
		filling_color = S.filling_color
	else
		var/list/rgbcolor = list(0,0,0,0)
		var/customcolor = GetColors(filling_color)
		var/ingcolor =  GetColors(S.filling_color)
		rgbcolor[1] = (customcolor[1]+ingcolor[1])/2
		rgbcolor[2] = (customcolor[2]+ingcolor[2])/2
		rgbcolor[3] = (customcolor[3]+ingcolor[3])/2
		rgbcolor[4] = (customcolor[4]+ingcolor[4])/2
		filling_color = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3], rgbcolor[4])

/obj/item/weapon/reagent_containers/food/snacks/customizable/update_overlays(obj/item/weapon/reagent_containers/food/snacks/S)
	var/image/I = new(icon, "[initial(icon_state)]_filling")
	if(S.filling_color == "#FFFFFF")
		I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
	else
		I.color = S.filling_color

	switch(ingredients_placement)
		if(INGREDIENTS_SCATTER)
			I.pixel_x = rand(-1,1)
			I.pixel_y = rand(-1,1)
		if(INGREDIENTS_STACK)
			I.pixel_x = rand(-1,1)
			I.pixel_y = 2 * ingredients.len - 1
		if(INGREDIENTS_STACKPLUSTOP)
			I.pixel_x = rand(-1,1)
			I.pixel_y = 2 * ingredients.len - 1
			overlays.Cut(ingredients.len)
			var/image/TOP = new(icon, "[icon_state]_top")
			TOP.pixel_y = 2 * ingredients.len + 3
			add_overlay(I)
			add_overlay(TOP)
			return
		if(INGREDIENTS_FILL)
			cut_overlays()
			I.color = filling_color
		if(INGREDIENTS_LINE)
			I.pixel_y = rand(-8,3)
			I.pixel_x = I.pixel_y

	add_overlay(I)


/obj/item/weapon/reagent_containers/food/snacks/customizable/initialize_slice(obj/item/weapon/reagent_containers/food/snacks/slice, reagents_per_slice)
	..()
	slice.name = "[customname] [initial(slice.name)]"
	slice.filling_color = filling_color
	slice.update_overlays(src)


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
	ingredients_placement = INGREDIENTS_STACKPLUSTOP
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "bun"


/obj/item/weapon/reagent_containers/food/snacks/customizable/bread
	name = "bread"
	ingMax = 6
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/custom
	slices_num = 5
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "tofubread"


/obj/item/weapon/reagent_containers/food/snacks/customizable/cake
	name = "cake"
	ingMax = 6
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/custom
	slices_num = 5
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "plaincake"


/obj/item/weapon/reagent_containers/food/snacks/customizable/kebab
	name = "kebab"
	desc = "Delicious food on a stick."
	ingredients_placement = INGREDIENTS_LINE
	trash = /obj/item/stack/rods
	list_reagents = list("nutriment" = 1)
	ingMax = 6
	icon_state = "rod"


/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	name = "spaghetti"
	desc = "Noodles. With stuff. Delicious."
	ingredients_placement = INGREDIENTS_SCATTER
	ingMax = 6
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "spaghettiboiled"


/obj/item/weapon/reagent_containers/food/snacks/customizable/pie
	name = "pie"
	ingMax = 6
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "pie"


/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	name = "pizza"
	desc = "A personalized pan pizza meant for only one person."
	ingredients_placement = INGREDIENTS_SCATTER
	ingMax = 8
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/custom
	slices_num = 6
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pizzamargherita"


/obj/item/weapon/reagent_containers/food/snacks/customizable/salad
	name = "salad"
	desc = "Very tasty."
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	ingMax = 6
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "bowl"


/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich
	name = "toast"
	desc = "A timeless classic."
	ingredients_placement = INGREDIENTS_STACK
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "breadslice"
	var/finished = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/initialize_custom_food(obj/item/weapon/reagent_containers/BASE, obj/item/I, mob/user)
	icon_state = BASE.icon_state
	..()

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/breadslice)) //we're finishing the custom food.
		var/obj/item/weapon/reagent_containers/food/snacks/breadslice/BS = I
		if(finished)
			return
		user << "<span class='notice'>You finish the [src.name].</span>"
		finished = 1
		name = "[customname] sandwich"
		BS.reagents.trans_to(src, BS.reagents.total_volume)
		ingMax = ingredients.len //can't add more ingredients after that
		var/image/TOP = new(icon, "[BS.icon_state]")
		TOP.pixel_y = 2 * ingredients.len + 3
		add_overlay(TOP)
		if(istype(BS, /obj/item/weapon/reagent_containers/food/snacks/breadslice/custom))
			var/image/O = new(icon, "[initial(BS.icon_state)]_filling")
			O.color = BS.filling_color
			O.pixel_y = 2 * ingredients.len + 3
			add_overlay(O)
		qdel(BS)
		return
	else
		..()


/obj/item/weapon/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	ingMax = 8
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "wishsoup"

/obj/item/weapon/reagent_containers/food/snacks/customizable/soup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")





// Bowl ////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/glass/bowl
	name = "bowl"
	desc = "A simple bowl, used for soups and salads."
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "bowl"
	container_type = OPENCONTAINER
	materials = list(MAT_GLASS = 500)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/reagent_containers/glass/bowl/attackby(obj/item/I,mob/user, params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = I
		if(I.w_class > WEIGHT_CLASS_SMALL)
			user << "<span class='warning'>The ingredient is too big for [src]!</span>"
		else if(contents.len >= 20)
			user << "<span class='warning'>You can't add more ingredients to [src]!</span>"
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
	cut_overlays()
	if(reagents && reagents.total_volume)
		var/image/filling = image('icons/obj/food/soupsalad.dmi', "fullbowl")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)
	else
		icon_state = "bowl"

#undef INGREDIENTS_FILL
#undef INGREDIENTS_SCATTER
#undef INGREDIENTS_STACK
#undef INGREDIENTS_STACKPLUSTOP
#undef INGREDIENTS_LINE
