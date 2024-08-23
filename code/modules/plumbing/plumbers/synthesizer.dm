///A single machine that produces a single chem. Can be placed in unison with others through plumbing to create chemical factories
/obj/machinery/plumbing/synthesizer
	name = "chemical synthesizer"
	desc = "Produces a single chemical at a given volume. Must be plumbed. Most effective when working in unison with other chemical synthesizers, heaters and filters."
	icon_state = "synthesizer"
	icon = 'icons/obj/pipes_n_cables/hydrochem/plumbers.dmi'

	///Amount we produce for every process. Ideally keep under 5 since thats currently the standard duct capacity
	var/amount = 1
	///I track them here because I have no idea how I'd make tgui loop like that
	var/static/list/possible_amounts = list(0, 1, 2, 3, 4, 5)
	///The reagent we are producing. We are a typepath, but are also typecast because there's several occations where we need to use initial.
	var/datum/reagent/reagent_id = null
	///straight up copied from chem dispenser. Being a subtype would be extremely tedious and making it global would restrict potential subtypes using different dispensable_reagents
	var/static/list/default_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel,
	)
	//reagents this synthesizer can dispense
	var/list/dispensable_reagents

/obj/machinery/plumbing/synthesizer/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)
	dispensable_reagents = default_reagents

/obj/machinery/plumbing/synthesizer/process(seconds_per_tick)
	if(!is_operational || !reagent_id || !amount)
		return

	//otherwise we get leftovers, and we need this to be precise
	if(reagents.total_volume >= amount)
		return
	reagents.add_reagent(reagent_id, amount)

	use_energy(active_power_usage * seconds_per_tick)

/obj/machinery/plumbing/synthesizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemSynthesizer", name)
		ui.open()

/obj/machinery/plumbing/synthesizer/ui_static_data(mob/user)
	. = ..()
	.["possible_amounts"] = possible_amounts

/obj/machinery/plumbing/synthesizer/ui_data(mob/user)
	. = list()
	.["amount"] = amount

	var/is_hallucinating = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)
	var/list/chemicals = list()

	for(var/reagentID in dispensable_reagents)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagentID]
		if(reagent)
			var/chemname = reagent.name
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals += list(list("title" = chemname, "id" = reagent.name))
	.["chemicals"] = chemicals

	.["current_reagent"] = initial(reagent_id.name)

/obj/machinery/plumbing/synthesizer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("amount")
			var/new_amount = text2num(params["target"])
			if(new_amount in possible_amounts)
				amount = new_amount
				. = TRUE

		if("select")
			var/new_reagent = GLOB.name2reagent[params["reagent"]]
			if(new_reagent in dispensable_reagents)
				reagent_id = new_reagent
				. = TRUE

	update_appearance()
	reagents.clear_reagents()

/obj/machinery/plumbing/synthesizer/update_overlays()
	. = ..()
	var/mutable_appearance/r_overlay = mutable_appearance(icon, "[icon_state]_overlay")
	r_overlay.color = reagent_id ? initial(reagent_id.color) : COLOR_WHITE
	. += r_overlay

/obj/machinery/plumbing/synthesizer/soda
	name = "soda synthesizer"
	desc = "Produces a single chemical at a given volume. Must be plumbed."
	icon_state = "synthesizer_soda"

	//Copied from soda dispenser
	var/static/list/soda_reagents = list(
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/cream,
		/datum/reagent/consumable/dr_gibb,
		/datum/reagent/consumable/grenadine,
		/datum/reagent/consumable/ice,
		/datum/reagent/consumable/icetea,
		/datum/reagent/consumable/lemonjuice,
		/datum/reagent/consumable/lemon_lime,
		/datum/reagent/consumable/limejuice,
		/datum/reagent/consumable/menthol,
		/datum/reagent/consumable/orangejuice,
		/datum/reagent/consumable/pineapplejuice,
		/datum/reagent/consumable/pwr_game,
		/datum/reagent/consumable/shamblers,
		/datum/reagent/consumable/spacemountainwind,
		/datum/reagent/consumable/sodawater,
		/datum/reagent/consumable/space_up,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/tomatojuice,
		/datum/reagent/consumable/tonic,
		/datum/reagent/water,
	)

/obj/machinery/plumbing/synthesizer/soda/Initialize(mapload, bolt, layer)
	. = ..()

	dispensable_reagents = soda_reagents

/obj/machinery/plumbing/synthesizer/beer
	name = "beer synthesizer"
	desc = "Produces a single chemical at a given volume. Must be plumbed."

	icon_state = "synthesizer_booze"

	//Copied from beer dispenser
	var/static/list/beer_reagents = list(
		/datum/reagent/consumable/ethanol/absinthe,
		/datum/reagent/consumable/ethanol/ale,
		/datum/reagent/consumable/ethanol/applejack,
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/cognac,
		/datum/reagent/consumable/ethanol/creme_de_cacao,
		/datum/reagent/consumable/ethanol/creme_de_coconut,
		/datum/reagent/consumable/ethanol/creme_de_menthe,
		/datum/reagent/consumable/ethanol/curacao,
		/datum/reagent/consumable/ethanol/gin,
		/datum/reagent/consumable/ethanol/hcider,
		/datum/reagent/consumable/ethanol/kahlua,
		/datum/reagent/consumable/ethanol/beer/maltliquor,
		/datum/reagent/consumable/ethanol/navy_rum,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/sake,
		/datum/reagent/consumable/ethanol/tequila,
		/datum/reagent/consumable/ethanol/triple_sec,
		/datum/reagent/consumable/ethanol/vermouth,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/ethanol/whiskey,
		/datum/reagent/consumable/ethanol/wine,
	)

/obj/machinery/plumbing/synthesizer/beer/Initialize(mapload, bolt, layer)
	. = ..()

	dispensable_reagents = beer_reagents
