/datum/scripture/create_structure/anchoring_crystal
	name = "Anchoring Crystal"
	desc = "Summon an anchoring crystal to the station."
	tip = "Oops!" //this is set on New()
	button_icon_state = "Clockwork Obelisk"
	power_cost = 2000
	invocation_time = 20 SECONDS
	invocation_text = list("Reality Fold...", "Time will mold...", "Anchor us here...", "Eng'ine is near!")
	summoned_structure = /obj/structure/destructible/clockwork/anchoring_crystal
	cogs_required = 5
	invokers_required = 3
	category = SPELLTYPE_STRUCTURES
	///how long in seconds until the scripture can be invoked again, pretty much a cooldown
	var/static/time_until_invokable = 0

/datum/scripture/create_structure/anchoring_crystal/New()
	tip = "With this crystal [anchoring_crystal_charge_message()]"
	. = ..()

/datum/scripture/create_structure/anchoring_crystal/process(seconds_per_tick)
	time_until_invokable = time_until_invokable - (seconds_per_tick SECONDS)
	if(time_until_invokable <= 0)
		var/datum/scripture/create_structure/anchoring_crystal/global_datum = GLOB.clock_scriptures_by_type[/datum/scripture/create_structure/anchoring_crystal]
		STOP_PROCESSING(SSprocessing, global_datum)
		time_until_invokable = 0

/datum/scripture/create_structure/anchoring_crystal/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(time_until_invokable)
		to_chat(invoker, span_warning("The ark will be stable enough to summon another crystal in [time_until_invokable] seconds."))
		return FALSE

	var/datum/objective/anchoring_crystals/crystals_objective = locate() in GLOB.main_clock_cult?.objectives
	if(!length(crystals_objective?.valid_areas))
		return FALSE

	if(get_charged_anchor_crystals() && !(get_area(invoker) in crystals_objective.valid_areas))
		var/list/area_list = list()
		for(var/area/added_area in crystals_objective.valid_areas)
			area_list += added_area.get_original_area_name()
		to_chat(invoker, span_warning("This cystal can only be summoned in [english_list(area_list)]."))
		return FALSE

	var/area/checked_area = get_area(invoker)
	if(!(checked_area?.area_flags & VALID_TERRITORY))
		to_chat(invoker, span_warning("You cannot summon an anchoring crystal here!"))
		return FALSE
	return TRUE

/datum/scripture/create_structure/anchoring_crystal/invoke()
	if(time_until_invokable) //check again in case they try and make two at once
		var/datum/scripture/create_structure/anchoring_crystal/scripture = GLOB.clock_scriptures_by_type[/datum/scripture/create_structure/anchoring_crystal]
		START_PROCESSING(SSprocessing, scripture) //make sure we dont brick somehow
		to_chat(invoker, span_warning("Another Anchoring Crystal is already charging!"))
		return FALSE
	. = ..()

/datum/scripture/create_structure/anchoring_crystal/invoke_success()
	. = ..()
	time_until_invokable = ANCHORING_CRYSTAL_COOLDOWN
	var/datum/scripture/create_structure/anchoring_crystal/scripture = GLOB.clock_scriptures_by_type[/datum/scripture/create_structure/anchoring_crystal]
	START_PROCESSING(SSprocessing, scripture)

/datum/scripture/create_structure/anchoring_crystal/proc/update_info()
	var/datum/objective/anchoring_crystals/crystals_objective = locate() in GLOB.main_clock_cult?.objectives
	if(crystals_objective && get_charged_anchor_crystals())
		var/list/area_list = list()
		for(var/area/added_area in crystals_objective.valid_areas)
			area_list += added_area.get_original_area_name()
		desc = "Summon an anchoring crystal to the station, it can be summoned in [english_list(area_list)]."
	tip = "With this crystal [anchoring_crystal_charge_message()]"
