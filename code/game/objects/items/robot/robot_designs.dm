//contains all the robot part and component designs

#define MECHFAB		16 //from designs.dm

/datum/design/robot/chassis
	name = "Cyborg Component (Robot chassis)"
	desc = "Used to build a Robot chassis."
	id = "robot_chassis"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_suit
	category = "Robot"

/datum/design/robot/torso
	name = "Cyborg Component (Robot torso)"
	desc = "Used to build a Robot torso."
	id = "robot_torso"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/chest
	category = "Robot"

/datum/design/robot/l_arm
	name = "Cyborg Component (Robot left arm)"
	desc = "Used to build a Robot left arm."
	id = "robot_larm"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_arm
	category = "Robot"

/datum/design/robot/r_arm
	name = "Cyborg Component (Robot right arm)"
	desc = "Used to build a Robot right arm."
	id = "robot_rarm"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_arm
	category = "Robot"

/datum/design/robot/l_leg
	name = "Cyborg Component (Robot left leg)"
	desc = "Used to build a Robot left leg."
	id = "robot_lleg"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_leg
	category = "Robot"

/datum/design/robot/r_leg
	name = "Cyborg Component (Robot right leg)"
	desc = "Used to build a Robot right leg."
	id = "robot_rleg"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_leg
	category = "Robot"

/datum/design/robot/head
	name = "Cyborg Component (Robot head)"
	desc = "Used to build a Robot head."
	id = "robot_head"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/head
	category = "Robot"

/datum/design/robot/binary_commucation_device
	name = "Cyborg Component (Binary Communication Device)"
	desc = "Used to build a binary communication device."
	id = "robot_bin_comms"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/binary_communication_device

/datum/design/robot/radio
	name = "Cyborg Component (Radio)"
	desc = "Used to build a radio."
	id = "robot_radio"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/radio

/datum/design/robot/actuator
	name = "Cyborg Component (Actuator)"
	desc = "Used to build an actuator."
	id = "robot_actuator"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/actuator

/datum/design/robot/diagnosis_unit
	name = "Cyborg Component (Diagnosis Unit)"
	desc = "Used to build a diagnosis unit."
	id = "robot_diagnosis_unit"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/diagnosis_unit

/datum/design/robot/camera
	name = "Cyborg Component (Camera)"
	desc = "Used to build a diagnosis unit."
	id = "robot_camera"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/camera

/datum/design/robot/armour
	name = "Cyborg Component (Armor)"
	desc = "Used to build cyborg armor."
	id = "robot_armour"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/armour