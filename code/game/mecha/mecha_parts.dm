/////////////////////////
////// Mecha Parts //////
/////////////////////////

/obj/item/mecha_parts
	name = "mecha part"
	icon = 'icons/mecha/mech_construct.dmi'
	icon_state = "blank"
	w_class = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "programming=2;materials=2"
	var/construction_time = 100
	var/list/construction_cost = list("metal"=20000,"glass"=5000)


/obj/item/mecha_parts/chassis
	name="Mecha Chassis"
	icon_state = "backbone"
	var/datum/construction/construct
	construction_cost = list("metal"=20000)
	flags = FPRINT | CONDUCT

	attackby(obj/item/W as obj, mob/user as mob)
		if(!construct || !construct.action(W, user))
			..()
		return

	attack_hand()
		return

/////////// Ripley

/obj/item/mecha_parts/chassis/ripley
	name = "\improper Ripley chassis"

	New()
		..()
		construct = new /datum/construction/mecha/ripley_chassis(src)

/obj/item/mecha_parts/part/ripley_torso
	name="\improper Ripley torso"
	desc="A torso part of Ripley APLU. Contains power unit, processing core and life support systems."
	icon_state = "ripley_harness"
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"
	construction_time = 200
	construction_cost = list("metal"=40000,"glass"=15000)

/obj/item/mecha_parts/part/ripley_left_arm
	name="\improper Ripley left arm"
	desc="A Ripley APLU left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_l_arm"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 150
	construction_cost = list("metal"=25000)

/obj/item/mecha_parts/part/ripley_right_arm
	name="\improper Ripley right arm"
	desc="A Ripley APLU right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_r_arm"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 150
	construction_cost = list("metal"=25000)

/obj/item/mecha_parts/part/ripley_left_leg
	name="\improper Ripley left leg"
	desc="A Ripley APLU left leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_l_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 150
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/ripley_right_leg
	name="\improper Ripley right leg"
	desc="A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 150
	construction_cost = list("metal"=30000)

///////// Gygax

/obj/item/mecha_parts/chassis/gygax
	name = "\improper Gygax chassis"
	construction_cost = list("metal"=25000)

	New()
		..()
		construct = new /datum/construction/mecha/gygax_chassis(src)

/obj/item/mecha_parts/part/gygax_torso
	name="\improper Gygax torso"
	desc="A torso part of Gygax. Contains power unit, processing core and life support systems. Has an additional equipment slot."
	icon_state = "gygax_harness"
	origin_tech = "programming=2;materials=2;biotech=3;engineering=3"
	construction_time = 300
	construction_cost = list("metal"=50000,"glass"=20000)

/obj/item/mecha_parts/part/gygax_head
	name="\improper Gygax head"
	desc="A Gygax head. Houses advanced surveilance and targeting sensors."
	icon_state = "gygax_head"
	origin_tech = "programming=2;materials=2;magnets=3;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=20000,"glass"=10000)

/obj/item/mecha_parts/part/gygax_left_arm
	name="\improper Gygax left arm"
	desc="A Gygax left arm. Data and power sockets are compatible with most exosuit tools and weapons."
	icon_state = "gygax_l_arm"
	origin_tech = "programming=2;materials=2;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/gygax_right_arm
	name="\improper Gygax right arm"
	desc="A Gygax right arm. Data and power sockets are compatible with most exosuit tools and weapons."
	icon_state = "gygax_r_arm"
	origin_tech = "programming=2;materials=2;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/gygax_left_leg
	name="\improper Gygax left leg"
	icon_state = "gygax_l_leg"
	origin_tech = "programming=2;materials=2;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=35000)

/obj/item/mecha_parts/part/gygax_right_leg
	name="\improper Gygax right leg"
	icon_state = "gygax_r_leg"
	origin_tech = "programming=2;materials=2;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=35000)

/obj/item/mecha_parts/part/gygax_armour
	gender = PLURAL
	name="\improper Gygax armour plates"
	icon_state = "gygax_armour"
	origin_tech = "materials=6;combat=4;engineering=5"
	construction_time = 600
	construction_cost = list("metal"=50000,"diamond"=10000)


//////////// Durand

/obj/item/mecha_parts/chassis/durand
	name = "\improper Durand chassis"
	construction_cost = list("metal"=25000)

	New()
		..()
		construct = new /datum/construction/mecha/durand_chassis(src)

/obj/item/mecha_parts/part/durand_torso
	name="\improper Durand torso"
	icon_state = "durand_harness"
	origin_tech = "programming=2;materials=3;biotech=3;engineering=3"
	construction_time = 300
	construction_cost = list("metal"=55000,"glass"=20000,"silver"=10000)

/obj/item/mecha_parts/part/durand_head
	name="\improper Durand head"
	icon_state = "durand_head"
	origin_tech = "programming=2;materials=3;magnets=3;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=25000,"glass"=10000,"silver"=3000)

/obj/item/mecha_parts/part/durand_left_arm
	name="\improper Durand left arm"
	icon_state = "durand_l_arm"
	origin_tech = "programming=2;materials=3;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=35000,"silver"=3000)

/obj/item/mecha_parts/part/durand_right_arm
	name="\improper Durand right arm"
	icon_state = "durand_r_arm"
	origin_tech = "programming=2;materials=3;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=35000,"silver"=3000)

/obj/item/mecha_parts/part/durand_left_leg
	name="\improper Durand left leg"
	icon_state = "durand_l_leg"
	origin_tech = "programming=2;materials=3;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=40000,"silver"=3000)

/obj/item/mecha_parts/part/durand_right_leg
	name="\improper Durand right leg"
	icon_state = "durand_r_leg"
	origin_tech = "programming=2;materials=3;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=40000,"silver"=3000)

/obj/item/mecha_parts/part/durand_armour
	gender = PLURAL
	name="\improper Durand armour plates"
	icon_state = "durand_armour"
	origin_tech = "materials=5;combat=4;engineering=5"
	construction_time = 600
	construction_cost = list("metal"=50000,"uranium"=10000)



////////// Firefighter

/obj/item/mecha_parts/chassis/firefighter
	name = "Firefighter chassis"

	New()
		..()
		construct = new /datum/construction/mecha/firefighter_chassis(src)
/*
/obj/item/mecha_parts/part/firefighter_torso
	name="Ripley-on-Fire Torso"
	icon_state = "ripley_harness"

/obj/item/mecha_parts/part/firefighter_left_arm
	name="Ripley-on-Fire Left Arm"
	icon_state = "ripley_l_arm"

/obj/item/mecha_parts/part/firefighter_right_arm
	name="Ripley-on-Fire Right Arm"
	icon_state = "ripley_r_arm"

/obj/item/mecha_parts/part/firefighter_left_leg
	name="Ripley-on-Fire Left Leg"
	icon_state = "ripley_l_leg"

/obj/item/mecha_parts/part/firefighter_right_leg
	name="Ripley-on-Fire Right Leg"
	icon_state = "ripley_r_leg"
*/

////////// HONK

/obj/item/mecha_parts/chassis/honker
	name = "\improper H.O.N.K chassis"

	New()
		..()
		construct = new /datum/construction/mecha/honker_chassis(src)

/obj/item/mecha_parts/part/honker_torso
	name="\improper H.O.N.K torso"
	icon_state = "honker_harness"
	construction_time = 300
	construction_cost = list("metal"=35000,"glass"=10000,"bananium"=10000)

/obj/item/mecha_parts/part/honker_head
	name="\improper H.O.N.K head"
	icon_state = "honker_head"
	construction_time = 200
	construction_cost = list("metal"=15000,"glass"=5000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_left_arm
	name="\improper H.O.N.K left arm"
	icon_state = "honker_l_arm"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_right_arm
	name="\improper H.O.N.K right arm"
	icon_state = "honker_r_arm"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_left_leg
	name="\improper H.O.N.K left leg"
	icon_state = "honker_l_leg"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_right_leg
	name="\improper H.O.N.K right leg"
	icon_state = "honker_r_leg"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)


////////// Phazon

/obj/item/mecha_parts/chassis/phazon
	name = "\improper Phazon chassis"
	origin_tech = "materials=7"

	New()
		..()
		construct = new /datum/construction/mecha/phazon_chassis(src)

/obj/item/mecha_parts/part/phazon_torso
	name="\improper Phazon torso"
	icon_state = "phazon_harness"
	construction_time = 300
	construction_cost = list("metal"=35000,"glass"=10000,"plasma"=20000)
	origin_tech = "programming=5;materials=7;bluespace=6;powerstorage=6"

/obj/item/mecha_parts/part/phazon_head
	name="\improper Phazon head"
	icon_state = "phazon_head"
	construction_time = 200
	construction_cost = list("metal"=15000,"glass"=5000,"plasma"=10000)
	origin_tech = "programming=4;materials=5;magnets=6"

/obj/item/mecha_parts/part/phazon_left_arm
	name="\improper Phazon left arm"
	icon_state = "phazon_l_arm"
	construction_time = 200
	construction_cost = list("metal"=20000,"plasma"=10000)
	origin_tech = "materials=5;bluespace=2;magnets=2"

/obj/item/mecha_parts/part/phazon_right_arm
	name="\improper Phazon right arm"
	icon_state = "phazon_r_arm"
	construction_time = 200
	construction_cost = list("metal"=20000,"plasma"=10000)
	origin_tech = "materials=5;bluespace=2;magnets=2"

/obj/item/mecha_parts/part/phazon_left_leg
	name="\improper Phazon left leg"
	icon_state = "phazon_l_leg"
	construction_time = 200
	construction_cost = list("metal"=20000,"plasma"=10000)
	origin_tech = "materials=5;bluespace=3;magnets=3"

/obj/item/mecha_parts/part/phazon_right_leg
	name="\improper Phazon right leg"
	icon_state = "phazon_r_leg"
	construction_time = 200
	construction_cost = list("metal"=20000,"plasma"=10000)
	origin_tech = "materials=5;bluespace=3;magnets=3"

///////// Odysseus


/obj/item/mecha_parts/chassis/odysseus
	name = "\improper Odysseus chassis"

	New()
		..()
		construct = new /datum/construction/mecha/odysseus_chassis(src)

/obj/item/mecha_parts/part/odysseus_head
	name="\improper Odysseus head"
	icon_state = "odysseus_head"
	construction_time = 100
	construction_cost = list("metal"=2000,"glass"=10000)
	origin_tech = "programming=3;materials=2"

/obj/item/mecha_parts/part/odysseus_torso
	name="\improper Odysseus torso"
	desc="A torso part of Odysseus. Contains power unit, processing core and life support systems."
	icon_state = "odysseus_torso"
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"
	construction_time = 180
	construction_cost = list("metal"=25000)

/obj/item/mecha_parts/part/odysseus_left_arm
	name="\improper Odysseus left arm"
	desc="An Odysseus left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "odysseus_l_arm"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 120
	construction_cost = list("metal"=10000)

/obj/item/mecha_parts/part/odysseus_right_arm
	name="\improper Odysseus right arm"
	desc="An Odysseus right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "odysseus_r_arm"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 120
	construction_cost = list("metal"=10000)

/obj/item/mecha_parts/part/odysseus_left_leg
	name="\improper Odysseus left leg"
	desc="An Odysseus left leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "odysseus_l_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 130
	construction_cost = list("metal"=15000)

/obj/item/mecha_parts/part/odysseus_right_leg
	name="\improper Odysseus right leg"
	desc="A Odysseus right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "odysseus_r_leg"
	origin_tech = "programming=2;materials=2;engineering=2"
	construction_time = 130
	construction_cost = list("metal"=15000)

/*/obj/item/mecha_parts/part/odysseus_armour
	name="Odysseus Carapace"
	icon_state = "odysseus_armour"
	origin_tech = "materials=3;engineering=3"
	construction_time = 200
	construction_cost = list("metal"=15000)*/


///////// Circuitboards

/obj/item/weapon/circuitboard/mecha
	name = "exosuit circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	board_type = "other"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15

	ripley
		origin_tech = "programming=3"

	ripley/peripherals
		name = "circuit board (Ripley Peripherals Control module)"
		icon_state = "mcontroller"

	ripley/main
		name = "circuit board (Ripley Central Control module)"
		icon_state = "mainboard"

	gygax
		origin_tech = "programming=4"

	gygax/peripherals
		name = "circuit board (Gygax Peripherals Control module)"
		icon_state = "mcontroller"

	gygax/targeting
		name = "circuit board (Gygax Weapon Control and Targeting module)"
		icon_state = "mcontroller"
		origin_tech = "programming=4;combat=4"

	gygax/main
		name = "circuit board (Gygax Central Control module)"
		icon_state = "mainboard"

	durand
		origin_tech = "programming=4"

	durand/peripherals
		name = "circuit board (Durand Peripherals Control module)"
		icon_state = "mcontroller"

	durand/targeting
		name = "circuit board (Durand Weapon Control and Targeting module)"
		icon_state = "mcontroller"
		origin_tech = "programming=4;combat=4"

	durand/main
		name = "circuit board (Durand Central Control module)"
		icon_state = "mainboard"

	honker
		origin_tech = "programming=4"

	honker/peripherals
		name = "circuit board (H.O.N.K Peripherals Control module)"
		icon_state = "mcontroller"

	honker/targeting
		name = "circuit board (H.O.N.K Weapon Control and Targeting module)"
		icon_state = "mcontroller"

	honker/main
		name = "circuit board (H.O.N.K Central Control module)"
		icon_state = "mainboard"

	odysseus
		origin_tech = "programming=3"

	odysseus/peripherals
		name = "circuit board (Odysseus Peripherals Control module)"
		icon_state = "mcontroller"

	odysseus/main
		name = "circuit board (Odysseus Central Control module)"
		icon_state = "mainboard"


