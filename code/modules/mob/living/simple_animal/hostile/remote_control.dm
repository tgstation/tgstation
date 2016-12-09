/mob/living/simple_animal/hostile/remote_control
	name = "remote control robot"
	desc = "A simple robot. The pilot is probably nearby."
	speak_emote = list("beeps")
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	ventcrawler = VENTCRAWLER_ALWAYS
	gender = NEUTER
	speed = 0
	a_intent = INTENT_HELP
	stop_automated_movement = 1
	pass_flags = PASSTABLE | PASSMOB
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "bumps into"
	maxHealth = 10
	health = 10
	environment_smash = 0
	melee_damage_lower = 3
	melee_damage_upper = 3
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	AIStatus = AI_OFF
	var/mob/living/pilot
	var/initial_pilot_health
	var/requires_pilot = TRUE

/mob/living/simple_animal/hostile/remote_control/Login()
	..()
	src << "You are now in control of [src]. To cease piloting, alt+click on [src]."

/mob/living/simple_animal/hostile/remote_control/Life()
	..()
	if(requires_pilot && is_pilot_unsafe())
		eject_pilot()

/mob/living/simple_animal/hostile/remote_control/death(gibbed)
	src << "[src] was destroyed!"
	eject_pilot()
	..()

/mob/living/simple_animal/hostile/remote_control/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(requires_pilot && A == src)
		src << "You cease piloting [src]."
		eject_pilot()
	..()

/mob/living/simple_animal/hostile/remote_control/proc/is_pilot_unsafe()
	if(!pilot)
		src << "Your body went missing!"
		return TRUE
	if(pilot.health < initial_pilot_health)
		src << "You're under attack!"
		return TRUE
	if(pilot.restrained())
		src << "You're having trouble controlling [src] while handcuffed."
		return TRUE
	if(pilot.stat || pilot.incapacitated() || pilot.lying)
		src << "You can't control [src] while you're incapacitated!"
		return TRUE

/mob/living/simple_animal/hostile/remote_control/proc/eject_pilot()
	if(pilot)
		if(mind)
			mind.transfer_to(pilot)
		else
			pilot.ckey = ckey
	else
		ghostize(0)
	pilot = null
	initial_pilot_health = null

/mob/living/simple_animal/hostile/remote_control/proc/assume_control(mob/living/user)
	if(pilot || !requires_pilot)
		user << "It's already being piloted."
	else
		initial_pilot_health = user.health
		pilot = user
		if(pilot.mind)
			pilot.mind.transfer_to(src)
		else
			ckey = pilot.ckey

/mob/living/simple_animal/hostile/remote_control/emp_act(severity)
	eject_pilot()

/mob/living/simple_animal/hostile/remote_control/AltClick(mob/living/user)
	if(user.canUseTopic(src))
		assume_control(user)
