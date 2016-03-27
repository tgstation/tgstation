
/obj/machinery/auto_cloner
	name = "mysterious pod"
	desc = "It's full of a viscous liquid, but appears dark and silent."
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "autoclone0"
	var/spawn_type
	var/current_ticks_spawning = 0
	var/ticks_required_to_spawn
	density = 1
	var/previous_power_state = 0

	use_power = 1
	active_power_usage = 2000
	idle_power_usage = 1000

	machine_flags = WRENCHMOVE

/obj/machinery/auto_cloner/New()
	..()

	ticks_required_to_spawn = rand(45,180)

	//33% chance to spawn nasties
	if(prob(33))
		spawn_type = pick(
			/mob/living/simple_animal/hostile/giant_spider/nurse,
			/mob/living/simple_animal/hostile/alien,
			/mob/living/simple_animal/hostile/bear,
			/mob/living/simple_animal/hostile/creature,
			/mob/living/simple_animal/hostile/monster/skrite,
			/mob/living/simple_animal/hostile/monster/necromorph,
			)
	else
		spawn_type = pick(
			/mob/living/simple_animal/cat,
			/mob/living/simple_animal/corgi,
			/mob/living/simple_animal/corgi/puppy,
			/mob/living/simple_animal/chicken,
			/mob/living/simple_animal/cow,
			/mob/living/simple_animal/parrot,
			/mob/living/simple_animal/slime,
			/mob/living/simple_animal/crab,
			/mob/living/simple_animal/mouse,
			/mob/living/simple_animal/hostile/retaliate/goat,
			/mob/living/carbon/monkey,
			)

//todo: how the hell is the asteroid permanently powered?
/obj/machinery/auto_cloner/process()
	if(powered(power_channel))
		if(!previous_power_state)
			previous_power_state = 1
			icon_state = "autoclone1"
			src.visible_message("<span class='notice'>[bicon(src)] [src] suddenly comes to life!</span>")

		//slowly grow a mob
		current_ticks_spawning++
		if(prob(5))
			src.visible_message("<span class='notice'>[bicon(src)] [src] [pick("gloops","glugs","whirrs","whooshes","hisses","purrs","hums","gushes")].</span>")

		//if we've finished growing...
		if(current_ticks_spawning >= ticks_required_to_spawn)
			current_ticks_spawning = 0
			use_power = 1
			src.visible_message("<span class='notice'>[bicon(src)] [src] pings!</span>")
			icon_state = "autoclone1"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow."
			if(spawn_type)
				new spawn_type(src.loc)
				playsound(get_turf(src), 'sound/machines/heps.ogg', 50, 0)

		//if we're getting close to finished, kick into overdrive power usage
		if(current_ticks_spawning / ticks_required_to_spawn > 0.75)
			use_power = 2
			icon_state = "autoclone2"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow. A dark shape appears to be forming inside..."
		else
			use_power = 1
			icon_state = "autoclone1"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow."
	else
		if(previous_power_state)
			previous_power_state = 0
			icon_state = "autoclone0"
			src.visible_message("<span class='notice'>[bicon(src)] [src] suddenly shuts down.</span>")

		//cloned mob slowly breaks down
		if(current_ticks_spawning > 0)
			current_ticks_spawning--

/obj/machinery/auto_cloner/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		log_attack("<font color='red'>[Proj.firer ? "[key_name(Proj.firer)]" : "Something"] shot [src]/([formatJumpTo(src)]) with a [Proj.type]</font>")
		src.visible_message("<span class='notice'>\The [Proj] [Proj.damage ? "hits" : "glances off"] \the [src]!</span>")
		if(prob(Proj.damage/2))
			if(Proj.firer)
				msg_admin_attack("[key_name(Proj.firer)] blew up [src]/([formatJumpTo(src)]) with a [Proj.type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[Proj.firer.x];Y=[Proj.firer.y];Z=[Proj.firer.z]'>JMP</a>)")
			explosion(get_turf(src), 1, 2, 3, 3)
			qdel(src)

/obj/machinery/auto_cloner/attackby(var/obj/O, var/mob/user)
	if(iswrench(O))
		return ..()
	else if(O.force > 10)
		log_attack("<font color='red'>[user] damaged [src]/([formatJumpTo(src)]) with [O]</font>")
		src.visible_message("<span class='warning'>\The [user] damages \the [src] with \the [O].</span>")
		if(prob(O.force/2))
			msg_admin_attack("[user] blew up [src]/([formatJumpTo(src)]) with [O] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			explosion(get_turf(src), 1, 2, 3, 3)
			qdel(src)
	else
		src.visible_message("<span class='warning'>\The [user] taps \the [src] with \the [O].</span>")
