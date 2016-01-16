/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////

#define MECH_SCREEN_MAIN		01

#define	MECH_SCREEN_ROBOT			11
#define MECH_SCREEN_ROBOT_PARTS		12
#define	MECH_SCREEN_ROBOT_UPGRADES	13

#define	MECH_SCREEN_EXOSUIT_TOOLS	21
#define	MECH_SCREEN_EXOSUIT_MODULES	22
#define	MECH_SCREEN_EXOSUIT_WEAPONS	23

#define	MECH_SCREEN_RIPLEY		31
#define	MECH_SCREEN_ODYSSEUS	32
#define	MECH_SCREEN_GYGAX		33
#define	MECH_SCREEN_DURAND		34
#define	MECH_SCREEN_HONK		35
#define	MECH_SCREEN_PHAZON		36

#define	MECH_SCREEN_MISC		41

#define MECH_BUILD_TIME 1

/obj/machinery/r_n_d/fabricator/mech
	name = "Exosuit Fabricator"
	desc = "A specialised fabricator for robotic and mechatronic components."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab"
	req_one_access = list(access_robotics)

	research_flags = NANOTOUCH | HASOUTPUT | HASMAT_OVER | TAKESMATIN | ACCESS_EMAG | LOCKBOXES

	nano_file = "exofab.tmpl"

	max_material_storage = 937500
	build_time = MECH_BUILD_TIME
	build_number = 16

	screen = MECH_SCREEN_MAIN

	part_sets = list(//set names must be unique
		"Robot"=list(
		),
		"Robot_Part" = list(
		),
		"Ripley"=list(
		),
		"Odysseus"=list(
		),
		"Gygax"=list(
		),
		"Durand"=list(
		),
		"HONK"=list(
		),
		"Phazon"=list(
		),
		"Exosuit_Tools"=list(
			/obj/item/mecha_parts/mecha_equipment/tool/sleeper,
			/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun,
		),
		"Exosuit_Modules"=list(
			/obj/item/mecha_parts/part/phazon_phase_array
		),
		"Exosuit_Weapons"=list(
		),
		"Robotic_Upgrade_Modules" = list(
		),
		"Misc"=list(
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