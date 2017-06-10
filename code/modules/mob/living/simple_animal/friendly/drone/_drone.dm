
#define DRONE_HANDS_LAYER 1
#define DRONE_HEAD_LAYER 2
#define DRONE_TOTAL_LAYERS 2

#define DRONE_NET_CONNECT "<span class='notice'>DRONE NETWORK: [name] connected.</span>"
#define DRONE_NET_DISCONNECT "<span class='danger'>DRONE NETWORK: [name] is not responding.</span>"

#define MAINTDRONE	"drone_maint"
#define REPAIRDRONE	"drone_repair"
#define SCOUTDRONE	"drone_scout"
#define CLOCKDRONE	"drone_clock"

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
	health = 30
	maxHealth = 30
	unsuitable_atmos_damage = 0
	wander = 0
	speed = 0
	ventcrawler = VENTCRAWLER_ALWAYS
	healable = 0
	density = 0
	pass_flags = PASSTABLE | PASSMOB
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = (CANPUSH | CANSTUN | CANWEAKEN)
	gender = NEUTER
	voice_name = "synthesized chirp"
	speak_emote = list("chirps")
	bubble_icon = "machine"
	initial_language_holder = /datum/language_holder/drone
	mob_size = MOB_SIZE_SMALL
	has_unlimited_silicon_privilege = 1
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	staticOverlays = list()
	hud_possible = list(DIAG_STAT_HUD, DIAG_HUD, ANTAG_HUD)
	unique_name = TRUE
	faction = list("neutral","silicon","turret")
	dextrous = TRUE
	dextrous_hud_type = /datum/hud/dextrous/drone
	var/staticChoice = "static"
	var/list/staticChoices = list("static", "blank", "letter", "animal")
	var/picked = FALSE //Have we picked our visual appearence (+ colour if applicable)
	var/colour = "grey"	//Stored drone color, so we can go back when unhacked.
	var/list/drone_overlays[DRONE_TOTAL_LAYERS]
	var/laws = \
	"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Drone.\n"+\
	"2. You may not harm any being, regardless of intent or circumstance.\n"+\
	"3. Your goals are to build, maintain, repair, improve, and provide power to the best of your abilities, You must never actively work against these goals."
	var/light_on = 0
	var/heavy_emp_damage = 25 //Amount of damage sustained if hit by a heavy EMP pulse
	var/alarms = list("Atmosphere" = list(), "Fire" = list(), "Power" = list())
	var/obj/item/internal_storage //Drones can store one item, of any size/type in their body
	var/obj/item/head
	var/obj/item/default_storage = /obj/item/weapon/storage/backpack/dufflebag/drone //If this exists, it will spawn in internal storage
	var/obj/item/default_hatmask //If this exists, it will spawn in the hat/mask slot if it can fit
	var/seeStatic = 1 //Whether we see static instead of mobs
	var/visualAppearence = MAINTDRONE //What we appear as
	var/hacked = 0 //If we have laws to destroy the station
	var/can_be_held = TRUE //if assholes can pick us up
	var/flavortext = \
	"\n<big><span class='warning'>DO NOT INTERFERE WITH THE ROUND AS A DRONE OR YOU WILL BE DRONE BANNED</span></big>\n"+\
	"<span class='notify'>Drones are a ghost role that are allowed to fix the station and build things. Interfering with the round as a drone is against the rules.</span>\n"+\
	"<span class='notify'>Actions that constitute interference include, but are not limited to:</span>\n"+\
	"<span class='notify'>     - Interacting with round critical objects (IDs, weapons, contraband, powersinks, bombs, etc.)</span>\n"+\
	"<span class='notify'>     - Interacting with living beings (communication, attacking, healing, etc.)</span>\n"+\
	"<span class='notify'>     - Interacting with non-living beings (dragging bodies, looting bodies, etc.)</span>\n"+\
	"<span class='warning'>These rules are at admin discretion and will be heavily enforced.</span>\n"+\
	"<span class='warning'><u>If you do not have the regular drone laws, follow your laws to the best of your ability.</u></span>"

/mob/living/simple_animal/drone/Initialize()
	. = ..()

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new /datum/job/captain
	access_card.access = C.get_access()

	if(default_storage)
		var/obj/item/I = new default_storage(src)
		equip_to_slot_or_del(I, slot_generic_dextrous_storage)
	if(default_hatmask)
		var/obj/item/I = new default_hatmask(src)
		equip_to_slot_or_del(I, slot_head)

	access_card.flags |= NODROP

	alert_drones(DRONE_NET_CONNECT)

	if(seeStatic)
		var/datum/action/generic/drone/select_filter/SF = new(src)
		SF.Grant(src)
	else
		verbs -= /mob/living/simple_animal/drone/verb/toggle_statics

	var/datum/atom_hud/data/diagnostic/diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)


/mob/living/simple_animal/drone/med_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/simple_animal/drone/med_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(stat == DEAD)
		holder.icon_state = "huddead2"
	else if(incapacitated())
		holder.icon_state = "hudoffline"
	else
		holder.icon_state = "hudstat"

/mob/living/simple_animal/drone/Destroy()
	qdel(access_card) //Otherwise it ends up on the floor!
	return ..()

/mob/living/simple_animal/drone/Login()
	..()
	check_laws()

	if(flavortext)
		to_chat(src, "[flavortext]")

	updateSeeStaticMobs()

	if(!picked)
		pickVisualAppearence()


/mob/living/simple_animal/drone/death(gibbed)
	..(gibbed)
	if(internal_storage)
		dropItemToGround(internal_storage)
	if(head)
		dropItemToGround(head)

	alert_drones(DRONE_NET_DISCONNECT)


/mob/living/simple_animal/drone/gib()
	dust()

/mob/living/simple_animal/drone/ratvar_act()
	if(status_flags & GODMODE)
		return

	if(internal_storage)
		dropItemToGround(internal_storage)
	if(head)
		dropItemToGround(head)
	var/mob/living/simple_animal/drone/cogscarab/ratvar/R = new /mob/living/simple_animal/drone/cogscarab/ratvar(loc)
	R.setDir(dir)
	if(mind)
		mind.transfer_to(R, 1)
	else
		R.key = key
	qdel(src)


/mob/living/simple_animal/drone/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <b>[src]</b>!\n"

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.flags & ABSTRACT))
			if(I.blood_DNA)
				msg += "<span class='warning'>It has \icon[I] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in its [get_held_index_name(get_held_index_of_item(I))]!</span>\n"
			else
				msg += "It has \icon[I] \a [I] in its [get_held_index_name(get_held_index_of_item(I))].\n"

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
		if(health > maxHealth * 0.33) //Between maxHealth and about a third of maxHealth, between 30 and 10 for normal drones
			msg += "<span class='warning'>Its screws are slightly loose.</span>\n"
		else //otherwise, below about 33%
			msg += "<span class='boldwarning'>Its screws are very loose!</span>\n"

	//Dead
	if(stat == DEAD)
		if(client)
			msg += "<span class='deadsay'>A message repeatedly flashes on its display: \"REBOOT -- REQUIRED\".</span>\n"
		else
			msg += "<span class='deadsay'>A message repeatedly flashes on its display: \"ERROR -- OFFLINE\".</span>\n"
	msg += "*---------*</span>"
	to_chat(user, msg)


/mob/living/simple_animal/drone/assess_threat() //Secbots won't hunt maintenance drones.
	return -10


/mob/living/simple_animal/drone/emp_act(severity)
	Stun(5)
	to_chat(src, "<span class='danger'><b>ER@%R: MME^RY CO#RU9T!</b> R&$b@0tin)...</span>")
	if(severity == 1)
		adjustBruteLoss(heavy_emp_damage)
		to_chat(src, "<span class='userdanger'>HeAV% DA%^MMA+G TO I/O CIR!%UUT!</span>")


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
		to_chat(src, "--- [class] alarm detected in [A.name]!")


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
			to_chat(src, "--- [class] alarm in [A.name] has been cleared.")

/mob/living/simple_animal/drone/handle_temperature_damage()
	return

/mob/living/simple_animal/drone/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	if(affect_silicon)
		return ..()

/mob/living/simple_animal/drone/mob_negates_gravity()
	return 1

/mob/living/simple_animal/drone/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/simple_animal/drone/experience_pressure_difference(pressure_difference, direction)
	return

/mob/living/simple_animal/drone/bee_friendly()
	// Why would bees pay attention to drones?
	return 1

/mob/living/simple_animal/drone/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	return 0 //So they don't die trying to fix wiring
