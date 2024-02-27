/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/service/janitor.dmi'
	icon_state = "mop"
	inhand_icon_state = "mop"
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
	var/max_reagent_volume = 45
	var/mopspeed = 1.5 SECONDS
	force_string = "robust... against germs"
	var/insertable = TRUE
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
	AddComponent(/datum/component/liquids_interaction, TYPE_PROC_REF(/obj/item/mop, attack_on_liquids_turf))
	create_reagents(max_reagent_volume)
	GLOB.janitor_devices += src

/obj/item/mop/attack_secondary(mob/living/victim, mob/living/user, params)


/obj/item/mop/Destroy(force)
	GLOB.janitor_devices -= src
	return ..()

/obj/item/mop/proc/attack_on_liquids_turf(obj/item/mop/the_mop, turf/T, mob/user, obj/effect/abstract/liquid_turf/liquids)
	if(!user.Adjacent(T))
		return FALSE
	var/free_space = max_reagent_volume - src.reagents.total_volume
	var/looping = TRUE
	var/speed_mult = 1
	var/datum/liquid_group/targeted_group = T.liquids.liquid_group
	while(looping)
		if(speed_mult >= 0.2)
			speed_mult -= 0.05
		if(free_space <= 0)
			to_chat(user, "<span class='warning'>Your mop can't absorb any more!</span>")
			looping = FALSE
			return TRUE
		if(do_after(user, src.mopspeed * speed_mult, target = T))
			if(the_mop.reagents.total_volume == the_mop.max_reagent_volume)
				to_chat(user, "<span class='warning'>Your [src.name] can't absorb any more!</span>")
				return TRUE
			if(targeted_group.reagents_per_turf)
				targeted_group.trans_to_seperate_group(the_mop.reagents, min(targeted_group.reagents_per_turf, 5))
				to_chat(user, "<span class='notice'>You soak up some liquids with the [src.name].</span>")
			else if(T.liquids.liquid_group)
				targeted_group = T.liquids.liquid_group
			else
				looping = FALSE
		else
			looping = FALSE
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE


///Checks whether or not we should clean.
/obj/item/mop/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	var/turf/turf_to_clean = atom_to_clean

	// Disable normal cleaning if there are liquids.
	if(isturf(atom_to_clean) && turf_to_clean.liquids)
		to_chat(cleaner, span_warning("It would be quite difficult to clean this with a pool of liquids on top!"))
		return DO_NOT_CLEAN

	if(clean_blacklist[atom_to_clean.type])
		return DO_NOT_CLEAN
	if(reagents.total_volume < 0.1)
		to_chat(cleaner, span_warning("Your mop is dry!"))
		return DO_NOT_CLEAN
	return reagents.has_chemical_flag(REAGENT_CLEANS, 1)

/**
 * Applies reagents to the cleaned floor and removes them from the mop.
 *
 * Arguments
 * * cleaning_source the source of the cleaning
 * * cleaned_turf the turf that is being cleaned
 * * cleaner the mob that is doing the cleaning
 */
/obj/item/mop/proc/apply_reagents(datum/cleaning_source, turf/cleaned_turf, mob/living/cleaner)
	reagents.expose(cleaned_turf, TOUCH, 10) //Needed for proper floor wetting.
	var/val2remove = 1
	if(cleaner?.mind)
		val2remove = round(cleaner.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER), 0.1)
	reagents.remove_any(val2remove) //reaction() doesn't use up the reagents

/obj/item/mop/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal, complete with a condenser for self-wetting! Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	max_reagent_volume = 100
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
	to_chat(user, span_notice("You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position."))
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

/obj/item/mop/advanced/cyborg
	insertable = FALSE

/obj/item/mop/sharp //Basically a slightly worse spear.
	desc = "A mop with a sharpened handle. Careful!"
	name = "sharpened mop"
	force = 10
	throwforce = 18
	throw_speed = 4
	demolition_mod = 0.75
	embedding = list("impact_pain_mult" = 2, "remove_pain_mult" = 4, "jostle_chance" = 2.5)
	armour_penetration = 10
	attack_verb_continuous = list("mops", "stabs", "shanks", "jousts")
	attack_verb_simple = list("mop", "stab", "shank", "joust")
	sharpness = SHARP_EDGED //spears aren't pointy either.  Just assume it's carved into a naginata-style blade
	wound_bonus = -15
	bare_wound_bonus = 15
