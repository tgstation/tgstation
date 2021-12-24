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
	name = "transforming spring"
	color = "#CBC3E3"
	light_color = "#CBC3E3"
	light_range = 3
	light_power = 1.75
	light_on = TRUE
	baseturfs = /turf/open/water/cursed_spring
	planetary_atmos = TRUE
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/water/cursed_spring/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/L = arrived
	if(!L.client || L.incorporeal_move || !L.mind)
		return
	if(HAS_TRAIT(L.mind, TRAIT_HOT_SPRING_CURSED)) // no double dipping
		return

	ADD_TRAIT(L.mind, TRAIT_HOT_SPRING_CURSED, TRAIT_GENERIC)
	var/random_choice = pick("Mob", "Appearance")
	switch(random_choice)
		if("Mob")
			L = L.wabbajack("animal")
		if("Appearance")
			var/mob/living/carbon/human/H = L.wabbajack("humanoid")
			randomize_human(H)
			var/list/all_species = list()
			for(var/stype in subtypesof(/datum/species))
				var/datum/species/S = stype
				if(initial(S.changesource_flags) & RACE_SWAP)
					all_species += stype
			var/random_race = pick(all_species)
			H.set_species(random_race)
			H.dna.update_dna_identity()
			L = H
	var/turf/T = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)
	L.forceMove(T)
	to_chat(L, span_notice("You blink and find yourself in [get_area_name(T)]."))
