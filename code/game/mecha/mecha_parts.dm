/////////////////////////
////// Mecha Parts //////
/////////////////////////

/obj/item/mecha_parts
	name = "mecha part"
	icon = 'mech_construct.dmi'
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
	name = "Ripley Chassis"

	New()
		..()
		construct = new /datum/construction/mecha/ripley_chassis(src)

/obj/item/mecha_parts/part/ripley_torso
	name="Ripley Torso"
	icon_state = "ripley_harness"
	origin_tech = "programming=2;materials=3;biotech=2"
	construction_time = 300
	construction_cost = list("metal"=40000,"glass"=15000)

/obj/item/mecha_parts/part/ripley_left_arm
	name="Ripley Left Arm"
	icon_state = "ripley_l_arm"
	origin_tech = "programming=2;materials=3"
	construction_time = 200
	construction_cost = list("metal"=25000)

/obj/item/mecha_parts/part/ripley_right_arm
	name="Ripley Right Arm"
	icon_state = "ripley_r_arm"
	origin_tech = "programming=2;materials=3"
	construction_time = 200
	construction_cost = list("metal"=25000)

/obj/item/mecha_parts/part/ripley_left_leg
	name="Ripley Left Leg"
	icon_state = "ripley_l_leg"
	origin_tech = "programming=2;materials=3"
	construction_time = 200
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/ripley_right_leg
	name="Ripley Right Leg"
	icon_state = "ripley_r_leg"
	origin_tech = "programming=2;materials=3"
	construction_time = 200
	construction_cost = list("metal"=30000)

///////// Gygax

/obj/item/mecha_parts/chassis/gygax
	name = "Gygax Chassis"
	construction_cost = list("metal"=25000)

	New()
		..()
		construct = new /datum/construction/mecha/gygax_chassis(src)

/obj/item/mecha_parts/part/gygax_torso
	name="Gygax Torso"
	icon_state = "gygax_harness"
	origin_tech = "programming=2;materials=5;biotech=3"
	construction_time = 300
	construction_cost = list("metal"=50000,"glass"=20000)

/obj/item/mecha_parts/part/gygax_head
	name="Gygax Head"
	icon_state = "gygax_head"
	origin_tech = "programming=2;materials=5;magnets=3"
	construction_time = 200
	construction_cost = list("metal"=20000,"glass"=10000)

/obj/item/mecha_parts/part/gygax_left_arm
	name="Gygax Left Arm"
	icon_state = "gygax_l_arm"
	origin_tech = "programming=2;materials=5"
	construction_time = 200
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/gygax_right_arm
	name="Gygax Right Arm"
	icon_state = "gygax_r_arm"
	origin_tech = "programming=2;materials=5"
	construction_time = 200
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/gygax_left_leg
	name="Gygax Left Leg"
	icon_state = "gygax_l_leg"
	origin_tech = "programming=2;materials=5"
	construction_time = 200
	construction_cost = list("metal"=35000)

/obj/item/mecha_parts/part/gygax_right_leg
	name="Gygax Right Leg"
	icon_state = "gygax_r_leg"
	origin_tech = "programming=2;materials=5"
	construction_time = 200
	construction_cost = list("metal"=35000)

/obj/item/mecha_parts/part/gygax_armour
	name="Gygax Armour Plates"
	icon_state = "gygax_armour"
	origin_tech = "materials=5;combat=4"
	construction_time = 600
	construction_cost = list("metal"=50000,"diamond"=10000)


//////////// Durand

/obj/item/mecha_parts/chassis/durand
	name = "Durand Chassis"
	construction_cost = list("metal"=25000)

	New()
		..()
		construct = new /datum/construction/mecha/durand_chassis(src)

/obj/item/mecha_parts/part/durand_torso
	name="Durand Torso"
	icon_state = "gygax_harness"
	origin_tech = "programming=2;materials=5;biotech=3"
	construction_time = 300
	construction_cost = list("metal"=55000,"glass"=20000,"silver"=10000)

/obj/item/mecha_parts/part/durand_head
	name="Durand Head"
	icon_state = "gygax_head"
	origin_tech = "programming=2;materials=5;magnets=3"
	construction_time = 200
	construction_cost = list("metal"=25000,"glass"=10000,"silver"=5000)

/obj/item/mecha_parts/part/durand_left_arm
	name="Durand Left Arm"
	icon_state = "gygax_l_arm"
	origin_tech = "programming=2;materials=5"
	construction_time = 200
	construction_cost = list("metal"=35000,"silver"=5000)

/obj/item/mecha_parts/part/durand_right_arm
	name="Durand Right Arm"
	icon_state = "gygax_r_arm"
	origin_tech = "programming=2;materials=5"
	construction_time = 200
	construction_cost = list("metal"=35000,"silver"=5000)

/obj/item/mecha_parts/part/durand_left_leg
	name="Durand Left Leg"
	icon_state = "gygax_l_leg"
	origin_tech = "programming=2;materials=5"
	construction_time = 200
	construction_cost = list("metal"=40000,"silver"=5000)

/obj/item/mecha_parts/part/durand_right_leg
	name="Durand Right Leg"
	icon_state = "gygax_r_leg"
	origin_tech = "programming=2;materials=5"
	construction_time = 200
	construction_cost = list("metal"=40000,"silver"=5000)

/obj/item/mecha_parts/part/durand_armour
	name="Durand Armour Plates"
	icon_state = "gygax_armour"
	origin_tech = "materials=5;combat=4"
	construction_time = 600
	construction_cost = list("metal"=50000,"uranium"=10000)



////////// Firefighter

/obj/item/mecha_parts/chassis/firefighter
	name = "Ripley-on-Fire Chassis"

	New()
		..()
		construct = new /datum/construction/mecha/firefighter_chassis(src)

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


////////// HONK

/obj/item/mecha_parts/chassis/honker
	name = "H.O.N.K Chassis"

	New()
		..()
		construct = new /datum/construction/mecha/honker_chassis(src)

/obj/item/mecha_parts/part/honker_torso
	name="H.O.N.K Torso"
	icon_state = "honker_harness"
	construction_time = 300
	construction_cost = list("metal"=35000,"glass"=10000,"bananium"=10000)

/obj/item/mecha_parts/part/honker_head
	name="H.O.N.K Head"
	icon_state = "honker_head"
	construction_time = 200
	construction_cost = list("metal"=15000,"glass"=5000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_left_arm
	name="H.O.N.K Left Arm"
	icon_state = "honker_l_arm"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_right_arm
	name="H.O.N.K Right Arm"
	icon_state = "honker_r_arm"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_left_leg
	name="H.O.N.K Left Leg"
	icon_state = "honker_l_leg"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_right_leg
	name="H.O.N.K Right Leg"
	icon_state = "honker_r_leg"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)


/obj/item/mecha_parts/circuitboard
	name = "Exosuit Circuit board"
	icon = 'module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15

	ripley
		origin_tech = "programming=3"

	ripley/peripherals
		name = "Circuit board (Ripley Peripherals Control module)"
		icon_state = "mcontroller"

	ripley/main
		name = "Circuit board (Ripley Central Control module)"
		icon_state = "mainboard"

	gygax
		origin_tech = "programming=4"

	gygax/peripherals
		name = "Circuit board (Gygax Peripherals Control module)"
		icon_state = "mcontroller"

	gygax/targeting
		name = "Circuit board (Gygax Weapon Control and Targeting module)"
		icon_state = "mcontroller"
		origin_tech = "programming=4;combat=4"

	gygax/main
		name = "Circuit board (Gygax Central Control module)"
		icon_state = "mainboard"

	durand
		origin_tech = "programming=4"

	durand/peripherals
		name = "Circuit board (Durand Peripherals Control module)"
		icon_state = "mcontroller"

	durand/targeting
		name = "Circuit board (Durand Weapon Control and Targeting module)"
		icon_state = "mcontroller"
		origin_tech = "programming=4;combat=4"

	durand/main
		name = "Circuit board (Durand Central Control module)"
		icon_state = "mainboard"

	firefighter/peripherals
		name = "Circuit board (Ripley-on-Fire Peripherals Control module)"
		icon_state = "mcontroller"

	honker
		origin_tech = "programming=4"

	honker/peripherals
		name = "Circuit board (H.O.N.K Peripherals Control module)"
		icon_state = "mcontroller"

	honker/targeting
		name = "Circuit board (H.O.N.K Weapon Control and Targeting module)"
		icon_state = "mcontroller"

	honker/main
		name = "Circuit board (H.O.N.K Central Control module)"
		icon_state = "mainboard"


