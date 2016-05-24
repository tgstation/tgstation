//Challenge Areas

/area/awaymission/challenge/start
	name = "Where Am I?"
	icon_state = "away"

/area/awaymission/challenge/main
	name = "Danger Room"
	icon_state = "away1"
	requires_power = 0

/area/awaymission/challenge/end
	name = "Administration"
	icon_state = "away2"
	requires_power = 0


/obj/machinery/power/emitter/energycannon
	name = "Energy Cannon"
	desc = "A heavy duty industrial laser"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 1
	density = 1

	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

	active = 1
	locked = 1
	state = 2

/obj/machinery/power/emitter/energycannon/RefreshParts()
	return

/obj/machinery/power/emitter/energycannon/magical
	name = "wabbajack statue"
	desc = "Who am I? What is my purpose in life? What do I mean by who am I?"
	projectile_type = /obj/item/projectile/magic/change
