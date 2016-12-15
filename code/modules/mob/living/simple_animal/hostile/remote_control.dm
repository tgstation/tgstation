/mob/living/simple_animal/hostile/remote_control
	name = "remote control robot"
	desc = "A simple robot. The pilot is probably nearby."
	speak_emote = list("beeps")
	icon_state = "remote_control"
	icon_living = "remote_control"
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
	var/obj/item/device/drone_controller/remote

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
	if(remote.loc != pilot)
		src << "You dropped the remote!"
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
	src << "Bzzzzzzzzzt. Connection lost."
	eject_pilot()

//Remote
/obj/item/device/drone_controller
	name = "remote controller"
	desc = "A remote for steering robots."
	icon_state = "gangtool-white"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	var/mob/living/simple_animal/hostile/remote_control/RC

/obj/item/device/drone_controller/afterattack(atom/A, mob/user,proximity)
	if(!proximity)
		return
	if(RC && RC == A)
		user << "[src] is already linked to [A]."
		return
	if(istype(A, /mob/living/simple_animal/hostile/remote_control))
		var/mob/living/simple_animal/hostile/remote_control/takeover = A
		if(takeover.remote || takeover.pilot)
			user << "[takeover] is already under someone elses control. You attempt to reset it..."
			if(do_after(user, 50, target = takeover))
				takeover << "Someone has hacked [takeover]! Your remote has lost its link."
				takeover.eject_pilot()
				takeover.pilot = null
				takeover.remote = null
				user << "You've disconnected [takeover]. It is no longer linked to any remotes."
		else
			user << "You link [takeover] to your remote. You may now control it."
	..()


/obj/item/device/drone_controller/attack_self(mob/user)
	if(!RC)
		user << "The remote isn't currently linked to anything. Use it on a controllable robot to sync the remote."
		return
	else
		RC.assume_control(user)

/obj/item/device/drone_controller/examine(mob/user)
	..()
	if(RC)
		user << "It is currently synced with [RC]."
		user << "[RC] Integrity: [RC.health]/[RC.maxHealth]"
	else
		user << "The remote is currently not synced with anything."