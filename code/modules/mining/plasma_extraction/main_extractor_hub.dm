///How many mining points every single miner gets as an award for completing the objective.
#define OBJECTIVE_MINING_POINTS_AWARD 3000
///Amount in % that each dot represents of the total.
#define AMOUNT_COMPLETED_PER_DOT 5
///Time you have to wait before you can turn the machine on/off to prevent cheesing.
#define TIME_BETWEEN_TOGGLES (10 SECONDS)

/**
 * The 'Main' extractor hub, that owns all the rest.
 * Also known as the 'bottom middle piece', which also works as a pipe in itself.
 * This holds important stuff such as the bar hud, soundloop, and the whole 3x3 machine together.
 */
/obj/structure/plasma_extraction_hub/part/pipe/main
	icon_state = "extractor-8"//mapping icon
	sprite_number = 8
	///A number representing the percentage of plasma that has been mined.
	var/percentage_of_plasma_mined
	///Boolean on whether we're trying to drill, regardless of whether we can or not.
	///This is used to tell recently repaired pipes that they should get back to working.
	var/drilling = FALSE
	///Reference to the plasma hud bar to show how much concentrated plasma has been collected.
	var/obj/effect/bar_hud_display/plasma_bar/display_panel_ref
	///List of pipe parts connected to the extraction hub, not including ourselves.
	var/list/obj/structure/plasma_extraction_hub/part/hub_parts = list()
	///Looping sound of the plasma engine running, extracting plasma.
	var/datum/looping_sound/plasma_engine/extracting_soundloop
	///Cooldown between toggling the drilling process on/off.
	COOLDOWN_DECLARE(toggle_cooldown)

/obj/structure/plasma_extraction_hub/part/pipe/main/Initialize(mapload)
	. = ..()
	register_context()
	setup_parts()
	update_appearance(UPDATE_ICON)
	extracting_soundloop = new(src, FALSE)

/obj/structure/plasma_extraction_hub/part/pipe/main/Destroy()
	QDEL_LIST(hub_parts)
	QDEL_NULL(extracting_soundloop)
	if(display_panel_ref)
		QDEL_NULL(display_panel_ref)
	return ..()

/obj/structure/plasma_extraction_hub/part/pipe/main/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Turn [drilling ? "off" : "on"]"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/plasma_extraction_hub/part/pipe/main/update_overlays()
	. = ..()
	if(drilling)
		. += "extractor-on"
	else
		. += "extractor-off"

///Copied from gravity gen, this sets up the parts of the plasma extraction hub, and its starting points.
/obj/structure/plasma_extraction_hub/part/pipe/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = CORNER_BLOCK_OFFSET(our_turf, 3, 3, -1, 0)
	var/count = 10
	for(var/turf/spawned_turf in spawn_turfs)
		count--
		if(spawned_turf == our_turf) // Skip our turf.
			continue
		var/obj/structure/plasma_extraction_hub/part/new_part
		switch(count)
			//east
			if(4)
				new_part = new /obj/structure/plasma_extraction_hub/part/pipe(spawned_turf)
				new_part.setDir(EAST)
			//west
			if(6)
				new_part = new /obj/structure/plasma_extraction_hub/part/pipe(spawned_turf)
				new_part.setDir(WEST)
			else
				new_part = new /obj/structure/plasma_extraction_hub/part(spawned_turf)
		new_part.sprite_number = count
		hub_parts += new_part
		new_part.pipe_owner = src
		new_part.update_appearance(UPDATE_ICON_STATE)
	pipe_owner = src //set ourselves as the pipe owner too, in case we check for `pipe_owner` on any part which could be us.

/obj/structure/plasma_extraction_hub/part/pipe/main/interact(mob/user)
	. = ..()
	if(percentage_of_plasma_mined >= 100)
		balloon_alert(user, "extraction completed")
		return
	if(!COOLDOWN_FINISHED(src, toggle_cooldown))
		balloon_alert(user, "on cooldown!")
		return
	var/ready_to_start = tgui_alert(user, "[drilling ? "Stop" : "Start"] collecting liquid plasma?", (drilling ? "Really stop drilling?" : "Ready to start?"), list("Yes", "No"))
	if(ready_to_start != "Yes")
		return
	toggle_mining(user)

/obj/structure/plasma_extraction_hub/part/pipe/main/on_completion()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(display_panel_ref)
	//unlocks plasma canisters purchasable from Cargo.
	var/datum/supply_pack/plasma_pack = SSshuttle.supply_packs["/datum/supply_pack/materials/gas_canisters/plasma"] //canister IDs are uniquely stored as strings
	plasma_pack.hidden = FALSE
	var/datum/supply_pack/weather_pack = SSshuttle.supply_packs[/datum/supply_pack/imports/weather_remover]
	weather_pack.hidden = FALSE
	//give miners their points.
	if(SSeconomy.bank_accounts_by_job[/datum/job/shaft_miner])
		for(var/datum/bank_account/miners as anything in SSeconomy.bank_accounts_by_job[/datum/job/shaft_miner])
			miners.mining_points += OBJECTIVE_MINING_POINTS_AWARD
			miners.bank_card_talk("You've been awarded [OBJECTIVE_MINING_POINTS_AWARD] mining points for the completion of the plasma extraction objective.")
	var/datum/station_goal/extract_plasma/goal = SSstation.get_station_goal(/datum/station_goal/extract_plasma)
	goal.completed = TRUE

/**
 * Toggles the drilling process on/off.
 * Handles things like removing the hud display, stopping the soundloop, and stopping the drilling process.
 * Doesn't allow drilling if the pipes are incomplete.
 * Lastly handles starting/stopping processing.
 */
/obj/structure/plasma_extraction_hub/part/pipe/main/proc/toggle_mining(mob/user)
	if(!COOLDOWN_FINISHED(src, toggle_cooldown))
		balloon_alert(user, "on cooldown!")
		return
	if(drilling)
		QDEL_NULL(display_panel_ref)
		drilling = FALSE
		STOP_PROCESSING(SSprocessing, src)
		extracting_soundloop.stop()
		for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts in hub_parts + src)
			pipe_parts.stop_drilling()
		update_appearance(UPDATE_OVERLAYS)
		COOLDOWN_START(src, toggle_cooldown, TIME_BETWEEN_TOGGLES)
		return
	for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts in hub_parts + src)
		if(!pipe_parts.check_parts())
			balloon_alert(user, "cant start, pipes incomplete!")
			return
	drilling = TRUE
	display_panel_ref = new(locate(x + 2, y, z))
	for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts in hub_parts + src)
		pipe_parts.start_drilling()
	extracting_soundloop.start(src)
	START_PROCESSING(SSprocessing, src)
	update_appearance(UPDATE_OVERLAYS)
	COOLDOWN_START(src, toggle_cooldown, TIME_BETWEEN_TOGGLES)

/obj/structure/plasma_extraction_hub/part/pipe/main/process(seconds_per_tick)
	if(HAS_TRAIT(src, TRAIT_FROZEN) || percentage_of_plasma_mined >= 100)
		return
	var/broken_hub = FALSE
	for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts in hub_parts + src)
		if(!pipe_parts.currently_functional)
			broken_hub = TRUE
			break
	if(broken_hub)
		if(extracting_soundloop.is_active())
			extracting_soundloop.stop()
		return
	if(!extracting_soundloop.is_active())
		extracting_soundloop.start(src)
	percentage_of_plasma_mined += clamp(1, 0, 100) * seconds_per_tick
	if(percentage_of_plasma_mined >= 100)
		for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts in hub_parts + src)
			pipe_parts.on_completion()
		return
	//this only has 20 dots so 1 dot = 5%
	display_panel_ref.active_dots = round(percentage_of_plasma_mined / 5, 1)
	display_panel_ref.update_appearance(UPDATE_OVERLAYS)

/obj/effect/bar_hud_display/plasma_bar/examine(mob/user)
	. = ..()
	. += span_notice("It is currently showing [active_dots*AMOUNT_COMPLETED_PER_DOT]% filled of [display_title].")

///A variant of the hud display panel for life shards, this one is set up to display two columns.
/obj/effect/bar_hud_display/plasma_bar
	name = "concentrated plasma extracted"

	dot_slots = 20 //Each dot represents 5% of completion.
	bar_offset_w = 3
	individual_dot_offset_x = -5
	number_of_columns = 2
	dot_icon_state = "gem_purple"
	dot_icon_state_empty = "gem_red_empty"
	display_title = "extracted plasma"

#undef OBJECTIVE_MINING_POINTS_AWARD
#undef AMOUNT_COMPLETED_PER_DOT
#undef TIME_BETWEEN_TOGGLES
