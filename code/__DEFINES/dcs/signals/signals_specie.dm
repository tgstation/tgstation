// /datum/species signals
///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_GAIN "species_gain"
///from datum/species/on_species_loss(): (datum/species/lost_species)
#define COMSIG_SPECIES_LOSS "species_loss"
///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species) called before anything is done to ensure passing of data
#define COMSIG_SPECIES_GAIN_PRE "species_gain_pre"
