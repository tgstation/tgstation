
/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 60
	armor = list(MELEE = 10, BULLET = 0, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 60, ACID = 60)
	key_type = /obj/item/key/security
	integrity_failure = 0.5

	///This stores a banana that, when used on the secway, prevents the vehicle from moving until it is removed.
	var/obj/item/food/grown/banana/eddie_murphy

/obj/vehicle/ridden/secway/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/secway)

/obj/vehicle/ridden/secway/atom_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/secway/process(delta_time)
	if(atom_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(DT_PROB(10, delta_time))
		return
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, location = src)
	smoke.start()

/obj/vehicle/ridden/secway/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(atom_integrity >= max_integrity)
		to_chat(user, span_notice("It is fully repaired already!"))
		return
	if(!I.use_tool(src, user, 0, volume = 50, amount = 1))
		return
	user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to \the [src]."))
	atom_integrity += min(10, max_integrity-atom_integrity)
	if(atom_integrity >= max_integrity)
		to_chat(user, span_notice("It looks to be fully repaired now."))
		STOP_PROCESSING(SSobj, src)

/obj/vehicle/ridden/secway/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W, /obj/item/food/grown/banana))
		return ..()
	// ignore the occupants because they're presumably too distracted to notice the guy stuffing fruit into their vehicle's exhaust. do segways have exhausts? they do now!
	user.visible_message(span_warning("[user] begins stuffing [W] into [src]'s tailpipe."), span_warning("You begin stuffing [W] into [src]'s tailpipe..."), ignored_mobs = occupants)
	if(!do_after(user, 3 SECONDS, src))
		return TRUE
	if(user.transferItemToLoc(W, src))
		user.visible_message(span_warning("[user] stuffs [W] into [src]'s tailpipe."), span_warning("You stuff [W] into [src]'s tailpipe."), ignored_mobs = occupants)
		eddie_murphy = W
	return TRUE

/obj/vehicle/ridden/secway/attack_hand(mob/living/user, list/modifiers)
	if(!eddie_murphy)
		return ..()
	user.visible_message(span_warning("[user] begins cleaning [eddie_murphy] out of [src]."), span_warning("You begin cleaning [eddie_murphy] out of [src]..."))
	if(!do_after(user, 60, target = src))
		return ..()
	user.visible_message(span_warning("[user] cleans [eddie_murphy] out of [src]."), span_warning("You manage to get [eddie_murphy] out of [src]."))
	eddie_murphy.forceMove(drop_location())
	eddie_murphy = null

/obj/vehicle/ridden/secway/examine(mob/user)
	. = ..()
	if(eddie_murphy)
		. += span_warning("Something appears to be stuck in its exhaust...")

/obj/vehicle/ridden/secway/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/secway/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

//bullets will have a 60% chance to hit any riders
/obj/vehicle/ridden/secway/bullet_act(obj/projectile/P)
	if(!buckled_mobs || prob(40))
		return ..()
	for(var/mob/rider as anything in buckled_mobs)
		rider.bullet_act(P)
	return TRUE
