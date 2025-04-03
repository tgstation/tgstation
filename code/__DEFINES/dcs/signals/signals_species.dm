// /datum/species signals
///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species, pref_load, regenerate_icons)
#define COMSIG_SPECIES_GAIN "species_gain"
///from datum/species/on_species_loss(): (datum/species/lost_species)
#define COMSIG_SPECIES_LOSS "species_loss"
///from datum/species/handle_chemical(): (datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
#define COMSIG_SPECIES_HANDLE_CHEMICAL "species_handle_chemicals"
	// same return values as COMSIG_MOB_STOP_REAGENT_CHECK
