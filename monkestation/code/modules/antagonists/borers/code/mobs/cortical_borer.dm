GLOBAL_VAR_INIT(objective_egg_borer_number, 2)
GLOBAL_VAR_INIT(objective_egg_egg_number, 5)
GLOBAL_VAR_INIT(objective_willing_hosts, 2)

GLOBAL_VAR_INIT(successful_egg_number, 0)
GLOBAL_LIST_EMPTY(willing_hosts)

GLOBAL_LIST_EMPTY(cortical_borers)

GLOBAL_LIST_INIT(borer_first_name, world.file2list("monkestation/code/modules/antagonists/borers/code/first_borer_names.txt"))
GLOBAL_LIST_INIT(borer_second_name, world.file2list("monkestation/code/modules/antagonists/borers/code/second_borer_names.txt"))

/// This divisor controls how fast body temperature changes to match the environment
#define BODYTEMP_DIVISOR 16

//we need a way of buffing leg speed
/datum/movespeed_modifier/focus_speed
	multiplicative_slowdown = -0.4

/datum/movespeed_modifier/borer_speed
	multiplicative_slowdown = -0.5

/datum/actionspeed_modifier/focus_speed
	multiplicative_slowdown = -0.3
	id = ACTIONSPEED_ID_BORER

//so that we know if a mob has a borer (only humans should have one, but in case)
/mob/proc/has_borer()
	for(var/check_content in contents)
		if(iscorticalborer(check_content))
			return check_content
	return FALSE

//this allows borers to slide under/through a door
/obj/machinery/door/Bumped(atom/movable/movable_atom)
	if(iscorticalborer(movable_atom) && density)
		if(!do_after(movable_atom, 5 SECONDS, src))
			return ..()
		movable_atom.forceMove(drop_location())
		to_chat(movable_atom, span_notice("You squeeze through [src]."))
		return
	return ..()

//so if a person is debrained, the borer is removed
/obj/item/organ/internal/brain/Remove(mob/living/carbon/target, special = 0, no_id_transfer = FALSE)
	. = ..()
	var/mob/living/basic/cortical_borer/cb_inside = target.has_borer()
	if(cb_inside)
		cb_inside.leave_host()

//borers also create an organ, so you dont need to debrain someone
/obj/item/organ/internal/borer_body
	name = "engorged cortical borer"
	desc = "the body of a cortical borer, full of human viscera, blood, and more."
	zone = BODY_ZONE_HEAD
	/// Ref to the borer who this organ belongs to
	var/mob/living/basic/cortical_borer/borer

/obj/item/organ/internal/borer_body/Destroy()
	borer = null
	return ..()

/obj/item/organ/internal/borer_body/Insert(mob/living/carbon/carbon_target, special, drop_if_replaced)
	. = ..()
	for(var/datum/borer_focus/body_focus as anything in borer.body_focuses)
		body_focus.on_add()
	carbon_target.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

//on removal, force the borer out
/obj/item/organ/internal/borer_body/Remove(mob/living/carbon/carbon_target, special)
	. = ..()
	var/mob/living/basic/cortical_borer/cb_inside = carbon_target.has_borer()
	for(var/datum/borer_focus/body_focus as anything in cb_inside.body_focuses)
		body_focus.on_remove()
	if(cb_inside)
		cb_inside.leave_host()
	carbon_target.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	qdel(src)

/obj/item/reagent_containers/borer
	volume = 100

/mob/living/basic/cortical_borer
	name = "cortical borer"
	desc = "A slimy creature that is known to go into the ear canal of unsuspecting victims."
	icon = 'monkestation/code/modules/antagonists/borers/icons/animal.dmi'
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	maxHealth = 25
	health = 25
	// They need to be able to pass tables and mobs
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	// They are below mobs, or below tables
	layer = BELOW_MOB_LAYER
	// Corticals are tiny
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	// Because they are small, why can't they be held?
	can_be_held = TRUE
	/// What chemicals borers know, starting with none
	var/list/known_chemicals = list()
	/// What chemicals the borer can learn
	var/list/potential_chemicals = list(
		/datum/reagent/drug/methamphetamine/borer_version,

		/datum/reagent/impurity/libitoil,

		/datum/reagent/lithium,

		/datum/reagent/medicine/antipathogenic/spaceacillin,

		/datum/reagent/medicine/c2/convermol,
		/datum/reagent/medicine/c2/lenturi,
		/datum/reagent/medicine/c2/libital,
		/datum/reagent/medicine/c2/multiver,
		/datum/reagent/medicine/c2/seiver,

		/datum/reagent/medicine/diphenhydramine,
		/datum/reagent/medicine/epinephrine,
		/datum/reagent/medicine/haloperidol,
		/datum/reagent/medicine/inacusiate,
		/datum/reagent/medicine/mannitol,
		/datum/reagent/medicine/morphine,
		/datum/reagent/medicine/mutadone,
		/datum/reagent/medicine/oculine,
		/datum/reagent/medicine/potass_iodide,
		/datum/reagent/medicine/salglu_solution,

		/datum/reagent/toxin/formaldehyde,
		/datum/reagent/toxin/heparin,
		/datum/reagent/toxin/mindbreaker,
	)
	/// Blacklisted chemicals - separate from chemicals that cannot be synthesized, borers specifically cannot learn these
	var/list/blacklisted_chemicals = list()


	/// How old the borer is, starting from zero. Goes up only when inside a host
	var/maturity_age = 0
	/// Just a little "timer" to compare to world.time
	var/timed_maturity = 0

	/// How many times you've levelled up over all
	var/level = 0

	/// The amount of "evolution" points a borer has for chemicals. Start with one
	var/chemical_evolution = 1
	/// The amount of "evolution" points a borer has for stats
	var/stat_evolution = 0

	/// How many chemical points the borer can have. Can be upgraded
	var/max_chemical_storage = 50
	/// How many chemical points the borer has
	var/chemical_storage = 50
	/// How fast chemicals are gained. Goes up only when inside a host
	var/chemical_regen = 1

	/// How much health you gain per level
	var/health_per_level = 2.5
	/// How much health regen you gain per level
	var/health_regen_per_level = 0.02

	/// How much more chemical storage you gain per level
	var/chem_storage_per_level = 20
	/// Chemical regen you gain per level
	var/chem_regen_per_level = 1

	/// The list of actions that the borer has
	var/list/datum/action/cooldown/borer/known_abilities = list(
		/datum/action/cooldown/borer/toggle_hiding,
		/datum/action/cooldown/borer/choosing_host,
		/datum/action/cooldown/borer/evolution_tree,
		/datum/action/cooldown/borer/inject_chemical,
		/datum/action/cooldown/borer/upgrade_chemical,
		/datum/action/cooldown/borer/learn_focus,
		/datum/action/cooldown/borer/upgrade_stat,
		/datum/action/cooldown/borer/force_speak,
		/datum/action/cooldown/borer/fear_human,
		/datum/action/cooldown/borer/check_blood,
	)

	/// The host
	var/mob/living/carbon/human/human_host
	/// What the host gains or loses with the borer
	var/list/hosts_abilities = list()

	/// Multiplies the current health up to the max health
	var/health_regen = 1.02
	/// Holds the chems right before injection
	var/obj/item/reagent_containers/reagent_holder
	/// Lust a flavor kind of thing
	var/generation = 0
	/// List of focus datums
	var/list/possible_focuses = list()
	/// What focuses the borer has unlocked
	var/list/body_focuses = list()
	/// How many children the borer has produced
	var/children_produced = 0
	/// How many blood chems have been learned through the blood
	var/blood_chems_learned = 0
	/// We dont want to spam the chat
	var/deathgasp_once = FALSE
	// The limit to the chemical and stat evolution
	var/limited_borer = 10
	/// Borers can only enter biologicals if true
	var/organic_restricted = TRUE
	/// Borers are unable to enter changelings if true
	var/changeling_restricted = TRUE
	/// Assoc list of chemical injection rates that the borer can have
	var/static/list/injection_rates = list(
		5,
		10,
		25,
		50,
	)
	/// Which injection rates the borer has unlocked
	var/list/injection_rates_unlocked = list(
		5,
	)
	/// What is the current injection rate of the borer
	var/injection_rate_current = 5
	/// Cooldown between injecting chemicals
	COOLDOWN_DECLARE(injection_cooldown)
	/// Evolutions we've already learned
	var/list/past_evolutions = list()
	/// Bitflag of upgrades and effects the borer has
	var/upgrade_flags = 0
	/// If the borer has evolved with a genome that locks out others of the same & higher tier
	var/genome_locked = FALSE
	/// Multiplier for a borer's negative effects to their host
	var/host_harm_multiplier = 1

	/// Controls if the borer can reproduce or not, TRUE means it wont be able to spawn eggs
	var/neutered = FALSE
	/// Used to give the borer the antagonist datum
	var/antagonist_datum = /datum/antagonist/cortical_borer/hivemind

	/// Skips unique borer status tab text, used for unique borer subtypes with their own status tabs
	var/skip_status_tab = FALSE

/mob/living/basic/cortical_borer/can_track(mob/living/user)
	return FALSE // The validhunt box machines are onto us, we cannot let them track us

/mob/living/basic/cortical_borer/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/squashable, \
		squash_chance = 25, \
		squash_damage = 25, \
		squash_flags = SQUASHED_DONT_SQUASH_IN_CONTENTS, \
	)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT) //they need to be able to move around

	var/matrix/borer_matrix = matrix(transform)
	borer_matrix.Scale(0.5, 0.5)
	transform = borer_matrix

	create_name()

	GLOB.cortical_borers += src
	reagent_holder = new /obj/item/reagent_containers/borer(src)

	for(var/action_type in known_abilities)
		var/datum/action/attack_action = new action_type(src)
		attack_action.Grant(src)

	if(mind)
		if(!mind.has_antag_datum(antagonist_datum))
			mind.add_antag_datum(antagonist_datum)

	for(var/focus_path in subtypesof(/datum/borer_focus))
		possible_focuses += new focus_path

	do_evolution(/datum/borer_evolution/base)
	INVOKE_ASYNC(src, PROC_REF(resolve_misc_issues)) // if things can fail, they will

/mob/living/basic/cortical_borer/Destroy()
	human_host = null
	GLOB.cortical_borers -= src
	QDEL_NULL(reagent_holder)
	return ..()

/mob/living/basic/cortical_borer/death(gibbed)
	if(inside_human())
		var/turf/human_turf = get_turf(human_host)
		forceMove(human_turf)
		human_host = null
	GLOB.cortical_borers -= src
	if(!deathgasp_once)
		deathgasp_once = TRUE
		for(var/borers in GLOB.cortical_borers)
			to_chat(borers, span_boldwarning("[src] has left the hivemind forcibly!"))
	if(gibbed)
		QDEL_NULL(reagent_holder)
	return ..()

//so we can add some stuff to status, making it easier to read... maybe some hud some day
/mob/living/basic/cortical_borer/get_status_tab_items()
	. = ..()
	if(skip_status_tab)
		return
	. += "Chemical Storage: [chemical_storage]/[max_chemical_storage]"
	. += "Chemical Evolution Points: [chemical_evolution]"
	. += "Stat Evolution Points: [stat_evolution]"
	. += ""
	if(host_sugar())
		. += "Sugar detected! Unable to generate resources!"
		. += ""
	. += "OBJECTIVES:"
	. += "1) [GLOB.objective_egg_borer_number] borers producing [GLOB.objective_egg_egg_number] eggs: [GLOB.successful_egg_number]/[GLOB.objective_egg_borer_number]"
	. += "2) [GLOB.objective_willing_hosts] willing hosts: [length(GLOB.willing_hosts)]/[GLOB.objective_willing_hosts]"
	. += "3) [GLOB.objective_blood_borer] borers learning [GLOB.objective_blood_chem] chemicals from the blood: [GLOB.successful_blood_chem]/[GLOB.objective_blood_borer]"

/mob/living/basic/cortical_borer/Life(seconds_per_tick, times_fired)
	. = ..()
	//can only do stuff when we are inside a LIVING human
	if(!inside_human() || human_host?.stat == DEAD)
		return

	//there needs to be a negative to having a borer
	if(prob(5 * host_harm_multiplier * ((upgrade_flags & BORER_STEALTH_MODE) ? 0.1 : 1)) && human_host.getToxLoss() <= (80 * host_harm_multiplier))
		human_host.adjustToxLoss(5 * host_harm_multiplier, TRUE, TRUE)

	human_host.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

	//cant do anything if the host has sugar
	if(host_sugar())
		if(!has_status_effect(/datum/status_effect/borer_sugar))
			apply_status_effect(/datum/status_effect/borer_sugar)
	else
		if(has_status_effect(/datum/status_effect/borer_sugar))
			remove_status_effect(/datum/status_effect/borer_sugar)

	//this is regenerating chemical_storage
	if(chemical_storage < max_chemical_storage)
		if(!(upgrade_flags & BORER_STEALTH_MODE))
			chemical_storage = min(chemical_storage + chemical_regen, max_chemical_storage)

	//this is regenerating health
	if(health < maxHealth)
		if(!(upgrade_flags & BORER_STEALTH_MODE))
			health = min(health * health_regen, maxHealth)

	//this is so they can evolve
	if(timed_maturity < world.time)
		mature()

//if it doesnt have a ckey, let ghosts have it
/mob/living/basic/cortical_borer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(ckey || key)
		return
	if(stat == DEAD)
		return
	var/choice = tgui_input_list(usr, "Do you want to control [src]?", "Confirmation", list("Yes", "No"))
	if(choice != "Yes")
		return
	if(ckey || key)
		return
	to_chat(user, span_warning("As a borer, you have the option to be friendly or not. Note that how you act will determine how a host responds!"))
	to_chat(user, span_warning("You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! You only grow/heal/talk when inside a host!"))
	ckey = user.ckey
	if(mind)
		mind.add_antag_datum(antagonist_datum)

/mob/living/basic/cortical_borer/proc/create_name()
	// So their gen and a random. ex 1-288 is first gen named 288, 4-483 is fourth gen named 483
	// Additionally we add in a random title,
	// mainly so people can ahelp borers quicker and admins dont have to look through the logs of the 5 borers that were inside you
	name = "[initial(name)] ([pick(borer_first_names)]: [pick(borer_second_names)]) ([generation]-[rand(100,999)])"

	if(istype(/mob/living/basic/cortical_borer/empowered, src)) // lets also distinguish empowered borers from normal ones
		name = "larger [name]"

	if(generation == 0) //The first ever borer gets a special name
		name = "The hivequeen [initial(name)]"

// if things can go wrong, they will. So this proc is an emergency measure meant to resolve them
/mob/living/basic/cortical_borer/proc/resolve_misc_issues()
	sleep(5 SECONDS) // give everything some time to resolve itself, if it fails then we come in
	if(name == initial(name))
		message_admins("[ADMIN_LOOKUPFLW(src)] had its name initialization fail, this should never happen! Automatically gave a backup name.")
		create_name()

	if(mind) // can actually happen if admins turn someone into a borer in a weird enough way
		if(!mind.has_antag_datum(antagonist_datum))
			message_admins("[ADMIN_LOOKUPFLW(src)] had its antag datum initialization fail, this should never happen! Automatically gave the mob antag datum [antagonist_datum]")
			mind.add_antag_datum(antagonist_datum)

	else // apparently can happen with the neutered borer spawner, not a damn clue what causes it
		message_admins("[ADMIN_LOOKUPFLW(src)] spawned despite having no ghost, automatically informed ghosts!")
		notify_ghosts(
			"[src] needs to obtain a ghost, click on it to submit yourself!",
			source = src,
			action = NOTIFY_ORBIT,
			header = "The code did not give it one"
		)

//check if we are inside a human
/mob/living/basic/cortical_borer/proc/inside_human()
	if(!ishuman(loc))
		return FALSE
	return TRUE

//check if the host has sugar
/mob/living/basic/cortical_borer/proc/host_sugar()
	if(upgrade_flags & BORER_SUGAR_IMMUNE)
		return FALSE
	if(human_host?.reagents?.has_reagent(/datum/reagent/consumable/sugar))
		return TRUE
	return FALSE

/// Base mob environment handler for body temperature, overridden to take into consideration being inside a host
/mob/living/basic/cortical_borer/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/loc_temp
	if(human_host)
		loc_temp = human_host.coretemperature // set the local temp to that of the host's core temp
	else
		loc_temp = get_temperature(environment)
	var/temp_delta = loc_temp - bodytemperature

	if(!human_host && ismovable(loc))
		var/atom/movable/occupied_space = loc
		temp_delta *= (1 - occupied_space.contents_thermal_insulation)

	if(temp_delta < 0) // it is cold here
		if(!on_fire) // do not reduce body temp when on fire
			adjust_bodytemperature(max(max(temp_delta / BODYTEMP_DIVISOR, BODYTEMP_COOLING_MAX) * seconds_per_tick, temp_delta))
	else // this is a hot place
		adjust_bodytemperature(min(min(temp_delta / BODYTEMP_DIVISOR, BODYTEMP_HEATING_MAX) * seconds_per_tick, temp_delta))

//leave the host, forced or not
/mob/living/basic/cortical_borer/proc/leave_host()
	if(!human_host)
		return
	var/obj/item/organ/internal/borer_body/borer_organ = locate() in human_host.organs
	if(borer_organ)
		borer_organ.Remove(human_host)
	forceMove(human_host.drop_location())
	human_host = null

//borers shouldnt be able to whisper...
/mob/living/basic/cortical_borer/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced, filterproof)
	to_chat(src, span_warning("You are not able to whisper!"))
	return FALSE

//previously had borers unable to emote... but that means less RP, and we want that

//borers should not be talking without a host at least
/mob/living/basic/cortical_borer/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	if(!inside_human())
		to_chat(src, span_warning("You are not able to speak without a host!"))
		return
	if(host_sugar())
		message = scramble_message_replace_chars(message, 10)
	message = sanitize(message)
	var/list/split_message = splittext(message, "")

	//this is so they can talk in hivemind
	if(split_message[1] == ";")
		message = copytext(message, 2)
		for(var/borer in GLOB.cortical_borers)
			to_chat(borer, span_purple("<b>Cortical Hivemind: [src] sings, \"[message]\"</b>"))
		for(var/mob/dead_mob in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(dead_mob, src)
			to_chat(dead_mob, span_purple("[link] <b>Cortical Hivemind: [src] sings, \"[message]\"</b>"))
		var/logging_textone = "[key_name(src)] spoke into the hivemind: [message]"
		log_say(logging_textone)
		return

	//this is when they speak normally
	to_chat(human_host, span_purple("Cortical Link: [src] sings, \"[message]\""))
	var/logging_texttwo = "[key_name(src)] spoke to [key_name(human_host)]: [message]"
	log_say(logging_texttwo)
	to_chat(src, span_purple("Cortical Link: [src] sings, \"[message]\""))
	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, src)
		to_chat(dead_mob, span_purple("[link] Cortical Hivemind: [src] sings to [human_host], \"[message]\""))

//borers should not be able to pull anything
/mob/living/basic/cortical_borer/start_pulling(atom/movable/AM, state, force, supress_message)
	to_chat(src, span_warning("You cannot pull things!"))
	return

/// Called on Life() for the borer to age a bit
/mob/living/basic/cortical_borer/proc/mature()
	. = TRUE
	if(upgrade_flags & BORER_STEALTH_MODE)
		return FALSE
	timed_maturity = world.time + 0.5 SECONDS
	maturity_age++

	/**
	 * The point values are double what they seem
	 * So in the beginning you start out with the following generation:
	 * Evolution point per 40 seconds
	 * Chemical point per 20 seconds
	 */

	//20:40, 15:30, 10:20, 5:10
	var/maturity_threshold = 2 SECONDS
	if(GLOB.successful_egg_number >= GLOB.objective_egg_borer_number)
		maturity_threshold -= 0.2 SECONDS
	if(length(GLOB.willing_hosts) >= GLOB.objective_willing_hosts)
		maturity_threshold -= 1 SECOND
	if(GLOB.successful_blood_chem >= GLOB.objective_blood_borer)
		maturity_threshold -= 0.3 SECONDS

	if(maturity_age == maturity_threshold)
		if(chemical_evolution < limited_borer) //you can only have a default of 10 at a time
			chemical_evolution++
			to_chat(src, span_notice("You gain a chemical evolution point. Spend it to learn a new chemical!"))
		else
			to_chat(src, span_warning("You were unable to gain a chemical evolution point due to having the max!"))
	if(maturity_age >= (maturity_threshold * 2))
		if(stat_evolution < limited_borer)
			stat_evolution++
			to_chat(src, span_notice("You gain a stat evolution point. Spend it to become stronger!"))
		else
			to_chat(src, span_warning("You were unable to gain a stat evolution point due to having the max!"))
		maturity_age = 0

/// Use to recalculate a borer's health and chemical stats when something retroactively affects them
/mob/living/basic/cortical_borer/proc/recalculate_stats()
	var/old_health = health
	maxHealth = initial(maxHealth) + (level * health_per_level)
	health_regen = initial(health_regen) + (level * health_regen_per_level)
	max_chemical_storage = initial(max_chemical_storage) + (level * chem_storage_per_level)
	chemical_regen = initial(chemical_regen) + (level * chem_regen_per_level)
	health = clamp(old_health, 1, maxHealth)

#undef BODYTEMP_DIVISOR
