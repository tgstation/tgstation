//Rituals. They do various things and have different kinds of effects. You need certain items or resources to do them.

#define RITUAL_NOT_STARTED 0 //A witch needs to begin the ritual.
#define RITUAL_IN_PROGRESS 1 //The circle is in use

/datum/ritual
	var/ritual_name = "Basic Ritual"
	var/ritual_desc = "This ritual serves no purpose."
	var/mob/living/invoker = null
	var/stage = RITUAL_NOT_STARTED
	var/obj/structure/witchcraft/ritual_circle/circle = null

/datum/ritual/proc/fail_ritual(var/reason_of_failure, var/manual = 0)
	if(circle)
		if(invoker && reason_of_failure)
			invoker << "<span class='warning'>[reason_of_failure]</span>"
		if(!manual)
			circle.visible_message("<span class='warning'>[circle] slowly darkens.</span>")
			animate(circle, color = initial(circle.color), time = 20)
	return 0

/datum/ritual/proc/begin_ritual()
	if(!invoker || !circle)
		return fail_ritual()
	if(stage > RITUAL_NOT_STARTED)
		return fail_ritual("This circle is in use.", 1)
	invoker << "<span class='notice'>You invoke the [ritual_name]...</span>"
	stage = RITUAL_IN_PROGRESS
	animate(circle, color = "#00AA00", time = 20)
	sleep(20)
	finish_ritual()

/datum/ritual/proc/finish_ritual()
	animate(circle, color = initial(circle.color), time = 20)
	stage = RITUAL_NOT_STARTED
	invoker << "<span class='boldnotice'>Ritual complete.</span>"

/datum/ritual/grow
	ritual_name = "Ritual of Growth"
	ritual_desc = "This ritual will emit a burst of vitality, instantly growing all plants nearby."

/datum/ritual/grow/finish_ritual()
	circle.visible_message("<span class='notice'><i>[circle] emits a flash of gentle green light!</i></span>")
	for(var/obj/machinery/hydroponics/H in range(5, circle))
		PoolOrNew(/obj/effect/overlay/temp/overgrowth, get_turf(H))
		if(H.myseed)
			H.harvest = 1
	..()
