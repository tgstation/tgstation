///An item that can be used to gather information on the fish, such as but not limited to: health, hunger and traits.
/obj/item/fish_analyzer
	name = "fish analyzer"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "fish_analyzer_map"
	base_icon_state = "fish_analyzer"
	inhand_icon_state = "fish_analyzer"
	worn_icon_state = "fish_analyzer"
	desc = "A fish-shaped scanner used to monitor fish's status and evolutionary traits."
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT *2)
	greyscale_config_inhand_left = /datum/greyscale_config/fish_analyzer_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/fish_analyzer_inhand_right
	greyscale_config_worn = /datum/greyscale_config/fish_analyzer_worn
	///The color of the case. Used by grayscale configs and update_overlays()
	var/case_color
	/**
	 * The radial menu shown when analyzing aquariums. Having a persistent one allows us
	 * to update it whenever fish come and go, and is also required since we have a select callback
	 * used to check right clicks for scanning traits instead of status.
	 */
	var/datum/radial_menu/persistent/fish_menu
	/// A cached list of the current choices for the aforedefined radial menu.
	var/list/radial_choices

/obj/item/fish_analyzer/Initialize(mapload)
	case_color = rgb(rand(16, 255), rand(16, 255), rand(16, 255))
	set_greyscale(colors = list(case_color))
	. = ..()

	var/static/list/fishe_signals = list(
		COMSIG_FISH_ANALYZER_ANALYZE_STATUS = TYPE_PROC_REF(/datum/component/experiment_handler, try_run_handheld_experiment),
	)
	AddComponent(/datum/component/experiment_handler, \
		config_mode = EXPERIMENT_CONFIG_ALTCLICK, \
		allowed_experiments = list(/datum/experiment/scanning/fish), \
		config_flags = EXPERIMENT_CONFIG_SILENT_FAIL|EXPERIMENT_CONFIG_IMMEDIATE_ACTION, \
		experiment_signals = fishe_signals, \
	)

	register_item_context()
	update_appearance()

/obj/item/fish_analyzer/Destroy()
	if(fish_menu)
		QDEL_NULL(fish_menu)
	radial_choices = null
	return ..()

/obj/item/fish_analyzer/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-Click</b> to access the Experiment Configuration UI")

/obj/item/fish_analyzer/update_icon_state()
	. = ..()
	icon_state = base_icon_state

/obj/item/fish_analyzer/update_overlays()
	. = ..()
	var/mutable_appearance/case = mutable_appearance(icon, "fish_analyzer_case")
	case.color = case_color
	. += case
	. += emissive_appearance(icon, "fish_analyzer_emissive", src)

/obj/item/fish_analyzer/add_item_context(obj/item/source, list/context, atom/target)
	if (isfish(target))
		context[SCREENTIP_CONTEXT_LMB] = "Analyze status"
		context[SCREENTIP_CONTEXT_RMB] = "Analyze traits"
		return CONTEXTUAL_SCREENTIP_SET
	else if(isaquarium(target))
		context[SCREENTIP_CONTEXT_LMB] = "Open radial menu"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/item/fish_analyzer/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!isfish(target) && !isaquarium(target))
		return NONE
	if(!user.can_read(src) || user.is_blind())
		return ITEM_INTERACT_BLOCKING

	if(isfish(target))
		balloon_alert(user, "analyzing stats")
		user.visible_message(span_notice("[user] analyzes [target]."), span_notice("You analyze [target]."))
		analyze_status(target, user)
	else if(istype(target, /obj/structure/aquarium))
		scan_aquarium(target, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/fish_analyzer/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isfish(interacting_with))
		return NONE
	if(!user.can_read(src) || user.is_blind())
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "analyzing traits")
	analyze_traits(interacting_with, user)
	return ITEM_INTERACT_SUCCESS

///Instantiates the radial menu, populates the list of choices, shows it and register signals on the aquarium.
/obj/item/fish_analyzer/proc/scan_aquarium(obj/structure/aquarium/aquarium, mob/user)
	if(fish_menu)
		balloon_alert(user, "already scanning")
		return
	var/list/fishes = aquarium.get_fishes()
	if(!length(fishes))
		balloon_alert(user, "no fish to scan")
		return
	radial_choices = list()
	for(var/obj/item/fish/fish as anything in fishes)
		radial_choices(fish)
	fish_menu = show_radial_menu_persistent(user, aquarium, radial_choices, select_proc = CALLBACK(src, PROC_REF(choice_selected), user, aquarium), tooltips = TRUE, custom_check = CALLBACK(src, PROC_REF(can_select_fish), user, aquarium))
	RegisterSignal(aquarium, COMSIG_ATOM_ABSTRACT_ENTERED, PROC_REF(on_aquarium_entered))
	RegisterSignal(aquarium, COMSIG_ATOM_ABSTRACT_EXITED, PROC_REF(on_aquarium_exited))
	RegisterSignal(aquarium, COMSIG_QDELETING, PROC_REF(delete_radial))

///Instantiates a radial menu choice datum for the current fish and adds it to the list of choices.
/obj/item/fish_analyzer/proc/radial_choices(obj/item/fish/fish)
	var/datum/radial_menu_choice/menu_choice = new
	menu_choice.name = fish.name
	menu_choice.info = "[fish.status == FISH_ALIVE ? "Alive" : "Dead"]\n[fish.size] cm\n[fish.weight] g\nProgenitors: [fish.progenitors]\nRight-click to analyze traits"
	var/mutable_appearance/fish_appearance = new(fish)
	fish_appearance.layer =  FLOAT_LAYER
	fish_appearance.plane = FLOAT_PLANE
	menu_choice.image = fish_appearance
	radial_choices[fish] = menu_choice

///Called when the user has selected a choice. If it's a right click, analyze the traits, else the status
/obj/item/fish_analyzer/proc/choice_selected(mob/user, obj/structure/aquarium/aquarium, obj/item/fish/choice, params)
	if(!choice || !can_select_fish(user, aquarium))
		delete_radial(aquarium)
		return
	var/is_right_clicking = LAZYACCESS(params2list(params), RIGHT_CLICK)
	user.visible_message(span_notice("[user] analyzes [choice] inside [aquarium]."), span_notice("You analyze [choice] inside [aquarium]."))
	if(is_right_clicking)
		analyze_traits(choice, user)
	else
		analyze_status(choice, user)

///Whether the item should continue to show its radial menu or delete it.
/obj/item/fish_analyzer/proc/can_select_fish(mob/user, obj/structure/aquarium/aquarium)
	if(!user.is_holding(src) || !user?.CanReach(aquarium) || IS_DEAD_OR_INCAP(user))
		delete_radial(aquarium)
		return FALSE
	return TRUE

///Called when something enters the aquarium. If it's a fish, update the choices.
/obj/item/fish_analyzer/proc/on_aquarium_entered(obj/structure/aquarium/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(isfish(arrived))
		radial_choices(arrived)
		fish_menu.change_choices(radial_choices, tooltips = TRUE, animate = TRUE)

///Called when something exits the aquarium. If it's a fish, update the choices.
/obj/item/fish_analyzer/proc/on_aquarium_exited(obj/structure/aquarium/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!isfish(gone))
		return
	radial_choices -= gone
	if(!length(radial_choices))
		delete_radial(source)
		return
	fish_menu.change_choices(radial_choices, tooltips = TRUE, animate = TRUE)

///Unregisters signals, delete the radial menu, unsets the choices.
/obj/item/fish_analyzer/proc/delete_radial(obj/structure/aquarium/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_ATOM_ABSTRACT_EXITED, COMSIG_ATOM_ABSTRACT_ENTERED, COMSIG_QDELETING))
	QDEL_NULL(fish_menu)
	radial_choices = null

/**
 * Called when a fish or a menu choice is left-clicked.
 * This returns the fish's status, size, weight, feed type, hunger, breeding timeout.
 */
/obj/item/fish_analyzer/proc/analyze_status(obj/item/fish/fish, mob/user)

	// the final list of strings to render
	var/render_list = list()

	var/fish_status = fish.status == FISH_DEAD ? span_alert("<b>Deceased</b>") : "<b>[PERCENT(fish.health/initial(fish.health))]% healthy</b>"

	render_list += "[span_info("Analyzing status for [fish]:")]\n<span class='info ml-1'>Overrall status: [fish_status]</span>\n"
	render_list += "<span class='info ml-1'>Size: [fish.size] cm - Weight: [fish.weight] g</span>\n"
	render_list += "<span class='info ml-1'>Required feed type: <font color='[initial(fish.food.color)]'>[initial(fish.food.name)]</font></span>\n"
	render_list += "<span class='info ml-1'>Safe temperature: [fish.required_temperature_min] - [fish.required_temperature_max]K"
	if(isaquarium(fish.loc))
		var/obj/structure/aquarium/aquarium = fish.loc
		if(!ISINRANGE(aquarium.fluid_temp, fish.required_temperature_min, fish.required_temperature_max))
			render_list += span_alert("(OUT OF RANGE)")
	render_list += "</span>\n"
	render_list += "<span class='info ml-1'>Safe fluid type: [fish.required_fluid_type]"
	if(isaquarium(fish.loc))
		var/obj/structure/aquarium/aquarium = fish.loc
		if(!compatible_fluid_type(fish.required_fluid_type, aquarium.fluid_type))
			render_list += span_alert("(IN UNSAFE FLUID)")
	render_list += "</span>"

	if(fish.status != FISH_DEAD)
		render_list += "\n"
		if(!HAS_TRAIT(fish, TRAIT_FISH_NO_HUNGER))
			var/hunger = PERCENT(min((world.time - fish.last_feeding) / fish.feeding_frequency, 1))
			var/hunger_string = "[hunger]%"
			switch(hunger)
				if(0 to 60)
					hunger_string = span_info(hunger_string)
				if(60 to 90)
					hunger_string = span_warning(hunger_string)
				if(90 to 100)
					hunger_string = span_alert(hunger_string)
			render_list += "<span class='info ml-1'>Hunger: [hunger_string]</span>\n"
		var/time_left = round(max(fish.breeding_wait - world.time, 0)/10)
		render_list += "<span class='info ml-1'>Time until it can breed: [time_left] seconds</span>"

	to_chat(user, examine_block(jointext(render_list, "")), type = MESSAGE_TYPE_INFO)

	SEND_SIGNAL(src, COMSIG_FISH_ANALYZER_ANALYZE_STATUS, fish, user)

/**
 * Called when a fish or a menu choice is left-clicked.
 * This returns the fish's progenitors, traits and their inheritability.
 */
/obj/item/fish_analyzer/proc/analyze_traits(obj/item/fish/fish, mob/user)

	// the final list of strings to render
	var/render_list = list()

	render_list += "[span_info("Analyzing traits for [fish]:")]\n<span class='info ml-1'>Progenitor species: [fish.progenitors]</span>\n"

	if(!length(fish.fish_traits))
		render_list += "<span class='info ml-1'>This fish has no trait to speak of...</span>\n"
	else
		render_list += "<span class='info ml-1'>Traits:</span>\n"
		for(var/trait_type in fish.fish_traits)
			var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
			var/tooltipped_trait = span_tooltip(trait.catalog_description, trait.name)
			render_list += "<span class='info ml-2'>[tooltipped_trait] - Inheritabilities: <font color='[COLOR_EMERALD]'>[trait.inheritability]%</font> - <font color='[COLOR_BRIGHT_ORANGE]'>[trait.diff_traits_inheritability]%</font></span>\n"

	var/evolution_len = length(fish.evolution_types)
	if(!evolution_len)
		render_list += "<span class='info ml-1'>This fish has no evolution to speak of...</span>"
	for(var/index in 1 to evolution_len)
		var/datum/fish_evolution/evolution = GLOB.fish_evolutions[fish.evolution_types[index]]
		var/evolution_name = evolution.name
		var/evolution_tooltip = evolution.get_evolution_tooltip()
		if(evolution_tooltip)
			evolution_name = span_tooltip(evolution_tooltip, evolution_name)
		render_list += "<span class='info ml-2'>[evolution_name] - Base Probability: [evolution.probability]%</span>"
		if(index != evolution_len)
			render_list += "\n"

	to_chat(user, examine_block(jointext(render_list, "")), type = MESSAGE_TYPE_INFO)
