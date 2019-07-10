/obj/machinery/power/plumbing/sprinkler
	name = "sprinkler"
	desc = "An automated sprinkler capable of detecting fire and spraying coolant."
	icon = 'icons/obj/objects.dmi'
	icon_state = "fuck"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	plane = FLOOR_PLANE
	max_integrity = 100
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 30)
	req_access = list(ACCESS_ENGINE)
	var/cooldown = 0
	var/working = FALSE
	idle_power_usage = 10
	active_power_usage = 1000
	anchored = FALSE
	density = FALSE
	volume = 10

/obj/machinery/power/plumbing/sprinkler/ComponentInitialize()
	AddComponent(/datum/component/plumbing/output)

/obj/machinery/power/plumbing/sprinkler/examine(mob/user)
	. = ..()
	. += "It is [anchored? "anchored" : "not anchored"]"

/obj/machinery/power/plumbing/sprinkler/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='danger'>Access denied.</span>")
		return
	dispense()
	log_game("[user] has manually actived the sprinkler in [AREACOORD(src)]")

/obj/machinery/power/plumbing/sprinkler/fire_act()
	. = ..()
	dispense()

/obj/machinery/power/plumbing/sprinkler/proc/dispense()
	if(cooldown < world.time)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/smoke = new()
		smoke.set_up(reagents, 5, 8,  get_turf(src))
		smoke.start()
		cooldown = world.time + 200

/obj/item/deployable_sprinkler
	name = "deployable sprinkler"
	desc = "A self-deploying sprinkler, just press the button to activate it."
	icon = 'icons/obj/device.dmi'
	icon_state = "ai-slipper0"
	var/deploying = FALSE

/obj/item/deployable_sprinkler/attack_self(mob/user)
	. = ..()
	var/turf/T = get_turf(loc)
	if(locate(/obj/machinery/power/plumbing/sprinkler) in T.contents)
		to_chat(user, "<span class='danger'>There is already a sprinkler here!</span>")
		return
	if(!deploying)
		to_chat(user, "You start planting \the [src]...")
		deploying = TRUE
		if(do_after(user, 50, target = src))
			to_chat(user, "You have activated \the [src].")
			new /obj/machinery/power/plumbing/sprinkler (get_turf(src))
			qdel(src)
		else
			deploying = FALSE

/obj/machinery/power/plumbing
	name = "pipe thing"
	icon = 'icons/obj/objects.dmi'
	icon_state = "water"
	anchored = FALSE
	var/volume = 100

/obj/machinery/power/plumbing/Initialize()
	create_reagents(volume, OPENCONTAINER | AMOUNT_VISIBLE)
	return ..()

/obj/machinery/power/plumbing/ComponentInitialize()
	AddComponent(/datum/component/plumbing/input)

/obj/machinery/power/plumbing/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/power/plumbing/default_unfasten_wrench(mob/user, obj/item/I, time = 5)
	..()
	var/datum/component/plumbing/P = GetComponent(/datum/component/plumbing)
	if(anchored)
		P.start()
		connect_to_network()
	else
		P.disable()
		disconnect_from_network()

/obj/machinery/power/plumbing/pipeinput
	name = "pipe input"
	icon = 'icons/obj/objects.dmi'
	icon_state = "fuel"
	volume = 100
	anchored = FALSE

/obj/machinery/power/plumbing/pipeoutput
	name = "pipe output"
	icon = 'icons/obj/objects.dmi'
	icon_state = "water"
	volume = 100
	anchored = FALSE

/obj/machinery/power/plumbing/pipeoutput/Initialize()
	. = ..()

/obj/machinery/power/plumbing/pipeoutput/ComponentInitialize()
	AddComponent(/datum/component/plumbing/output)