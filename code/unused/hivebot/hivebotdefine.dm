/mob/living/silicon/hivebot
	name = "Robot"
	icon = 'hivebot.dmi'
	icon_state = "basic"
	health = 80
	var/health_max = 80
	robot_talk_understand = 2

//HUD
	var/obj/screen/cells = null
	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/obj/item/device/radio/radio = null

	var/list/req_access = list(ACCESS_ROBOTICS)
	var/energy = 4000
	var/energy_max = 4000
	var/jetpack = 0

	var/mob/living/silicon/hive_mainframe/mainframe = null
	var/dependent = 0
	var/shell = 1

/mob/living/silicon/hive_mainframe
	name = "Robot Mainframe"
	voice_name = "synthesized voice"

	icon_state = "hive_main"
	health = 200
	var/health_max = 200
	robot_talk_understand = 2

	anchored = 1
	var/online = 1
	var/mob/living/silicon/hivebot = null
	var/hivebot_name = null
	var/force_mind = 0