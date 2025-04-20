/// How likely are we to do something weird to the clone? Persists between construct/deconstruct
GLOBAL_VAR_INIT(experimental_cloner_fuckup_chance, 50)

/// Machine which experimentally clones people you scanned with the experimental cloner scanner
/obj/machinery/experimental_cloner
	name = "experimental cloning pod"
	desc = "An early prototype of the currently-outlawed cloning pods used by Nanotrasen executives. I wonder if it still works?"
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	base_icon_state = "pod"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/experimental_cloner
	use_power = NO_POWER_USE
	processing_flags = START_PROCESSING_MANUALLY
	/// Are we cooking?
	var/running = FALSE
	/// Data for mob we're about to produce
	var/datum/experimental_cloning_record/loaded_record
	/// Sound to play while cooking
	var/datum/looping_sound/microwave/sound_loop
	/// How long it takes to bake a new man
	var/cloning_time = 1 MINUTES
	/// Time until we're done cooking
	var/running_timer

/obj/machinery/experimental_cloner/Initialize(mapload)
	. = ..()
	sound_loop = new(src, FALSE)

/obj/machinery/experimental_cloner/power_change()
	. = ..()
	if (machine_stat & NOPOWER && running)
		fail_growing()

/obj/machinery/experimental_cloner/examine(mob/user)
	. = ..()
	if (running)
		. += span_notice("You can see a shape forming in the murky liquid.")

/obj/machinery/experimental_cloner/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[running]"

/// Start growing a guy
/obj/machinery/experimental_cloner/proc/start_cloning(datum/experimental_cloning_record/to_create)
	if (!to_create)
		return
	running = TRUE
	loaded_record = to_create // We'll need this later
	update_use_power(ACTIVE_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)
	sound_loop.start()
	running_timer = addtimer(CALLBACK(src, PROC_REF(finish_cloning)), cloning_time, TIMER_STOPPABLE | TIMER_DELETE_ME)

/// This one didn't make it
/obj/machinery/experimental_cloner/proc/fail_growing()
	new /obj/effect/gibspawner/human(drop_location())
	playsound(src, 'sound/machines/toilet_flush.ogg', vol = 40, vary = TRUE)
	deltimer(running_timer)
	on_finished()

/// Stuff to do when we stop processing
/obj/machinery/experimental_cloner/proc/on_finished()
	loaded_record = null
	running = FALSE
	update_use_power(NO_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)
	sound_loop.stop()

/// Produce a man and poll for ghosts
/obj/machinery/experimental_cloner/proc/finish_cloning()
	var/datum/experimental_cloner_fuckup/mistake = get_cloning_mistake()

	var/mob/living/result = create_result_mob(mistake?.replacement_mob_path)
	result.forceMove(src)
	mistake?.apply_to_mob(result)

	RegisterSignals(result, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_clone_failed))

	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
		check_jobban = ROLE_RECOVERED_CREW,
		poll_time = 10 SECONDS,
		checked_target = result,
		ignore_category = POLL_IGNORE_EXPERIMENTAL_CLONER,
		alert_pic = result,
		role_name_text = "Clone of [loaded_record.name]",
		announce_chosen = TRUE,
	)

	if(QDELETED(result))
		return // We'll assume the signal will handle ending the cloning process
	if(isnull(chosen_one))
		on_clone_failed(result)
		return

	GLOB.experimental_cloner_fuckup_chance += rand(1, 5) // Each success gets more unstable

	chosen_one.log_message("took control of experimental clone of [result].", LOG_GAME)
	result.PossessByPlayer(chosen_one.ckey)
	to_chat(chosen_one, span_boldnotice(get_policy(ROLE_EXPERIMENTAL_CLONER) || "You are [loaded_record.name]! You aren't quite sure where you are or how you got here, though."))

	UnregisterSignal(result, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	result.forceMove(drop_location())
	mistake?.post_emerged(result)
	on_finished()

/// Return either nothing or something weird to happen to our clone
/obj/machinery/experimental_cloner/proc/get_cloning_mistake()
	if (!prob(GLOB.experimental_cloner_fuckup_chance))
		return

	var/list/all_types = subtypesof(/datum/experimental_cloner_fuckup)
	var/list/weighted_types = list()
	for (var/type in all_types)
		var/datum/experimental_cloner_fuckup/new_type = new type()
		if (!new_type.is_valid(loaded_record.dna.species.type))
			qdel(type)
			continue
		weighted_types[new_type] = new_type.weight

	return pick_weight(weighted_types)

/// Return a mob for our tube to produce
/obj/machinery/experimental_cloner/proc/create_result_mob(mob_type = /mob/living/carbon/human)
	var/mob/living/carbon/human/new_clone = new mob_type()

	if(!istype(new_clone))
		return new_clone // Well I guess you're not a human, sorry friend

	loaded_record.apply_profile(new_clone)

	if (prob(75))
		var/static/list/permitted_heights = list(HUMAN_HEIGHT_SHORTEST, HUMAN_HEIGHT_SHORT, HUMAN_HEIGHT_MEDIUM, HUMAN_HEIGHT_TALL, HUMAN_HEIGHT_TALLER, HUMAN_HEIGHT_TALLEST)
		new_clone.dna.remove_mutation(/datum/mutation/human/dwarfism)
		new_clone.set_mob_height(pick(permitted_heights - loaded_record.height)) // To differentiate the clones

	return new_clone

/// Somehow our clone exited the cloner or was deleted before we were ready or we just didn't find any ghosts
/obj/machinery/experimental_cloner/proc/on_clone_failed(mob/living/clone)
	SIGNAL_HANDLER
	UnregisterSignal(clone, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	if (!QDELETED(clone))
		qdel(clone) // Fuck you then
	fail_growing()
