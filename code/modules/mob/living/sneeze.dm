/// Launch a sneeze that can infect with a disease
/mob/living/proc/infectious_sneeze(datum/disease/disease, force, range = 4, charge_time = 0.5 SECONDS, obj/projectile/sneezoid = /obj/projectile/sneeze)
	sneeze(range, charge_time, sneezoid, on_sneeze_hit_callback = CALLBACK(src, PROC_REF(try_sneeze_infect), disease, force))

/// Try and infect following a sneeze hit. force to always infect
/mob/living/proc/try_sneeze_infect(datum/disease/disease, force, mob/living/target)
	target.AirborneContractDisease(disease, force)

/// Inhale and start the sneeze timer. on_sneeze_callback can be used to do custom sneezes, on_sneeze_hit_callback for special effects, but probably usually making it infect
/mob/living/proc/sneeze(range = 4, charge_time = 0.5 SECONDS, obj/projectile/sneezoid = /obj/projectile/sneeze, on_sneeze_callback = null, on_sneeze_hit_callback = null)
	if(charge_time)
		emote("inhale")

	var/callback = on_sneeze_callback || CALLBACK(src, PROC_REF(launch_sneeze), range, sneezoid, on_sneeze_hit_callback)
	addtimer(callback, charge_time)

/// Shoot the sneeze projectile
/mob/living/proc/launch_sneeze(range, obj/projectile/sneezoid, datum/callback/on_sneeze_hit_callback)
	emote("sneeze")

	var/obj/projectile/sneezium = new sneezoid(get_turf(src), on_sneeze_hit_callback)
	sneezium.range = range
	sneezium.firer = src
	sneezium.fire(dir2angle(dir))

/// Sneeze projectile launched by sneezing. gross
/obj/projectile/sneeze
	name = "sneezoid"
	icon_state = "sneeze"

	suppressed = TRUE
	range = 4
	speed = 4
	damage_type = BRUTE
	damage = 0

	/// Call this when we hit something
	var/datum/callback/sneezie_callback

/obj/projectile/sneeze/Initialize(mapload, callback)
	. = ..()

	sneezie_callback = callback

/obj/projectile/sneeze/on_hit(atom/target, blocked, pierce_hit)
	. = ..()

	if(isliving(target))
		sneezie_callback?.Invoke(target) //you've been sneezered
