//indices of values in mat lists. used by listmat.
#define MOLES			1
#define ARCHIVE			2
#define MAT_META		3

#define META_MAT_NAME			1 // The name of the material.
#define META_MAT_SPECIFIC_HEAT	2 // The specific heat of the material. Affects how much energy it costs to heat it up.
#define META_MAT_STATE			3 // The state of the material. SOLID|LIQUID|GAS|PLASMA. Only GAS and PLASMA are used by atmos.
#define META_MAT_VALUE			4 // The value of the material. Used by chem_dispenser and cargo.
#define META_MAT_DESC			5 // The description of the material. Used by scanners in chemistry/atmos.
#define META_MAT_COLOR			6 // The color of the material. Reuse colors as much as possible. Don't make one material #FEFFFF if another material is #FFFFFF. I've been using 12bit colors to save on resources.
#define META_MAT_ALPHA			7 // The alpha of the material. Used by chemistry/atmos.
#define META_MAT_ROBUSTNESS		8 // The robustness of the material.
#define META_MAT_INSTANCE		9 // Used for feeding special material procs.

#define SOLID		 1 // A nonfluid material.
#define LIQUID		 2 // A fluid of finite volume.
#define GAS			 4 // A fluid of infinite volume.
#define PLASMA		 8 // Functionally the same as gas, but uses a different, more visible, gasoverlay.
#define FINITE_MATS	 3 // Shorthand for SOLID|LIQUID
#define GASEOUS_MATS 12 // Shorthand for GAS|PLASMA
#define FLUID_MATS	 14 // Shorthand for LIQUID|GAS|PLASMA
#define	ALL_MATS	 15 // Shorthand for SOLID|LIQUID|GAS|PLASMA

/proc/meta_mat_list()
	. = new /list
	for(var/mat_path in subtypesof(/datum/mat))
		var/list/mat_info = new(9)
		var/datum/mat/mat = mat_path

		mat_info[META_MAT_NAME] = initial(mat.name)
		mat_info[META_MAT_SPECIFIC_HEAT] = initial(mat.specific_heat)
		mat_info[META_MAT_STATE] = initial(mat.state)
		mat_info[META_MAT_VALUE] = initial(mat.value)
		mat_info[META_MAT_DESC] = initial(mat.desc)
		mat_info[META_MAT_COLOR] = initial(mat.color)
		mat_info[META_MAT_ALPHA] = initial(mat.alpha)
		mat_info[META_MAT_ROBUSTNESS] = initial(mat.robustness)
		mat_info[META_MAT_INSTANCE] = initial(mat.instance)
		.[initial(mat.id)] = mat_info

//#define MAT_id "id" // Use defines for id's, as it'll let the compiler do the spellchecking for you.
/datum/mat
	var/id = ""
	var/name = ""
	var/specific_heat = 20 // The default specific heat is 20.
	var/state = SOLID
	var/value = 0
	var/desc = ""
	var/color = "#808080" // Default color is colorless.
	var/alpha = 0
	var/robustness = 0
	var/datum/material/instance