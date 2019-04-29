#define CREDIT_ROLL_SPEED 185
#define CREDIT_SPAWN_SPEED 20
#define CREDIT_ANIMATE_HEIGHT (14 * world.icon_size)
#define CREDIT_EASE_DURATION 22

GLOBAL_LIST(end_titles)

/client/proc/RollCredits()
	set waitfor = FALSE
	if(!GLOB.end_titles)
		GLOB.end_titles = SSticker.mode.generate_credit_text()
	LAZYINITLIST(credits)
	if(!credits)
		return
	var/list/_credits = credits
	verbs += /client/proc/ClearCredits
	_credits += new /obj/screen/credit/title_card(null, null, src, SSticker.mode.title_icon)
	sleep(CREDIT_SPAWN_SPEED * 3)
	for(var/I in GLOB.end_titles)
		_credits += new /obj/screen/credit(null, I, src)
		sleep(CREDIT_SPAWN_SPEED)
	sleep(CREDIT_ROLL_SPEED - CREDIT_SPAWN_SPEED)
	ClearCredits()
	verbs -= /client/proc/ClearCredits

/client/proc/ClearCredits()
	set name = "Hide Credits"
	set category = "OOC"
	verbs -= /client/proc/ClearCredits
	QDEL_LIST(credits)

/obj/screen/credit
	icon_state = "blank"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	screen_loc = "1,1"
	layer = SPLASHSCREEN_LAYER
	var/client/parent
	var/matrix/target

/obj/screen/credit/Initialize(mapload, credited, client/P)
	. = ..()
	parent = P
	maptext = credited
	maptext_height = world.icon_size * 2
	maptext_width = world.icon_size * 14
	var/matrix/M = matrix(transform)
	M.Translate(0, CREDIT_ANIMATE_HEIGHT)
	animate(src, transform = M, time = CREDIT_ROLL_SPEED)
	target = M
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, .proc/FadeOut), CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION)
	QDEL_IN(src, CREDIT_ROLL_SPEED)
	P.screen += src

/obj/screen/credit/Destroy()
	var/client/P = parent
	if(parent)
		P.screen -= src
	LAZYREMOVE(P.credits, src)
	parent = null
	return ..()

/obj/screen/credit/proc/FadeOut()
	animate(src, alpha = 0, transform = target, time = CREDIT_EASE_DURATION)

/obj/screen/credit/title_card
	icon = 'icons/title_cards.dmi'
	screen_loc = "4,1"

/obj/screen/credit/title_card/Initialize(mapload, credited, client/P, title_icon_state)
	icon_state = title_icon_state
	. = ..()
	maptext = null
