
//size
#define ARTIFACT_SIZE_TINY 0 //items
#define ARTIFACT_SIZE_SMALL 1 //big items
#define ARTIFACT_SIZE_LARGE 2 //not items

// origins
#define ORIGIN_NARSIE "narnar"
#define ORIGIN_SILICON "silicon"
#define ORIGIN_WIZARD "wiznerd"
#define ORIGIN_PRECURSOR "precursor"
#define ORIGIN_MARTIAN "martian"
// rarities
#define ARTIFACT_COMMON 500
#define ARTIFACT_UNCOMMON 400
#define ARTIFACT_VERYUNCOMMON 300
#define ARTIFACT_RARE 250
#define ARTIFACT_VERYRARE 140

//cuts down on boiler plate code
#define ARTIFACT_SETUP(X,subsystem) ##X/Initialize(mapload, var/forced_origin = null,var/forced_effect = null){\
	. = ..();\
	START_PROCESSING(subsystem, src);\
	if(assoc_comp) {\
		assoc_comp = AddComponent(assoc_comp, forced_origin, forced_effect);\
		RegisterSignal(src, COMSIG_QDELETING, PROC_REF(on_delete));\
	}\
} \
##X/proc/on_delete(atom/source){\
	SIGNAL_HANDLER;\
	assoc_comp = null;\
} \
##X/process(){\
	assoc_comp?.stimulate_from_turf_heat(get_turf(src));\
	if(assoc_comp?.active) {\
		for(var/datum/artifact_effect/eff in assoc_comp.artifact_effects) {\
			eff.effect_process();\
		}\
	}\
} \
##X/rad_act(intensity){\
	assoc_comp?.stimulate_from_rad_act(intensity)\
}

#define STIMULUS_CARBON_TOUCH (1<<0)
#define STIMULUS_SILICON_TOUCH (1<<1)
#define STIMULUS_FORCE (1<<2)
#define STIMULUS_HEAT (1<<3)
#define STIMULUS_SHOCK (1<<4)
#define STIMULUS_RADIATION (1<<5)
#define STIMULUS_DATA (1<<6)
