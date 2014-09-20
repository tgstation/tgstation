
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

var/global/deepFriedEverything = 1
var/global/deepFriedNutriment = 1
var/global/foodNesting = 1
var/global/ingredientLimit = 30

/client/proc/configFood()
	set name = "Configure Food"
	set category = "Debug"
	. = (alert("Deep Fried Everything?",,"Yes","No")=="Yes")
	if(.)	deepFriedEverything = 1
	else	deepFriedEverything = 0
	. = (alert("Cereal Cereal Cereal?",,"Yes","No")=="Yes")
	if(.)	foodNesting = 1
	else	foodNesting = 0
	. = (input("Deep Fried Nutriment? (1 to 50)"))
	. = text2num(.)
	if(isnum(.) && (. in 1 to 50)) deepFriedNutriment = .
	else usr << "That wasn't a valid number."
	. = (input("Ingredient Limit? (1 to 100)"))
	. = text2num(.)
	if(isnum(.) && (. in 1 to 100)) ingredientLimit = .
	else usr << "That wasn't a valid number."
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
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500

	machine_flags = WRENCHMOVE | FIXED2WORK //need to add circuits before the other flags get in

	var/active				=	0 //Currently cooking?
	var/cookSound			=	'sound/machines/ding.ogg'
	var/cookTime			=	100	//In ticks
	var/obj/item/ingredient	=	null //Current ingredient
	var/list/foodChoices	=	list() //Null if not offered

/obj/machinery/cooking/New()
	if(src.foodChoices)
		src.foodChoices = src.getFoodChoices()
		var/list/L[src.foodChoices.len]
		var/obj/item/foodPath
		for(. in src.foodChoices)
			foodPath = .
			L[initial(foodPath.name)] = foodPath
		src.foodChoices = L
	return ..()

/obj/machinery/cooking/proc/getFoodChoices()
	return (typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook))

// Interactions ////////////////////////////////////////////////

/obj/machinery/cooking/examine()
	. = ..()
	if(src.active) usr << "It's currently processing [src.ingredient ? src.ingredient.name : ""]."
	return

/obj/machinery/cooking/attack_hand(mob/user)
	if(istype(user,/mob/dead/observer))	user << "Your ghostly hand goes straight through."
	else if(istype(user,/mob/living/silicon)) user << "This is old analog equipment. You can't interface with it."
	else if(src.active)
		if(src.ingredient && (get_turf(src.ingredient)==get_turf(src)))
			if(alert(user,"Remove the [src.ingredient.name]?",,"Yes","No") == "Yes")
				src.active = 0
				src.icon_state = initial(src.icon_state)
				src.ingredient.mouse_opacity = 1
				user.put_in_hands(src.ingredient)
				user << "<span class='notice'>You remove the [src.ingredient.name] from the [src.name].</span>"
				src.ingredient = null
			else user << "You leave the [src.name] alone."
		else src.active = 0
	else . = ..()
	return

/obj/machinery/cooking/attackby(obj/item/I,mob/user)
	if(istype(user,/mob/living/silicon))
		user << "<span class='warning'>That's a terrible idea.</span>"
	else if(src.active)
		user << "<span class='warning'>[src.name] is currently busy.</span>"
	else if(!..())
		src.takeIngredient(I,user)
	return

// Food Processing /////////////////////////////////////////////

//Returns "valid" or the reason for denial.
/obj/machinery/cooking/proc/validateIngredient(var/obj/item/I)
	if(istype(I,/obj/item/weapon/grab) || istype(I,/obj/item/tk_grab)) . = "It won't fit."
	else if(istype(I,/obj/item/weapon/disk/nuclear)) . = "It's the fucking nuke disk!"
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks) || deepFriedEverything) . = "valid"
	else . = "It's not edible food."
	return

/obj/machinery/cooking/proc/takeIngredient(var/obj/item/I,mob/user)
	. = src.validateIngredient(I)
	if(. == "valid")
		if(src.foodChoices) . = src.foodChoices[(input("Select production.") in src.foodChoices)]
		user.drop_item()
		I.loc = src
		src.ingredient = I
		spawn() src.cook(.)
		user << "<span class='notice'>You add the [I.name] to the [src.name].</span>"
		return 1
	else user << "<span class='warning'>You can't put that in the [src.name]. \n[.]</span>"
	return 0

/obj/machinery/cooking/proc/cook(var/foodType)
	src.active = 1
	src.icon_state = src.icon_state_on
	sleep(src.cookTime)
	if(!src.ingredient) return
	src.active = 0
	src.icon_state = initial(src.icon_state)
	playsound(get_turf(src),src.cookSound,100,1)
	src.makeFood(foodType)
	return

/obj/machinery/cooking/proc/makeFood(var/foodType)
	new foodType(src.loc,src.ingredient)
	qdel(src.ingredient)
	src.ingredient = null
	return

// Candy Machine ///////////////////////////////////////////////

/obj/machinery/cooking/candy
	name = "candy machine"
	desc = "Makes you the candyman."
	icon_state = "mixer_off"
	icon_state_on = "mixer_on"
	cookSound = 'sound/machines/juicer.ogg'

/obj/machinery/cooking/candy/validateIngredient(var/obj/item/I)
	. = ..()
	if((. == "valid") && (!foodNesting))
		for(. in src.foodChoices)
			if(findtext(I.name,.))
				. = "It's already candy."
				break
	return

/obj/machinery/cooking/candy/makeFood(var/foodType)
	var/obj/item/I = new foodType(src.loc,src.ingredient)
	I.name = "[src.ingredient.name] [I.name]"
	qdel(src.ingredient)
	src.ingredient = null
	return

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
	cookTime = 200

/obj/machinery/cooking/cerealmaker/validateIngredient(var/obj/item/I)
	. = ..()
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"cereal")) . = "It's already cereal."
	return

/obj/machinery/cooking/cerealmaker/makeFood()
	var/obj/item/weapon/reagent_containers/food/snacks/cereal/C = new(src.loc)
	if(istype(src.ingredient,/obj/item/weapon/reagent_containers))
		src.ingredient.reagents.trans_to(C,src.ingredient.reagents.total_volume)
	C.name = "[src.ingredient.name] cereal"
	var/image/I = image(src.ingredient.icon,,src.ingredient.icon_state)
	I.transform *= 0.7
	C.overlays += I
	src.ingredient = null
	qdel(src.ingredient)
	return

// Deep Fryer //////////////////////////////////////////////////

/obj/machinery/cooking/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon_state = "fryer_off"
	icon_state_on = "fryer_on"
	foodChoices = null
	cookTime = 200

/obj/machinery/cooking/deepfryer/validateIngredient(var/obj/item/I)
	. = ..()
	if((. == "valid") && (!foodNesting))
		if(findtext(I.name,"fried")) . = "It's already deep-fried."
		else if(findtext(I.name,"grilled")) . = "It's already grilled."
	return

/obj/machinery/cooking/deepfryer/makeFood(var/item/I)
	var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/D = new(src.loc)
	if(istype(src.ingredient,/obj/item/weapon/reagent_containers))
		src.ingredient.reagents.trans_to(D,src.ingredient.reagents.total_volume)
	D.name = "deep fried [src.ingredient.name]"
	D.icon = src.ingredient.icon
	D.icon_state = src.ingredient.icon_state
	D.overlays = src.ingredient.overlays
	D.color = "#FFAD33"
	src.ingredient = null
	qdel(src.ingredient)
	return

// Grill ///////////////////////////////////////////////////////

/obj/machinery/cooking/deepfryer/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon_state = "grill_off"
	icon_state_on = "grill_on"
	cookTime = 450

/obj/machinery/cooking/deepfryer/grill/cook()
	src.active = 1
	src.icon_state = src.icon_state_on
	src.ingredient.pixel_y += 5
	src.ingredient.loc = src.loc
	src.ingredient.mouse_opacity = 0
	sleep(src.cookTime/3)
	if(src.ingredient) src.ingredient.color = "#C28566"
	sleep(src.cookTime/3)
	src.ingredient.color = "#A34719"
	sleep(src.cookTime/3)
	src.icon_state = initial(src.icon_state)
	src.active = 0
	if(src.ingredient)
		playsound(get_turf(src),src.cookSound,100,1)
		src.makeFood()
	return

/obj/machinery/cooking/deepfryer/grill/makeFood()
	if(istype(src.ingredient,/obj/item/weapon/reagent_containers/food))
		var/obj/item/weapon/reagent_containers/food/F = src.ingredient
		F.reagents.add_reagent("nutriment",10)
		F.reagents.trans_to(src.ingredient,src.ingredient.reagents.total_volume)
	src.ingredient.mouse_opacity = 1
	src.ingredient.name = "grilled [src.ingredient.name]"
	src.ingredient.loc = src.loc
	src.ingredient = null
	return
