//////////////////////
//     BLOODBAG     //
//////////////////////

#define BLOODBAG_GULP_SIZE 5

/// Taken from drinks.dm
/obj/item/reagent_containers/blood/attack(mob/living/victim, mob/living/attacker, params)
	if(!can_drink(victim, attacker))
		return

	if(victim != attacker)
		if(!do_after(victim, 5 SECONDS, attacker))
			return
		attacker.visible_message(
			span_notice("[attacker] forces [victim] to drink from the [src]."),
			span_notice("You put the [src] up to [victim]'s mouth."))
		reagents.trans_to(victim, BLOODBAG_GULP_SIZE, transferred_by = attacker, methods = INGEST)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
		return TRUE

	while(do_after(victim, 1 SECONDS, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(can_drink), attacker, victim)))
		victim.visible_message(
			span_notice("[victim] puts the [src] up to their mouth."),
			span_notice("You take a sip from the [src]."),
		)
		reagents.trans_to(victim, BLOODBAG_GULP_SIZE, transferred_by = attacker, methods = INGEST)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
	return TRUE

#undef BLOODBAG_GULP_SIZE

/obj/item/reagent_containers/blood/proc/can_drink(mob/living/victim, mob/living/attacker)
	if(!canconsume(victim, attacker))
		return FALSE
	if(!reagents || !reagents.total_volume)
		to_chat(victim, span_warning("[src] is empty!"))
		return FALSE
	return TRUE

///Bloodbag of Bloodsucker blood (used by Vassals only)
/obj/item/reagent_containers/blood/o_minus/bloodsucker
	name = "blood pack"
	unique_blood = /datum/reagent/blood/bloodsucker

/obj/item/reagent_containers/blood/o_minus/bloodsucker/examine(mob/user)
	. = ..()
	if(user.mind.has_antag_datum(/datum/antagonist/ex_vassal) || user.mind.has_antag_datum(/datum/antagonist/vassal/revenge))
		. += span_notice("Seems to be just about the same color as your Master's...")
