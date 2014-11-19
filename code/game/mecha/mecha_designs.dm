//Contains the designs for, in this order:
//Ripley parts
//Odysseus parts
//Gygax parts
//Durand parts
//Honker parts
//Phazon parts

#define MECHFAB		16 //from designs.dm

/datum/design/ripley/chassis
	name = "Exosuit Structure (Ripley chassis)"
	desc = "Used to build a Ripley chassis."
	id = "ripley_chassis"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ripley
	category = "Ripley"
	materials = list("$iron"=20000)

/datum/design/ripley/torso
	name = "Exosuit Structure (Ripley torso)"
	desc = "Used to build a Ripley torso."
	id = "ripley_torso"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_torso
	category = "Ripley"
	materials = list("$iron"=40000,"$glass"=15000)

/datum/design/ripley/l_arm
	name = "Exosuit Structure (Ripley left arm)"
	desc = "Used to build a Ripley left arm."
	id = "ripley_larm"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	category = "Ripley"
	materials = list("$iron"=25000)

/datum/design/ripley/r_arm
	name = "Exosuit Structure (Ripley right arm)"
	desc = "Used to build a Ripley right arm."
	id = "ripley_rarm"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	category = "Ripley"
	materials = list("$iron"=25000)

/datum/design/ripley/l_leg
	name = "Exosuit Structure (Ripley left leg)"
	desc = "Used to build a Ripley left leg."
	id = "ripley_lleg"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	category = "Ripley"
	materials = list("$iron"=30000)

/datum/design/ripley/r_leg
	name = "Exosuit Structure (Ripley right leg)"
	desc = "Used to build a Ripley right leg."
	id = "ripley_rleg"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	category = "Ripley"
	materials = list("$iron"=30000)

////////////////
////ODYSSEUS////
////////////////

/datum/design/odysseus/chassis
	name = "Exosuit Structure (Odysseus chassis)"
	desc = "Used to build a Odysseus chassis."
	id = "odysseus_chassis"
	req_tech = list("biotech" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/odysseus
	category = "Odysseus"
	materials = list("$iron"=20000)

/datum/design/odysseus/torso
	name = "Exosuit Structure (Odysseus torso)"
	desc = "Used to build a Odysseus torso."
	id = "odysseus_torso"
	req_tech = list("biotech" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	category = "Odysseus"
	materials = list("$iron"=25000)

/datum/design/odysseus/l_arm
	name = "Exosuit Structure (Odysseus left arm)"
	desc = "Used to build a Odysseus left arm."
	id = "odysseus_larm"
	req_tech = list("biotech" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	category = "Odysseus"
	materials = list("$iron"=10000)

/datum/design/odysseus/r_arm
	name = "Exosuit Structure (Odysseus right arm)"
	desc = "Used to build a Odysseus right arm."
	id = "odysseus_rarm"
	req_tech = list("biotech" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	category = "Odysseus"
	materials = list("$iron"=10000)

/datum/design/odysseus/l_leg
	name = "Exosuit Structure (Odysseus left leg)"
	desc = "Used to build a Odysseus left leg."
	id = "odysseus_lleg"
	req_tech = list("biotech" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	category = "Odysseus"
	materials = list("$iron"=15000)

/datum/design/odysseus/r_leg
	name = "Exosuit Structure (Odysseus right leg)"
	desc = "Used to build a Odysseus right leg."
	id = "odysseus_rleg"
	req_tech = list("biotech" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	category = "Odysseus"
	materials = list("$iron"=15000)

/datum/design/odysseus/head
	name = "Exosuit Structure (Odysseus head)"
	desc = "Used to build a Odysseus head."
	id = "odysseus_head"
	req_tech = list("biotech" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_head
	category = "Odysseus"
	materials = list("$iron"=2000,"$glass"=10000)

////////////////
/////GYGAX//////
////////////////
/datum/design/gygax/chassis
	name = "Exosuit Structure (Gygax chassis)"
	desc = "Used to build a Gygax chassis."
	id = "gygax_chassis"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/gygax
	category = "Gygax"
	materials = list("$iron"=25000)

/datum/design/gygax/torso
	name = "Exosuit Structure (Gygax torso)"
	desc = "Used to build a Gygax torso."
	id = "gygax_torso"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_torso
	category = "Gygax"
	materials = list("$iron"=50000,"$glass"=20000)

/datum/design/gygax/l_arm
	name = "Exosuit Structure (Gygax left arm)"
	desc = "Used to build a Gygax left arm."
	id = "gygax_larm"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	category = "Gygax"
	materials = list("$iron"=30000)

/datum/design/gygax/r_arm
	name = "Exosuit Structure (Gygax right arm)"
	desc = "Used to build a Gygax right arm."
	id = "gygax_rarm"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	category = "Gygax"
	materials = list("$iron"=30000)

/datum/design/gygax/l_leg
	name = "Exosuit Structure (Gygax left leg)"
	desc = "Used to build a Gygax left leg."
	id = "gygax_lleg"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	category = "Gygax"
	materials = list("$iron"=35000)

/datum/design/gygax/r_leg
	name = "Exosuit Structure (Gygax right leg)"
	desc = "Used to build a Gygax right leg."
	id = "gygax_rleg"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	category = "Gygax"
	materials = list("$iron"=35000)

/datum/design/gygax/head
	name = "Exosuit Structure (Gygax head)"
	desc = "Used to build a Gygax head."
	id = "gygax_head"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_head
	category = "Gygax"
	materials = list("$iron"=20000,"$glass"=10000)

/datum/design/gygax/armor
	name = "Exosuit Structure (Gygax plates)"
	desc = "Used to build Gygax armor plates."
	id = "gygax_armor"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_armour
	category = "Gygax"
	materials = list("$iron"=50000,"$diamond"=10000)

///////////////
////DURAND/////
///////////////

/datum/design/durand/chassis
	name = "Exosuit Structure (Durand chassis)"
	desc = "Used to build a Durand chassis."
	id = "durand_chassis"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/durand
	category = "Durand"
	materials = list("$iron"=25000)

/datum/design/durand/torso
	name = "Exosuit Structure (Durand torso)"
	desc = "Used to build a Durand torso."
	id = "durand_torso"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_torso
	category = "Durand"
	materials = list("$iron"=55000,"$glass"=20000,"$silver"=10000)

/datum/design/durand/l_arm
	name = "Exosuit Structure (Durand left arm)"
	desc = "Used to build a Durand left arm."
	id = "durand_larm"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	category = "Durand"
	materials = list("$iron"=35000,"$silver"=3000)

/datum/design/durand/r_arm
	name = "Exosuit Structure (Durand right arm)"
	desc = "Used to build a Durand right arm."
	id = "durand_rarm"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	category = "Durand"
	materials = list("$iron"=35000,"$silver"=3000)

/datum/design/durand/l_leg
	name = "Exosuit Structure (Durand left leg)"
	desc = "Used to build a Durand left leg."
	id = "durand_lleg"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	category = "Durand"
	materials = list("$iron"=40000,"$silver"=3000)

/datum/design/durand/r_leg
	name = "Exosuit Structure (Durand right leg)"
	desc = "Used to build a Durand right leg."
	id = "durand_rleg"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	category = "Durand"
	materials = list("$iron"=40000,"$silver"=3000)

/datum/design/durand/head
	name = "Exosuit Structure (Durand head)"
	desc = "Used to build a Durand head."
	id = "durand_head"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_head
	category = "Durand"
	materials = list("$iron"=25000,"$glass"=10000,"$silver"=3000)

/datum/design/durand/armor
	name = "Exosuit Structure (Durand plates)"
	desc = "Used to build Durand armor plates."
	id = "durand_armor"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_armour
	category = "Durand"
	materials = list("$iron"=50000,"$uranium"=10000)

////////////////
////HONK////////
////////////////
/datum/design/honker/chassis
	name = "Exosuit Structure (H.O.N.K. chassis)"
	desc = "Used to build a H.O.N.K. chassis."
	id = "honker_chassis"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/honker
	category = "HONK"
	materials = list("$iron"=20000)

/datum/design/honker/torso
	name = "Exosuit Structure (H.O.N.K. torso)"
	desc = "Used to build a H.O.N.K. torso."
	id = "honker_torso"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_torso
	category = "HONK"
	materials = list("$iron"=35000,"$glass"=10000,"$clown"=10000)

/datum/design/honker/l_arm
	name = "Exosuit Structure (H.O.N.K. left arm)"
	desc = "Used to build a H.O.N.K. left arm."
	id = "honker_larm"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_left_arm
	category = "HONK"
	materials = list("$iron"=20000,"$clown"=5000)

/datum/design/honker/r_arm
	name = "Exosuit Structure (H.O.N.K. right arm)"
	desc = "Used to build a H.O.N.K. right arm."
	id = "honker_rarm"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_arm
	category = "HONK"
	materials = list("$iron"=20000,"$clown"=5000)

/datum/design/honker/l_leg
	name = "Exosuit Structure (H.O.N.K. left leg)"
	desc = "Used to build a H.O.N.K. left leg."
	id = "honker_lleg"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_left_leg
	category = "HONK"
	materials = list("$iron"=20000,"$clown"=5000)

/datum/design/honker/r_leg
	name = "Exosuit Structure (H.O.N.K. right leg)"
	desc = "Used to build a H.O.N.K. right leg."
	id = "honker_rleg"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_leg
	category = "HONK"
	materials = list("$iron"=20000,"$clown"=5000)

/datum/design/honker/head
	name = "Exosuit Structure (H.O.N.K. head)"
	desc = "Used to build a H.O.N.K. head."
	id = "honker_head"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_head
	category = "HONK"
	materials = list("$iron"=15000,"$glass"=5000,"$clown"=5000)

//////////////
/////PHAZON///
//////////////

/datum/design/phazon/chassis
	name = "Exosuit Structure (Phazon chassis)"
	desc = "Used to build a Phazon chassis."
	id = "phazon_chassis"
	req_tech = list("bluespace" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/phazon
	category = "Phazon"
	materials = list("$iron"=25000)

/datum/design/phazon/torso
	name = "Exosuit Structure (Phazon torso)"
	desc = "Used to build a Phazon torso."
	id = "phazon_torso"
	req_tech = list("bluespace" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_torso
	category = "Phazon"
	materials = list("$iron"=35000,"$glass"=10000,"$plasma"=20000, "$phazon"=5000)

/datum/design/phazon/l_arm
	name = "Exosuit Structure (Phazon left arm)"
	desc = "Used to build a Phazon left arm."
	id = "phazon_larm"
	req_tech = list("bluespace" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_arm
	category = "Phazon"
	materials = list("$iron"=20000,"$plasma"=10000, "$phazon"=2500)

/datum/design/phazon/r_arm
	name = "Exosuit Structure (Phazon right arm)"
	desc = "Used to build a Phazon right arm."
	id = "phazon_rarm"
	req_tech = list("bluespace" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_arm
	category = "Phazon"
	materials = list("$iron"=20000,"$plasma"=10000, "$phazon"=2500)

/datum/design/phazon/l_leg
	name = "Exosuit Structure (Phazon left leg)"
	desc = "Used to build a Phazon left leg."
	id = "phazon_lleg"
	req_tech = list("bluespace" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_leg
	category = "Phazon"
	materials = list("$iron"=20000,"$plasma"=10000, "$phazon"=2500)

/datum/design/phazon/r_leg
	name = "Exosuit Structure (Phazon right leg)"
	desc = "Used to build a Phazon right leg."
	id = "phazon_rleg"
	req_tech = list("bluespace" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_leg
	category = "Phazon"
	materials = list("$iron"=20000,"$plasma"=10000, "$phazon"=2500)

/datum/design/phazon/head
	name = "Exosuit Structure (Phazon head)"
	desc = "Used to build a Phazon head."
	id = "phazon_head"
	req_tech = list("bluespace" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_head
	category = "Phazon"
	materials = list("$iron"=15000,"$glass"=5000,"$plasma"=10000, "$phazon"=2500)