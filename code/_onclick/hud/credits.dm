#define CREDIT_ROLL_SPEED 125
#define CREDIT_SPAWN_SPEED 10
#define CREDIT_ANIMATE_HEIGHT (14 * ICON_SIZE_Y)
#define CREDIT_EASE_DURATION 22
#define CREDITS_PATH "[global.config.directory]/contributors.dmi"

/client/proc/RollCredits()
	set waitfor = FALSE
	if(!fexists(CREDITS_PATH))
		return
	var/icon/credits_icon = new(CREDITS_PATH)
	LAZYINITLIST(credits)
	var/list/_credits = credits
	add_verb(src, /client/proc/ClearCredits)
	var/static/list/credit_order_for_this_round
	if(isnull(credit_order_for_this_round))
		credit_order_for_this_round = list("Thanks for playing!") + (shuffle(icon_states(credits_icon)) - "Thanks for playing!")
	for(var/I in credit_order_for_this_round)
		if(!credits)
			return
		_credits += new /atom/movable/screen/credit(null, null, I, src, credits_icon)
		sleep(CREDIT_SPAWN_SPEED)
	sleep(CREDIT_ROLL_SPEED - CREDIT_SPAWN_SPEED)
	remove_verb(src, /client/proc/ClearCredits)
	qdel(credits_icon)

/client/proc/ClearCredits()
	set name = "Hide Credits"
	set category = "OOC"
	remove_verb(src, /client/proc/ClearCredits)
	QDEL_LIST(credits)
	credits = null

/atom/movable/screen/credit
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	screen_loc = "12,1"
	plane = SPLASHSCREEN_PLANE
	var/client/parent
	var/matrix/target

/atom/movable/screen/credit/Initialize(mapload, datum/hud/hud_owner, credited, client/P, icon/I)
	. = ..()
	icon = I
	parent = P
	icon_state = credited
	maptext = MAPTEXT_PIXELLARI(credited)
	maptext_x = ICON_SIZE_X + 8
	maptext_y = (ICON_SIZE_Y / 2) - 4
	maptext_width = ICON_SIZE_X * 3
	var/matrix/M = matrix(transform)
	M.Translate(0, CREDIT_ANIMATE_HEIGHT)
	animate(src, transform = M, time = CREDIT_ROLL_SPEED)
	target = M
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(FadeOut)), CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION)
	QDEL_IN(src, CREDIT_ROLL_SPEED)
	if(parent)
		parent.screen += src

/atom/movable/screen/credit/Destroy()
	icon = null
	if(parent)
		parent.screen -= src
		LAZYREMOVE(parent.credits, src)
		parent = null
	return ..()

/atom/movable/screen/credit/proc/FadeOut()
	animate(src, alpha = 0, transform = target, time = CREDIT_EASE_DURATION)

#undef CREDIT_ANIMATE_HEIGHT
#undef CREDIT_EASE_DURATION
#undef CREDIT_ROLL_SPEED
#undef CREDIT_SPAWN_SPEED
#undef CREDITS_PATH
