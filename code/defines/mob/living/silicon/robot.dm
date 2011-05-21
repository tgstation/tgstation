/mob/living/silicon/robot
	name = "Robot"
	voice_name = "synthesized voice"
	icon = 'robots.dmi'//
	icon_state = "robot"
	health = 300

#define BORGMESON 1
#define BORGTHERM 2
#define BORGXRAY  4

	var/sight_mode = 0

//Hud stuff

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
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null

	var/obj/item/device/mmi/mmi = null

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/list/req_access = list(access_robotics)
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list())
	var/viewalerts = 0
	var/modtype = null
	var/lower_mod = 0
	var/jetpack = 0
	var/datum/effects/system/ion_trail_follow/ion_trail = null
	var/datum/effects/system/spark_spread/spark_system//So they can initialize sparks whenever/N
	var/jeton = 0
	var/borgwires = 15
	var/killswitch = 0
	var/killswitch_time = 60
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/datum/ai_laws/laws = null //Making it so borgs can have laws when there isn't an AI.
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lockcharge //Used when locking down a borg to preserve cell charge
