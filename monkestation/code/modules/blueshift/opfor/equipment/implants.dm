/datum/opposing_force_equipment/implants
	category = OPFOR_EQUIPMENT_CATEGORY_IMPLANTS

//Skillchips
/datum/opposing_force_equipment/implants/engichip
	item_type = /obj/item/skillchip/job/engineer
	description = "A skillchip that, when installed, allows the user to recognise airlock and APC wire layouts and understand their functionality at a glance. Highly valuable and sought after."

/datum/opposing_force_equipment/implants/roboticist
	item_type = /obj/item/skillchip/job/roboticist
	description = "A skillchip that, when installed, allows the user to recognise cyborg wire layouts and understand their functionality at a glance."

//Implants
/datum/opposing_force_equipment/implants/nodrop
	item_type = /obj/item/autosurgeon/syndicate/nodrop
	name = "Anti Drop Implant"
	admin_note = "Allows the user to tighten their grip, their held items unable to be dropped by any cause. Hardstuns user for a longtime if hit with EMP."
	description = "An implant that prevents you from dropping items in your hand involuntarily. Comes loaded in a syndicate autosurgeon."

/datum/opposing_force_equipment/implants/cns
	name = "CNS Rebooter Implant"
	item_type = /obj/item/autosurgeon/syndicate/anti_stun
	description = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."

/datum/opposing_force_equipment/implants/reviver
	name = "Reviver Implant"
	item_type = /obj/item/autosurgeon/syndicate/reviver
	description = "This implant will attempt to revive and heal you if you lose consciousness. For the faint of heart!"

/datum/opposing_force_equipment/implants/sad_trombone
	name = "Sad Trombone Implant"
	item_type = /obj/item/implanter/sad_trombone

/datum/opposing_force_equipment/implants/toolarm
	name = "Tool Arm Implant"
	admin_note = "Force 20 implanted combat knife on emag."
	item_type = /obj/item/autosurgeon/toolset

/datum/opposing_force_equipment/implants/surgery
	name = "Surgery Arm Implant"
	admin_note = "Force 20 implanted combat knife on emag."
	item_type = /obj/item/autosurgeon/surgery

/datum/opposing_force_equipment/implants/botany
	name = "Botany Arm Implant"
	admin_note = "Chainsaw arm on emag."
	item_type = /obj/item/autosurgeon/botany

/datum/opposing_force_equipment/implants/janitor
	name = "Janitor Arm Implant"
	item_type = /obj/item/autosurgeon/janitor

/datum/opposing_force_equipment/implants/armblade
	name = "Mantis Blade Arm Implant"
	admin_note = "Force 30 IF emagged."
	item_type = /obj/item/autosurgeon/organ/syndicate/syndie_mantis

/datum/opposing_force_equipment/implants/muscle
	name = "Muscle Arm Implant"
	item_type = /obj/item/autosurgeon/muscle

/datum/opposing_force_equipment/implants_illegal
	category = OPFOR_EQUIPMENT_CATEGORY_IMPLANTS_ILLEGAL

/datum/opposing_force_equipment/implants_illegal/stealth
	name = "Stealth Implant"
	item_type = /obj/item/implanter/stealth
	admin_note = "Allows the user to become completely invisible as long as they remain inside a cardboard box."
	description = "An implanter that grants you the ability to wield the ultimate in invisible box technology. Best used in conjunction with a tape recorder playing Snake Eater."

/datum/opposing_force_equipment/implants_illegal/radio
	name = "Syndicate Radio Implant"
	item_type = /obj/item/implanter/radio/syndicate
	description = "An implanter that grants you inherent access to the Syndicate radio channel, in addition to being able to listen to all on-station channels."

/datum/opposing_force_equipment/implants_illegal/storage
	name = "Storage Implant"
	item_type = /obj/item/implanter/storage
	admin_note = "Allows user to stow items without any sign of having a storage item."
	description = "An implanter that grants you access to a small pocket of bluespace, capable of storing a few items."

/datum/opposing_force_equipment/implants_illegal/freedom
	name = "Freedom Implant"
	item_type = /obj/item/implanter/freedom
	admin_note = "Allows the user to break handcuffs or e-snares four times, after it will run out and become useless."
	description = "An implanter that grants you the ability to break out of handcuffs a certain number of times."

/* TODO Removal pending replacement
/datum/opposing_force_equipment/implants_illegal/micro
	name = "Microbomb Implant"
	admin_note = "RRs the user."
	item_type = /obj/item/implanter/explosive
	description = "An implanter that will make you explode on death in a decent-sized explosion."
*/

/datum/opposing_force_equipment/implants_illegal/emp
	name = "EMP Implant"
	item_type = /obj/item/implanter/emp
	admin_note = "Gives the user a big EMP on an action button. Has three uses after which it becomes useless."
	description = "An implanter that grants you the ability to create several EMP pulses, centered on you."

/datum/opposing_force_equipment/implants_illegal/xray
	name = "X-Ray Eyes"
	item_type = /obj/item/autosurgeon/syndicate/xray_eyes
	description = "These cybernetic eyes will give you X-ray vision. Blinking is futile."

/datum/opposing_force_equipment/implants_illegal/thermal
	name = "Thermal Eyes"
	item_type = /obj/item/autosurgeon/syndicate/thermal_eyes
	description = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."

/datum/opposing_force_equipment/implants_illegal/armlaser
	name = "Arm-mounted Laser Implant"
	item_type = /obj/item/autosurgeon/syndicate/laser_arm
	admin_note = "A basic laser gun, but no-drop."
	description = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."

/datum/opposing_force_equipment/implants_illegal/eswordarm
	name = "Energy Sword Arm Implant"
	item_type = /obj/item/autosurgeon/syndicate/esword_arm
	admin_note = "Force 30 no-drop, extremely robust."
	description = "It's an energy sword, in your arm. Pretty decent for getting past stop-searches and assassinating people. Comes loaded in a Syndicate brand autosurgeon to boot!"

/datum/opposing_force_equipment/implants_illegal/baton
	name = "Baton Arm Implant"
	item_type = /obj/item/autosurgeon/syndicate/baton

/datum/opposing_force_equipment/implants_illegal/flash
	name = "Flash Arm Implant"
	item_type = /obj/item/autosurgeon/syndicate/flash
