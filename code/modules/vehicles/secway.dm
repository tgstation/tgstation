
/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 60
	armor = list(MELEE = 10, BULLET = 0, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 60, ACID = 60)
	key_type = /obj/item/key/security
	integrity_failure = 0.5



	///This stores a banana that, when used on the secway, prevents the vehicle from moving until it is removed.
	var/obj/item/reagent_containers/food/snacks/grown/banana/eddie_murphy
	///When jammed with a banana, the secway will make a stalling sound. This stores the last time it made a sound to prevent spam.
	var/stall_cooldown

/obj/vehicle/ridden/secway/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1.75
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))

/obj/vehicle/ridden/secway/obj_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/secway/process(delta_time)
	if(obj_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(DT_PROB(10, delta_time))
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()

/obj/vehicle/ridden/secway/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(obj_integrity < max_integrity)
			if(W.use_tool(src, user, 0, volume = 50, amount = 1))
				user.visible_message("<span class='notice'>[user] repairs some damage to [name].</span>", "<span class='notice'>You repair some damage to \the [src].</span>")
				obj_integrity += min(10, max_integrity-obj_integrity)
				if(obj_integrity == max_integrity)
					to_chat(user, "<span class='notice'>It looks to be fully repaired now.</span>")
		return TRUE

	if(istype(W, /obj/item/reagent_containers/food/snacks/grown/banana))
		// ignore the occupants because they're presumably too distracted to notice the guy stuffing fruit into their vehicle's exhaust. do segways have exhausts? they do now!
		user.visible_message("<span class='warning'>[user] begins stuffing [W] into [src]'s tailpipe.</span>", "<span class='warning'>You begin stuffing [W] into [src]'s tailpipe...</span>", ignored_mobs = occupants)
		if(do_after(user, 3 SECONDS, src))
			if(user.transferItemToLoc(W, src))
				user.visible_message("<span class='warning'>[user] stuffs [W] into [src]'s tailpipe.</span>", "<span class='warning'>You stuff [W] into [src]'s tailpipe.</span>", ignored_mobs = occupants)
				eddie_murphy = W
		return TRUE
	return ..()

/obj/vehicle/ridden/secway/attack_hand(mob/living/user)
	if(eddie_murphy)                                                       // v lol
		user.visible_message("<span class='warning'>[user] begins cleaning [eddie_murphy] out of [src].</span>", "<span class='warning'>You begin cleaning [eddie_murphy] out of [src]...</span>")
		if(do_after(user, 60, target = src))
			user.visible_message("<span class='warning'>[user] cleans [eddie_murphy] out of [src].</span>", "<span class='warning'>You manage to get [eddie_murphy] out of [src].</span>")
			eddie_murphy.forceMove(drop_location())
			eddie_murphy = null
		return
	return ..()

/obj/vehicle/ridden/secway/driver_move(mob/living/user, direction)
	if(is_key(inserted_key) && eddie_murphy)
		if(stall_cooldown + 10 < world.time)
			visible_message("<span class='warning'>[src] sputters and refuses to move!</span>")
			playsound(src, 'sound/effects/stall.ogg', 70)
			stall_cooldown = world.time
		return FALSE
	return ..()

/obj/vehicle/ridden/secway/examine(mob/user)
	. = ..()

	if(eddie_murphy)
		. += "<span class='warning'>Something appears to be stuck in its exhaust...</span>"

/obj/vehicle/ridden/secway/obj_destruction()
	explosion(src, -1, 0, 2, 4, flame_range = 3)
	return ..()

/obj/vehicle/ridden/secway/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/vehicle/ridden/secway/bullet_act(obj/projectile/P)
	if(prob(60) && buckled_mobs)
		for(var/mob/M in buckled_mobs)
			M.bullet_act(P)
		return TRUE
	return ..()
