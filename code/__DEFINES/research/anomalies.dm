// Max amounts of cores you can make
#define MAX_CORES_BLUESPACE 3
#define MAX_CORES_GRAVITATIONAL 6
#define MAX_CORES_FLUX 5
#define MAX_CORES_VORTEX 3
#define MAX_CORES_PYRO 8
#define MAX_CORES_HALLUCINATION 8
#define MAX_CORES_BIOSCRAMBLER 8
#define MAX_CORES_DIMENSIONAL 8
#define MAX_CORES_ECTOPLASMIC 8

///Defines for the different types of explosion a flux anomaly can have
#define FLUX_NO_EMP 0
#define FLUX_EMP 1
#define FLUX_LIGHT_EMP 2

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
	/obj/item/organ/pod_hair,
	/obj/item/organ/spines,
	/obj/item/organ/wings,
	/obj/item/organ/wings/functional,
	/obj/item/organ/alien,
	/obj/item/organ/brain,
	/obj/item/organ/body_egg,
	/obj/item/organ/cyberimp,
	/obj/item/organ/ears/dullahan,
	/obj/item/organ/eyes/dullahan,
	/obj/item/organ/heart/cursed,
	/obj/item/organ/heart/demon,
	/obj/item/organ/lungs,
	/obj/item/organ/monster_core,
	/obj/item/organ/tongue/dullahan,
	/obj/item/organ/vocal_cords/colossus,
	/obj/item/organ/zombie_infection,
)))

/// List of body parts we can apply to people
GLOBAL_LIST_EMPTY(bioscrambler_valid_parts)
/// List of organs we can apply to people
GLOBAL_LIST_EMPTY(bioscrambler_valid_organs)
