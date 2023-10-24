//size
#define ARTIFACT_SIZE_TINY 0 //items
#define ARTIFACT_SIZE_SMALL 1 //big items
#define ARTIFACT_SIZE_LARGE 2 //not items
// stimuli
#define STIMULUS_CARBON_TOUCH "carbontouch"
#define STIMULUS_SILICON_TOUCH "silicontouch"
#define STIMULUS_FORCE "force"
#define STIMULUS_HEAT "heat" //also works for cold
#define STIMULUS_SHOCK "electricity"
#define STIMULUS_RADIATION "rads"
#define STIMULUS_DATA "data"
// origins
#define ORIGIN_NARSIE "narnar"
#define ORIGIN_SILICON "silicon"
#define ORIGIN_WIZARD "wiznerd"
// rarities
#define ARTIFACT_COMMON 500
#define ARTIFACT_UNCOMMON 400
#define ARTIFACT_VERYUNCOMMON 300
#define ARTIFACT_RARE 250
#define ARTIFACT_VERYRARE 140

//cuts down on boiler plate code 
#define ARTIFACT_SETUP(X,subsystem) ##X/Initialize(mapload, var/forced_origin = null){\
	. = ..();\
	START_PROCESSING(subsystem, src);\
	assoc_comp = AddComponent(assoc_comp, forced_origin);\
	RegisterSignal(src, COMSIG_QDELETING, PROC_REF(on_delete));\
} \
##X/proc/on_delete(atom/source){\
	SIGNAL_HANDLER;\
	assoc_comp = null;\
} \
##X/process(){\
	assoc_comp?.heat_from_turf(get_turf(src));\
	if(assoc_comp?.active) {\
		assoc_comp.effect_process();\
	}\
}
