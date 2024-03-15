#define BLOOD_TIMER_REQUIREMENT (10 MINUTES)
#define BLOOD_TIMER_HALWAY (BLOOD_TIMER_REQUIREMENT / 2)

/datum/antagonist/ex_vassal
	name = "\improper Ex-Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "vassal_grey"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	silent = TRUE
	ui_name = FALSE
	hud_icon = 'monkestation/icons/bloodsuckers/bloodsucker_icons.dmi'

	///The revenge vassal that brought us into the fold.
	var/datum/antagonist/vassal/revenge/revenge_vassal
	///Timer we have to live
	COOLDOWN_DECLARE(blood_timer)

/datum/antagonist/ex_vassal/on_gain()
	. = ..()
	RegisterSignal(owner.current, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/antagonist/ex_vassal/on_removal()
	if(revenge_vassal)
		revenge_vassal.ex_vassals -= src
		revenge_vassal = null
	blood_timer = null
	return ..()

/datum/antagonist/ex_vassal/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER

	var/datum/antagonist/vassal/revenge/vassaldatum = examiner.mind?.has_antag_datum(/datum/antagonist/vassal/revenge)
	if(vassaldatum && !revenge_vassal)
		examine_text += span_notice("[owner.current] is an ex-vassal!")

/datum/antagonist/ex_vassal/add_team_hud(mob/target)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
	))

	var/datum/atom_hud/alternate_appearance/basic/has_antagonist/hud = team_hud_ref.resolve()

	var/list/mob/living/mob_list = list()
	mob_list += revenge_vassal.owner.current
	for(var/datum/antagonist/ex_vassal/former_vassals as anything in revenge_vassal.ex_vassals)
		mob_list += former_vassals.owner.current

	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if(!(antag_hud.target in mob_list))
			continue
		antag_hud.show_to(target)
		hud.show_to(antag_hud.target)

/**
 * Fold return
 *
 * Called when a Revenge bloodsucker gets a vassal back into the fold.
 */
/datum/antagonist/ex_vassal/proc/return_to_fold(datum/antagonist/vassal/revenge/mike_ehrmantraut)
	revenge_vassal = mike_ehrmantraut
	mike_ehrmantraut.ex_vassals += src
	COOLDOWN_START(src, blood_timer, BLOOD_TIMER_REQUIREMENT)
	add_team_hud(owner.current)

	RegisterSignal(src, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/antagonist/ex_vassal/proc/on_life(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(COOLDOWN_TIMELEFT(src, blood_timer) <= BLOOD_TIMER_HALWAY + 2 && COOLDOWN_TIMELEFT(src, blood_timer) >= BLOOD_TIMER_HALWAY - 2) //just about halfway
		to_chat(owner.current, span_cultbold("You need new blood from your Master!"))
	if(!COOLDOWN_FINISHED(src, blood_timer))
		return
	to_chat(owner.current, span_cultbold("You are out of blood!"))
	to_chat(revenge_vassal.owner.current, span_cultbold("[owner.current] has ran out of blood and is no longer in the fold!"))
	owner.remove_antag_datum(/datum/antagonist/ex_vassal)


/**
 * Bloodsucker Blood
 *
 * Artificially made, this must be fed to ex-vassals to keep them on their high.
 */
/datum/reagent/blood/bloodsucker
	name = "Blood two"

/datum/reagent/blood/bloodsucker/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message, touch_protection)
	var/datum/antagonist/ex_vassal/former_vassal = exposed_mob.mind.has_antag_datum(/datum/antagonist/ex_vassal)
	if(former_vassal)
		to_chat(exposed_mob, span_cult("You feel the blood restore you... You feel safe."))
		COOLDOWN_RESET(former_vassal, blood_timer)
		COOLDOWN_START(former_vassal, blood_timer, BLOOD_TIMER_REQUIREMENT)
	return ..()

#undef BLOOD_TIMER_REQUIREMENT
#undef BLOOD_TIMER_HALWAY
