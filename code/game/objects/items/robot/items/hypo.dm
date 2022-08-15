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
		/datum/reagent/consumable/coffee, /datum/reagent/consumable/cream, /datum/reagent/consumable/dr_gibb,\
		/datum/reagent/consumable/grenadine, /datum/reagent/consumable/ice, /datum/reagent/consumable/lemonjuice,\
		/datum/reagent/consumable/lemon_lime, /datum/reagent/consumable/limejuice, /datum/reagent/consumable/menthol,\
		/datum/reagent/consumable/milk, /datum/reagent/consumable/nothing, /datum/reagent/consumable/orangejuice,\
		/datum/reagent/consumable/peachjuice, /datum/reagent/consumable/pineapplejuice,\
		/datum/reagent/consumable/pwr_game, /datum/reagent/consumable/shamblers, /datum/reagent/consumable/sodawater,\
		/datum/reagent/consumable/sol_dry, /datum/reagent/consumable/soymilk, /datum/reagent/consumable/space_cola,\
		/datum/reagent/consumable/spacemountainwind, /datum/reagent/consumable/space_up, /datum/reagent/consumable/sugar,\
		/datum/reagent/consumable/tea, /datum/reagent/consumable/tomatojuice, /datum/reagent/consumable/tonic,\
		/datum/reagent/water,\
		/datum/reagent/consumable/ethanol/ale, /datum/reagent/consumable/ethanol/applejack, /datum/reagent/consumable/ethanol/beer,\
		/datum/reagent/consumable/ethanol/champagne, /datum/reagent/consumable/ethanol/cognac, /datum/reagent/consumable/ethanol/creme_de_coconut,\
		/datum/reagent/consumable/ethanol/creme_de_cacao, /datum/reagent/consumable/ethanol/creme_de_menthe, /datum/reagent/consumable/ethanol/gin,\
		/datum/reagent/consumable/ethanol/kahlua, /datum/reagent/consumable/ethanol/rum, /datum/reagent/consumable/ethanol/sake,\
		/datum/reagent/consumable/ethanol/tequila, /datum/reagent/consumable/ethanol/triple_sec, /datum/reagent/consumable/ethanol/vermouth,\
		/datum/reagent/consumable/ethanol/vodka, /datum/reagent/consumable/ethanol/whiskey, /datum/reagent/consumable/ethanol/wine\
	)
#define HACKED_SERVICE_REAGENTS list(\
		/datum/reagent/toxin/fakebeer,\
		/datum/reagent/consumable/ethanol/fernet\
	)

///Borg Hypospray
/obj/item/reagent_containers/borghypo
	name = "cyborg hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
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
	var/charge_cost = 50
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
/obj/item/reagent_containers/borghypo/process(delta_time)
	charge_timer += delta_time
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

/obj/item/reagent_containers/borghypo/attack(mob/living/carbon/injectee, mob/user)
	if(!istype(injectee))
		return
	if(!selected_reagent)
		balloon_alert(user, "no reagent selected!")
		return
	if(!stored_reagents.has_reagent(selected_reagent.type, amount_per_transfer_from_this))
		balloon_alert(user, "not enough [selected_reagent.name]!")
		return

	if(injectee.try_inject(user, user.zone_selected, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE | (bypass_protection ? INJECT_CHECK_PENETRATE_THICK : 0)))
		// This is the in-between where we're storing the reagent we're going to inject the injectee with
		// because we cannot specify a singular reagent to transfer in trans_to
		var/datum/reagents/hypospray_injector = new()
		stored_reagents.remove_reagent(selected_reagent.type, amount_per_transfer_from_this)
		hypospray_injector.add_reagent(selected_reagent.type, amount_per_transfer_from_this, reagtemp = dispensed_temperature, no_react = TRUE)

		to_chat(injectee, span_warning("You feel a tiny prick!"))
		to_chat(user, span_notice("You inject [injectee] with the injector ([selected_reagent.name])."))

		if(injectee.reagents)
			hypospray_injector.trans_to(injectee, amount_per_transfer_from_this, transfered_by = user, methods = INJECT)
			balloon_alert(user, "[amount_per_transfer_from_this] unit\s injected")
			log_combat(user, injectee, "injected", src, "(CHEMICALS: [selected_reagent])")
	else
		balloon_alert(user, "[user.zone_selected] is blocked!")

/obj/item/reagent_containers/borghypo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgHypo", name)
		ui.open()

/obj/item/reagent_containers/borghypo/ui_data(mob/user)
	var/list/available_reagents = list()
	for(var/datum/reagent/reagent in stored_reagents.reagent_list)
		if(reagent)
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

/obj/item/reagent_containers/borghypo/ui_act(action, params)
	. = ..()
	if(.)
		return

	for(var/datum/reagent/reagent in stored_reagents.reagent_list)
		if(reagent.name == action)
			selected_reagent = reagent
			. = TRUE
			playsound(loc, 'sound/effects/pop.ogg', 50, FALSE)

			var/mob/living/silicon/robot/cyborg = src.loc
			balloon_alert(cyborg, "dispensing [selected_reagent.name]")
			break

/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()
	. += "Currently loaded: [selected_reagent ? "[selected_reagent]. [selected_reagent.description]" : "nothing."]"
	. += span_notice("<i>Alt+Click</i> to change transfer amount. Currently set to [amount_per_transfer_from_this]u.")

/obj/item/reagent_containers/borghypo/AltClick(mob/living/user)
	. = ..()
	if(user.stat == DEAD || user != loc)
		return //IF YOU CAN HEAR ME SET MY TRANSFER AMOUNT TO 1
	change_transfer_amount(user)

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
	charge_cost = 20
	recharge_time = 2
	default_reagent_types = BASE_SYNDICATE_REAGENTS
	bypass_protection = TRUE

/// Borg Shaker for the serviceborgs
/obj/item/reagent_containers/borghypo/borgshaker
	name = "cyborg shaker"
	desc = "An advanced drink synthesizer and mixer."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "shaker"
	possible_transfer_amounts = list(5,10,20)
	// Lots of reagents all regenerating at once, so the charge cost is lower. They also regenerate faster.
	charge_cost = 20
	recharge_time = 3
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP //Water stays wet, ice stays ice
	default_reagent_types = BASE_SERVICE_REAGENTS

/obj/item/reagent_containers/borghypo/borgshaker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgShaker", name)
		ui.open()

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
	return data

/obj/item/reagent_containers/borghypo/borgshaker/attack(mob/M, mob/user)
	return //Can't inject stuff with a shaker, can we? //not with that attitude

/obj/item/reagent_containers/borghypo/borgshaker/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!selected_reagent)
		balloon_alert(user, "no reagent selected!")
		return
	if(target.is_refillable())
		if(!stored_reagents.has_reagent(selected_reagent.type, amount_per_transfer_from_this))
			balloon_alert(user, "not enough [selected_reagent.name]!")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			balloon_alert(user, "[target] is full!")
			return

		// This is the in-between where we're storing the reagent we're going to pour into the container
		// because we cannot specify a singular reagent to transfer in trans_to
		var/datum/reagents/shaker = new()
		stored_reagents.remove_reagent(selected_reagent.type, amount_per_transfer_from_this)
		shaker.add_reagent(selected_reagent.type, amount_per_transfer_from_this, reagtemp = dispensed_temperature, no_react = TRUE)

		shaker.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		balloon_alert(user, "[amount_per_transfer_from_this] unit\s poured")

/obj/item/reagent_containers/borghypo/borgshaker/hacked
	name = "cyborg shaker"
	desc = "Will mix drinks that knock them dead."
	icon_state = "threemileislandglass"
	tgui_theme = "syndicate"
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP
	default_reagent_types = HACKED_SERVICE_REAGENTS

#undef BASE_MEDICAL_REAGENTS
#undef EXPANDED_MEDICAL_REAGENTS
#undef HACKED_MEDICAL_REAGENTS
#undef BASE_PEACE_REAGENTS
#undef HACKED_PEACE_REAGENTS
#undef BASE_CLOWN_REAGENTS
#undef HACKED_CLOWN_REAGENTS
#undef BASE_SYNDICATE_REAGENTS
#undef BASE_SERVICE_REAGENTS
#undef HACKED_SERVICE_REAGENTS
