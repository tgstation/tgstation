/obj/machinery/plumbing/sprinkler
	name = "sprinkler"
	desc = "An automated sprinkler capable of detecting fire and spraying coolant."
	icon_state = "sprinkler"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	plane = FLOOR_PLANE
	max_integrity = 100
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 30)
	req_access = list(ACCESS_ENGINE)
	anchored = FALSE
	density = FALSE
	active_power_usage = 70
	deployable = /obj/item/deployable/sprinkler
	volume = 10
	/// it holds the time after the sprinkler can dispense again
	var/cooldown = 0

/obj/machinery/plumbing/sprinkler/Initialize()
	. = ..()
	create_reagents(volume, AMOUNT_VISIBLE)
	AddComponent(/datum/component/plumbing/output)

/obj/machinery/plumbing/sprinkler/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/machinery/plumbing/sprinkler/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[dirty? "It's dirty" : "It's clean"].</span>"

/obj/machinery/plumbing/sprinkler/default_unfasten_wrench(mob/user, obj/item/I, time = 5)
	. = ..()
	if(anchored)
		START_PROCESSING(SSobj, src)
		return
	STOP_PROCESSING(SSobj, src)

/obj/machinery/plumbing/sprinkler/process()
	var/turf/T = get_turf(loc)
	if(find_sparks(T))
		dispense()
	if(prob(10) && find_dirt(T))
		dirty = TRUE
		STOP_PROCESSING(SSobj, src)
		add_overlay("[icon_state]_dirty")

/obj/machinery/plumbing/sprinkler/interact(mob/user)
	. = ..()
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	dispense(user)

///locates sparks in the turf returns true if found
/obj/machinery/plumbing/sprinkler/proc/find_sparks(turf/T)
	var/obj/effect/particle_effect/sparks/S = locate() in T.contents
	if(S)
		return TRUE

/obj/machinery/plumbing/sprinkler/fire_act()
	. = ..()
	dispense()

///dispenses 10u of the chemicals inside as not blinding smoke and logs it
/obj/machinery/plumbing/sprinkler/proc/dispense(mob/user)
	if(cooldown < world.time && reagents.total_volume && powered() && !dirty && anchored)
		to_chat(user, "<span class='notice'>You have actived the [src].</span>")
		playsound(src, 'sound/machines/beep.ogg', 100, 1)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/smoke = new()
		smoke.set_up(reagents, 5, 8,  get_turf(src))
		smoke.start()
		cooldown = world.time + 200
		log_game("A sprinkler has been activated in [AREACOORD(src)] [user? "by [user]." : "."]")
		message_admins("A sprinkler has been activated in [AREACOORD(src)] [user? "by [user]." : "."]")

/obj/item/deployable/sprinkler
	name = "deployable sprinkler"
	desc = "A self-deploying sprinkler, just press the button to activate it."
	icon_state = "sprinkler_d"
	result = /obj/machinery/plumbing/sprinkler