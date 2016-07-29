//hunters have the most poison and move the fastest, so they can find prey
// THEY CAN ALSO OPEN DOORS OH GOD
/mob/living/simple_animal/hostile/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120 // Was 60
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 5
	speed=-1
	// Hunters attack doors (jam them open)
	wanted_objects = list(
		/obj/machinery/door/airlock,
		/obj/machinery/bot,          // Beepsky and friends
		/obj/machinery/light,        // Bust out lights
	)
	idle_vision_range = 7
	search_objects = 1 // Consider objects when searching.  Set to 0 when attacked
	wander = 1
	ranged = 0
	minimum_distance = 1

/mob/living/simple_animal/hostile/giant_spider/hunter/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(target == C && get_dist(src,target) > 1)
				target = null
			busy = 0
			stop_automated_movement = 0