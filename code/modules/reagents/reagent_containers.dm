/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = WEIGHT_CLASS_TINY
	var/amount_per_transfer_from_this = 5
	var/list/possible_transfer_amounts = list(5,10,15,20,25,30)
	var/volume = 30
	var/reagent_flags
	var/list/list_reagents = null
	var/spawned_disease = null
	var/disease_amount = 20
	var/spillable = FALSE
	var/list/fill_icon_thresholds = null
	var/fill_icon_state = null // Optional custom name for reagent fill icon_state prefix
	var/container_HP = 2
	var/cached_icon
	var/container_flags

/obj/item/reagent_containers/Initialize(mapload, vol)
	. = ..()
	if(isnum(vol) && vol > 0)
		volume = vol
	create_reagents(volume, reagent_flags)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease()
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent(/datum/reagent/blood, disease_amount, data)

	add_initial_reagents()

/obj/item/reagent_containers/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), .proc/on_reagent_change)
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, .proc/on_reagents_del)

/obj/item/reagent_containers/Destroy()
	return ..()

/obj/item/reagent_containers/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_PARENT_QDELETING))
	return NONE

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/attack_self(mob/user)
	if(possible_transfer_amounts.len)
		var/i=0
		for(var/A in possible_transfer_amounts)
			i++
			if(A == amount_per_transfer_from_this)
				if(i<possible_transfer_amounts.len)
					amount_per_transfer_from_this = possible_transfer_amounts[i+1]
				else
					amount_per_transfer_from_this = possible_transfer_amounts[1]
				to_chat(user, "<span class='notice'>[src]'s transfer amount is now [amount_per_transfer_from_this] units.</span>")
				return

/obj/item/reagent_containers/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		return ..()

/obj/item/reagent_containers/proc/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	var/mob/living/carbon/C = eater
	var/covered = ""
	if(C.is_mouth_covered(head_only = 1))
		covered = "headgear"
	else if(C.is_mouth_covered(mask_only = 1))
		covered = "mask"
	if(covered)
		var/who = (isnull(user) || eater == user) ? "your" : "[eater.p_their()]"
		to_chat(user, "<span class='warning'>You have to remove [who] [covered] first!</span>")
		return FALSE
	return TRUE

/*
 * On accidental consumption, transfer a portion of the reagents to the eater and the item it's in, then continue to the base proc (to deal with shattering glass containers)
 */
/obj/item/reagent_containers/on_accidental_consumption(mob/living/carbon/M, mob/living/carbon/user, obj/item/source_item,  discover_after = TRUE)
	M.losebreath += 2
	reagents?.trans_to(M, min(15, reagents.total_volume / rand(5,10)), transfered_by = user, methods = INGEST)
	if(source_item?.reagents)
		reagents.trans_to(source_item, min(source_item.reagents.total_volume / 2, reagents.total_volume / 5), transfered_by = user, methods = TOUCH)

	return ..()

/obj/item/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()

/obj/item/reagent_containers/fire_act(exposed_temperature, exposed_volume)
	reagents.expose_temperature(exposed_temperature)
	..()

/obj/item/reagent_containers/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	SplashReagents(hit_atom, TRUE)

/obj/item/reagent_containers/proc/bartender_check(atom/target)
	. = FALSE
	if(target.CanPass(src, get_turf(src)) && thrownby && HAS_TRAIT(thrownby, TRAIT_BOOZE_SLIDER))
		. = TRUE

/obj/item/reagent_containers/proc/SplashReagents(atom/target, thrown = FALSE)
	if(!reagents || !reagents.total_volume || !spillable)
		return

	if(ismob(target) && target.reagents)
		if(thrown)
			reagents.total_volume *= rand(5,10) * 0.1 //Not all of it makes contact with the target
		var/mob/M = target
		var/R
		target.visible_message("<span class='danger'>[M] is splashed with something!</span>", \
						"<span class='userdanger'>[M] is splashed with something!</span>")
		for(var/datum/reagent/A in reagents.reagent_list)
			R += "[A.type]  ([num2text(A.volume)]),"

		if(thrownby)
			log_combat(thrownby, M, "splashed", R)
		reagents.expose(target, TOUCH)

	else if(bartender_check(target) && thrown)
		visible_message("<span class='notice'>[src] lands onto the [target.name] without spilling a single drop.</span>")
		return

	else
		if(isturf(target) && reagents.reagent_list.len && thrownby)
			log_combat(thrownby, target, "splashed (thrown) [english_list(reagents.reagent_list)]", "in [AREACOORD(target)]")
			log_game("[key_name(thrownby)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [AREACOORD(target)].")
			message_admins("[ADMIN_LOOKUPFLW(thrownby)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [ADMIN_VERBOSEJMP(target)].")
		visible_message("<span class='notice'>[src] spills its contents all over [target].</span>")
		reagents.expose(target, TOUCH)
		if(QDELETED(src))
			return

	reagents.clear_reagents()

//melts plastic beakers
/obj/item/reagent_containers/microwave_act(obj/machinery/microwave/M)
	reagents.expose_temperature(1000)
	if(container_flags & TEMP_WEAK)
		visible_message("<span class='notice'>[icon2html(src, viewers(DEFAULT_MESSAGE_RANGE, src))] [src]'s melts from the temperature!</span>")
		playsound(src, 'sound/chemistry/heatmelt.ogg', 80, 1)
		qdel(src)
	..()

//melts plastic beakers
/obj/item/reagent_containers/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	reagents.expose_temperature(exposed_temperature)
	temp_check()

/obj/item/reagent_containers/proc/temp_check()
	if(container_flags & TEMP_WEAK)
		if(reagents.chem_temp >= 444)//assuming polypropylene
			START_PROCESSING(SSobj, src)

//melts glass beakers
/obj/item/reagent_containers/proc/pH_check()
	if(container_flags & PH_WEAK)
		if((reagents.pH < 1.5) || (reagents.pH > 12.5)) //superbases/acids don't exist anymore
			START_PROCESSING(SSobj, src)

/// Updates the icon of the container when the reagents change. Eats signal args
/obj/item/reagent_containers/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	update_icon()
	return NONE

/obj/item/reagent_containers/update_overlays()
	. = ..()
	if(!fill_icon_thresholds)
		return
	if(reagents.total_volume)
		var/fill_name = fill_icon_state? fill_icon_state : initial(icon_state)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[fill_name][fill_icon_thresholds[1]]")

		var/percent = round((reagents.total_volume / volume) * 100)
		for(var/i in 1 to fill_icon_thresholds.len)
			var/threshold = fill_icon_thresholds[i]
			var/threshold_end = (i == fill_icon_thresholds.len)? INFINITY : fill_icon_thresholds[i+1]
			if(threshold <= percent && percent < threshold_end)
				filling.icon_state = "[fill_name][fill_icon_thresholds[i]]"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/item/reagent_containers/process()
	if(!cached_icon)
		cached_icon = icon_state
	var/damage
	var/cause
	if(container_flags & PH_WEAK)
		if(reagents.pH < 2)
			damage = (2 - reagents.pH)/20
			cause = "from the caustic acidity"
			playsound(get_turf(src), 'sound/chemistry/bufferadd.ogg', 50, 1)

		if(reagents.pH > 12)
			damage = (reagents.pH - 12)/20
			cause = "from the astringent alkalinity"
			playsound(get_turf(src), 'sound/chemistry/bufferadd.ogg', 50, 1)

	if(container_flags & TEMP_WEAK)
		if(reagents.chem_temp >= 444)
			if(damage)
				damage += (reagents.chem_temp/444)/5
			else
				damage = (reagents.chem_temp/444)/5
			if(cause)
				cause += " and "
			cause += "from the high temperature"
			playsound(get_turf(src), 'sound/chemistry/heatdam.ogg', 50, 1)

	if(!damage || damage <= 0)
		STOP_PROCESSING(SSobj, src)

	container_HP -= damage

	var/damage_percent = ((container_HP / initial(container_HP)*100))
	var/volume_to_remove = 0
	switch(damage_percent)
		if(-INFINITY to 0)
			visible_message("<span class='notice'>[icon2html(src, viewers(DEFAULT_MESSAGE_RANGE, src))] [src]'s melts [cause]!</span>")
			playsound(src, 'sound/chemistry/acidmelt.ogg', 80, 1)
			SSblackbox.record_feedback("tally", "Re_chem", 1, "Times beakers have melted")
			volume_to_remove = volume
		if(0 to 35)
			icon_state = "[cached_icon]_m3"
			desc = "[initial(desc)] It is severely deformed."
			volume_to_remove = volume - initial(volume) * 0.25
		if(35 to 70)
			icon_state = "[cached_icon]_m2"
			desc = "[initial(desc)] It is deformed."
			volume_to_remove = volume - initial(volume) * 0.50
		if(70 to 85)
			desc = "[initial(desc)] It is mildly deformed."
			icon_state = "[cached_icon]_m1"
			volume_to_remove = volume - initial(volume) * 0.75

	if(volume - volume_to_remove == 0)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if(!C.get_item_by_slot(ITEM_SLOT_GLOVES))
				SplashReagents(C)
		else
			SplashReagents(loc)
		STOP_PROCESSING(SSobj, src)
		qdel(src)
		return

	reagents.maximum_volume -= volume_to_remove
	volume -= volume_to_remove

	update_icon()
	update_overlays()
	if(prob(25))
		visible_message("<span class='notice'>[icon2html(src, viewers(DEFAULT_MESSAGE_RANGE, src))] [src]'s is damaged by [cause] and begins to deform!</span>")
