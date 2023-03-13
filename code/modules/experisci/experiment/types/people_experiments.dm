/datum/experiment/scanning/points/people/species/standard_crew_species
	name = "Human Field Research: Crewmembers"
	description = "Explore the variety of species that staff themselves amongst our crew. \
		Scan fellow crewmembers of each type of species that work for Nanotrasen."
	required_points = 4
	dupes_banned = TRUE // too easy

/datum/experiment/scanning/points/people/species/standard_crew_species/New()
	required_species_ids = make_associative(get_selectable_species())
	// Felinids being enabled adds a blurb to the end of the description
	// to rib at the fact that Felinids are "genetic mixups" of an existing species
	if(required_species_ids[SPECIES_FELINE])
		description += " ...Yes, that includes [format_item_as_name(SPECIES_FELINE)]."

	// Don't put required points above the number of species actually available
	required_points = min(required_points, length(required_species_ids))
	return ..()

/datum/experiment/scanning/points/people/species/ayyyys
	name = "Human Field Research: Abductors"
	description = "Scan the scanners and probe the probers. Scan an Abductor so we can get some insight into their ... existence."
	required_points = 2
	required_species_ids = list(SPECIES_ABDUCTOR = 1)
	mind_required = FALSE // Dead aliens may apply

/datum/experiment/scanning/points/people/species/slime_species
	name = "Human Field Research: Slime-Human Hybrids"
	description = "Through slimeperson mutation toxin harvested from the Green Slime genome, it seems that we can invoke a \
		metamorphosis between human and slime. Scan samples of these new slime-human hybrids."
	required_points = 3 // Updated in new
	dupes_banned = TRUE // One of each

/datum/experiment/scanning/points/people/species/slime_species/New()
	for(var/datum/species/slime_subtype as anything in subtypesof(/datum/species/jelly))
		required_species_ids[initial(slime_subtype.id)] = 1

	required_points = length(required_species_ids)
	return ..()

/datum/experiment/scanning/points/people/wounds/all_wounds
	name = "Human Field Research: Wounds"
	description = "Burning of the flesh, cuts to the bone. The Medical wing is tasked with curing these as quickly as possible, \
		but maybe we can do some research on them first? Surely the patients won't mind."
	// Bearing in mind one person can contribute multiple wounds worth of points for this value
	required_points = 12
	required_wound_types = list(
		/datum/wound/burn/moderate = 1,
		/datum/wound/burn/severe = 2,
		/datum/wound/burn/critical = 3,
		/datum/wound/slash/moderate = 1,
		/datum/wound/slash/severe = 2,
		/datum/wound/slash/critical = 3,
		/datum/wound/pierce/moderate = 1,
		/datum/wound/pierce/severe = 2,
		/datum/wound/pierce/critical = 3,
	)

/datum/experiment/scanning/points/people/mutations/combination
	name = "Human Field Research: Mutations"
	description = "Certain mutations combined with one another seem to produce more volatile mutations. \
		Experiment with combining mutations in your test subjects."
	required_points = 5
	required_mutation_types = list(
		/datum/mutation/human/hulk = 1,
		/datum/mutation/human/shock = 1,
		/datum/mutation/human/mindreader = 1,
		/datum/mutation/human/glow/anti = 1,
		/datum/mutation/human/tongue_spike/chem = 1,
		/datum/mutation/human/martyrdom = 2,
	)

/datum/experiment/scanning/points/people/brain_traumas/random
	name = "Human Field Research: Mental Trauma"
	description = "The company's rated our station in the bottom 99% for mental health and crew sanity. \
		We're not entirely sure why, but a good way to start figuring out would be scanning some brains of \
		your fellow man. Look for some of these traumas to start."
	required_points = 3

/datum/experiment/scanning/points/people/brain_traumas/random/New()
	// Pick a random assortment of common or uncommon traumas
	var/possible_traumas = subtypesof(/datum/brain_trauma/mild) + subtypesof(/datum/brain_trauma/severe)
	for(var/i in 1 to required_points * 2)
		var/datum/brain_trauma/picked = pick_n_take(possible_traumas)
		if(!initial(picked.random_gain))
			continue
		required_trauma_type[picked] = initial(picked.resilience)
	return ..()
