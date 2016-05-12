/mob/living/simple_animal/hellbound
	name = "damned spirit"
	real_name = "damned spirit"
	desc = "Your eternal reward"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	maxHealth = INFINITY
	health = INFINITY
	speak_emote = list("whines")
	emote_hear = list("wails.","screeches.")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	friendly = "stares sullenly at"
	speak_chance = 1
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "sighs at"
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speed = 10
	stop_automated_movement = 1
	status_flags = GODMODE
	faction = list("hellbound")
	status_flags = CANPUSH
	flying = 1
	var/damned_key = null

/mob/living/simple_animal/hellbound/Life()
	..()
	if(damned_key && ckey != damned_key)
		ckey = damned_key
		src << "Where do you think you're going?"

/mob/living/simple_animal/hellbound/death()
	return

/mob/living/simple_animal/hellbound/suicide()
	return

/mob/living/simple_animal/hellbound/ghostize(can_reenter_corpse = 1)
	return

/mob/living/simple_animal/hellbound/Destroy()
	return QDEL_HINT_LETMELIVE

/obj/machinery/hellbound_controller
	name = "hell controller"
	desc = "Used to keep the damned in line."
	icon = 'icons/obj/device.dmi'
	icon_state = "null"
	anchored = 1
	invisibility = 101
	var/list/damned_ckeys = list()

/obj/machinery/hellbound_controller/Destroy()
	return QDEL_HINT_LETMELIVE

/obj/machinery/hellbound_controller/process()
	for(var/mob/M in player_list)
		world << "checking [M]"
		if(M.ckey in damned_ckeys && M.stat == DEAD)
			var/mob/living/simple_animal/hellbound/H = new(get_turf(src))
			H.ckey = M.ckey
			H << "Shouldn't have sold your soul."


/area/hell
	name = "hell"
	icon_state = "yellow"
	requires_power = 0
	has_gravity = 1