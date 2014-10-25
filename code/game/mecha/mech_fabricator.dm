/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////

#define MECH_SCREEN_MAIN		1
#define	MECH_SCREEN_QUEUE		2

#define	MECH_SCREEN_ROBOT		3
#define	MECH_SCREEN_RIPLEY		4
#define	MECH_SCREEN_ODYSSEUS	5
#define	MECH_SCREEN_GYGAX		6
#define	MECH_SCREEN_DURAND		7
#define	MECH_SCREEN_HONK		8
#define	MECH_SCREEN_PHAZON		9

#define	MECH_SCREEN_EXOSUIT		10
#define	MECH_SCREEN_UPGRADE		11
#define	MECH_SCREEN_SPACE_POD	12
#define	MECH_SCREEN_MISC		13



/obj/machinery/r_n_d/fabricator/mech
	name = "Exosuit Fabricator"
	desc = "Nothing is being built."
	req_one_access = list(access_robotics)
	time_coeff = 1.5 //can be upgraded with research
	resource_coeff = 1.5 //can be upgraded with research
	has_mat_overlays = 1

	nano_file = "exofab.tmpl"

	locked_parts = list(
		/obj/item/mecha_parts/mecha_equipment/weapon,
		/obj/item/mecha_parts/mecha_equipmet/tool/jail
	)

	unlocked_parts = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar,
		/obj/item/mecha_parts/mecha_equipment/weapon/honker
	)

	screen = MECH_SCREEN_MAIN
	part_sets = list( //set names must be unique
	"Robot"=list(
						/obj/item/robot_parts/robot_suit,
						/obj/item/robot_parts/chest,
						/obj/item/robot_parts/head,
						/obj/item/robot_parts/l_arm,
						/obj/item/robot_parts/r_arm,
						/obj/item/robot_parts/l_leg,
						/obj/item/robot_parts/r_leg,
						/obj/item/robot_parts/robot_component/binary_communication_device,
						/obj/item/robot_parts/robot_component/radio,
						/obj/item/robot_parts/robot_component/actuator,
						/obj/item/robot_parts/robot_component/diagnosis_unit,
						/obj/item/robot_parts/robot_component/camera,
						/obj/item/robot_parts/robot_component/armour
					),
	"Ripley"=list(
						/obj/item/mecha_parts/chassis/ripley,
						/obj/item/mecha_parts/part/ripley_torso,
						/obj/item/mecha_parts/part/ripley_left_arm,
						/obj/item/mecha_parts/part/ripley_right_arm,
						/obj/item/mecha_parts/part/ripley_left_leg,
						/obj/item/mecha_parts/part/ripley_right_leg
					),
	"Odysseus"=list(
						/obj/item/mecha_parts/chassis/odysseus,
						/obj/item/mecha_parts/part/odysseus_torso,
						/obj/item/mecha_parts/part/odysseus_head,
						/obj/item/mecha_parts/part/odysseus_left_arm,
						/obj/item/mecha_parts/part/odysseus_right_arm,
						/obj/item/mecha_parts/part/odysseus_left_leg,
						/obj/item/mecha_parts/part/odysseus_right_leg
					),

	"Gygax"=list(
						/obj/item/mecha_parts/chassis/gygax,
						/obj/item/mecha_parts/part/gygax_torso,
						/obj/item/mecha_parts/part/gygax_head,
						/obj/item/mecha_parts/part/gygax_left_arm,
						/obj/item/mecha_parts/part/gygax_right_arm,
						/obj/item/mecha_parts/part/gygax_left_leg,
						/obj/item/mecha_parts/part/gygax_right_leg,
						/obj/item/mecha_parts/part/gygax_armour
					),
	"Durand"=list(
						/obj/item/mecha_parts/chassis/durand,
						/obj/item/mecha_parts/part/durand_torso,
						/obj/item/mecha_parts/part/durand_head,
						/obj/item/mecha_parts/part/durand_left_arm,
						/obj/item/mecha_parts/part/durand_right_arm,
						/obj/item/mecha_parts/part/durand_left_leg,
						/obj/item/mecha_parts/part/durand_right_leg,
						/obj/item/mecha_parts/part/durand_armour
					),
	"Honk"=list(
						/obj/item/mecha_parts/chassis/honker,
						/obj/item/mecha_parts/part/honker_torso,
						/obj/item/mecha_parts/part/honker_head,
						/obj/item/mecha_parts/part/honker_left_arm,
						/obj/item/mecha_parts/part/honker_right_arm,
						/obj/item/mecha_parts/part/honker_left_leg,
						/obj/item/mecha_parts/part/honker_right_leg
						),
	"Phazon"=list(
						/obj/item/mecha_parts/chassis/phazon,
						/obj/item/mecha_parts/part/phazon_torso,
						/obj/item/mecha_parts/part/phazon_head,
						/obj/item/mecha_parts/part/phazon_left_arm,
						/obj/item/mecha_parts/part/phazon_right_arm,
						/obj/item/mecha_parts/part/phazon_left_leg,
						/obj/item/mecha_parts/part/phazon_right_leg
						),
	"Exosuit_Equipment"=list(
						/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,
						/obj/item/mecha_parts/mecha_equipment/tool/drill,
						/obj/item/mecha_parts/mecha_equipment/tool/extinguisher,
						/obj/item/mecha_parts/mecha_equipment/tool/cable_layer,
						/obj/item/mecha_parts/mecha_equipment/tool/sleeper,
						/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun,
						/obj/item/mecha_parts/chassis/firefighter,
						///obj/item/mecha_parts/mecha_equipment/repair_droid,
						/obj/item/mecha_parts/mecha_equipment/generator,
						///obj/item/mecha_parts/mecha_equipment/jetpack, //TODO MECHA JETPACK SPRITE MISSING
						/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser,
						/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
						/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar,
						/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar,
						/obj/item/mecha_parts/mecha_equipment/weapon/honker,
						/obj/item/mecha_parts/part/phazon_phase_array
						),

	"Robotic_Upgrade_Modules" = list(
						/obj/item/borg/upgrade/reset,
						/obj/item/borg/upgrade/rename,
						/obj/item/borg/upgrade/restart,
						/obj/item/borg/upgrade/vtec,
						/obj/item/borg/upgrade/tasercooler,
						/obj/item/borg/upgrade/jetpack
						),

	"Space_Pod" = list(
						/obj/item/pod_parts/core
						),
	"Misc"=list(
						/obj/item/mecha_parts/mecha_tracking,
						/obj/item/mecha_parts/janicart_upgrade
						)
	)




/obj/machinery/r_n_d/fabricator/mech/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/mechfab,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()