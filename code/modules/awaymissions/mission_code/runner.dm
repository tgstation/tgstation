/datum/outfit/vr/runner
	name = "Runner Equipment"
	shoes = /obj/item/clothing/shoes/bhop

/obj/effect/portal/permanent/one_way/recall/pit_faller
	name = "Runner Portal"
	desc = "A game of eternal running, where one misstep means certain death."
	equipment = /datum/outfit/vr/runner
	recall_equipment = /datum/outfit/vr
	id = "vr runner"
	light_color = LIGHT_COLOR_FIRE
	light_power = 1
	light_range = 2

/obj/effect/portal/permanent/one_way/destroy/pit_faller
	name = "Runner Exit Portal"
	id = "vr runner"

/turf/open/indestructible/runner
	name = "Shaky Ground"
	desc = "If you walk on that that you better keep running!"
	var/can_fall = 1 // so the turf doesnt fall in the staging period
	var/not_reset = 0 // check so turfs dont fall after being reset
	var/falling_time = 5 // time it takes for the turf to fall

/turf/open/indestructible/runner/Entered(atom/movable/A)
	. = ..()
	var/datum/thrownthing/throwcheck = A.throwing
	if(isliving(A) && can_fall && !throwcheck || (throwcheck.dist_travelled >= throwcheck.maxrange || A.loc == throwcheck.target_turf))
		INVOKE_ASYNC(src, .proc/turf_fall)
	return

/turf/open/indestructible/runner/proc/turf_fall()
	color = COLOR_RED
	not_reset = 1
	sleep(falling_time)
	if(!not_reset)
		return
	not_reset = 0
	ChangeTurf(/turf/open/chasm)
	color = initial(color)
	return

/turf/open/indestructible/runner/proc/reset_fall()
	not_reset = 0
	ChangeTurf(/turf/open/indestructible/runner)
	color = initial(color)
	return