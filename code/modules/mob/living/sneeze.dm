/// How many degrees, up and down, can our sneeze deviate from our facing direction?
#define SNEEZE_CONE 60

/// Launch a sneeze that can infect with a disease
/mob/living/proc/infectious_sneeze(datum/disease/disease, force, range = 4, count = 4, charge_time = 0.5 SECONDS, obj/projectile/sneezoid = /obj/projectile/sneeze)
	sneeze(range, count, charge_time, sneezoid, on_sneeze_hit_callback = CALLBACK(src, PROC_REF(try_sneeze_infect), disease.Copy(), force))

/// Try and infect following a sneeze hit. force to always infect
/mob/living/proc/try_sneeze_infect(datum/disease/disease, force, mob/living/target)
	target.contract_airborne_disease(disease)

/// Inhale and start the sneeze timer. on_sneeze_callback can be used to do custom sneezes, on_sneeze_hit_callback for special effects, but probably usually making it infect
/mob/living/proc/sneeze(range = 4, count = 3, charge_time = 0.5 SECONDS, obj/projectile/sneezoid = /obj/projectile/sneeze, on_sneeze_callback = null, on_sneeze_hit_callback = null)
	if(charge_time)
		emote("inhale")

	clear_fullscreen("sneezer", 0)
	var/atom/movable/screen/fullscreen/cursor_catcher/catcher = overlay_fullscreen("sneezer", /atom/movable/screen/fullscreen/cursor_catcher, FALSE)
	if(client)
		catcher.assign_to_mob(src)
	var/callback = on_sneeze_callback || CALLBACK(src, PROC_REF(launch_sneeze), range, count, sneezoid, on_sneeze_hit_callback, catcher)
	addtimer(callback, charge_time)

/// Shoot the sneeze projectile
/mob/living/proc/launch_sneeze(range, count, obj/projectile/sneezoid, datum/callback/on_sneeze_hit_callback, atom/movable/screen/fullscreen/cursor_catcher/catcher)
	emote("sneeze")

	var/angle = dir2angle(dir)

	if(catcher && catcher.given_turf)
		catcher.calculate_params()
		/// Take the target and subtract self for relative grid position. Then take the pixel x on the tile and divide by the tiles pixel size, and add 0.5 so it's fired from the center
		var/sneeze_x = catcher.given_turf.x - x + catcher.given_x / ICON_SIZE_X - 0.5
		var/sneeze_y = catcher.given_turf.y - y + catcher.given_y / ICON_SIZE_Y - 0.5
		angle = ATAN2(sneeze_y, sneeze_x)

		// Check if we're within the sneeze cone, otherwise just sneeze straight
		if(abs(closer_angle_difference(angle, dir2angle(dir) - SNEEZE_CONE)) + abs(closer_angle_difference(angle, dir2angle(dir) + SNEEZE_CONE)) > 2 * SNEEZE_CONE)
			angle = dir2angle(dir)

		clear_fullscreen("sneezer", 0)

	for(var/i in 0 to count)
		var/obj/projectile/sneezium = new sneezoid(get_turf(src), on_sneeze_hit_callback)
		sneezium.range = range
		sneezium.firer = src
		sneezium.fire(angle)

/// Sneeze projectile launched by sneezing. gross
/obj/projectile/sneeze
	name = "sneeze"
	icon_state = "sneeze"

	suppressed = SUPPRESSED_VERY
	range = 4
	speed = 0.25
	spread = 40
	damage_type = BRUTE
	damage = 0
	hitsound = null

	/// Call this when we hit something
	var/datum/callback/sneezie_callback

/obj/projectile/sneeze/Initialize(mapload, callback)
	. = ..()

	sneezie_callback = callback

/obj/projectile/sneeze/on_hit(atom/target, blocked, pierce_hit)
	. = ..()

	if(isliving(target))
		sneezie_callback?.Invoke(target) //you've been sneezered

#undef SNEEZE_CONE
