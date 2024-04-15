// Max amounts of cores you can make
#define MAX_CORES_BLUESPACE 8
#define MAX_CORES_GRAVITATIONAL 8
#define MAX_CORES_FLUX 8
#define MAX_CORES_VORTEX 8
#define MAX_CORES_PYRO 8
#define MAX_CORES_HALLUCINATION 8
#define MAX_CORES_BIOSCRAMBLER 8
#define MAX_CORES_DIMENSIONAL 8
#define MAX_CORES_ECTOPLASMIC 8

///Defines for the different types of explosion a flux anomaly can have
#define FLUX_NO_EXPLOSION 0
#define FLUX_EXPLOSIVE 1
#define FLUX_LOW_EXPLOSIVE 2

/// Chance of anomalies moving every process tick
#define ANOMALY_MOVECHANCE 45

/// Blacklist of parts which should not appear when bioscrambled, largely because they will make you look totally fucked up
GLOBAL_LIST_INIT(bioscrambler_parts_blacklist, typecacheof(list(
	/obj/item/bodypart/chest/larva,
	/obj/item/bodypart/head/larva,
)))

/// Blacklist of organs which should not appear when bioscrambled.
/// Either will look terrible outside of intended host, give you magical powers, are irreversible, or kill you
GLOBAL_LIST_INIT(bioscrambler_organs_blacklist, typecacheof(list (
	/obj/item/organ/external/pod_hair,
	/obj/item/organ/external/spines,
	/obj/item/organ/external/wings,
	/obj/item/organ/external/wings/functional,
	/obj/item/organ/internal/alien,
	/obj/item/organ/internal/brain,
	/obj/item/organ/internal/body_egg,
	/obj/item/organ/internal/cyberimp,
	/obj/item/organ/internal/ears/dullahan,
	/obj/item/organ/internal/eyes/dullahan,
	/obj/item/organ/internal/heart/cursed,
	/obj/item/organ/internal/heart/demon,
	/obj/item/organ/internal/lungs,
	/obj/item/organ/internal/monster_core,
	/obj/item/organ/internal/tongue/dullahan,
	/obj/item/organ/internal/vocal_cords/colossus,
	/obj/item/organ/internal/zombie_infection,
)))

/// List of body parts we can apply to people
GLOBAL_LIST_EMPTY(bioscrambler_valid_parts)
/// List of organs we can apply to people
GLOBAL_LIST_EMPTY(bioscrambler_valid_organs)
