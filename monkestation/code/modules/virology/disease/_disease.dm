/datum/disease
	//the disease's antigens, that the body's immune_system will read to produce corresponding antibodies. Without antigens, a disease cannot be cured.
	var/list/antigen = list()
	///can we spread
	var/spread = FALSE
	//alters a pathogen's propensity to mutate. Set to FALSE to forbid a pathogen from ever mutating.
	var/mutation_modifier = TRUE
	//the antibody concentration at which the disease will fully exit the body
	var/strength = 100
	//the percentage of the strength at which effects will start getting disabled by antibodies.
	var/robustness = 100
	//chance to cure the disease at every proc when the body is getting cooked alive.
	var/max_bodytemperature = 1000
	//very low temperatures will stop the disease from activating/progressing
	var/min_bodytemperature = 120

	//logging
	var/log = ""
	var/origin = "Unknown"
	var/logged_virusfood = FALSE
	var/fever_warning = FALSE

	//cosmetic
	var/color
	var/pattern = 1
	var/pattern_color

	///pathogenic warfare - If you have a second disease of a form name in the list they will start fighting.
	var/list/can_kill = list("Bacteria")

	//When an opportunity for the disease to spread to a mob arrives, runs this percentage through prob()
	//Ignored if infected materials are ingested (injected with infected blood, eating infected meat)
	var/infectionchance = 70
	var/infectionchance_base = 70

	//ticks increases by [speed] every time the disease activates. Drinking Virus Food also accelerates the process by 10.
	var/ticks = 0
	var/speed = 1

/proc/filter_disease_by_spread(list/diseases, required = NONE)
	if(!length(diseases))
		return list()

	var/list/viable = list()
	for(var/datum/disease/disease as anything in diseases)
		if(!(disease.spread_flags & required))
			continue
		viable += disease
	return viable
