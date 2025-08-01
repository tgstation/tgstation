/// Global typecache of things which should never be fried.
GLOBAL_LIST_INIT(oilfry_blacklisted_items, typecacheof(list(
	/obj/item/bodybag/bluespace,
	/obj/item/delivery,
	/obj/item/his_grace,
	/obj/item/mod/control,
	/obj/item/reagent_containers/condiment,
	/obj/item/reagent_containers/cup,
	/obj/item/reagent_containers/syringe,
	/obj/item/reagent_containers/hypospray/medipen, //letting medipens become edible opens them to being injected/drained with IV drip & saltshakers
	/obj/item/slimecrossbeaker/autoinjector, //same as medipen
)))

/obj/machinery/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "fryer_off"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/deep_fryer

	/// What's being fried RIGHT NOW?
	var/obj/item/frying
	/// How long the current object has been cooking for
	var/cook_time = 0
	/// How much cooking oil is used per process
	var/oil_use = 0.025
	/// How quickly we fry food - modifier applied per process tick
	var/fry_speed = 1
	/// Has our currently frying object been fried?
	var/frying_fried = FALSE
	/// Has our currently frying object been burnt?
	var/frying_burnt = FALSE
	/// How dirty the fryer is - show overlay at 1
	var/grease_level = 0
	/// The chance (%) of grease_level increase on process()
	var/grease_increase_chance = 50
	/// The amount of grease_level increase on process()
	var/grease_Increase_amount = 0.1

	/// Our sound loop for the frying sounde effect.
	var/datum/looping_sound/deep_fryer/fry_loop
	/// Static typecache of things we can't fry.
	var/static/list/deepfry_blacklisted_items = typecacheof(list(
		/obj/item/screwdriver,
		/obj/item/crowbar,
		/obj/item/wrench,
		/obj/item/wirecutters,
		/obj/item/multitool,
		/obj/item/weldingtool,
	))

/obj/machinery/deepfryer/Initialize(mapload)
	. = ..()
	create_reagents(50, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/consumable/nutriment/fat/oil, 25)
	fry_loop = new(src, FALSE)
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_cleaned))
	AddComponent(/datum/component/fishing_spot, GLOB.preset_fish_sources[/datum/fish_source/deepfryer])
	AddElement(/datum/element/fish_safe_storage) //Prevents fryish and fritterish from dying inside the deepfryer.

/obj/machinery/deepfryer/Destroy()
	QDEL_NULL(fry_loop)
	QDEL_NULL(frying)
	return ..()

/obj/machinery/deepfryer/on_deconstruction(disassembled)
	// This handles nulling out frying via exited
	if(frying)
		frying.forceMove(drop_location())

/obj/machinery/deepfryer/RefreshParts()
	. = ..()
	var/oil_efficiency = 0
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		oil_efficiency += laser.tier
	oil_use = initial(oil_use) - (oil_efficiency * 0.00475)
	fry_speed = oil_efficiency

/obj/machinery/deepfryer/update_overlays()
	. = ..()
	if(grease_level >= 1)
		. += "fryer_greasy"

/obj/machinery/deepfryer/examine(mob/user)
	. = ..()
	if(frying)
		. += "You can make out \a [frying] in the oil."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Frying at <b>[fry_speed*100]%</b> speed.<br>Using <b>[oil_use]</b> units of oil per second.")

/obj/machinery/deepfryer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/deepfryer/attackby(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	// Dissolving pills into the frier
	if(istype(weapon, /obj/item/reagent_containers/applicator/pill))
		if(!reagents.total_volume)
			to_chat(user, span_warning("There's nothing to dissolve [weapon] in!"))
			return
		user.visible_message(span_notice("[user] drops [weapon] into [src]."), span_notice("You dissolve [weapon] in [src]."))
		weapon.reagents.trans_to(src, weapon.reagents.total_volume, transferred_by = user)
		qdel(weapon)
		return
	// Make sure we have cooking oil
	if(!reagents.has_reagent(/datum/reagent/consumable/nutriment/fat, check_subtypes = TRUE))
		to_chat(user, span_warning("[src] has no fat or oil to fry with!"))
		return
	// Don't deep fry indestructible things, for sanity reasons
	if(weapon.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, span_warning("You don't feel it would be wise to fry [weapon]..."))
		return
	// No fractal frying
	if(HAS_TRAIT(weapon, TRAIT_FOOD_FRIED))
		to_chat(user, span_userdanger("Your cooking skills are not up to the legendary Doublefry technique."))
		return
	// Handle opening up the fryer with tools
	if(default_deconstruction_screwdriver(user, "fryer_off", "fryer_off", weapon)) //where's the open maint panel icon?!
		return
	else
		// So we skip the attack animation
		if(weapon.is_drainable())
			return
		// Check for stuff we certainly shouldn't fry
		else if(is_type_in_typecache(weapon, deepfry_blacklisted_items) \
			|| is_type_in_typecache(weapon, GLOB.oilfry_blacklisted_items) \
			|| weapon.atom_storage \
			|| HAS_TRAIT(weapon, TRAIT_NODROP) \
			|| (weapon.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM)))
			return ..()
		// Do the frying.
		else if(!frying && user.transferItemToLoc(weapon, src))
			start_fry(weapon, user)
			return

	return ..()

/obj/machinery/deepfryer/process(seconds_per_tick)
	..()
	var/datum/reagent/consumable/nutriment/fat/frying_oil = reagents.has_reagent(/datum/reagent/consumable/nutriment/fat, check_subtypes = TRUE)
	if(!frying_oil)
		return
	reagents.chem_temp = frying_oil.fry_temperature
	if(!frying)
		return

	reagents.trans_to(frying, oil_use * seconds_per_tick, multiplier = fry_speed * 3) //Fried foods gain more of the reagent thanks to space magic
	grease_level += prob(grease_increase_chance) * grease_Increase_amount

	cook_time += fry_speed * seconds_per_tick SECONDS
	if(cook_time >= FRYING_TIME_PERFECT && !frying_fried)
		frying_fried = TRUE //frying... frying... fried
		playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
		audible_message(span_notice("[src] dings!"))
	else if (cook_time >= FRYING_TIME_WARNING && !frying_burnt)
		frying_burnt = TRUE
		var/list/anosmia_havers = list()
		for(var/mob/smeller in get_hearers_in_view(DEFAULT_MESSAGE_RANGE, src))
			if(HAS_TRAIT(smeller, TRAIT_ANOSMIA))
				anosmia_havers += smeller
		visible_message(span_warning("[src] emits an acrid smell!"), ignored_mobs = anosmia_havers)

	use_energy(active_power_usage)

/obj/machinery/deepfryer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == frying)
		reset_frying()

/obj/machinery/deepfryer/proc/reset_frying()
	if(!QDELETED(frying))
		frying.AddElement(/datum/element/fried_item, cook_time)

	frying = null
	frying_fried = FALSE
	frying_burnt = FALSE
	fry_loop.stop()
	cook_time = 0
	flick("fryer_stop", src)
	icon_state = "fryer_off"
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/deepfryer/proc/start_fry(obj/item/frying_item, mob/user)
	to_chat(user, span_notice("You put [frying_item] into [src]."))
	if(istype(frying_item, /obj/item/freeze_cube))
		log_bomber(user, "put a freeze cube in a", src)
		visible_message(span_userdanger("[src] starts glowing... Oh no..."))
		playsound(src, 'sound/effects/pray_chaplain.ogg', 100)
		add_filter("entropic_ray", 10, list("type" = "rays", "size" = 35, "color" = COLOR_VIVID_YELLOW))
		addtimer(CALLBACK(src, PROC_REF(blow_up)), 5 SECONDS)

	frying = frying_item
	// Give them reagents to put frying oil in
	if(isnull(frying.reagents))
		frying.create_reagents(50, INJECTABLE)
	if(user.mind)
		ADD_TRAIT(frying, TRAIT_FOOD_CHEF_MADE, REF(user.mind))
	SEND_SIGNAL(frying, COMSIG_ITEM_ENTERED_FRYER)

	flick("fryer_start", src)
	icon_state = "fryer_on"
	fry_loop.start()

/obj/machinery/deepfryer/proc/blow_up()
	visible_message(span_userdanger("[src] blows up from the entropic reaction!"))
	explosion(src, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, flame_range = 7)
	deconstruct(FALSE)

/obj/machinery/deepfryer/attack_ai(mob/user)
	return

/obj/machinery/deepfryer/attack_hand(mob/living/user, list/modifiers)
	if(frying)
		to_chat(user, span_notice("You eject [frying] from [src]."))
		frying.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(frying)
		return

	else if(user.pulling && iscarbon(user.pulling) && reagents.total_volume)
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return
		var/mob/living/carbon/dunking_target = user.pulling
		log_combat(user, dunking_target, "dunked", null, "into [src]")
		user.visible_message(span_danger("[user] dunks [dunking_target]'s face in [src]!"))
		reagents.expose(dunking_target, TOUCH)
		var/bio_multiplier = dunking_target.getarmor(BODY_ZONE_HEAD, BIO) * 0.01
		var/target_temp = dunking_target.bodytemperature
		var/cold_multiplier = 1
		if(target_temp < TCMB + 10) // a tiny bit of leeway
			dunking_target.visible_message(span_userdanger("[dunking_target] explodes from the entropic difference! Holy fuck!"))
			dunking_target.investigate_log("has been gibbed by entropic difference (being dunked into [src]).", INVESTIGATE_DEATHS)
			dunking_target.gib(DROP_ALL_REMAINS)
			log_combat(user, dunking_target, "blew up", null, "by dunking them into [src]")
			return

		else if(target_temp < T0C)
			cold_multiplier += round(target_temp * 1.5 / T0C, 0.01)
		dunking_target.apply_damage(min(30 * bio_multiplier * cold_multiplier, reagents.total_volume), BURN, BODY_ZONE_HEAD)
		if(reagents.reagent_list) //This can runtime if reagents has nothing in it.
			reagents.remove_all((reagents.total_volume/2))
		dunking_target.Paralyze(60)
		user.changeNext_move(CLICK_CD_MELEE)
	return ..()

/obj/machinery/deepfryer/proc/on_cleaned(obj/source_component, obj/source)
	SIGNAL_HANDLER

	. = NONE

	grease_level = 0
	update_appearance(UPDATE_OVERLAYS)
	. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP
