/obj/effect/clockwork/reebe_exit
	name = "exit gateway"
	desc = "A gently thrumming tear in reality. Looks like you could use this to get out of here..."
	clockwork_desc = "A gateway in reality. It's an exit to any stationary rifts."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_active"
	pixel_x = -32
	pixel_y = -32
	layer = ABOVE_SPACE_LAYER
	light_range = 2
	light_power = 4
	light_color = "#6A4D2F"

/obj/effect/clockwork/reebe_exit/Initialize()
	. = ..()
	transform *= 2.3

/obj/effect/clockwork/reebe_exit/attack_hand(mob/living/user)
	if(!GLOB.ark_of_the_clockwork_justicar.active)
		return
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

/obj/effect/clockwork/reebe_exit/attackby(obj/item/I, mob/living/user, params)
	if(GLOB.ark_of_the_clockwork_justicar.active && user.drop_item())
		user.visible_message("<span class='warning'>[user] drops [I] into [src]!</span>", "<span class='danger'>You drop [I] into [src]!</span>")
		pass_through_gateway(I)
		return TRUE
	return ..()

/obj/effect/clockwork/reebe_exit/Crossed(atom/movable/AM)
	..()
	if(GLOB.ark_of_the_clockwork_justicar.active && !QDELETED(AM))
		pass_through_gateway(AM, FALSE)

/obj/effect/clockwork/reebe_exit/CollidedWith(atom/movable/AM)
	..()
	if(GLOB.ark_of_the_clockwork_justicar.active && !QDELETED(AM))
		pass_through_gateway(AM, FALSE)

/obj/effect/clockwork/reebe_exit/proc/pass_through_gateway(atom/movable/A)
	var/turf/T = get_turf(pick(GLOB.generic_event_spawns))
	quick_spatial_gate(A.loc, T, A)

/obj/effect/clockwork/reebe_exit/invisible
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "nothing"
	pixel_x = 0
	pixel_y = 0
	light_range = 0