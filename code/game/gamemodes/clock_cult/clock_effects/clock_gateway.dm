//Spatial gateway: A usually one-way rift to another location.
/obj/effect/clockwork/spatial_gateway
	name = "spatial gateway"
	desc = "A gently thrumming tear in reality."
	clockwork_desc = "A gateway in reality."
	icon_state = "spatial_gateway"
	density = 1
	var/sender = TRUE //If this gateway is made for sending, not receiving
	var/both_ways = FALSE
	var/lifetime = 25 //How many deciseconds this portal will last
	var/uses = 1 //How many objects or mobs can go through the portal
	var/obj/effect/clockwork/spatial_gateway/linked_gateway //The gateway linked to this one

/obj/effect/clockwork/spatial_gateway/New()
	..()
	spawn(1)
		if(!linked_gateway)
			qdel(src)
			return 0
		if(both_ways)
			clockwork_desc = "A gateway in reality. It can both send and receive objects."
		else
			clockwork_desc = "A gateway in reality. It can only [sender ? "send" : "receive"] objects."
		QDEL_IN(src, lifetime)

//set up a gateway with another gateway
/obj/effect/clockwork/spatial_gateway/proc/setup_gateway(obj/effect/clockwork/spatial_gateway/gatewayB, set_duration, set_uses, two_way)
	if(!gatewayB || !set_duration || !uses)
		return 0
	linked_gateway = gatewayB
	gatewayB.linked_gateway = src
	if(two_way)
		both_ways = TRUE
		gatewayB.both_ways = TRUE
	else
		sender = TRUE
		gatewayB.sender = FALSE
		gatewayB.density = FALSE
	lifetime = set_duration
	gatewayB.lifetime = set_duration
	uses = set_uses
	gatewayB.uses = set_uses
	return 1

/obj/effect/clockwork/spatial_gateway/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='brass'>It has [uses] uses remaining.</span>"

/obj/effect/clockwork/spatial_gateway/attack_ghost(mob/user)
	if(linked_gateway)
		user.forceMove(get_turf(linked_gateway))
	..()

/obj/effect/clockwork/spatial_gateway/attack_hand(mob/living/user)
	if(!uses)
		return 0
	if(user.pulling && user.a_intent == "grab" && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.anchored || L.has_buckled_mobs())
			return 0
		user.visible_message("<span class='warning'>[user] shoves [L] into [src]!</span>", "<span class='danger'>You shove [L] into [src]!</span>")
		user.stop_pulling()
		pass_through_gateway(L)
		return 1
	if(!user.canUseTopic(src))
		return 0
	user.visible_message("<span class='warning'>[user] climbs through [src]!</span>", "<span class='danger'>You brace yourself and step through [src]...</span>")
	pass_through_gateway(user)
	return 1

/obj/effect/clockwork/spatial_gateway/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message("<span class='warning'>[user] dispels [src] with [I]!</span>", "<span class='danger'>You close [src] with [I]!</span>")
		qdel(linked_gateway)
		qdel(src)
		return 1
	if(istype(I, /obj/item/clockwork/slab))
		user << "<span class='heavy_brass'>\"I don't think you want to drop your slab into that\".\n\"If you really want to, try throwing it.\"</span>"
		return 1
	if(user.drop_item() && uses)
		user.visible_message("<span class='warning'>[user] drops [I] into [src]!</span>", "<span class='danger'>You drop [I] into [src]!</span>")
		pass_through_gateway(I)
	..()

/obj/effect/clockwork/spatial_gateway/ex_act(severity)
	if(severity == 1 && uses)
		uses = 0
		visible_message("<span class='warning'>[src] is disrupted!</span>")
		animate(src, alpha = 0, transform = matrix()*2, time = 10)
		QDEL_IN(src, 10)
		linked_gateway.uses = 0
		linked_gateway.visible_message("<span class='warning'>[linked_gateway] is disrupted!</span>")
		animate(linked_gateway, alpha = 0, transform = matrix()*2, time = 10)
		QDEL_IN(linked_gateway, 10)
		return TRUE
	return FALSE

/obj/effect/clockwork/spatial_gateway/Bumped(atom/A)
	..()
	if(isliving(A) || istype(A, /obj/item))
		pass_through_gateway(A)

/obj/effect/clockwork/spatial_gateway/proc/pass_through_gateway(atom/movable/A)
	if(!linked_gateway)
		qdel(src)
		return 0
	if(!sender)
		visible_message("<span class='warning'>[A] bounces off of [src]!</span>")
		return 0
	if(!uses)
		return 0
	if(isliving(A))
		var/mob/living/user = A
		user << "<span class='warning'><b>You pass through [src] and appear elsewhere!</b></span>"
	linked_gateway.visible_message("<span class='warning'>A shape appears in [linked_gateway] before emerging!</span>")
	playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)
	playsound(linked_gateway, 'sound/effects/EMPulse.ogg', 50, 1)
	transform = matrix() * 1.5
	animate(src, transform = matrix() / 1.5, time = 10)
	linked_gateway.transform = matrix() * 1.5
	animate(linked_gateway, transform = matrix() / 1.5, time = 10)
	A.forceMove(get_turf(linked_gateway))
	uses = max(0, uses - 1)
	linked_gateway.uses = max(0, linked_gateway.uses - 1)
	spawn(10)
		if(!uses)
			qdel(src)
			qdel(linked_gateway)
	return 1
