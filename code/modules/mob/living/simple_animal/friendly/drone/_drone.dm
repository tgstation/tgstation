
#define DRONE_HANDS_LAYER 1
#define DRONE_HEAD_LAYER 2
#define DRONE_TOTAL_LAYERS 2

#define DRONE_NET_CONNECT "<span class='notice'>DRONE NETWORK: [name] connected.</span>"
#define DRONE_NET_DISCONNECT "<span class='danger'>DRONE NETWORK: [name] is not responding.</span>"

#define MAINTDRONE	"drone_maint"
#define REPAIRDRONE	"drone_repair"

/mob/living/simple_animal/drone
	name = "Drone"
	desc = "A maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_grey"
	icon_living = "drone_maint_grey"
	icon_dead = "drone_maint_dead"
	gender = NEUTER
	health = 30
	maxHealth = 30
	unsuitable_atmos_damage = 0
	wander = 0
	speed = 0
	ventcrawler = 2
	density = 0
	pass_flags = PASSTABLE | PASSMOB
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = (CANPUSH | CANSTUN | CANWEAKEN)
	gender = NEUTER
	voice_name = "synthesized chirp"
	languages = DRONE
	mob_size = MOB_SIZE_SMALL
	has_unlimited_silicon_privilege = 1
	staticOverlays = list()
	var/staticChoice = "static"
	var/list/staticChoices = list("static", "blank", "letter")
	var/picked = FALSE //Have we picked our visual appearence (+ colour if applicable)
	var/list/drone_overlays[DRONE_TOTAL_LAYERS]
	var/laws = \
	"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Drone.\n"+\
	"2. You may not harm any being, regardless of intent or circumstance.\n"+\
	"3. Your goals are to build, maintain, repair, improve, and power to the best of your abilities, You must never actively work against these goals."
	var/light_on = 0
	var/heavy_emp_damage = 25 //Amount of damage sustained if hit by a heavy EMP pulse
	var/health_repair_max = 0 //Drone will only be able to be repaired/reactivated up to this point, defaults to health
	var/alarms = list("Atmosphere" = list(), "Fire" = list(), "Power" = list())
	var/obj/item/internal_storage //Drones can store one item, of any size/type in their body
	var/obj/item/head
	var/obj/item/default_storage = /obj/item/weapon/storage/toolbox/drone //If this exists, it will spawn in internal storage
	var/obj/item/default_hatmask //If this exists, it will spawn in the hat/mask slot if it can fit
	var/seeStatic = 1 //Whether we see static instead of mobs
	var/visualAppearence = MAINTDRONE //What we appear as


/mob/living/simple_animal/drone/New()
	..()

	name = name + " ([rand(100,999)])"
	real_name = name

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new /datum/job/captain
	access_card.access = C.get_access()

	if(!health_repair_max)
		health_repair_max = initial(health)

	if(default_storage)
		var/obj/item/I = new default_storage(src)
		equip_to_slot_or_del(I, "drone_storage_slot")
	if(default_hatmask)
		var/obj/item/I = new default_hatmask(src)
		equip_to_slot_or_del(I, slot_head)

	alert_drones(DRONE_NET_CONNECT)


/mob/living/simple_animal/drone/Destroy()
	qdel(access_card) //Otherwise it ends up on the floor!
	..()

/mob/living/simple_animal/drone/Login()
	..()
	update_inv_hands()
	update_inv_head()
	update_inv_internal_storage()
	check_laws()

	updateSeeStaticMobs()

	if(!picked)
		pickVisualAppearence()


/mob/living/simple_animal/drone/death(gibbed)
	..(gibbed)
	drop_l_hand()
	drop_r_hand()
	if(internal_storage)
		unEquip(internal_storage)
	if(head)
		unEquip(head)

	alert_drones(DRONE_NET_DISCONNECT)


/mob/living/simple_animal/drone/gib()
	dust()


/mob/living/simple_animal/drone/examine(mob/user)
	. = ..()
	if(!client && stat != DEAD)
		user << "<span class='notice'>A small blue LED is blinking on and off at a steady rate.</span>"

	if(stat == DEAD)
		user << "<span class='notice'>The drone's LED screen shows a BSOD, Blue screen of Death!</span>"


/mob/living/simple_animal/drone/IsAdvancedToolUser()
	return 1


/mob/living/simple_animal/drone/canUseTopic()
	if(stat)
		return
	return 1


/mob/living/simple_animal/drone/assess_threat() //Secbots won't hunt maintenance drones.
	return -10


/mob/living/simple_animal/drone/emp_act(severity)
	Stun(5)
	src << "<span class='danger'><b>ER@%R: MME^RY CO#RU9T!</b> R&$b@0tin)...</span>"
	if(severity == 1)
		adjustBruteLoss(heavy_emp_damage)
		src << "<span class='userdanger'>HeAV% DA%^MMA+G TO I/O CIR!%UUT!</span>"


/mob/living/simple_animal/drone/proc/triggerAlarm(var/class, area/A, var/O, var/obj/alarmsource)
	if(alarmsource.z != z)
		return
	if(stat != DEAD)
		var/list/L = src.alarms[class]
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/sources = alarm[2]
				if (!(alarmsource in sources))
					sources += alarmsource
				return
		L[A.name] = list(A, list(alarmsource))
		src << "--- [class] alarm detected in [A.name]!"


/mob/living/simple_animal/drone/proc/cancelAlarm(var/class, area/A as area, obj/origin)
	if(stat != DEAD)
		var/list/L = alarms[class]
		var/cleared = 0
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/srcs  = alarm[2]
				if (origin in srcs)
					srcs -= origin
				if (srcs.len == 0)
					cleared = 1
					L -= I
		if(cleared)
			src << "--- [class] alarm in [A.name] has been cleared."

/mob/living/simple_animal/drone/check_eye_prot()
	return 2

/mob/living/simple_animal/drone/handle_temperature_damage()
	return
