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
	///The icon state to revert to when the tool is empty
	var/spent_icon_state = "rsf_empty"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	///The current matter count
	var/matter = 0
	///The max amount of matter in the device
	var/max_matter = 30
	///The type of the object we are going to dispense
	var/to_dispense
	///The cost of the object we are going to dispense
	var/dispense_cost = 0
	w_class = WEIGHT_CLASS_NORMAL
	///An associated list of atoms and charge costs. This can contain a seperate list, as long as it's associated item is an object
	var/list/cost_by_item = list(/obj/item/reagent_containers/food/drinks/drinkingglass = 20,
								/obj/item/paper = 10,
								/obj/item/storage/pill_bottle/dice = 200,
								/obj/item/pen = 50,
								/obj/item/clothing/mask/cigarette = 10,
								)
	///An associated list of fuel and it's value
	var/list/matter_by_item = list(/obj/item/rcd_ammo = 10,)
	///A list of surfaces that we are allowed to place things on.
	var/list/allowed_surfaces = list(/turf/open/floor, /obj/structure/table)
	///The unit of mesure of the matter, for use in text
	var/discriptor = "fabrication-units"
	///The verb that describes what we're doing, for use in text
	var/action_type = "Dispensing"

/obj/item/rsf/Initialize()
	. = ..()
	to_dispense = cost_by_item[1]
	dispense_cost = cost_by_item[to_dispense]

/obj/item/rsf/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It currently holds [matter]/[max_matter] [discriptor].</span>"

/obj/item/rsf/cyborg
	matter = 30

/obj/item/rsf/attackby(obj/item/W, mob/user, params)
	if(is_type_in_list(W,matter_by_item))//If the thing we got hit by is in our matter list
		var/tempMatter = matter_by_item[W.type] + matter
		if(tempMatter > max_matter)
			to_chat(user, "<span class='warning'>\The [src] can't hold any more [discriptor]!</span>")
			return
		qdel(W)
		matter = tempMatter //We add its value
		playsound(src.loc, 'sound/machines/click.ogg', 10, TRUE)
		to_chat(user, "<span class='notice'>\The [src] now holds [matter]/[max_matter] [discriptor].</span>")
		icon_state = initial(icon_state)//and set the icon state to the initial value it had
	else
		return ..()

/obj/item/rsf/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, FALSE)
	var/target = cost_by_item
	var/cost = 0
	//Warning, prepare for bodgecode
	while(islist(target))//While target is a list we continue the loop
		var/picked = show_radial_menu(user, src, formRadial(target), custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE)
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
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/rsf/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!is_allowed(A))
		return
	if(use_matter(dispense_cost, user))//If we can charge that amount of charge, we do so and return true
		playsound(loc, 'sound/machines/click.ogg', 10, TRUE)
		var/atom/meme = new to_dispense(get_turf(A))
		to_chat(user, "<span class='notice'>[action_type] [meme.name]...</span>")

///A helper proc. checks to see if we can afford the amount of charge that is passed, and if we can docs the charge from our base, and returns TRUE. If we can't we return FALSE
/obj/item/rsf/proc/use_matter(charge, mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		var/end_charge = R.cell.charge - charge
		if(end_charge < 0)
			to_chat(user, "<span class='warning'>You do not have enough power to use [src].</span>")
			icon_state = spent_icon_state
			return FALSE
		R.cell.charge = end_charge
		return TRUE
	else
		if(matter - 1 < 0)
			to_chat(user, "<span class='warning'>\The [src] doesn't have enough [discriptor] left.</span>")
			icon_state = spent_icon_state
			return FALSE
		matter--
		to_chat(user, "<span class='notice'>\The [src] now holds [matter]/[max_matter] [discriptor].</span>")
		return TRUE

///Helper proc that iterates through all the things we are allowed to spawn on, and sees if the passed atom is one of them
/obj/item/rsf/proc/is_allowed(atom/to_check)
	for(var/sort in allowed_surfaces)
		if(istype(to_check, sort))
			return TRUE
	return FALSE

/obj/item/rsf/cookiesynth
	name = "Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon_state = "rcd"
	spent_icon_state = "rcd"
	max_matter = 10
	cost_by_item = list(/obj/item/reagent_containers/food/snacks/cookie = 100)
	dispense_cost = 100
	discriptor = "cookie-units"
	action_type = "Fabricates"
	///Tracks whether or not the cookiesynth is about to print a poisoned cookie
	var/toxin = FALSE //This might be better suited to some initialize fuckery, but I don't have a good "poisoned" sprite
	///Holds a copy of world.time taken the last time the synth gained a charge. Used with cooldowndelay to track when the next charge should be gained
	var/cooldown = 0
	///The period between recharges
	var/cooldowndelay = 10

/obj/item/rsf/cookiesynth/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/item/rsf/cookiesynth/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/item/rsf/cookiesynth/attackby()
	return

/obj/item/rsf/cookiesynth/emag_act(mob/user)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>You short out [src]'s reagent safety checker!</span>")
	else
		to_chat(user, "<span class='warning'>You reset [src]'s reagent safety checker!</span>")

/obj/item/rsf/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(iscyborg(user))
		P = user
	if(((obj_flags & EMAGGED) || (P?.emagged)) && !toxin)
		toxin = TRUE
		to_dispense = /obj/item/reagent_containers/food/snacks/cookie/sleepy
		to_chat(user, "<span class='alert'>Cookie Synthesizer hacked.</span>")
	else
		toxin = FALSE
		to_dispense = /obj/item/reagent_containers/food/snacks/cookie
		to_chat(user, "<span class='notice'>Cookie Synthesizer reset.</span>")

/obj/item/rsf/cookiesynth/process(delta_time)
	matter = min(matter += delta_time, max_matter) //We add 1 up to a point
	if(matter >= max_matter)
		STOP_PROCESSING(SSprocessing, src)

/obj/item/rsf/cookiesynth/afterattack(atom/A, mob/user, proximity)
	if(cooldown > world.time)
		return
	. = ..()
	cooldown = world.time + cooldowndelay
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSprocessing, src)
