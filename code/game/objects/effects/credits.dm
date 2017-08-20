#define CREDIT_ROLL_SPEED 150
#define CREDIT_SPAWN_SPEED 15
#define CREDIT_ANIMATE_HEIGHT (14 * world.icon_size)
#define CREDIT_EASE_DURATION 30
#define CREDITS_LOC locate(12, 167, ZLEVEL_CENTCOM)

/proc/RollCredits()
	set waitfor = FALSE
	var/turf/T = CREDITS_LOC
	for(var/I in shuffle(icon_states('icons/credits.dmi')))
		new /obj/effect/abstract/credit(T, I)
		sleep(CREDIT_SPAWN_SPEED)

/proc/TestCredit(name)
	new /obj/effect/abstract/credit(get_turf(usr), name)

/obj/effect/abstract/credit
	icon = 'icons/credits.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	layer = SPLASHSCREEN_LAYER

/obj/effect/abstract/credit/Initialize(mapload, credited)
	. = ..()
	icon_state = credited
	maptext = credited
	maptext_x = world.icon_size + 8
	maptext_y = (world.icon_size / 2) - 4
	maptext_width = world.icon_size * 3
	animate(src, pixel_y = CREDIT_ANIMATE_HEIGHT, time = CREDIT_ROLL_SPEED)
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, .proc/FadeOut), CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION)
	QDEL_IN(src, CREDIT_ROLL_SPEED)

/obj/effect/abstract/credit/proc/FadeOut()
	animate(src, alpha = 0, pixel_y = CREDIT_ANIMATE_HEIGHT, time = CREDIT_EASE_DURATION)
