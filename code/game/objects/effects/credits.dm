#define CREDIT_ROLL_SPEED 150
#define CREDIT_SPAWN_SPEED 15
#define CREDIT_ANIMATE_HEIGHT (14 * TURF_PIXEL_DIAMETER)
#define CREDIT_EASE_DURATION 30
#define CREDITS_LOC locate(12, 167, ZLEVEL_CENTCOM)

/proc/RollCredits()
	set waitfor = FALSE
	var/list/contributors = icon_states('icons/credits.dmi') - ""
	contributors = shuffle(contributors)

	for(var/I in contributors)
		new/obj/effect/abstract/credit(CREDITS_LOC, I)
		sleep(CREDIT_SPAWN_SPEED)

/proc/TestCredit(name)
	new /obj/effect/abstract/credit(get_turf(usr), name)

/obj/effect/abstract/credit
	icon = 'icons/credits.dmi'
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	alpha = 0
	layer = SPLASHSCREEN_LAYER
	maptext_x = TURF_PIXEL_DIAMETER + 8
	maptext_y = (TURF_PIXEL_DIAMETER / 2) - 4
	maptext_width = TURF_PIXEL_DIAMETER * 3

/obj/effect/abstract/credit/Initialize(mapload, credited)
	. = ..()
	name = text("\improper []", credited)
	icon_state = credited
	maptext = credited
	animate(src, pixel_y = CREDIT_ANIMATE_HEIGHT, time = CREDIT_ROLL_SPEED)
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, .proc/FadeOut), CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION)
	QDEL_IN(src, CREDIT_ROLL_SPEED)

/obj/effect/abstract/credit/proc/FadeOut()
	animate(src, alpha = 0, pixel_y = CREDIT_ANIMATE_HEIGHT, time = CREDIT_EASE_DURATION)
