//These spawn across the station when the Ark activates. Anyone can walk through one to teleport to Reebe.
/obj/effect/clockwork/reebe_rift
	name = "celestial rift"
	desc = "A stable bluespace rip. You're not sure it where leads."
	clockwork_desc = "A rift to Reebe. Because it's linked to the Ark, it can't be closed."
	icon_state = "spatial_gateway"
	resistance_flags = INDESTRUCTIBLE
	density = TRUE
	light_range = 2
	light_power = 3
	light_color = "#6A4D2F"

/obj/effect/clockwork/reebe_rift/Initialize()
	. = ..()
	visible_message("<span class='warning'>The air above [loc] shimmers and pops as a [name] forms there!</span>")
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			if(get_dist(src, M) >= 7)
				M.playsound_local(src, 'sound/magic/blink.ogg', 10, FALSE, falloff = 10)
			else
				M.playsound_local(src, 'sound/magic/blink.ogg', 50, FALSE)

/obj/effect/clockwork/reebe_rift/attack_hand(mob/living/user)
	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.anchored || L.has_buckled_mobs())
			return FALSE
		user.visible_message("<span class='warning'>[user] shoves [L] into [src]!</span>", "<span class='danger'>You shove [L] into [src]!</span>")
		user.stop_pulling()
		pass_through_gateway(L)
		return TRUE
	user.visible_message("<span class='warning'>[user] climbs through [src]!</span>", "<span class='danger'>You brace yourself and step through [src]...</span>")
	pass_through_gateway(user)
	return TRUE
	. = ..()

/obj/effect/clockwork/reebe_rift/attackby(obj/item/I, mob/living/user, params)
	if(user.drop_item())
		user.visible_message("<span class='warning'>[user] drops [I] into [src]!</span>", "<span class='danger'>You drop [I] into [src]!</span>")
		pass_through_gateway(I)
		return TRUE
	return ..()

/obj/effect/clockwork/reebe_rift/CollidedWith(atom/movable/AM)
	..()
	if(!QDELETED(AM))
		pass_through_gateway(AM, FALSE)

/obj/effect/clockwork/reebe_rift/proc/pass_through_gateway(atom/movable/A)
	quick_spatial_gate(loc, pick(is_servant_of_ratvar(A) ? GLOB.servant_spawns : GLOB.reebe_spawns), A)