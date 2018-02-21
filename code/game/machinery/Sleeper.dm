/obj/machinery/sleep_console
	name = "sleeper console"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "console"
	density = FALSE
	anchored = TRUE

/obj/machinery/sleeper
	name = "sleeper"
	desc = "An enclosed machine used to stabilize patients."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = FALSE
	anchored = TRUE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/sleeper
	var/efficiency = 1
	var/min_health = -25
	var/list/available_chems
	var/controls_inside = FALSE
	var/obj/item/reagent_containers/list/chem_stores
	var/list/chem_store_names
	var/selected_store = 0
	var/list/possible_chem_stores = list(1, 2, 4, 6)
	var/list/possible_chems
	var/list/chem_buttons	//Used when emagged to scramble which chem is used, eg: antitoxin -> morphine
	var/scrambled_chems = FALSE //Are chem buttons scrambled? used as a warning
	var/enter_message = "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"

/obj/machinery/sleeper/chems
	possible_chems = list(
		list("epinephrine", "morphine", "salbutamol", "bicaridine", "kelotane"),
		list("oculine","inacusiate"),
		list("antitoxin", "mutadone", "mannitol", "pen_acid"),
		list("omnizine")
	)
	possible_chem_stores = null

/obj/machinery/sleeper/Initialize()
	. = ..()
	update_icon()
	reset_chem_buttons()

/obj/machinery/sleeper/Destroy()
	drop_stores()
	..()

/obj/machinery/sleeper/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	var/I
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		I += M.rating

	efficiency = initial(efficiency)* E
	min_health = initial(min_health) * E
	available_chems = list()
	var/list/adding_chems
	for(var/i in 1 to I)
		adding_chems = LAZYACCESS(possible_chems, i)
		if(adding_chems) //With LAZYACCESS, adding_chems can be null, so |= will add nulls, and we don't want nulls.
			available_chems |= adding_chems
	var/new_stores_len = LAZYACCESS(possible_chem_stores, E)
	var/obj/item/reagent_containers/list/new_stores_list = list()
	for(var/i in 1 to new_stores_len)
		var/obj/item/reagent_containers/C = LAZYACCESS(chem_stores, i)
		new_stores_list[i] = C
	drop_stores(new_stores_len)
	chem_stores = new_stores_list
	reset_chem_buttons()



/obj/machinery/sleeper/update_icon()
	icon_state = initial(icon_state)
	if(state_open)
		icon_state += "-open"

/obj/machinery/sleeper/container_resist(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/sleeper/relaymove(mob/user)
	container_resist(user)

/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		..()

/obj/machinery/sleeper/dropContents()
	if(occupant && isliving(occupant))
		var/mob/living/L = occupant
		L.SetStasis(FALSE)
	..()

/obj/machinery/sleeper/drop_stores(from_index = 1)
	var/stores_len = LAZYLEN(chem_stores)
	if(from_index <= stores_len)
		for(var/i in from_index to stores_len)
			eject_store(i)
	UNSETEMPTY(chem_stores)

/obj/machinery/sleeper/add_store(obj/item/reagent_containers/C, store_index)
	store_index = store_index || selected_store
	if(store_index && LAZYLEN(chem_stores) >= store_index && !chem_stores[store_index] && istype(C, /obj/item/reagent_containers))
		chem_stores[store_index] = C
		C.moveToNullspace()
		return TRUE

/obj/machinery/sleeper/eject_store(store_index)
	var/obj/item/reagent_containers/C = LAZYACCESS(chem_stores, store_index)
	if(C)
		var/atom/L = drop_location()
		if(L)
			C.forceMove(L)
		chem_stores[store_index] = null //if L is null then the sleeper is probably in nullspace so we still want to null this ref

#define SLEEPER_STORE_INJECT_AMT 10
/obj/machinery/sleeper/inject_store(store_index)
	var/obj/item/reagent_containers/C = LAZYACCESS(chem_stores, store_index)
	var/datum/reagents/R = C.reagents
	if(C && R && R.total_volume)
		if(isliving(occupant))
			var/mob/living/L = occupant
			if(!L.is_injectable())
				return
		var/coeff = min(SLEEPER_STORE_INJECT_AMT/R.total_volume, 1)
		R.reaction(occupant, INJECT, coeff)
		R.trans_to(occupant, SLEEPER_STORE_INJECT_AMT)
#undef SLEEPER_STORE_INJECT_AMT

/obj/machinery/sleeper/close_machine(mob/living/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant)
			mob_occupant.SetStasis(TRUE)
			mob_occupant.ExtinguishMob()
			if(mob_occupant.stat != DEAD)
				to_chat(occupant, "[enter_message]")

/obj/machinery/sleeper/emp_act(severity)
	if(is_operational() && occupant)
		open_machine()
	..(severity)

/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	close_machine(target)

/obj/machinery/sleeper/attackby(obj/item/I, mob/user, params)
	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(exchange_parts(user, I))
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return
	if(add_store(I))
		return
	return ..()

/obj/machinery/sleeper/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.notcontained_state)

	if(controls_inside && state == GLOB.notcontained_state)
		state = GLOB.default_state // If it has a set of controls on the inside, make it actually controllable by the mob in it.

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sleeper", name, 375, 550, master_ui, state)
		ui.open()

/obj/machinery/sleeper/ui_data()
	var/list/data = list()
	data["occupied"] = occupant ? 1 : 0
	data["open"] = state_open

	data["chems"] = list()
	for(var/chem in available_chems)
		var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
		data["chems"] += list(list("name" = R.name, "id" = R.id, "allowed" = chem_allowed(chem)))

	data["chemStores"] = list()
	for(var/i in 1 to LAZYLEN(chem_stores))
		var/obj/item/reagent_containers/C = chem_stores[i]
		data["chemStores"] += (C && C.reagents) ? C.reagents.total_volume : FALSE

	data["chemStoreNames"] = list(SANITIZELIST(chem_store_names).Copy())

	data["occupant"] = list()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = mob_occupant.health
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = HEALTH_THRESHOLD_DEAD
		data["occupant"]["bruteLoss"] = mob_occupant.getBruteLoss()
		data["occupant"]["oxyLoss"] = mob_occupant.getOxyLoss()
		data["occupant"]["toxLoss"] = mob_occupant.getToxLoss()
		data["occupant"]["fireLoss"] = mob_occupant.getFireLoss()
		data["occupant"]["cloneLoss"] = mob_occupant.getCloneLoss()
		data["occupant"]["brainLoss"] = mob_occupant.getBrainLoss()
		data["occupant"]["reagents"] = list()
		if(occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
				data["occupant"]["reagents"] += list(list("name" = R.name, "volume" = R.volume))
	return data

/obj/machinery/sleeper/ui_act(action, params)
	if(..())
		return
	var/mob/living/mob_occupant = occupant

	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("inject")
			var/chem = params["chem"]
			if(!is_operational() || !mob_occupant)
				return
			if(mob_occupant.health < min_health && chem != "epinephrine")
				return
			if(inject_chem(chem))
				. = TRUE
				if(scrambled_chems && prob(5))
					to_chat(usr, "<span class='warning'>Chem System Re-route detected, results may not be as expected!</span>")
		if("injectstore")
			var/store = text2num(params["store"])
			if(!is_operational() || !mob_occupant || !store)
				return
			if(store && (LAZYLEN(chem_stores) >= store) && chem_stores[store])
				inject_store(store)
		if("invstore")
			var/store = text2num(params["store"])
			if(store && (LAZYLEN(chem_stores) >= store))
				selected_store = store
		if("storename")
			var/store = text2num(params["store"])
			var/name = params["name"]
			var/chem_stores_len = LAZYLEN(chem_stores)
			if(store && chem_stores_len && chem_stores_len >= store)
				name = sanitize(trim(name, 25))
				var/chem_store_names_len = LAZYLEN(chem_store_names)
				if(!chem_store_names || chem_store_names_len < chem_stores_len)
					LAZYINITLIST(chem_store_names)
					chem_store_names.len = chem_stores_len
					chem_store_names[store] = name

/obj/machinery/sleeper/emag_act(mob/user)
	if(LAZYLEN(available_chems))
		scramble_chem_buttons()
		to_chat(user, "<span class='warning'>You scramble the sleeper's user interface!</span>")

/obj/machinery/sleeper/proc/inject_chem(chem)
	if((chem in available_chems) && chem_allowed(chem))
		occupant.reagents.add_reagent(chem_buttons[chem], 10) //emag effect kicks in here so that the "intended" chem is used for all checks, for extra FUUU
		return TRUE

/obj/machinery/sleeper/proc/chem_allowed(chem)
	var/mob/living/mob_occupant = occupant
	if(!mob_occupant || !isliving(mob_occupant) || !mob_occupant.is_injectable())
		return
	var/amount = mob_occupant.reagents.get_reagent_amount(chem) + 10 <= 20 * efficiency
	var/occ_health = mob_occupant.health > min_health || chem == "epinephrine"
	return amount && occ_health

/obj/machinery/sleeper/proc/reset_chem_buttons()
	scrambled_chems = FALSE
	LAZYINITLIST(chem_buttons)
	for(var/chem in available_chems)
		chem_buttons[chem] = chem

/obj/machinery/sleeper/proc/scramble_chem_buttons()
	scrambled_chems = TRUE
	var/list/av_chem = available_chems.Copy()
	for(var/chem in av_chem)
		chem_buttons[chem] = pick_n_take(av_chem) //no dupes, allow for random buttons to still be correct


/obj/machinery/sleeper/chems/syndie
	icon_state = "sleeper_s"
	controls_inside = TRUE

/obj/machinery/sleeper/clockwork
	name = "soothing sleeper"
	desc = "A large cryogenics unit built from brass. Its surface is pleasantly cool the touch."
	icon_state = "sleeper_clockwork"
	enter_message = "<span class='bold inathneq_small'>You hear the gentle hum and click of machinery, and are lulled into a sense of peace.</span>"
	possible_chems = list(list("epinephrine", "salbutamol", "bicaridine", "kelotane", "oculine", "inacusiate", "mannitol"))

/obj/machinery/sleeper/clockwork/process()
	if(occupant && isliving(occupant))
		var/mob/living/L = occupant
		if(GLOB.clockwork_vitality) //If there's Vitality, the sleeper has passive healing
			GLOB.clockwork_vitality = max(0, GLOB.clockwork_vitality - 1)
			L.adjustBruteLoss(-1)
			L.adjustFireLoss(-1)
			L.adjustOxyLoss(-5)

/obj/machinery/sleeper/chems/old
	icon_state = "oldpod"
