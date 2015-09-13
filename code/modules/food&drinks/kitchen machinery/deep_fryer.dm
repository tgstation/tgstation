// Deep Fryer //////////////////////////////////////////////////





/obj/machinery/cooking/deepfryer
	name = "deep fryer"
	desc = "A large Deep fryer. You feel fat just from looking at it."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer_off"
	var/icon_state_on = "fryer_on"
	//cookTime = 200
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500
	reagents = new(0)
	var/active				=	0 //Currently cooking?
	var/cookSound			=	'sound/machines/ding.ogg'
	var/cookTime			=	30	//In ticks
	var/obj/item/ingredient	=	null //Current ingredient
	var/fry_power = 1
	var/oil_min_volume = 10
	var/oil_current_volume = 0
	var/oil_in_use = null
	flags = OPENCONTAINER



/obj/machinery/cooking/deepfryer/New()
	..()
	create_reagents(100)
	reagents.maximum_volume = 100
	//reagents.add_reagent("cornoil", 100)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/deepfryer(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()
	empty_icon()

/obj/machinery/cooking/deepfryer/RefreshParts()
	var/F = 1
	var/max_oil = 100
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		F = M.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		max_oil = 100 * M.rating
	fry_power = F
	oil_min_volume = 10 - (3 * (F-1))
	cookTime = 30 - (5 * (F-1))
	reagents.maximum_volume = max_oil

/obj/machinery/cooking/deepfryer/verb/flush_reagents()
	set name = "Remove ingredients"
	set category = "Object"
	set src in oview(1)
	reagents.clear_reagents()
	empty_icon()
	usr << "<span class='notice'>You empty the deep fryer.</span>"

/obj/machinery/cooking/deepfryer/examine(mob/user as mob)
	..()
	if(src.active) user << "<span class='info'>It's currently processing [ingredient ? ingredient.name : ""].</span>"

/obj/machinery/cooking/deepfryer/proc/empty_icon() //sees if the value is empty, and changes the icon if it is
	reagents.update_total() //make the values refresh
	if(ingredient)
		icon_state = "fryer_on"
		return
	if(reagents.total_volume < oil_min_volume)
		icon_state = "fryer_empty"
		return

	icon_state = initial(icon_state)
	return

/obj/machinery/cooking/deepfryer/proc/check_oil()
	oil_current_volume = 0
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.id == "cornoil")
			oil_current_volume = R.volume
			oil_in_use = "cornoil"
		if(R.id == "oil" && R.volume > oil_current_volume)
			oil_current_volume = R.volume
			oil_in_use = "oil"
		if(R.id == "fuel" && R.volume > oil_current_volume)
			oil_current_volume = R.volume
			oil_in_use = "fuel"


/obj/machinery/cooking/deepfryer/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	..()
	empty_icon()
	check_oil()

	if(default_deconstruction_screwdriver(user, "fryer_empty", "fryer_off", O))
		empty_icon()
		return
	if(default_unfasten_wrench(user, O))
		return
	if(exchange_parts(user, O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if(src.active)
		user << "<span class='info'>The deep fryer is already in use.</span>"
		return

	if(oil_current_volume < oil_min_volume)
		user << "<span class='info'>The deep fryer does not have enough oil.</span>"
		return
	if(findtext(O.name,"fried"))
		user << "It's already deep-fried."
		return

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		ingredient = O
		user.drop_item()
		O.loc = src
		user << "<span class='info'>You insert [O.name] in the deep fryer.</span>"
		deepfry(O)
		return


	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		if(!istype(G.affecting, /mob/living/carbon/))
			user << "<span class='warning'>This thing can't be deep fried!</span>"
			return

		user.visible_message("<span class='danger'>[user] forces [G.affecting] into the deep fryer!</span>")
		src.add_fingerprint(user)
		if(do_after(user, cookTime, target = src) && G && G.affecting)
			user.visible_message("<span class='danger'>[user] deep fries [G.affecting]'s face!</span>")
			var/mob/living/carbon/M = G.affecting
			M.apply_damage(25*fry_power,BURN,"head")
			return

	user << "<span class='info'>You can't deep fry that.</span>"
	return

/obj/machinery/cooking/deepfryer/proc/deepfry(var/item/I)
	if(ingredient)
		active = 1
		empty_icon()
		sleep(cookTime)
		playsound(get_turf(src),src.cookSound,100,1)
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id == oil_in_use) R.volume -= oil_min_volume
			else reagents.trans_id_to(ingredient, R.id, fry_power)
		if(oil_in_use == "oil") ingredient.reagents.add_reagent("histamine",fry_power)
		if(oil_in_use == "fuel") ingredient.reagents.add_reagent("tirizene",fry_power)
		ingredient.reagents.add_reagent("nutriment",fry_power)
		ingredient.name = "deep fried [ingredient.name]"
		ingredient.color = "#FFAD33"
		ingredient.loc = src.loc
		ingredient = null
	empty_icon() //see if the icon needs updating from the loss of oil
	active = 0
	return

//add item/cook item
	//check if fried
	//make new item
	//consume oil
