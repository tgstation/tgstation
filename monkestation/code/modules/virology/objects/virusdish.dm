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
	var/datum/disease/contained_virus
	var/open = FALSE
	var/cloud_delay = 8 SECONDS//similar to a mob's breathing
	var/last_cloud_time = 0
	var/mob/last_openner

/obj/item/weapon/virusdish/New(loc)
	..()
	reagents = new(10)
	reagents.my_atom = src
	GLOB.virusdishes.Add(src)

/obj/item/weapon/virusdish/Destroy()
	contained_virus = null
	STOP_PROCESSING(SSobj, src)
	GLOB.virusdishes.Remove(src)
	..()

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
	update_icon()
	to_chat(user,"<span class='notice'>You [open?"open":"close"] dish's lid.</span>")
	if (open)
		last_openner = user
		if (contained_virus)
			contained_virus.log += "<br />[timestamp()] Containment Dish openned by [key_name(user)]."
		processing_objects.Add(src)
	else
		if (contained_virus)
			contained_virus.log += "<br />[timestamp()] Containment Dish closed by [key_name(user)]."
		processing_objects.Remove(src)
	infection_attempt(user)

/obj/item/weapon/virusdish/attackby(obj/item/I, mob/living/user, params)
	..()
	if(istype(I,/obj/item/hand_labeler))
		return
	if((user.istate & ISTATE_HARM) && I.force)
		visible_message("<span class='danger'>The virus dish is smashed to bits!</span>")
		shatter(user)

/obj/item/weapon/virusdish/is_open_container()
	return open

/obj/item/weapon/virusdish/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(.)
		return
	if (!adjacency_flag)
		return
	if (open)
		if (istype(target,/obj/structure/reagent_dispensers))
			var/obj/structure/reagent_dispensers/S = target
			if(S.can_transfer(src, user))
				var/tx_amount = transfer_sub(target, src, S.amount_per_transfer_from_this, user)
				if (tx_amount > 0)
					to_chat(user, "<span class='notice'>You fill \the [src] with [tx_amount] units of the contents of \the [target].</span>")
					return tx_amount
		if (istype(target,/obj/item/weapon/reagent_containers))
			var/success = 0
			var/obj/container = target
			if (!container.is_open_container() && istype(container,/obj/item/weapon/reagent_containers) && !istype(container,/obj/item/weapon/reagent_containers/food/snacks))
				return
			if(target.is_open_container())
				success = transfer_sub(src, target, 10, user, log_transfer = TRUE)
			if (success > 0)
				to_chat(user, "<span class='notice'>You transfer [success] units of the solution to \the [target].</span>")
		if (istype(target,/obj/structure/toilet))
			var/obj/structure/toilet/T = target
			if (T.open)
				empty(user,target)
		if (istype(target,/obj/structure/urinal)||istype(target,/obj/structure/sink))
			empty(user,target)

/obj/item/weapon/virusdish/proc/empty(var/mob/user,var/atom/target)
	if (user && target)
		to_chat(user,"<span class='notice'>You empty \the [src]'s reagents into \the [target].</span>")
	reagents.clear_reagents()
/obj/item/weapon/virusdish/process()
	if (!contained_virus || !(contained_virus.spread & SPREAD_AIRBORNE))
		processing_objects.Remove(src)
		return
	if(world.time - last_cloud_time >= cloud_delay)
		last_cloud_time = world.time
		var/list/L = list()
		L["[contained_virus.uniqueID]-[contained_virus.subID]"] = contained_virus
		getFromPool(/obj/effect/effect/pathogen_cloud/core,get_turf(src), last_openner, virus_copylist(L), FALSE)
/obj/item/weapon/virusdish/random
	name = "growth dish"
/obj/item/weapon/virusdish/random/New(loc)
	..(loc)
	if (loc)//because fuck you /datum/subsystem/supply_shuttle/Initialize()
		var/virus_choice = pick(subtypesof(/datum/disease2/disease))
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
		update_icon()
	else
		GLOB.virusdishes.Remove(src)
/obj/item/weapon/virusdish/throw_impact(atom/hit_atom, var/speed, mob/user)
	..()
	if(isturf(hit_atom))
		visible_message("<span class='danger'>The virus dish shatters on impact!</span>")
		shatter(user)
/obj/item/weapon/virusdish/proc/incubate(var/mutatechance=5,var/growthrate=3)
	if (contained_virus)
		if(!reagents.remove_reagent(VIRUSFOOD,0.2))
			growth = min(growth + growthrate, 100)
		if(!reagents.remove_reagent(WATER,0.2))
			growth = max(growth - growthrate, 0)
		contained_virus.incubate(src,mutatechance)
/obj/item/weapon/virusdish/on_reagent_change()
	if (contained_virus)
		var/datum/reagent/blood/blood = locate() in reagents.reagent_list
		if (blood)
			var/list/L = list()
			L["[contained_virus.uniqueID]-[contained_virus.subID]"] = contained_virus
			blood.data["virus2"] |= filter_disease_by_spread(virus_copylist(L),required = SPREAD_BLOOD)
	..()
/obj/item/weapon/virusdish/proc/shatter(var/mob/user)
	var/obj/effect/decal/cleanable/virusdish/dish = new(get_turf(src))
	dish.pixel_x = pixel_x
	dish.pixel_y = pixel_y
	if (contained_virus)
		dish.contained_virus = contained_virus.getcopy()
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
		contained_virus.log += "<br />[timestamp()] Containment Dish shattered by [key_name(user)]."
		if (contained_virus.spread & SPREAD_AIRBORNE)
			var/strength = contained_virus.infectionchance
			var/list/L = list()
			L["[contained_virus.uniqueID]-[contained_virus.subID]"] = contained_virus
			while (strength > 0)
				getFromPool(/obj/effect/effect/pathogen_cloud/core,get_turf(src), user, virus_copylist(L), FALSE)
				strength -= 40
	qdel(src)
/obj/item/weapon/virusdish/examine(var/mob/user)
	..()
	if(open)
		to_chat(user, "<span class='notice'>Its lid is open!</span>")
	else
		to_chat(user, "<span class='notice'>Its lid is closed!</span>")
	if(info)
		to_chat(user, "<span class='info'>There is a sticker with some printed information on it. <a href ='?src=\ref[src];examine=1'>(Read it)</a></span>")
/obj/item/weapon/virusdish/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["examine"])
		var/datum/browser/popup = new(usr, "\ref[src]", name, 600, 300, src)
		popup.set_content(info)
		popup.open()

/obj/item/weapon/virusdish/infection_attempt(var/mob/living/perp,var/datum/disease2/disease/D)
	if (open)//If the dish is open, we may get infected by the disease inside on top of those that might be stuck on it.
		var/block = 0
		var/bleeding = 0
		if (src in perp.held_items)
			block = perp.check_contact_sterility(HANDS)
			bleeding = perp.check_bodypart_bleeding(HANDS)
			if (!block)
				if (contained_virus.spread & SPREAD_CONTACT)
					perp.infect_disease2(contained_virus, notes="(Contact, from picking up \a [src])")
				else if (bleeding && (contained_virus.spread & SPREAD_BLOOD))
					perp.infect_disease2(contained_virus, notes="(Blood, from picking up \a [src])")
		else if (isturf(loc) && loc == perp.loc)//is our perp standing over the open dish?
			if (perp.lying)
				block = perp.check_contact_sterility(FULL_TORSO)
				bleeding = perp.check_bodypart_bleeding(FULL_TORSO)
			else
				block = perp.check_contact_sterility(FEET)
				bleeding = perp.check_bodypart_bleeding(FEET)
			if (!block)
				if (contained_virus.spread & SPREAD_CONTACT)
					perp.infect_disease2(contained_virus, notes="(Contact, from [perp.lying?"lying":"standing"] over a virus dish[last_openner ? " openned by [key_name(last_openner)]" : ""])")
				else if (bleeding && (contained_virus.spread & SPREAD_BLOOD))
					perp.infect_disease2(contained_virus, notes="(Blood, from [perp.lying?"lying":"standing"] over a virus dish[last_openner ? " openned by [key_name(last_openner)]" : ""])")
	..(perp,D)
