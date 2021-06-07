GLOBAL_LIST_EMPTY(cursed_minds)

/**
 * Turns whoever enters into a mob or random person
 *
 * If mob is chosen, turns the person into a random animal type
 * If appearance is chosen, turns the person into a random human with a random species
 * This changes name, and changes their DNA as well
 * Random species is same as wizard swap event so people don't get killed ex: plasmamen
 * Once the spring is used, it cannot be used by the same mind ever again
 * After usage, teleports the user back to a random safe turf (so mobs are not killed by ice moon atmosphere)
 *
 */

/turf/open/water/cursed_spring
	baseturfs = /turf/open/water/cursed_spring
	planetary_atmos = TRUE
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/water/cursed_spring/Entered(atom/movable/thing, atom/oldLoc)
	. = ..()
	if(!isliving(thing))
		return
	var/mob/living/L = thing
	if(!L.client || L.incorporeal_move)
		return
	if(GLOB.cursed_minds[L.mind])
		return
	GLOB.cursed_minds[L.mind] = TRUE
	RegisterSignal(L.mind, COMSIG_PARENT_QDELETING, .proc/remove_from_cursed)
	var/random_choice = pick("Mob", "Appearance")
	switch(random_choice)
		if("Mob")
			L = wabbajack(L, "animal")
		if("Appearance")
			var/mob/living/carbon/human/H = wabbajack(L, "humanoid")
			randomize_human(H)
			var/list/all_species = list()
			for(var/stype in subtypesof(/datum/species))
				var/datum/species/S = stype
				if(initial(S.changesource_flags) & RACE_SWAP)
					all_species += stype
			var/random_race = pick(all_species)
			H.set_species(random_race)
			H.dna.unique_enzymes = H.dna.generate_unique_enzymes()
			L = H
	var/turf/T = find_safe_turf()
	L.forceMove(T)
	to_chat(L, "<span class='notice'>You blink and find yourself in [get_area_name(T)].</span>")

/**
 * Deletes minds from the cursed minds list after their deletion
 *
 */
/turf/open/water/cursed_spring/proc/remove_from_cursed(datum/mind/M)
	SIGNAL_HANDLER
	GLOB.cursed_minds -= M
