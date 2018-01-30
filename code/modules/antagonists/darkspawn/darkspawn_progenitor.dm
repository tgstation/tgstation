/mob/living/simple_animal/hostile/darkspawn_progenitor
	name = "cosmic progenitor"
	desc = "..."
	icon = 'icons/mob/darkspawn_progenitor.dmi'
	icon_state = "darkspawn_progenitor"
	icon_living = "darkspawn_progenitor"
	health = INFINITY
	maxHealth = INFINITY
	attacktext = "rips apart"
	attack_sound = 'sound/creatures/progenitor_attack.ogg'
	friendly = "stares down"
	speak_emote = list("roars")
	armour_penetration = 100
	melee_damage_lower = 40
	melee_damage_upper = 40
	move_to_delay = 10
	speed = 1
	pixel_x = -48
	pixel_y = -32
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_WALLS
	obj_damage = 100
	light_range = 15
	light_color = "#21007F"
	weather_immunities = list("lava", "ash")
	anchored = TRUE
	movement_type = FLYING
	var/time_since_last_roar = 0

/mob/living/simple_animal/hostile/darkspawn_progenitor/Initialize()
	. = ..()
	alpha = 0
	animate(src, alpha = 255, time = 10)
	var/obj/item/device/radio/headset/ai/radio = new(src) //so the progenitor can hear people's screams over radio
	radio.wires.cut(WIRE_TX) //but not talk over it

/mob/living/simple_animal/hostile/darkspawn_progenitor/AttackingTarget()
	if(istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		playsound(target, 'sound/magic/pass_smash_door.ogg', 100, FALSE)
		obj_damage = 60
	. = ..()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Login()
	..()
	var/image/I = image(icon = 'icons/mob/mob.dmi' , icon_state = "smol_progenitor", loc = src)
	I.override = 1
	I.pixel_x -= pixel_x
	I.pixel_y -= pixel_y
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smolgenitor", I)
	time_since_last_roar = world.time + 300

/mob/living/simple_animal/hostile/darkspawn_progenitor/Life()
	..()
	if(time_since_last_roar <= world.time)
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/say()
	if(time_since_last_roar > world.time + 350) //at least give it SOME time
		return
	roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Process_Spacemove()
	return TRUE

/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/roar()
	playsound(src, 'sound/creatures/progenitor_roar.ogg', 100, TRUE)
	for(var/mob/M in GLOB.player_list)
		if(get_dist(M, src) > 7)
			M.playsound_local(src, 'sound/creatures/progenitor_distant.ogg', 75, FALSE, falloff = 5)
		else if(isliving(M))
			var/mob/living/L = M
			to_chat(M, "<span class='boldannounce'>You stand paralyzed in the shadow of the cold as it descends from on high.</span>")
			L.Stun(20)
	time_since_last_roar = world.time + 400

/mob/living/simple_animal/hostile/darkspawn_progenitor/narsie_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ratvar_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/singularity_act()
	return
