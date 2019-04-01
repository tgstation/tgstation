


/mob/living/proc/AmBloodsucker(falseIfMortalDisguise=FALSE)
	// No Datum
	if (!mind || !mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		return FALSE




/datum/antagonist/bloodsucker/proc/LifeTick() // Should probably run from life.dm, same as handle_changeling




/datum/antagonist/bloodsucker/proc/SetBloodVolume(value)
	owner.current.blood_volume = CLAMP(owner.current.blood_volume + value, 0, maxBloodVolume)
	//update_hud()


/datum/antagonist/bloodsucker/proc/HandleFeeding(mob/living/carbon/target)

	var/blood_taken = min(feedAmount, target.blood_volume)	// Starts at 15 (now 8 since we doubled the Feed time)
	target.blood_volume -= blood_taken

	// Simple Animals lose a LOT of blood, and take damage. This is to keep cats, cows, and so forth from giving you insane amounts of blood.
	if (!ishuman(target))
		target.blood_volume -= (blood_taken / max(target.mob_size, 0.1)) * 3.5 // max() to prevent divide-by-zero
		target.apply_damage_type(blood_taken / 3.5) // Don't do too much damage, or else they die and provide no blood nourishment.
		if (target.blood_volume <= 0)
			target.blood_volume = 0
			target.death(0)

	// Reduce Value Quantity
	if (target.stat == DEAD)	// Penalty for Dead Blood			<------ **** ALSO make drunk????!
		blood_taken /= 3
	if (!ishuman(target))		// Penalty for Non-Human Blood
		blood_taken /= 2
	//if (!iscarbon(target))	// Penalty for Animals (they're junk food)


	// Apply to Volume
	SetBloodVolume(blood_taken)

	// Reagents (NOT Blood!)
	if(target.reagents && target.reagents.total_volume)
		target.reagents.reaction(owner.current, INGEST, 1 / target.reagents.total_volume) // Run Reaction: what happens when what they have mixes with what I have?
		target.reagents.trans_to(owner.current, 1)	// Run transfer of 1 unit of reagent from them to me.

	// Blood Gulp Sound
	owner.current.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.


/datum/antagonist/bloodsucker/proc/HandleHealing()




