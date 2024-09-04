/*
CONTAINS:
RSF

*/
///Extracts the related object from an associated list of objects and values, or lists and objects.
#define OBJECT_OR_LIST_ELEMENT(from, input) (islist(input) ? from[input] : input)
/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	inhand_icon_state = "rsf"
	base_icon_state = "rsf"
	///The icon state to revert to when the tool is empty
	var/spent_icon_state = "rsf_empty"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	armor_type = /datum/armor/none
	///The current matter count
	var/matter = 0
	///The max amount of matter in the device
	var/max_matter = 30
	///The type of the object we are going to dispense
	var/to_dispense
	///The cost of the object we are going to dispense
	var/dispense_cost = 0
	w_class = WEIGHT_CLASS_NORMAL
	///An associated list of atoms and charge costs. This can contain a separate list, as long as its associated item is an object
	///The RSF item list below shows in the player facing ui in this order, this is why it isn't in alphabetical order, but instead sorted by category
	var/list/cost_by_item = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass = 20,
		/obj/item/reagent_containers/cup/glass/sillycup = 10,
		/obj/item/plate = 70,
		/obj/item/reagent_containers/cup/bowl = 70,
		/obj/item/kitchen/fork/plastic = 30,
		/obj/item/knife/plastic = 30,
		/obj/item/kitchen/spoon/plastic = 30,
		/obj/item/food/seaweedsheet = 30,
		/obj/item/storage/dice = 200,
		/obj/item/toy/cards/deck = 200,
		/obj/item/paper = 10,
		/obj/item/pen = 50,
		/obj/item/cigarette = 10,
	)
	///An associated list of fuel and its value
	var/list/matter_by_item = list(/obj/item/rcd_ammo = 10,)
	///A list of surfaces that we are allowed to place things on.
	var/list/allowed_surfaces = list(/turf/open/floor, /obj/structure/table)
	///The unit of mesure of the matter, for use in text
	var/discriptor = "fabrication-units"
	///The verb that describes what we're doing, for use in text
	var/action_type = "Dispensing"
	///Holds a copy of world.time from the last time the synth was used.
	var/cooldown = 0
	///How long should the minimum period between this RSF's item dispensings be?
	var/cooldowndelay = 0 SECONDS

/obj/item/rsf/Initialize(mapload)
	. = ..()
	to_dispense = cost_by_item[1]
	dispense_cost = cost_by_item[to_dispense]

/obj/item/rsf/examine(mob/user)
	. = ..()
	. += span_notice("It currently holds [matter]/[max_matter] [discriptor].")

/obj/item/rsf/cyborg
	matter = 30

/obj/item/rsf/attackby(obj/item/W, mob/user, params)
	if(is_type_in_list(W,matter_by_item))//If the thing we got hit by is in our matter list
		var/tempMatter = matter_by_item[W.type] + matter
		if(tempMatter > max_matter)
			to_chat(user, span_warning("\The [src] can't hold any more [discriptor]!"))
			return
		if(isstack(W))
			var/obj/item/stack/stack = W
			stack.use(1)
		else
			qdel(W)
		matter = tempMatter //We add its value
		playsound(src.loc, 'sound/machines/click.ogg', 10, TRUE)
		to_chat(user, span_notice("\The [src] now holds [matter]/[max_matter] [discriptor]."))
		icon_state = base_icon_state//and set the icon state to the base state
	else
		return ..()

/obj/item/rsf/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, FALSE)
	var/target = cost_by_item
	var/cost = 0
	//Warning, prepare for bodgecode
	while(islist(target))//While target is a list we continue the loop
		var/picked = show_radial_menu(user, src, formRadial(target), custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
		if(!check_menu(user) || picked == null)
			return
		for(var/emem in target)//Back through target agian
			var/atom/test = OBJECT_OR_LIST_ELEMENT(target, emem)
			if(picked == initial(test.name))//We try and find the entry that matches the radial selection
				cost = target[emem]//We cash the cost
				target = emem
				break
		//If we found a list we start it all again, this time looking through its contents.
		//This allows for sublists
	to_dispense = target
	dispense_cost = cost
	// Change mode

///Forms a radial menu based off an object in a list, or a list's associated object
/obj/item/rsf/proc/formRadial(from)
	var/list/radial_list = list()
	for(var/meme in from)//We iterate through all of targets entrys
		var/atom/temp = OBJECT_OR_LIST_ELEMENT(from, meme)
		//We then add their data into the radial menu
		radial_list[initial(temp.name)] = image(icon = initial(temp.icon), icon_state = initial(temp.icon_state))
	return radial_list

/obj/item/rsf/proc/check_menu(mob/user)
	if(user.incapacitated || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/rsf/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(cooldown > world.time)
		return NONE
	if (!is_allowed(interacting_with))
		return NONE
	if(use_matter(dispense_cost, user))//If we can charge that amount of charge, we do so and return true
		playsound(loc, 'sound/machines/click.ogg', 10, TRUE)
		var/atom/meme = new to_dispense(get_turf(interacting_with))
		to_chat(user, span_notice("[action_type] [meme.name]..."))
		cooldown = world.time + cooldowndelay
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

///A helper proc. checks to see if we can afford the amount of charge that is passed, and if we can docs the charge from our base, and returns TRUE. If we can't we return FALSE
/obj/item/rsf/proc/use_matter(charge, mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		var/end_charge = R.cell.charge - charge
		if(end_charge < 0)
			to_chat(user, span_warning("You do not have enough power to use [src]."))
			icon_state = spent_icon_state
			return FALSE
		R.cell.charge = end_charge
		return TRUE
	else
		if(matter - 1 < 0)
			to_chat(user, span_warning("\The [src] doesn't have enough [discriptor] left."))
			icon_state = spent_icon_state
			return FALSE
		matter--
		to_chat(user, span_notice("\The [src] now holds [matter]/[max_matter] [discriptor]."))
		return TRUE

///Helper proc that iterates through all the things we are allowed to spawn on, and sees if the passed atom is one of them
/obj/item/rsf/proc/is_allowed(atom/to_check)
	return is_type_in_list(to_check, allowed_surfaces)

/obj/item/rsf/cookiesynth
	name = "Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon_state = "rcd"
	base_icon_state = "rcd"
	spent_icon_state = "rcd"
	max_matter = 10
	cost_by_item = list(/obj/item/food/cookie = 100)
	dispense_cost = 100
	discriptor = "cookie-units"
	action_type = "Fabricates"
	cooldowndelay = 10 SECONDS
	///Tracks whether or not the cookiesynth is about to print a poisoned cookie
	var/toxin = FALSE //This might be better suited to some initialize fuckery, but I don't have a good "poisoned" sprite

/obj/item/rsf/cookiesynth/emag_act(mob/user, obj/item/card/emag/emag_card)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		balloon_alert(user, "reagent safety checker shorted out")
	else
		balloon_alert(user, "reagent safety checker reset")
	return TRUE

/obj/item/rsf/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(iscyborg(user))
		P = user
	if(((obj_flags & EMAGGED) || (P?.emagged)) && !toxin)
		toxin = TRUE
		to_dispense = /obj/item/food/cookie/sleepy
		to_chat(user, span_alert("Cookie Synthesizer hacked."))
	else
		toxin = FALSE
		to_dispense = /obj/item/food/cookie
		to_chat(user, span_notice("Cookie Synthesizer reset."))

#undef OBJECT_OR_LIST_ELEMENT
