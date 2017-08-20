#define CREDIT_ROLL_SPEED 125
#define CREDIT_SPAWN_SPEED 15
#define CREDIT_ANIMATE_HEIGHT (14 * world.icon_size)
#define CREDIT_EASE_DURATION 22

/client/proc/RollCredits()
	set waitfor = FALSE
	ClearCredits()
	LAZYINITLIST(credits)
	var/list/_credits = credits
	var/static/list/credit_order_for_this_round = list("Thanks for playing!") + (shuffle(icon_states('icons/credits.dmi')) - "Thanks for playing!")
	for(var/I in credit_order_for_this_round)
		if(!credits)
			break
		_credits += new /obj/screen/credit(null, I, src)
		sleep(CREDIT_SPAWN_SPEED)

/client/verb/ClearCredits()
	set name = "Hide Credits"
	set category = "OOC"
	for(var/I in credits)
		var/obj/screen/credit/C = I
		var/fot = C.fadeout_timer
		if(fot)
			deltimer(fot)
		deltimer(C.deletion_timer)
		animate(C, alpha = 0, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
		QDEL_IN(C, CREDIT_EASE_DURATION)

/obj/screen/credit
	icon = 'icons/credits.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	screen_loc = "12,1"
	layer = SPLASHSCREEN_LAYER
	var/fadeout_timer
	var/deletion_timer
	var/client/parent
	var/matrix/target

/obj/screen/credit/Initialize(mapload, credited, client/P)
	parent = P
	icon_state = credited
	. = ..()
	maptext = credited
	maptext_x = world.icon_size + 8
	maptext_y = (world.icon_size / 2) - 4
	maptext_width = world.icon_size * 3
	var/matrix/M = matrix(transform)
	M.Translate(0, CREDIT_ANIMATE_HEIGHT)
	animate(src, transform = M, time = CREDIT_ROLL_SPEED)
	target = M
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	fadeout_timer = addtimer(CALLBACK(src, .proc/FadeOut), CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION, TIMER_STOPPABLE)
	deletion_timer = QDEL_IN(src, CREDIT_ROLL_SPEED)
	P.screen += src

/obj/screen/credit/Destroy()
	var/client/P = parent
	P.screen -= src
	LAZYREMOVE(P.credits, src)
	parent = null
	return ..()

/obj/screen/credit/proc/FadeOut()
	fadeout_timer = null
	animate(src, alpha = 0, transform = target, time = CREDIT_EASE_DURATION)
