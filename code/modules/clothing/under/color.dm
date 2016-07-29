<<<<<<< HEAD
/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"

/obj/item/clothing/under/color/random/New()
	..()
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - /obj/item/clothing/under/color/random)
	name = initial(C.name)
	icon_state = initial(C.icon_state)
	item_state = initial(C.item_state)
	item_color = initial(C.item_color)

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	burn_state = FIRE_PROOF

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	item_state = "gy_suit"
	item_color = "grey"

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."

/obj/item/clothing/under/color/grey/glorf/hit_reaction(mob/living/carbon/human/owner)
	owner.forcesay(hit_appends)
	return 0

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	item_color = "blue"

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	item_color = "green"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	icon_state = "orange"
	item_state = "o_suit"
	item_color = "orange"

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	icon_state = "pink"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	item_state = "p_suit"
	item_color = "pink"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	item_color = "red"

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	item_color = "white"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	item_color = "yellow"

/obj/item/clothing/under/color/lightblue
	name = "lightblue jumpsuit"
	icon_state = "lightblue"
	item_state = "b_suit"
	item_color = "lightblue"

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	icon_state = "aqua"
	item_state = "b_suit"
	item_color = "aqua"

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	icon_state = "purple"
	item_state = "p_suit"
	item_color = "purple"

/obj/item/clothing/under/color/lightpurple
	name = "lightpurple jumpsuit"
	icon_state = "lightpurple"
	item_state = "p_suit"
	item_color = "lightpurple"

/obj/item/clothing/under/color/lightgreen
	name = "lightgreen jumpsuit"
	icon_state = "lightgreen"
	item_state = "g_suit"
	item_color = "lightgreen"

/obj/item/clothing/under/color/lightbrown
	name = "lightbrown jumpsuit"
	icon_state = "lightbrown"
	item_state = "lb_suit"
	item_color = "lightbrown"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_state = "brown"
	item_state = "lb_suit"
	item_color = "brown"

/obj/item/clothing/under/color/yellowgreen
	name = "yellowgreen jumpsuit"
	icon_state = "yellowgreen"
	item_state = "y_suit"
	item_color = "yellowgreen"

/obj/item/clothing/under/color/darkblue
	name = "darkblue jumpsuit"
	icon_state = "darkblue"
	item_state = "b_suit"
	item_color = "darkblue"

/obj/item/clothing/under/color/lightred
	name = "lightred jumpsuit"
	icon_state = "lightred"
	item_state = "r_suit"
	item_color = "lightred"

/obj/item/clothing/under/color/darkred
	name = "darkred jumpsuit"
	icon_state = "darkred"
	item_state = "r_suit"
	item_color = "darkred"

/obj/item/clothing/under/color/maroon
	name = "maroon jumpsuit"
	icon_state = "maroon"
	item_state = "r_suit"
	item_color = "maroon"

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "A multi-colored jumpsuit!"
	icon_state = "rainbow"
	item_state = "rainbow"
	item_color = "rainbow"
	can_adjust = 0
=======
/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	_color = "black"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/color/blackf
	name = "feminine black jumpsuit"
	desc = "It's very smart and in a ladies-size!"
	icon_state = "black"
	item_state = "bl_suit"
	_color = "blackf"
	flags = FPRINT

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	_color = "blue"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	_color = "green"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	icon_state = "grey"
	item_state = "gy_suit"
	_color = "grey"
	flags = FPRINT  | ONESIZEFITSALL
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	icon_state = "orange"
	item_state = "o_suit"
	_color = "orange"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/color/prisoner
	name = "prison jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	item_state = "o_suit"
	_color = "prisoner"
	has_sensor = 2
	sensor_mode = 3
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	icon_state = "pink"
	item_state = "p_suit"
	_color = "pink"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	_color = "red"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	_color = "white"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	_color = "yellow"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	_color = "psyche"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/lightblue
	name = "lightblue jumpsuit"
	icon_state = "lightblue"
	_color = "lightblue"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/aqua
	name = "aqua jumpsuit"
	icon_state = "aqua"
	_color = "aqua"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/purple
	name = "purple jumpsuit"
	icon_state = "purple"
	item_state = "p_suit"
	_color = "purple"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/lightpurple
	name = "lightpurple jumpsuit"
	icon_state = "lightpurple"
	_color = "lightpurple"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/lightgreen
	name = "lightgreen jumpsuit"
	icon_state = "lightgreen"
	_color = "lightgreen"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/lightbrown
	name = "lightbrown jumpsuit"
	icon_state = "lightbrown"
	_color = "lightbrown"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/brown
	name = "brown jumpsuit"
	icon_state = "brown"
	_color = "brown"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/yellowgreen
	name = "yellowgreen jumpsuit"
	icon_state = "yellowgreen"
	_color = "yellowgreen"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/darkblue
	name = "darkblue jumpsuit"
	icon_state = "darkblue"
	_color = "darkblue"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/lightred
	name = "lightred jumpsuit"
	icon_state = "lightred"
	_color = "lightred"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/darkred
	name = "darkred jumpsuit"
	icon_state = "darkred"
	_color = "darkred"
	flags = FPRINT  | ONESIZEFITSALL

/obj/item/clothing/under/blackpants
	name = "black pants"
	icon_state = "blpants"
	_color = "blpants"
	flags = FPRINT  | ONESIZEFITSALL
	gender = PLURAL

/obj/item/clothing/under/redpants
	name = "red pants"
	icon_state = "rpants"
	_color = "rpants"
	flags = FPRINT  | ONESIZEFITSALL
	gender = PLURAL

/obj/item/clothing/under/bluepants
	name = "blue pants"
	icon_state = "bpants"
	_color = "bpants"
	flags = FPRINT  | ONESIZEFITSALL
	gender = PLURAL

/obj/item/clothing/under/greypants
	name = "grey pants"
	icon_state = "gpants"
	_color = "gpants"
	flags = FPRINT  | ONESIZEFITSALL
	gender = PLURAL
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
