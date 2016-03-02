
#define DRONE_HANDS_LAYER 1
#define DRONE_HEAD_LAYER 2
#define DRONE_TOTAL_LAYERS 2

#define DRONE_NET_CONNECT "<span class='notice'>DRONE NETWORK: [name] connected.</span>"
#define DRONE_NET_DISCONNECT "<span class='danger'>DRONE NETWORK: [name] is not responding.</span>"

#define MAINTDRONE	"drone_maint"
#define REPAIRDRONE	"drone_repair"
#define SCOUTDRONE	"drone_scout"

#define MAINTDRONE_HACKED "drone_maint_red"
#define REPAIRDRONE_HACKED "drone_repair_hacked"
#define SCOUTDRONE_HACKED "drone_scout_hacked"

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
	healable = 0
	density = 0
	pass_flags = PASSTABLE | PASSMOB
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = (CANPUSH | CANSTUN | CANWEAKEN)
	gender = NEUTER
	voice_name = "synthesized chirp"
	speak_emote = list("chirps")
	bubble_icon = "machine"
	languages = DRONE
	mob_size = MOB_SIZE_SMALL
	has_unlimited_silicon_privilege = 1
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
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
	var/alarms = list("Atmosphere" = list(), "Fire" = list(), "Power" = list())
	var/obj/item/internal_storage //Drones can store one item, of any size/type in their body
	var/obj/item/head
	var/obj/item/default_storage = /obj/item/weapon/storage/toolbox/drone //If this exists, it will spawn in internal storage
	var/obj/item/default_hatmask //If this exists, it will spawn in the hat/mask slot if it can fit
	var/seeStatic = 1 //Whether we see static instead of mobs
	var/visualAppearence = MAINTDRONE //What we appear as
	var/hacked = 0 //If we have laws to destroy the station


/mob/living/simple_animal/drone/New()
	..()

	name = name + " ([rand(100,999)])"
	real_name = name

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new /datum/job/captain
	access_card.access = C.get_access()

	if(default_storage)
		var/obj/item/I = new default_storage(src)
		equip_to_slot_or_del(I, slot_drone_storage)
	if(default_hatmask)
		var/obj/item/I = new default_hatmask(src)
		equip_to_slot_or_del(I, slot_head)

	access_card.flags |= NODROP

	alert_drones(DRONE_NET_CONNECT)


/mob/living/simple_animal/drone/Destroy()
	qdel(access_card) //Otherwise it ends up on the floor!
	return ..()

/mob/living/simple_animal/drone/Login()
	..()
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
	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <b>[src]</b>!\n"

	//Left hand items
	if(l_hand && !(l_hand.flags&ABSTRACT))
		if(l_hand.blood_DNA)
			msg += "<span class='warning'>It is holding \icon[l_hand] [l_hand.gender==PLURAL?"some":"a"] blood-stained [l_hand.name] in its left hand!</span>\n"
		else
			msg += "It is holding \icon[l_hand] \a [l_hand] in its left hand.\n"

	//Right hand items
	if(r_hand && !(r_hand.flags&ABSTRACT))
		if(r_hand.blood_DNA)
			msg += "<span class='warning'>It is holding \icon[r_hand] [r_hand.gender==PLURAL?"some":"a"] blood-stained [r_hand.name] in its right hand!</span>\n"
		else
			msg += "It is holding \icon[r_hand] \a [r_hand] in its right hand.\n"

	//Internal storage
	if(internal_storage && !(internal_storage.flags&ABSTRACT))
		if(internal_storage.blood_DNA)
			msg += "<span class='warning'>It is holding \icon[internal_storage] [internal_storage.gender==PLURAL?"some":"a"] blood-stained [internal_storage.name] in its internal storage!</span>\n"
		else
			msg += "It is holding \icon[internal_storage] \a [internal_storage] in its internal storage.\n"

	//Cosmetic hat - provides no function other than looks
	if(head && !(head.flags&ABSTRACT))
		if(head.blood_DNA)
			msg += "<span class='warning'>It is wearing \icon[head] [head.gender==PLURAL?"some":"a"] blood-stained [head.name] on its head!</span>\n"
		else
			msg += "It is wearing \icon[head] \a [head] on its head.\n"

	//Braindead
	if(!client && stat != DEAD)
		msg += "Its status LED is blinking at a steady rate.\n"

	//Hacked
	if(hacked)
		msg += "<span class='warning'>Its display is glowing red!</span>\n"

	//Damaged
	if(health != maxHealth)
		if(health > 10) //Between 30 and 10
			msg += "<span class='warning'>Its screws are slightly loose.</span>\n"
		else //Between 9 and 0
			msg += "<span class='warning'><b>Its screws are very loose!</b></span>\n"

	//Dead
	if(stat == DEAD)
		if(client)
			msg += "<span class='deadsay'>A message repeatedly flashes on its display: \"REBOOT -- REQUIRED\".</span>\n"
		else
			msg += "<span class='deadsay'>A message repeatedly flashes on its display: \"ERROR -- OFFLINE\".</span>\n"
	msg += "*---------*</span>"
	user << msg

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


/mob/living/simple_animal/drone/proc/triggerAlarm(class, area/A, O, obj/alarmsource)
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


/mob/living/simple_animal/drone/proc/cancelAlarm(class, area/A, obj/origin)
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

/mob/living/simple_animal/drone/handle_temperature_damage()
	return

/mob/living/simple_animal/drone/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	if(affect_silicon)
		return ..()

/mob/living/simple_animal/drone/mob_negates_gravity()
	return 1

/mob/living/simple_animal/drone/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/simple_animal/drone/experience_pressure_difference(pressure_difference, direction)
	return

/mob/living/simple_animal/drone/fully_heal(admin_revive = 0)
	adjustBruteLoss(-getBruteLoss()) //Heal all brute damage


