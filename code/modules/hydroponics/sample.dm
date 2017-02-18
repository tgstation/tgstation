var/list/chem_t1_reagents = list(
	"hydrogen", "oxygen", "silicon",
	"phosphorus", "sulfur", "carbon",
	"nitrogen", "water"
)

var/list/chem_t2_reagents = list(
	"lithium", "copper", "mercury",
	"sodium", "iodine", "bromine"
) // "sugar", "sacid" removed because they are already in roundstart plants

var/list/chem_t3_reagents = list(
	"ethanol", "chlorine", "potassium",
	"aluminium", "radium", "fluorine",
	"iron", "welding_fuel",	"silver",
	"stable_plasma"
)

var/list/chem_t4_reagents = list(
	"oil", "ash", "acetone",
	"saltpetre", "ammonia", "diethylamine"
)

/obj/item/seeds/sample
	name = "plant sample"
	icon_state = "sample-empty"
	potency = -1
	yield = -1
	var/sample_color = "#FFFFFF"

/obj/item/seeds/sample/New()
	..()
	if(sample_color)
		var/image/I = image(icon, icon_state = "sample-filling")
		I.color = sample_color
		add_overlay(I)

/obj/item/seeds/sample/get_analyzer_text()
	return " The DNA of this sample is damaged beyond recovery, it can't support life on its own.\n*---------*"

/obj/item/seeds/sample/alienweed
	name = "alien weed sample"
	icon_state = "alienweed"
	sample_color = null