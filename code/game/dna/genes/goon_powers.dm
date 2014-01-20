

// WAS: /datum/bioEffect/alcres
/datum/dna/gene/basic/sober
	name="Sober"
	activation_messages=list("You feel unusually sober.")
	deactivation_messages = list("You feel like you could use a stiff drink.")

	mutation=M_SOBER

	New()
		block=SOBERBLOCK

//WAS: /datum/bioEffect/psychic_resist
/datum/dna/gene/basic/psychic_resist
	name="Psy-Resist"
	desc = "Boosts efficiency in sectors of the brain commonly associated with meta-mental energies."
	activation_messages = list("Your mind feels closed.")
	deactivation_messages = list("You feel oddly exposed.")

	mutation=M_PSY_RESIST

	New()
		block=PSYRESISTBLOCK

/////////////////////////
// Stealth Enhancers
/////////////////////////

/datum/dna/gene/basic/stealth
	can_activate(var/mob/M, var/flags)
		// Can only activate one of these at a time.
		if(is_type_in_list(/datum/dna/gene/basic/stealth,M.mutations))
			return 0
		return ..(M,flags)

// WAS: /datum/bioEffect/darkcloak
/datum/dna/gene/basic/stealth/darkcloak
	name = "Cloak of Darkness"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	activation_messages = list("You begin to fade into the shadows.")
	deactivation_messages = list("You become fully visible.")

	New()
		block=SHADOWBLOCK

	OnMobLife(var/mob/M)
		var/turf/simulated/T = get_turf(M)
		if(!istype(T))
			return
		if(T.lighting_lumcount <= 2)
			M.alpha = round((255 * 0.15))
		else
			M.alpha = round((255 * 0.80))

//WAS: /datum/bioEffect/chameleon
/datum/dna/gene/basic/stealth/chameleon
	name = "Chameleon"
	desc = "The subject becomes able to subtly alter light patterns to become invisible, as long as they remain still."
	activation_messages = list("You feel one with your surroundings.")
	deactivation_messages = list("You feel oddly exposed.")

	New()
		block=CHAMELEONBLOCK

	OnMobLife(var/mob/M)
		if((world.timeofday - M.last_move_intent) >= 30 && !M.stat && M.canmove && !M.restrained())
			M.alpha = round((255 * 0.15))
		else
			M.alpha = round((255 * 0.80))
		return