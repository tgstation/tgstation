
//malfunctioning combat drones
/mob/living/simple_animal/hostile/retaliate/malf_drone
	name = "combat drone"
	desc = "An automated combat drone armed with state of the art weaponry and shielding."
	icon_state = "drone3"
	icon_living = "drone3"
	icon_dead = "drone_dead"
	ranged = 1
	rapid = 1
	speak_chance = 5
	turns_per_move = 3
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("ALERT.","Hostile-ile-ile entities dee-twhoooo-wected.","Threat parameterszzzz- szzet.","Bring sub-sub-sub-systems uuuup to combat alert alpha-a-a.")
	emote_see = list("beeps menacingly","whirrs threateningly","scans it's immediate vicinity")
	a_intent = "harm"
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	speed = 4
	projectiletype = /obj/item/projectile/beam
	projectilesound = 'sound/weapons/laser3.ogg'
	destroy_surroundings = 0
	var/datum/effect/effect/system/ion_trail_follow/ion_trail

	//the drone randomly switches between these states because it's malfunctioning
	var/hostile_drone = 0
	//0 - retaliate, only attack enemies that attack it
	//1 - hostile, attack everything that comes near

	var/turf/patrol_target
	var/explode_chance = 1
	var/disabled = 0

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 600

	var/has_loot = 1
	faction = "malf_drone"

/mob/living/simple_animal/hostile/retaliate/malf_drone/New()
	..()
	if(prob(5))
		projectiletype = /obj/item/projectile/beam/pulse
		projectilesound = 'sound/weapons/pulse2.ogg'
	ion_trail = new
	ion_trail.set_up(src)
	ion_trail.start()

/mob/living/simple_animal/hostile/retaliate/malf_drone/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/retaliate/malf_drone/ListTargets()
	if(hostile_drone)
		return view(src, 10)
	else
		return ..()

//self repair systems have a chance to bring the drone back to life
/mob/living/simple_animal/hostile/retaliate/malf_drone/Life()

	if(disabled > 0)
		stat = UNCONSCIOUS
		icon_state = "drone_dead"
		disabled--
		if(disabled <= 0)
			stat = CONSCIOUS
			icon_state = "drone0"
		else
			return

	if(prob(1))
		src.visible_message("\red \icon[src] [src] shudders and shakes.")
		if(stat == DEAD)
			health = rand(5,15)
		else if(health < maxHealth)
			health += rand(5,15)

	if(prob(disabled ? 0 : 1))
		if(hostile_drone)
			src.visible_message("\red \icon[src] [src] retracts several targetting vanes, and dulls it's running lights.")
			hostile_drone = 0
		else
			src.visible_message("\red \icon[src] [src] suddenly lights up, and additional targetting vanes slide into place.")
			hostile_drone = 1

	if(health / maxHealth > 0.75)
		icon_state = "drone3"
		explode_chance = 0
	else if(health / maxHealth > 0.5)
		icon_state = "drone2"
		explode_chance = 0
	else if(health / maxHealth > 0.25)
		icon_state = "drone1"
		explode_chance = 0.5
	else
		icon_state = "drone0"
		explode_chance = 5

	if(!disabled && prob(explode_chance))
		src.visible_message("\red \icon[src] [src] begins to spark and shake violenty!")
		spawn(rand(30,100))
			if(!disabled)
				explosion(get_turf(src), 1, 2, 3, 7)
	..()

//ion rifle!
/mob/living/simple_animal/hostile/retaliate/malf_drone/emp_act(severity)
	health -= rand(3,15) * (severity + 1)
	disabled = rand(150, 600)
	hostile_drone = 0

/mob/living/simple_animal/hostile/retaliate/malf_drone/Del()
	//some random debris left behind
	if(has_loot)
		var/obj/O

		//shards
		O = new /obj/item/weapon/shard(src.loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = new /obj/item/weapon/shard(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = new /obj/item/weapon/shard(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = new /obj/item/weapon/shard(src.loc)
			step_to(O, get_turf(pick(view(7, src))))

		//rods
		O = new /obj/item/stack/rods(src.loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = new /obj/item/stack/rods(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = new /obj/item/stack/rods(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = new /obj/item/stack/rods(src.loc)
			step_to(O, get_turf(pick(view(7, src))))

		//plasteel
		O = new /obj/item/stack/sheet/plasteel(src.loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = new /obj/item/stack/sheet/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = new /obj/item/stack/sheet/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = new /obj/item/stack/sheet/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))

		//also drop dummy circuit boards deconstructable for research (loot)
		var/obj/item/weapon/circuitboard/C

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone CPU motherboard"
			C.origin_tech = "programming=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone neural interface"
			C.origin_tech = "biotech=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone suspension processor"
			C.origin_tech = "magnets=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone shielding controller"
			C.origin_tech = "bluespace=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone power capacitor"
			C.origin_tech = "powerstorage=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone hull reinforcer"
			C.origin_tech = "materials=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone auto-repair system"
			C.origin_tech = "engineering=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone plasma overcharge counter"
			C.origin_tech = "plasma=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone targetting circuitboard"
			C.origin_tech = "combat=[rand(3,10)]"

		if(prob(25))
			C = new(src.loc)
			C.name = "Drone morality core"
			C.origin_tech = "illegal=[rand(3,10)]"

	..()
