/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/service/janitor.dmi'
	icon_state = "mop"
	inhand_icon_state = "mop"
	icon_angle = 135
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("mops", "bashes", "bludgeons", "whacks")
	attack_verb_simple = list("mop", "bash", "bludgeon", "whack")
	resistance_flags = FLAMMABLE
	var/mopcount = 0
	///Maximum volume of reagents it can hold.
	var/max_reagent_volume = 15
	var/mopspeed = 1.5 SECONDS
	force_string = "robust... against germs"
	var/static/list/clean_blacklist = typecacheof(list(
		/obj/item/reagent_containers/cup/bucket,
		/obj/structure/mop_bucket,
	))

/obj/item/mop/apply_fantasy_bonuses(bonus)
	. = ..()
	mopspeed = modify_fantasy_variable("mopspeed", mopspeed, -bonus)

/obj/item/mop/remove_fantasy_bonuses(bonus)
	mopspeed = reset_fantasy_variable("mopspeed", mopspeed)
	return ..()

/obj/item/mop/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleaner, mopspeed, pre_clean_callback=CALLBACK(src, PROC_REF(should_clean)), on_cleaned_callback=CALLBACK(src, PROC_REF(apply_reagents)))
	create_reagents(max_reagent_volume)
	GLOB.janitor_devices += src

/obj/item/mop/Destroy(force)
	GLOB.janitor_devices -= src
	return ..()

///Checks whether or not we should clean.
/obj/item/mop/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(clean_blacklist[atom_to_clean.type])
		return CLEAN_BLOCKED|CLEAN_DONT_BLOCK_INTERACTION
	if(reagents.total_volume < 0.1)
		cleaner.balloon_alert(cleaner, "mop is dry!")
		return CLEAN_BLOCKED
	if(reagents.has_reagent(amount = 1, chemical_flags = REAGENT_CLEANS))
		return CLEAN_ALLOWED
	return CLEAN_ALLOWED|CLEAN_NO_XP|CLEAN_NO_WASH

/**
 * Applies reagents to the cleaned floor and removes them from the mop.
 *
 * Arguments
 * * cleaning_source the source of the cleaning
 * * cleaned_turf the turf that is being cleaned
 * * cleaner the mob that is doing the cleaning
 */
/obj/item/mop/proc/apply_reagents(datum/cleaning_source, turf/cleaned_turf, mob/living/cleaner, clean_succeeded)
	if(!clean_succeeded)
		return
	reagents.expose(cleaned_turf, TOUCH, 10) //Needed for proper floor wetting.
	var/val2remove = 1
	if(cleaner?.mind)
		val2remove = round(cleaner.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER), 0.1)
	reagents.remove_all(val2remove) //reaction() doesn't use up the reagents

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal, complete with a condenser for self-wetting! Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	max_reagent_volume = 10
	icon_state = "advmop"
	inhand_icon_state = "advmop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 12
	throwforce = 14
	throw_range = 4
	mopspeed = 0.8 SECONDS
	var/refill_enabled = TRUE //Self-refill toggle for when a janitor decides to mop with something other than water.
	/// Amount of reagent to refill per second
	var/refill_rate = 0.5
	var/refill_reagent = /datum/reagent/water //Determins what reagent to use for refilling, just in case someone wanted to make a HOLY MOP OF PURGING

/obj/item/mop/advanced/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/attack_self(mob/user)
	refill_enabled = !refill_enabled
	if(refill_enabled)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj,src)
	user.balloon_alert(user, "condenser switch [refill_enabled ? "on" : "off"]")
	playsound(user, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/mop/advanced/process(seconds_per_tick)
	var/amadd = min(max_reagent_volume - reagents.total_volume, refill_rate * seconds_per_tick)
	if(amadd > 0)
		reagents.add_reagent(refill_reagent, amadd)

/obj/item/mop/advanced/examine(mob/user)
	. = ..()
	. += span_notice("The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.")

/obj/item/mop/advanced/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
