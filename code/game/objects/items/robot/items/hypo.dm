/// All of the default reagent lists for each hypospray (+ hacked variants)
#define BASE_MEDICAL_REAGENTS list(\
		/datum/reagent/medicine/c2/aiuri,\
		/datum/reagent/medicine/c2/convermol,\
		/datum/reagent/medicine/epinephrine,\
		/datum/reagent/medicine/c2/libital,\
		/datum/reagent/medicine/c2/multiver,\
		/datum/reagent/medicine/salglu_solution,\
		/datum/reagent/medicine/spaceacillin\
	)
#define EXPANDED_MEDICAL_REAGENTS list(\
		/datum/reagent/medicine/haloperidol,\
		/datum/reagent/medicine/inacusiate,\
		/datum/reagent/medicine/mannitol,\
		/datum/reagent/medicine/mutadone,\
		/datum/reagent/medicine/oculine,\
		/datum/reagent/medicine/oxandrolone,\
		/datum/reagent/medicine/pen_acid,\
		/datum/reagent/medicine/rezadone,\
		/datum/reagent/medicine/sal_acid\
	)
#define HACKED_MEDICAL_REAGENTS list(\
		/datum/reagent/toxin/cyanide,\
		/datum/reagent/toxin/acid/fluacid,\
		/datum/reagent/toxin/heparin,\
		/datum/reagent/toxin/lexorin,\
		/datum/reagent/toxin/mutetoxin,\
		/datum/reagent/toxin/sodium_thiopental\
	)
#define BASE_PEACE_REAGENTS list(\
		/datum/reagent/peaceborg/confuse,\
		/datum/reagent/pax/peaceborg,\
		/datum/reagent/peaceborg/tire\
	)
#define HACKED_PEACE_REAGENTS list(\
		/datum/reagent/toxin/cyanide,\
		/datum/reagent/toxin/fentanyl,\
		/datum/reagent/toxin/sodium_thiopental,\
		/datum/reagent/toxin/staminatoxin,\
		/datum/reagent/toxin/sulfonal\
	)
#define BASE_CLOWN_REAGENTS list(\
		/datum/reagent/consumable/laughter\
	)
#define HACKED_CLOWN_REAGENTS list(\
		/datum/reagent/consumable/superlaughter\
	)
#define BASE_SYNDICATE_REAGENTS list(\
		/datum/reagent/medicine/inacusiate,\
		/datum/reagent/medicine/morphine,\
		/datum/reagent/medicine/potass_iodide,\
		/datum/reagent/medicine/syndicate_nanites\
	)
#define BASE_SERVICE_REAGENTS list(/datum/reagent/consumable/applejuice, /datum/reagent/consumable/banana,\
		/datum/reagent/consumable/berryjuice, /datum/reagent/consumable/cherryjelly, /datum/reagent/consumable/coffee,\
		/datum/reagent/consumable/cream, /datum/reagent/consumable/dr_gibb, /datum/reagent/consumable/grenadine,\
		/datum/reagent/consumable/ice, /datum/reagent/consumable/lemon_lime, /datum/reagent/consumable/limejuice,\
		/datum/reagent/consumable/lemonjuice, /datum/reagent/consumable/melon_soda, /datum/reagent/consumable/menthol,\
		/datum/reagent/consumable/milk, /datum/reagent/consumable/nothing, /datum/reagent/consumable/orangejuice,\
		/datum/reagent/consumable/peachjuice, /datum/reagent/consumable/pineapplejuice, /datum/reagent/consumable/pwr_game,\
		/datum/reagent/consumable/shamblers, /datum/reagent/consumable/sodawater, /datum/reagent/consumable/sol_dry,\
		/datum/reagent/consumable/soymilk, /datum/reagent/consumable/space_cola, /datum/reagent/consumable/spacemountainwind,\
		/datum/reagent/consumable/space_up, /datum/reagent/consumable/tea, /datum/reagent/consumable/tomatojuice,\
		/datum/reagent/consumable/tonic, /datum/reagent/consumable/vinegar, /datum/reagent/water,\
		/datum/reagent/consumable/ethanol/absinthe, /datum/reagent/consumable/ethanol/ale, /datum/reagent/consumable/ethanol/applejack,\
		/datum/reagent/consumable/ethanol/beer, /datum/reagent/consumable/ethanol/champagne, /datum/reagent/consumable/ethanol/coconut_rum,\
		/datum/reagent/consumable/ethanol/cognac, /datum/reagent/consumable/ethanol/creme_de_coconut, /datum/reagent/consumable/ethanol/creme_de_cacao,\
		/datum/reagent/consumable/ethanol/creme_de_menthe, /datum/reagent/consumable/ethanol/curacao, /datum/reagent/consumable/ethanol/gin,\
		/datum/reagent/consumable/ethanol/hcider, /datum/reagent/consumable/ethanol/kahlua, /datum/reagent/consumable/ethanol/beer/maltliquor,\
		/datum/reagent/consumable/ethanol/navy_rum, /datum/reagent/consumable/ethanol/rice_beer, /datum/reagent/consumable/ethanol/rum,\
		/datum/reagent/consumable/ethanol/sake, /datum/reagent/consumable/ethanol/tequila, /datum/reagent/consumable/ethanol/triple_sec,\
		/datum/reagent/consumable/ethanol/vermouth, /datum/reagent/consumable/ethanol/vodka, /datum/reagent/consumable/ethanol/whiskey,\
		/datum/reagent/consumable/ethanol/wine, /datum/reagent/consumable/ethanol/yuyake,\
	)
#define EXPANDED_SERVICE_REAGENTS list(\
	/datum/reagent/consumable/blackpepper,\
	/datum/reagent/consumable/coco,\
	/datum/reagent/consumable/cornmeal,\
	/datum/reagent/consumable/nutriment/fat/oil,\
	/datum/reagent/consumable/corn_starch,\
	/datum/reagent/consumable/eggwhite,\
	/datum/reagent/consumable/eggyolk,\
	/datum/reagent/consumable/flour,\
	/datum/reagent/consumable/rice,\
	/datum/reagent/consumable/sugar,\
	/datum/reagent/consumable/salt,\
	/datum/reagent/consumable/vanilla,\
)
#define HACKED_SERVICE_REAGENTS list(\
		/datum/reagent/blood,\
		/datum/reagent/toxin/carpotoxin,\
		/datum/reagent/toxin/fakebeer,\
		/datum/reagent/consumable/ethanol/fernet,\
)

#define REAGENT_CONTAINER_INTERNAL "internal_beaker"
#define REAGENT_CONTAINER_BEVAPPARATUS "beverage_apparatus"

///Borg Hypospray
/obj/item/reagent_containers/borghypo
	name = "cyborg hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/medical/syringe.dmi'
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(2,5)

	/** The maximum volume for each reagent stored in this hypospray
	 * In most places we add + 1 because we're secretly keeping [max_volume_per_reagent + 1]
	 * units, so that when this reagent runs out it's not wholesale removed from the reagents
	 */
	var/max_volume_per_reagent = 30
	/// Cell cost for charging a reagent
	var/charge_cost = 0.05 * STANDARD_CELL_CHARGE
	/// Counts up to the next time we charge
	var/charge_timer = 0
	/// Time it takes for shots to recharge (in seconds)
	var/recharge_time = 10
	///Optional variable to override the temperature add_reagent() will use
	var/dispensed_temperature = DEFAULT_REAGENT_TEMPERATURE
	/// If the hypospray can go through armor or thick material
	var/bypass_protection = FALSE
	/// If this hypospray has been upgraded
	var/upgraded = FALSE

	/// The basic reagents that come with this hypo
	var/list/default_reagent_types
	/// The expanded suite of reagents that comes from upgrading this hypo
	var/list/expanded_reagent_types

	/// The reagents we're actually storing
	var/datum/reagents/stored_reagents
	/// The reagent we've selected to dispense
	var/datum/reagent/selected_reagent
	/// The theme for our UI (hacked hypos get syndicate UI)
	var/tgui_theme = "ntos"

/obj/item/reagent_containers/borghypo/Initialize(mapload)
	. = ..()
	stored_reagents = new(new_flags = NO_REACT)
	stored_reagents.maximum_volume = length(default_reagent_types) * (max_volume_per_reagent + 1)
	for(var/reagent in default_reagent_types)
		add_new_reagent(reagent)
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/// Every [recharge_time] seconds, recharge some reagents for the cyborg
/obj/item/reagent_containers/borghypo/process(seconds_per_tick)
	charge_timer += seconds_per_tick
	if(charge_timer >= recharge_time)
		regenerate_reagents(default_reagent_types)
		if(upgraded)
			regenerate_reagents(expanded_reagent_types)
		charge_timer = 0
	return 1

/// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/add_new_reagent(datum/reagent/reagent)
	stored_reagents.add_reagent(reagent, (max_volume_per_reagent + 1), reagtemp = dispensed_temperature, no_react = TRUE)

/// Regenerate our supply of all reagents (if they're not full already)
/obj/item/reagent_containers/borghypo/proc/regenerate_reagents(list/reagents_to_regen)
	if(iscyborg(src.loc))
		var/mob/living/silicon/robot/cyborg = src.loc
		if(cyborg?.cell)
			for(var/reagent in reagents_to_regen)
				var/datum/reagent/reagent_to_regen = reagent
				if(!stored_reagents.has_reagent(reagent_to_regen, max_volume_per_reagent))
					cyborg.cell.use(charge_cost)
					stored_reagents.add_reagent(reagent_to_regen, 5, reagtemp = dispensed_temperature, no_react = TRUE)

/obj/item/reagent_containers/borghypo/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!iscarbon(interacting_with))
		return NONE
	var/mob/living/carbon/injectee = interacting_with
	if(!selected_reagent)
		balloon_alert(user, "no reagent selected!")
		return ITEM_INTERACT_BLOCKING
	if(!stored_reagents.has_reagent(selected_reagent.type, amount_per_transfer_from_this))
		balloon_alert(user, "not enough [selected_reagent.name]!")
		return ITEM_INTERACT_BLOCKING

	if(!injectee.try_inject(user, user.zone_selected, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE | (bypass_protection ? INJECT_CHECK_PENETRATE_THICK : 0)))
		balloon_alert(user, "[injectee.parse_zone_with_bodypart(user.zone_selected)] is blocked!")
		return ITEM_INTERACT_BLOCKING

	// This is the in-between where we're storing the reagent we're going to inject the injectee with
	// because we cannot specify a singular reagent to transfer in trans_to
	var/datum/reagents/hypospray_injector = new()
	stored_reagents.remove_reagent(selected_reagent.type, amount_per_transfer_from_this)
	hypospray_injector.add_reagent(selected_reagent.type, amount_per_transfer_from_this, reagtemp = dispensed_temperature, no_react = TRUE)

	to_chat(injectee, span_warning("You feel a tiny prick!"))
	to_chat(user, span_notice("You inject [injectee] with the injector ([selected_reagent.name])."))

	if(injectee.reagents)
		hypospray_injector.trans_to(injectee, amount_per_transfer_from_this, transferred_by = user, methods = INJECT)
		balloon_alert(user, "[amount_per_transfer_from_this] unit\s injected")
		log_combat(user, injectee, "injected", src, "(CHEMICALS: [selected_reagent])")
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/borghypo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgHypo", name)
		ui.open()

/obj/item/reagent_containers/borghypo/ui_data(mob/user)
	var/list/available_reagents = list()
	for(var/datum/reagent/reagent in stored_reagents.reagent_list)
		available_reagents.Add(list(list(
			"name" = reagent.name,
			"volume" = round(reagent.volume, 0.01) - 1,
			"description" = reagent.description,
		))) // list in a list because Byond merges the first list...

	var/data = list()
	data["theme"] = tgui_theme
	data["maxVolume"] = max_volume_per_reagent
	data["reagents"] = available_reagents
	data["selectedReagent"] = selected_reagent?.name
	return data

/obj/item/reagent_containers/borghypo/attack_self(mob/user)
	ui_interact(user)

/obj/item/reagent_containers/borghypo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	for(var/datum/reagent/reagent in stored_reagents.reagent_list)
		if(reagent.name == action)
			selected_reagent = reagent
			. = TRUE
			var/mob/living/silicon/robot/cyborg = loc
			if(istype(loc, /obj/item/robot_model))
				var/obj/item/robot_model/container_model = loc
				cyborg = container_model.robot
			playsound(cyborg, 'sound/effects/pop.ogg', 50, FALSE)
			balloon_alert(cyborg, "dispensing [selected_reagent.name]")
			break

/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()
	. += "Currently loaded: [selected_reagent ? "[selected_reagent]. [selected_reagent.description]" : "nothing."]"
	. += span_notice("<i>Alt+Click</i> to change transfer amount. Currently set to [amount_per_transfer_from_this]u.")

/obj/item/reagent_containers/borghypo/click_alt(mob/living/user)
	change_transfer_amount(user)
	return CLICK_ACTION_SUCCESS

/// Default Medborg Hypospray
/obj/item/reagent_containers/borghypo/medical
	default_reagent_types = BASE_MEDICAL_REAGENTS
	expanded_reagent_types = EXPANDED_MEDICAL_REAGENTS

/// Upgrade our hypospray to hold even more new reagents!
/obj/item/reagent_containers/borghypo/medical/proc/upgrade_hypo()
	upgraded = TRUE
	// Expand the holder's capacity to allow for our new suite of reagents
	stored_reagents.maximum_volume += (length(expanded_reagent_types) * (max_volume_per_reagent + 1))
	for(var/reagent in expanded_reagent_types)
		var/datum/reagent/reagent_to_add = reagent
		add_new_reagent(reagent_to_add)

/// Remove the reagents we got from the expansion, back to our base reagents
/obj/item/reagent_containers/borghypo/medical/proc/remove_hypo_upgrade()
	upgraded = FALSE
	for(var/reagent in expanded_reagent_types)
		var/datum/reagent/reagent_to_remove = reagent
		stored_reagents.del_reagent(reagent_to_remove)
	// Reduce the holder's capacity because we no longer need the room for those reagents
	stored_reagents.maximum_volume -= (length(expanded_reagent_types) * (max_volume_per_reagent + 1))

/obj/item/reagent_containers/borghypo/medical/hacked
	icon_state = "borghypo_s"
	tgui_theme = "syndicate"
	default_reagent_types = HACKED_MEDICAL_REAGENTS
	expanded_reagent_types = null

/// Peacekeeper hypospray
/obj/item/reagent_containers/borghypo/peace
	name = "Peace Hypospray"
	default_reagent_types = BASE_PEACE_REAGENTS

/obj/item/reagent_containers/borghypo/peace/hacked
	desc = "Everything's peaceful in death!"
	icon_state = "borghypo_s"
	tgui_theme = "syndicate"
	default_reagent_types = HACKED_PEACE_REAGENTS

/// Clownborg hypospray
/obj/item/reagent_containers/borghypo/clown
	name = "laughter injector"
	desc = "Keeps the crew happy and productive!"
	default_reagent_types = BASE_CLOWN_REAGENTS

/obj/item/reagent_containers/borghypo/clown/hacked
	desc = "Keeps the crew so happy they don't work!"
	icon_state = "borghypo_s"
	tgui_theme = "syndicate"
	default_reagent_types = HACKED_CLOWN_REAGENTS

/// Syndicate medborg hypospray
/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. \
		Also metabolizes potassium iodide for radiation poisoning, inacusiate for ear damage and morphine for offense."
	icon_state = "borghypo_s"
	tgui_theme = "syndicate"
	charge_cost = 0.02 * STANDARD_CELL_CHARGE
	recharge_time = 2
	default_reagent_types = BASE_SYNDICATE_REAGENTS
	bypass_protection = TRUE

/// Borg Shaker for the serviceborgs
/obj/item/reagent_containers/borghypo/borgshaker
	name = "cyborg shaker"
	desc = "An advanced drink synthesizer and mixer."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "shaker"
	possible_transfer_amounts = list(5,10,20,1)
	// Lots of reagents all regenerating at once, so the charge cost is lower. They also regenerate faster.
	charge_cost = 0.02 * STANDARD_CELL_CHARGE
	recharge_time = 3
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP //Water stays wet, ice stays ice
	default_reagent_types = BASE_SERVICE_REAGENTS
	expanded_reagent_types = EXPANDED_SERVICE_REAGENTS
	var/reagent_search_container = REAGENT_CONTAINER_BEVAPPARATUS

/obj/item/reagent_containers/borghypo/borgshaker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgShaker", name)
		ui.open()

/obj/item/reagent_containers/borghypo/borgshaker/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/user = usr
	switch(action)
		if("reaction_lookup")
			if(!iscyborg(usr))
				return
			if (reagent_search_container == REAGENT_CONTAINER_BEVAPPARATUS)
				var/obj/item/borg/apparatus/beaker/service/beverage_apparatus = (locate() in user.model.modules) || (locate() in user.held_items)
				if (!isnull(beverage_apparatus) && !isnull(beverage_apparatus.stored))
					beverage_apparatus.stored.reagents.ui_interact(user)
			else if (reagent_search_container == REAGENT_CONTAINER_INTERNAL)
				var/obj/item/reagent_containers/cup/beaker/large/internal_beaker = (locate() in user.model.modules) || (locate() in user.held_items)
				if (!isnull(internal_beaker))
					internal_beaker.reagents.ui_interact(user)
		if ("set_preferred_container")
			reagent_search_container = params["value"]
	return TRUE

/obj/item/reagent_containers/borghypo/borgshaker/ui_data(mob/user)
	var/list/drink_reagents = list()
	var/list/alcohol_reagents = list()
	for(var/datum/reagent/reagent in stored_reagents.reagent_list)
		// Split the reagents into alcoholic/non-alcoholic
		if(istype(reagent, /datum/reagent/consumable/ethanol))
			alcohol_reagents.Add(list(list(
				"name" = reagent.name,
				"volume" = round(reagent.volume, 0.01) - 1,
			))) // list in a list because Byond merges the first list...
		else
			drink_reagents.Add(list(list(
				"name" = reagent.name,
				"volume" = round(reagent.volume, 0.01) - 1,
			)))

	var/data = list()
	data["theme"] = tgui_theme
	data["minVolume"] = amount_per_transfer_from_this
	data["sodas"] = drink_reagents
	data["alcohols"] = alcohol_reagents
	data["selectedReagent"] = selected_reagent?.name
	data["reagentSearchContainer"] = reagent_search_container

	if(iscyborg(user))
		var/mob/living/silicon/robot/cyborg = user
		var/obj/item/borg/apparatus/beaker/service/beverage_apparatus = (locate() in cyborg.model.modules) || (locate() in cyborg.held_items)

		if (isnull(beverage_apparatus))
			to_chat(user, span_warning("This unit has no beverage apparatus. This shouldn't be possible. Delete yourself, NOW!"))
			data["apparatusHasItem"] = FALSE
		else
			data["apparatusHasItem"] = !isnull(beverage_apparatus.stored)
	return data

/obj/item/reagent_containers/borghypo/borgshaker/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!interacting_with.is_refillable())
		return NONE
	if(!selected_reagent)
		balloon_alert(user, "no reagent selected!")
		return ITEM_INTERACT_BLOCKING
	if(!stored_reagents.has_reagent(selected_reagent.type, amount_per_transfer_from_this))
		balloon_alert(user, "not enough [selected_reagent.name]!")
		return ITEM_INTERACT_BLOCKING
	if(interacting_with.reagents.total_volume >= interacting_with.reagents.maximum_volume)
		balloon_alert(user, "it's full!")
		return ITEM_INTERACT_BLOCKING

	// This is the in-between where we're storing the reagent we're going to pour into the container
	// because we cannot specify a singular reagent to transfer in trans_to
	var/datum/reagents/shaker = new()
	stored_reagents.remove_reagent(selected_reagent.type, amount_per_transfer_from_this)
	shaker.add_reagent(selected_reagent.type, amount_per_transfer_from_this, reagtemp = dispensed_temperature, no_react = TRUE)

	shaker.trans_to(interacting_with, amount_per_transfer_from_this, transferred_by = user)
	balloon_alert(user, "[amount_per_transfer_from_this] unit\s poured")
	return ITEM_INTERACT_SUCCESS


/obj/item/reagent_containers/borghypo/condiment_synthesizer // Solids! Condiments! The borger uprising!
	name = "Condiment Synthesizer"
	desc = "An advanced condiment synthesizer"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "flour"
	possible_transfer_amounts = list(5,10,20,1)
	// Lots of reagents all regenerating at once, so the charge cost is lower. They also regenerate faster.
	charge_cost = 0.04 * STANDARD_CELL_CHARGE //Costs double the power of the borgshaker due to synthesizing solids
	recharge_time = 6 //Double the recharge time too, for the same reason.
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP
	default_reagent_types = EXPANDED_SERVICE_REAGENTS

/obj/item/reagent_containers/borghypo/condiment_synthesizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgHypo", name)
		ui.open()

/obj/item/reagent_containers/borghypo/condiment_synthesizer/ui_data(mob/user)
	var/list/condiments = list()
	for(var/datum/reagent/reagent in stored_reagents.reagent_list)
		condiments.Add(list(list(
			"name" = reagent.name,
			"volume" = round(reagent.volume, 0.01) - 1,
			"description" = reagent.description,
		))) // list in a list because Byond merges the first list...

	var/data = list()
	data["theme"] = tgui_theme
	data["minVolume"] = amount_per_transfer_from_this
	data["maxVolume"] = max_volume_per_reagent
	data["reagents"] = condiments
	data["selectedReagent"] = selected_reagent?.name
	return data

/obj/item/reagent_containers/borghypo/condiment_synthesizer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!interacting_with.is_refillable())
		return NONE
	if(!selected_reagent)
		balloon_alert(user, "no reagent selected!")
		return ITEM_INTERACT_BLOCKING
	if(!stored_reagents.has_reagent(selected_reagent.type, amount_per_transfer_from_this))
		balloon_alert(user, "not enough [selected_reagent.name]!")
		return ITEM_INTERACT_BLOCKING
	if(interacting_with.reagents.total_volume >= interacting_with.reagents.maximum_volume)
		balloon_alert(user, "it's full!")
		return ITEM_INTERACT_BLOCKING
	// This is the in-between where we're storing the reagent we're going to pour into the container
	// because we cannot specify a singular reagent to transfer in trans_to
	var/datum/reagents/shaker = new()
	stored_reagents.remove_reagent(selected_reagent.type, amount_per_transfer_from_this)
	shaker.add_reagent(selected_reagent.type, amount_per_transfer_from_this, reagtemp = dispensed_temperature, no_react = TRUE)
	shaker.trans_to(interacting_with, amount_per_transfer_from_this, transferred_by = user)
	balloon_alert(user, "[amount_per_transfer_from_this] unit\s poured")
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/borghypo/borgshaker/hacked
	name = "cyborg shaker"
	desc = "Will mix drinks that knock them dead."
	icon_state = "threemileislandglass"
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	tgui_theme = "syndicate"
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP
	default_reagent_types = HACKED_SERVICE_REAGENTS

#undef REAGENT_CONTAINER_INTERNAL
#undef REAGENT_CONTAINER_BEVAPPARATUS
#undef BASE_MEDICAL_REAGENTS
#undef EXPANDED_MEDICAL_REAGENTS
#undef HACKED_MEDICAL_REAGENTS
#undef BASE_PEACE_REAGENTS
#undef HACKED_PEACE_REAGENTS
#undef BASE_CLOWN_REAGENTS
#undef HACKED_CLOWN_REAGENTS
#undef BASE_SYNDICATE_REAGENTS
#undef BASE_SERVICE_REAGENTS
#undef EXPANDED_SERVICE_REAGENTS
#undef HACKED_SERVICE_REAGENTS
