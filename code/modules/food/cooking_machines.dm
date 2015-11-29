
//**************************************************************
//
// Cooking Machinery
// ---------------------
// Now with inheritance!
// Set deepFriedEverything to 0 to disable silliness.
// You can also do this in-game with toggleFryers().
//
//**************************************************************

// Globals /////////////////////////////////////////////////////

var/global/deepFriedEverything = 0
var/global/deepFriedNutriment = 0
var/global/foodNesting = 0
var/global/recursiveFood = 0
var/global/ingredientLimit = 10

/client/proc/configFood()
	set name = "Configure Food"
	set category = "Debug"

	. = (alert("Deep Fried Everything?",,"Yes","No")=="Yes")
	if(.)	deepFriedEverything = 1
	else	deepFriedEverything = 0
	. = (alert("Food Nesting?",,"Yes","No")=="Yes")
	if(.)	foodNesting = 1
	else	foodNesting = 0
	. = (alert("Enable recursive food? (WARNING: May cause server instability!)",,"Yes","No")=="Yes")
	if(.)	recursiveFood = 1
	else	recursiveFood = 0
	. = (input("Deep Fried Nutriment? (1 to 50)"))
	. = text2num(.)
	if(isnum(.) && (. in 1 to 50)) deepFriedNutriment = . //This is absolutely terrible
	else to_chat(usr, "That wasn't a valid number.")
	. = (input("Ingredient Limit? (1 to 100)"))
	. = text2num(.)
	if(isnum(.) && (. in 1 to 100)) ingredientLimit = .
	else to_chat(usr, "That wasn't a valid number.")
	log_admin("[key_name(usr)] set deepFriedEverything to [deepFriedEverything].")
	log_admin("[key_name(usr)] set foodNesting to [foodNesting].")
	log_admin("[key_name(usr)] set deepFriedNutriment to [deepFriedNutriment]")
	log_admin("[key_name(usr)] set ingredientLimit to [ingredientLimit]")

	message_admins("[key_name(usr)] set deepFriedEverything to [deepFriedEverything].")
	message_admins("[key_name(usr)] set foodNesting to [foodNesting].")
	message_admins("[key_name(usr)] set deepFriedNutriment to [deepFriedNutriment]")
	message_admins("[key_name(usr)] set ingredientLimit to [ingredientLimit]")
	return

// Base (Oven) /////////////////////////////////////////////////

/obj/machinery/cooking
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	var/icon_state_on = "oven_on"
	var/recursive_ingredients = 0 //allow /food/snacks/customizable as a valid ingredient
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500

	machine_flags = WRENCHMOVE | FIXED2WORK //need to add circuits before the other flags get in

	var/active				=	0 //Currently cooking?
	var/cookSound			=	'sound/machines/ding.ogg'
	var/cookTime			=	150	//In ticks
	var/obj/item/ingredient	=	null //Current ingredient
	var/list/foodChoices	=	list() //Null if not offered

	var/cooks_in_reagents = 0 //are we able to add stuff to the machine so that reagents are added to food?
	var/cks_max_volume = 50

/obj/machinery/cooking/cultify()
	new /obj/structure/cult/talisman(loc)
	..()

/obj/machinery/cooking/New()
	if (ticker)
		initialize()

	return ..()

/obj/machinery/cooking/initialize()
	if (foodChoices)
		var/obj/item/food

		for (var/path in getFoodChoices())
			food = path

			foodChoices.Add(list(initial(food.name) = path))

	if (cooks_in_reagents) // if we can cook in something
		create_reagents(cks_max_volume) // maximum volume is set by the machine var

/obj/machinery/cooking/proc/getFoodChoices()
	return (typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook))

/obj/machinery/cooking/is_open_container()
	if(cooks_in_reagents)
		return 1

// Interactions ////////////////////////////////////////////////

/obj/machinery/cooking/examine(mob/user)
	. = ..()
	if(src.active)
		to_chat(user, "<span class='info'>It's currently processing [src.ingredient ? src.ingredient.name : ""].</span>")
	if(src.cooks_in_reagents)
		to_chat(user, "<span class='info'>It seems to have [reagents.total_volume] units left.</span>")

/obj/machinery/cooking/attack_hand(mob/user)
	if(isobserver(user))
		to_chat(user, "Your ghostly hand goes straight through.")
	else if(issilicon(user))
		to_chat(user, "This is old analog equipment. You can't interface with it.")

	else if(src.active)
		if(alert(user,"Remove \the [src.ingredient.name]?",,"Yes","No") == "Yes")
			if(src.ingredient && (get_turf(src.ingredient)==get_turf(src)))
				if(Adjacent(user))
					src.active = 0
					src.icon_state = initial(src.icon_state)
					src.ingredient.mouse_opacity = 1
					user.put_in_hands(src.ingredient)
					to_chat(user, "<span class='notice'>You remove \the [src.ingredient.name] from \the [src.name].</span>")
					src.ingredient = null
				else to_chat(user, "You are too far away from [src.name].")
			else src.active = 0
		else to_chat(user, "You leave \the [src.name] alone.")
	else . = ..()

/obj/machinery/cooking/attackby(obj/item/I,mob/user)
	if(src.active)
		to_chat(user, "<span class='warning'>[src.name] is currently busy.</span>")
		return
	else if(..())
		return 1
	else if(istype(user,/mob/living/silicon))
		to_chat(user, "<span class='warning'>That's a terrible idea.</span>")
		return
	else
		src.takeIngredient(I,user)
	return

/obj/machinery/cooking/verb/flush_reagents()
	set name = "Remove ingredients"
	set category = "Object"
	set src in oview(1)

	if(cooks_in_reagents)
		if(do_after(usr, src, src.reagents.total_volume / 10))
			src.reagents.clear_reagents()
			if(usr)
				to_chat(usr, "You clean \the [src] of any ingredients.")

// Food Processing /////////////////////////////////////////////

//Returns "valid" or the reason for denial.
/obj/machinery/cooking/proc/validateIngredient(var/obj/item/I)
	if(istype(I,/obj/item/weapon/grab) || istype(I,/obj/item/tk_grab)) . = "It won't fit."
	else if(istype(I,/obj/item/weapon/disk/nuclear)) . = "It's the fucking nuke disk!"
	else if(!recursive_ingredients && !recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable)) . = "It would be a straining topological exercise."
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks) || istype(I,/obj/item/weapon/holder) || deepFriedEverything) . = "valid"
	else if(istype(I,/obj/item/weapon/reagent_containers)) . = "transto"
	else if(istype(I,/obj/item/organ))
		var/obj/item/organ/organ = I
		if(organ.robotic) . = "That's a prosthetic. It wouldn't taste very good."
		else . = "valid"
	else . = "It's not edible food."
	return

/obj/machinery/cooking/proc/takeIngredient(var/obj/item/I,mob/user)
	. = src.validateIngredient(I)
	if(. == "transto")
		return
	if(. == "valid")
		if(src.foodChoices) . = src.foodChoices[(input("Select production.") in src.foodChoices)]
		if (!Adjacent(user) || user.stat || user.get_active_hand() != I)
			return 0
		user.drop_item(I, src)
		src.ingredient = I
		spawn() src.cook(.)
		to_chat(user, "<span class='notice'>You add \the [I.name] to \the [src.name].</span>")
		return 1
	else to_chat(user, "<span class='warning'>You can't put that in \the [src.name]. \n[.]</span>")
	return 0

/obj/machinery/cooking/proc/transfer_reagents_to_food(var/obj/item/I)
	var/obj/item/target_food
	if(I)
		target_food = I
	else if (src.ingredient)
		target_food = ingredient

	if(!target_food || !src.reagents || !src.reagents.total_volume) //we have nothing to transfer to or nothing to transfer from
		return

	if(istype(target_food,/obj/item/weapon/reagent_containers))
		for(var/datum/reagent/reagent in reagents.reagent_list)
			src.reagents.trans_id_to(target_food, reagent.id, max(5, target_food.w_class * 5) / reagents.reagent_list.len)
	return

/obj/machinery/cooking/proc/cook_after(var/delay, var/numticks = 5) //adaptation of do_after()
	var/delayfraction = round(delay/numticks)
	for (var/i = 1 to numticks)
		sleep(delayfraction)
		if (!src.ingredient || !active || get_turf(src.ingredient)!=get_turf(src))
			return 0
	return 1

/obj/machinery/cooking/proc/cook(var/foodType)
	src.active = 1
	src.icon_state = src.icon_state_on
	if (cook_after(src.cookTime, 25))
		src.makeFood(foodType)
		playsound(get_turf(src),src.cookSound,100,1)
	src.active = 0
	src.icon_state = initial(src.icon_state)
	return

/obj/machinery/cooking/proc/makeFood(var/foodType)
	if(istype(src.ingredient, /obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.ingredient
		if(H.stored_mob)
			H.stored_mob.ghostize()
			H.stored_mob.death()
			H.contents -= H.stored_mob
			qdel(H.stored_mob)
			H.stored_mob = null

	var/obj/item/I = src.ingredient
	var/obj/item/weapon/reagent_containers/food/new_food = new foodType(src.loc,I)
	if(cooks_in_reagents)
		transfer_reagents_to_food(new_food)

	if(I.reagents)
		I.reagents.trans_to(new_food,I.reagents.total_volume)

	if (istype(new_food, /obj/item/weapon/reagent_containers/food/snacks/customizable))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/F = new_food
		F.ingredients += I
		F.updateName()
		F.overlays += F.generateFilling(I)
	else if (istype(new_food, /obj/item/weapon/reagent_containers/food/drinks/bottle/customizable))
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/F = new_food
		F.ingredients += I
		F.updateName()
		F.overlays += F.generateFilling(I)
	src.ingredient = null
	return new_food

// Candy Machine ///////////////////////////////////////////////

/obj/machinery/cooking/candy
	name = "candy machine"
	desc = "Makes you the candyman."
	icon_state = "mixer_off"
	icon_state_on = "mixer_on"
	cookSound = 'sound/machines/juicer.ogg'


/obj/machinery/cooking/candy/validateIngredient(var/obj/item/I)
	. = ..()
	if ((. == "valid") && (!foodNesting))
		for (var/food in foodChoices)
			if (findtext(I.name, food))
				. = "It's already candy."
				break

/*/obj/machinery/cooking/candy/makeFood(var/foodType)
	var/old_food = src.ingredient.name
	var/obj/item/weapon/reagent_containers/food/new_food = ..()
	new_food.name = "[old_food] [new_food.name]"
	return new_food*/

/obj/machinery/cooking/candy/getFoodChoices()
	return (typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy))


// Still ///////////////////////////////////////////////////////

/obj/machinery/cooking/still
	name = "still"
	desc = "Alright, so, t'make some moonshine, fust yo' gotta combine some of this hyar egg wif th' deep fried sausage."
	icon_state = "still_off"
	icon_state_on = "still_on"
	cookSound = 'sound/machines/juicer.ogg'

/obj/machinery/cooking/still/validateIngredient(var/obj/item/I)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/grown)) . = "valid"
	else . = "It ain't grown food!"
	return

/obj/machinery/cooking/still/getFoodChoices()
	return (typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable)-(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable))

// Cereal Maker ////////////////////////////////////////////////

/obj/machinery/cooking/cerealmaker
	name = "cereal maker"
	desc = "Sorry, Dann-O's are not available. But everything else is."
	icon_state = "cereal_off"
	icon_state_on = "cereal_on"
	foodChoices = null

/obj/machinery/cooking/cerealmaker/validateIngredient(var/obj/item/I)
	. = ..()
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"cereal")) . = "It's already cereal."
	return

/obj/machinery/cooking/cerealmaker/makeFood()
	var/obj/item/weapon/reagent_containers/food/snacks/cereal/C = new(src.loc)
	if(src.ingredient.reagents)
		src.ingredient.reagents.trans_to(C,src.ingredient.reagents.total_volume)
	if(cooks_in_reagents)
		src.transfer_reagents_to_food(C) //add the stuff from the machine
	C.name = "[src.ingredient.name] cereal"
	var/image/I = image(getFlatIcon(src.ingredient, src.ingredient.dir, 0))
	I.transform *= 0.7
	C.overlays += I

	if(istype(src.ingredient, /obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.ingredient
		if(H.stored_mob)
			H.stored_mob.ghostize()
			H.stored_mob.death()

			qdel(H.stored_mob)

	qdel(src.ingredient)
	src.ingredient = null

	return

// Deep Fryer //////////////////////////////////////////////////

#define DEEPFRY_MINOIL	50

/obj/machinery/cooking/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon_state = "fryer_off"
	icon_state_on = "fryer_on"
	foodChoices = null
	cookTime = 200
	recursive_ingredients = 1

	cks_max_volume = 400
	cooks_in_reagents = 1

/obj/machinery/cooking/deepfryer/initialize()
	..()
	reagents.add_reagent("cornoil", 300)

/obj/machinery/cooking/deepfryer/proc/empty_icon() //sees if the value is empty, and changes the icon if it is
	reagents.update_total() //make the values refresh
	if(ingredient)
		icon_state = "fryer_on"
	else if(reagents.total_volume < DEEPFRY_MINOIL)
		icon_state = "fryer_empty"
	else
		icon_state = initial(icon_state)

/obj/machinery/cooking/deepfryer/attackby()
	. = ..()
	empty_icon()

/obj/machinery/cooking/deepfryer/takeIngredient(var/obj/item/I, mob/user)
	if(reagents.total_volume < DEEPFRY_MINOIL)
		to_chat(user, "\The [src] doesn't have enough oil to fry in.")
		return
	else
		return ..()

/obj/machinery/cooking/deepfryer/validateIngredient(var/obj/item/I)
	. = ..()
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"fried")) . = "It's already deep-fried."
		else if(findtext(I.name,"grilled")) . = "It's already grilled."
	return

/obj/machinery/cooking/deepfryer/flush_reagents()
	..()
	empty_icon()

/obj/machinery/cooking/deepfryer/makeFood(var/item/I)
	if(istype(src.ingredient,/obj/item/weapon/reagent_containers/food/snacks))
		if(cooks_in_reagents)
			src.transfer_reagents_to_food(src.ingredient)
		src.ingredient.name = "deep fried [src.ingredient.name]"
		src.ingredient.color = "#FFAD33"
		src.ingredient.loc = src.loc
	else //some admin enabled funfood and we're frying the captain's ID or someshit
		var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/D = new(src.loc)
		if(cooks_in_reagents)
			src.transfer_reagents_to_food(D)
		D.name = "deep fried [src.ingredient.name]"
		D.color = "#FFAD33"
		D.icon = src.ingredient.icon
		D.icon_state = src.ingredient.icon_state
		D.overlays = src.ingredient.overlays

		if(istype(src.ingredient, /obj/item/weapon/holder))
			var/obj/item/weapon/holder/H = src.ingredient
			if(H.stored_mob)
				H.stored_mob.ghostize()
				H.stored_mob.death()
				qdel(H.stored_mob)

		qdel(src.ingredient)

	src.ingredient = null
	empty_icon() //see if the icon needs updating from the loss of oil
	return

// Grill ///////////////////////////////////////////////////////

/obj/machinery/cooking/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon_state = "grill_off"
	icon_state_on = "grill_on"
	foodChoices = null
	cookTime = 210
	recursive_ingredients = 1

	cooks_in_reagents = 1

/obj/machinery/cooking/grill/validateIngredient(var/obj/item/I)
	. = ..()
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"fried")) . = "It's already deep-fried."
		else if(findtext(I.name,"grilled")) . = "It's already grilled."
	return

/obj/machinery/cooking/grill/cook()
	src.active = 1
	src.icon_state = src.icon_state_on
	src.ingredient.pixel_y += 5
	src.ingredient.loc = src.loc
	src.ingredient.mouse_opacity = 0
	if (cook_after(src.cookTime/3, 14))
		src.ingredient.color = "#C28566"
		if (cook_after(src.cookTime/3, 14))
			src.ingredient.color = "#A34719"
			if (cook_after(src.cookTime/3, 14))
				src.makeFood()
				playsound(get_turf(src),src.cookSound,100,1)
	src.icon_state = initial(src.icon_state)
	src.active = 0
	return

/obj/machinery/cooking/grill/makeFood()
	if(cooks_in_reagents)
		src.transfer_reagents_to_food()
	if(istype(src.ingredient,/obj/item/weapon/reagent_containers/food))
		var/obj/item/weapon/reagent_containers/food/F = src.ingredient
		F.reagents.add_reagent("nutriment",10)
		F.reagents.trans_to(src.ingredient,src.ingredient.reagents.total_volume)
	src.ingredient.mouse_opacity = 1
	src.ingredient.name = "grilled [src.ingredient.name]"
	src.ingredient.loc = src.loc

	if(istype(src.ingredient, /obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.ingredient
		if(H.stored_mob)
			H.stored_mob.ghostize()
			H.stored_mob.death()
			qdel(H.stored_mob)

	src.ingredient = null
	return
