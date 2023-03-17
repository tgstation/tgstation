/obj/item/organ/internal
	name = "organ"

/obj/item/organ/internal/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/internal/Destroy()
	if(owner)
		// The special flag is important, because otherwise mobs can die
		// while undergoing transformation into different mobs.
		Remove(owner, special=TRUE)
	else
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/organ/internal/Insert(mob/living/carbon/receiver, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(!. || !owner)
		return

	// organs_slot must ALWAYS be ordered in the same way as organ_process_order
	// Otherwise life processing breaks down
	sortTim(owner.organs_slot, GLOBAL_PROC_REF(cmp_organ_slot_asc))

	STOP_PROCESSING(SSobj, src)

/obj/item/organ/internal/Remove(mob/living/carbon/organ_owner, special = FALSE)
	. = ..()

	if(organ_owner)
		if((organ_flags & ORGAN_VITAL) && !special && !(organ_owner.status_flags & GODMODE))
			if(organ_owner.stat != DEAD)
				organ_owner.investigate_log("has been killed by losing a vital organ ([src]).", INVESTIGATE_DEATHS)
			organ_owner.death()

	START_PROCESSING(SSobj, src)


/obj/item/organ/internal/process(delta_time, times_fired)
	on_death(delta_time, times_fired) //Kinda hate doing it like this, but I really don't want to call process directly.

/obj/item/organ/internal/on_death(delta_time, times_fired) //runs decay when outside of a person
	if(organ_flags & (ORGAN_SYNTHETIC | ORGAN_FROZEN))
		return
	applyOrganDamage(decay_factor * maxHealth * delta_time)

/// Called once every life tick on every organ in a carbon's body
/// NOTE: THIS IS VERY HOT. Be careful what you put in here
/// To give you some scale, if there's 100 carbons in the game, they each have maybe 9 organs
/// So that's 900 calls to this proc every life process. Please don't be dumb
/obj/item/organ/internal/on_life(delta_time, times_fired) //repair organ damage if the organ is not failing
	if(organ_flags & ORGAN_FAILING)
		handle_failing_organs(delta_time)
		return

	if(failure_time > 0)
		failure_time--

	if(organ_flags & ORGAN_SYNTHETIC_EMP) //Synthetic organ has been emped, is now failing.
		applyOrganDamage(decay_factor * maxHealth * delta_time)
		return

	if(!damage) // No sense healing if you're not even hurt bro
		return

	///Damage decrements by a percent of its maxhealth
	var/healing_amount = healing_factor
	///Damage decrements again by a percent of its maxhealth, up to a total of 4 extra times depending on the owner's health
	healing_amount += (owner.satiety > 0) ? (4 * healing_factor * owner.satiety / MAX_SATIETY) : 0
	applyOrganDamage(-healing_amount * maxHealth * delta_time, damage) // pass curent damage incase we are over cap

///Used as callbacks by object pooling
/obj/item/organ/internal/exit_wardrobe()
	START_PROCESSING(SSobj, src)

//See above
/obj/item/organ/internal/enter_wardrobe()
	STOP_PROCESSING(SSobj, src)

///Organs don't die instantly, and neither should you when you get fucked up
/obj/item/organ/internal/handle_failing_organs(delta_time)
	if(owner.stat == DEAD)
		return

	failure_time += delta_time
	organ_failure(delta_time)
