///////////////VIRUS DISH///////////////
GLOBAL_LIST_INIT(virusdishes, list())
/obj/item/weapon/virusdish
	name = "growth dish"
	desc = "A petri dish fit to contain viral, bacteriologic, parasitic, or any other kind of pathogenic culture."
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "virusdish"
	w_class = WEIGHT_CLASS_SMALL
	//sterility = 100//the outside of the dish is sterile.
	var/growth = 0
	var/info = ""
	var/analysed = FALSE
	var/datum/disease/advanced/contained_virus
	var/open = FALSE
	var/cloud_delay = 8 SECONDS//similar to a mob's breathing
	var/last_cloud_time = 0
	var/mob/last_openner

/obj/item/weapon/virusdish/New(loc)
	..()
	reagents = new(10)
	reagents.my_atom = src
	GLOB.virusdishes.Add(src)

	var/list/reagent_change_signals = list(
			COMSIG_REAGENTS_ADD_REAGENT,
			COMSIG_REAGENTS_NEW_REAGENT,
			COMSIG_REAGENTS_REM_REAGENT,
			COMSIG_REAGENTS_DEL_REAGENT,
			COMSIG_REAGENTS_CLEAR_REAGENTS,
			COMSIG_REAGENTS_REACTED,
	)
	RegisterSignals(src.reagents, reagent_change_signals, PROC_REF(on_reagent_change))

/obj/item/weapon/virusdish/Destroy()
	contained_virus = null
	STOP_PROCESSING(SSobj, src)
	GLOB.virusdishes.Remove(src)
	. = ..()

/*
/obj/item/weapon/virusdish/clean_blood()
	..()
	if (open)
		contained_virus = null
		growth = 0
		update_icon()
*/

/obj/item/weapon/virusdish/update_icon()
	. = ..()
	overlays.len = 0
	if (!contained_virus)
		if (open)
			icon_state = "virusdish1"
		else
			icon_state = "virusdish"
		return
	icon_state = "virusdish-outline"
	var/image/I1 = image(icon,src,"virusdish-bottom")
	I1.color = contained_virus.color
	var/image/I2 = image(icon,src,"pattern-[contained_virus.pattern]")
	I2.color = contained_virus.pattern_color
	var/image/I3 = image(icon,src,"virusdish-[open?"open":"closed"]")
	I3.color = contained_virus.color
	overlays += I1
	if (open)
		overlays += I3
		I2.alpha = growth*255/200+127
		overlays += I2
	else
		overlays += I2
		overlays += I3
		I2.alpha = (growth*255/200+127)*60/100
		overlays += I2
		var/image/I4 = image(icon,src,"virusdish-reflection")
		overlays += I4
	if (analysed)
		overlays += "virusdish-label"
	else if (info != "" && copytext(info, 1, 9) == "OUTDATED")
		overlays += "virusdish-outdated"

/obj/item/weapon/virusdish/attack_hand(mob/living/user, list/modifiers)
	..()
	infection_attempt(user)

/obj/item/weapon/virusdish/attack_self(mob/living/user, list/modifiers)
	open = !open
	update_appearance()
	to_chat(user,span_notice("You [open?"open":"close"] dish's lid."))
	update_desc()
	if (open)
		last_openner = user
		if (contained_virus)
			contained_virus.log += "<br />[ROUND_TIME()] Containment Dish opened by [key_name(user)]."
		START_PROCESSING(SSobj, src)
	else
		if (contained_virus)
			contained_virus.log += "<br />[ROUND_TIME()] Containment Dish closed by [key_name(user)]."
		STOP_PROCESSING(SSobj, src)
	infection_attempt(user)

/obj/item/weapon/virusdish/attackby(obj/item/I, mob/living/user, params)
	..()
	if(istype(I,/obj/item/hand_labeler))
		return
	if(istype(I, /obj/item/reagent_containers/syringe))
		if(growth < 50)
			to_chat(user, span_warning("There isn't enough growth in the [src]."))
		else
			growth = growth - 50
			var/obj/item/reagent_containers/syringe/B = I
			var/list/data = list("viruses"=null,"blood_DNA"=null,"blood_type"="O-","resistances"=null,"trace_chem"=null,"viruses"=list(),"immunity"=list())
			data["viruses"] |= list(contained_virus)
			B.reagents.add_reagent(/datum/reagent/blood, B.volume, data)
			to_chat(user, span_notice("You take some blood from the [src]."))
	if (open)
		if (istype(I,/obj/item/reagent_containers))
			var/success = 0
			var/obj/container = I
			if (!container.is_open_container() && istype(container, /obj/item/reagent_containers))
				return
			if(I.is_open_container())
				success = I.reagents.trans_to(src, 10, transfered_by = user)
			if (success > 0)
				to_chat(user, span_notice("You transfer [success] units of the solution to \the [src]."))
			return
	if((user.istate & ISTATE_HARM) && I.force)
		visible_message(span_danger("The virus dish is smashed to bits!"))
		shatter(user)

/obj/item/weapon/virusdish/is_open_container()
	return open

/obj/item/weapon/virusdish/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(.)
		return
	if(open)
		if (istype(target,/obj/item/reagent_containers))
			var/success = 0
			var/obj/container = target
			if (!container.is_open_container() && istype(container, /obj/item/reagent_containers))
				return
			if(is_open_container())
				success = reagents.trans_to(target, 10, transfered_by = user)
			if (success > 0)
				to_chat(user, span_notice("You transfer [success] units of the solution to \the [target]."))
			return
		if(istype(target, /obj/structure/reagent_dispensers))
			var/obj/structure/reagent_dispensers/obj = target
			var/success = obj.reagents.trans_to(src, 10, transfered_by = user)
			if (success > 0)
				to_chat(user, span_notice("You transfer [success] units of the solution to \the [src]."))

		if (istype(target,/obj/structure/toilet))
			var/obj/structure/toilet/T = target
			if (T.open)
				empty(user,target)
		if (istype(target,/obj/structure/urinal)||istype(target,/obj/structure/sink))
			empty(user,target)

/obj/item/weapon/virusdish/proc/empty(mob/user, atom/target)
	if (user && target)
		to_chat(user,span_notice("You empty \the [src]'s reagents into \the [target]."))
	reagents.clear_reagents()

/obj/item/weapon/virusdish/process()
	if (!contained_virus || !(contained_virus.spread_flags & DISEASE_SPREAD_AIRBORNE))
		STOP_PROCESSING(SSobj, src)
		return
	if(world.time - last_cloud_time >= cloud_delay)
		last_cloud_time = world.time
		var/list/L = list()
		L += contained_virus
		new /obj/effect/pathogen_cloud/core(get_turf(src), last_openner, virus_copylist(L), FALSE)

/obj/item/weapon/virusdish/random
	name = "growth dish"
/obj/item/weapon/virusdish/random/New(loc)
	..(loc)
	if (loc)//because fuck you /datum/subsystem/supply_shuttle/Initialize()
		var/virus_choice = pick(subtypesof(/datum/disease/advanced)- typesof(/datum/disease/advanced/premade))
		contained_virus = new virus_choice
		var/list/anti = list(
			ANTIGEN_BLOOD	= 2,
			ANTIGEN_COMMON	= 2,
			ANTIGEN_RARE	= 1,
			ANTIGEN_ALIEN	= 0,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 1,
			EFFECT_DANGER_FLAVOR	= 2,
			EFFECT_DANGER_ANNOYING	= 2,
			EFFECT_DANGER_HINDRANCE	= 2,
			EFFECT_DANGER_HARMFUL	= 2,
			EFFECT_DANGER_DEADLY	= 0,
			)
		contained_virus.makerandom(list(50,90),list(10,100),anti,bad,src)
		growth = rand(5, 50)
		name = "growth dish (Unknown [contained_virus.form])"
		update_appearance()
		contained_virus.origin = "Random Dish"
	else
		GLOB.virusdishes.Remove(src)

/obj/item/weapon/virusdish/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(isturf(hit_atom))
		visible_message(span_danger("The virus dish shatters on impact!"))
		shatter(throwingdatum.thrower)

/obj/item/weapon/virusdish/proc/incubate(mutatechance=5, growthrate=3, effect_focus = 0)
	if (contained_virus)
		if(reagents.remove_reagent(/datum/reagent/consumable/virus_food, 0.2))
			growth = min(growth + growthrate, 100)
		if(reagents.remove_reagent(/datum/reagent/water, 0.2))
			growth = max(growth - growthrate, 0)
		contained_virus.incubate(src,mutatechance,effect_focus)

/obj/item/weapon/virusdish/proc/on_reagent_change(datum/reagents/reagents)
	SIGNAL_HANDLER

	if (contained_virus)
		var/datum/reagent/blood/blood = locate() in reagents.reagent_list
		if (blood)
			var/list/L = list()
			L |= contained_virus
			blood.data["diseases"] |= filter_disease_by_spread(L, required = DISEASE_SPREAD_BLOOD)

/obj/item/weapon/virusdish/proc/shatter(mob/user)
	var/obj/effect/decal/cleanable/virusdish/dish = new(get_turf(src))
	dish.pixel_x = pixel_x
	dish.pixel_y = pixel_y
	if (contained_virus)
		dish.contained_virus = contained_virus.Copy()
	dish.last_openner = key_name(user)
	src.transfer_fingerprints_to(dish)
	playsound(get_turf(src), "shatter", 70, 1)
	var/image/I1
	var/image/I2
	if (contained_virus)
		I1 = image(icon,src,"brokendish-color")
		I1.color = contained_virus.color
		I2 = image(icon,src,"pattern-[contained_virus.pattern]b")
		I2.color = contained_virus.pattern_color
	else
		I1 = image(icon,src,"brokendish")
	dish.overlays += I1
	if (contained_virus)
		dish.overlays += I2
		contained_virus.log += "<br />[ROUND_TIME()] Containment Dish shattered by [key_name(user)]."
		if (contained_virus.spread_flags & DISEASE_SPREAD_AIRBORNE)
			var/strength = contained_virus.infectionchance
			var/list/L = list()
			L += contained_virus
			while (strength > 0)
				new /obj/effect/pathogen_cloud/core(get_turf(src), last_openner, virus_copylist(L), FALSE)
				strength -= 40
	qdel(src)

/obj/item/weapon/virusdish/update_desc(updates)
	. = ..()
	desc = initial(desc)
	if(open)
		desc += "\nIts lid is open!"
	else
		desc += "\nIts lid is closed!"
	if(info)
		desc += "\nThere is a sticker with some printed information on it. <a href ='?src=\ref[src];examine=1'>(Read it)</a>"


/obj/item/weapon/virusdish/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["examine"])
		var/datum/browser/popup = new(usr, "\ref[src]", name, 600, 300, src)
		popup.set_content(info)
		popup.open()

/obj/item/weapon/virusdish/infection_attempt(mob/living/perp, datum/disease/D)
	if (open)//If the dish is open, we may get infected by the disease inside on top of those that might be stuck on it.
		var/block = 0
		var/bleeding = 0
		if (src in perp.held_items)
			block = perp.check_contact_sterility(BODY_ZONE_ARMS)
			bleeding = perp.check_bodypart_bleeding(BODY_ZONE_ARMS)
			if (!block && (contained_virus.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
				perp.infect_disease(contained_virus, notes="(Contact, from picking up \a [src])")
			else if (bleeding && (contained_virus.spread_flags & DISEASE_SPREAD_BLOOD))
				perp.infect_disease(contained_virus, notes="(Blood, from picking up \a [src])")
		else if (isturf(loc) && loc == perp.loc)//is our perp standing over the open dish?
			if (perp.body_position & LYING_DOWN)
				block = perp.check_contact_sterility(BODY_ZONE_EVERYTHING)
				bleeding = perp.check_bodypart_bleeding(BODY_ZONE_EVERYTHING)
			else
				block = perp.check_contact_sterility(BODY_ZONE_LEGS)
				bleeding = perp.check_bodypart_bleeding(BODY_ZONE_LEGS)
			if (!block && (contained_virus.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
				perp.infect_disease(contained_virus, notes="(Contact, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over a virus dish[last_openner ? " opened by [key_name(last_openner)]" : ""])")
			else if (bleeding && (contained_virus.spread_flags & DISEASE_SPREAD_BLOOD))
				perp.infect_disease(contained_virus, notes="(Blood, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over a virus dish[last_openner ? " opened by [key_name(last_openner)]" : ""])")
	..(perp,D)
