//Spatial gateway: A usually one-way rift to another location.
/obj/effect/clockwork/spatial_gateway
	name = "spatial gateway"
	desc = "A gently thrumming tear in reality."
	clockwork_desc = "A gateway in reality."
	icon_state = "spatial_gateway"
	density = 1
	light_range = 2
	light_power = 3
	light_color = "#6A4D2F"
	var/sender = TRUE //If this gateway is made for sending, not receiving
	var/both_ways = FALSE
	var/lifetime = 25 //How many deciseconds this portal will last
	var/uses = 1 //How many objects or mobs can go through the portal
	var/obj/effect/clockwork/spatial_gateway/linked_gateway //The gateway linked to this one
	var/timerid

/obj/effect/clockwork/spatial_gateway/New()
	..()
	update_light()
	addtimer(CALLBACK(src, .proc/check_setup), 1)

/obj/effect/clockwork/spatial_gateway/Destroy()
	deltimer(timerid)
	return ..()

/obj/effect/clockwork/spatial_gateway/proc/check_setup()
	if(!linked_gateway)
		qdel(src)
		return
	if(both_ways)
		clockwork_desc = "A gateway in reality. It can both send and receive objects."
	else
		clockwork_desc = "A gateway in reality. It can only [sender ? "send" : "receive"] objects."
	timerid = QDEL_IN(src, lifetime)

//set up a gateway with another gateway
/obj/effect/clockwork/spatial_gateway/proc/setup_gateway(obj/effect/clockwork/spatial_gateway/gatewayB, set_duration, set_uses, two_way)
	if(!gatewayB || !set_duration || !uses)
		return FALSE
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
	return TRUE

/obj/effect/clockwork/spatial_gateway/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='brass'>It has [uses] uses remaining.</span>")

/obj/effect/clockwork/spatial_gateway/attack_ghost(mob/user)
	if(linked_gateway)
		user.forceMove(get_turf(linked_gateway))
	..()

/obj/effect/clockwork/spatial_gateway/attack_hand(mob/living/user)
	if(!uses)
		return FALSE
	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.anchored || L.has_buckled_mobs())
			return FALSE
		user.visible_message("<span class='warning'>[user] shoves [L] into [src]!</span>", "<span class='danger'>You shove [L] into [src]!</span>")
		user.stop_pulling()
		pass_through_gateway(L)
		return TRUE
	if(!user.canUseTopic(src))
		return FALSE
	user.visible_message("<span class='warning'>[user] climbs through [src]!</span>", "<span class='danger'>You brace yourself and step through [src]...</span>")
	pass_through_gateway(user)
	return TRUE

/obj/effect/clockwork/spatial_gateway/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message("<span class='warning'>[user] dispels [src] with [I]!</span>", "<span class='danger'>You close [src] with [I]!</span>")
		qdel(linked_gateway)
		qdel(src)
		return TRUE
	if(istype(I, /obj/item/clockwork/slab))
		to_chat(user, "<span class='heavy_brass'>\"I don't think you want to drop your slab into that.\"\n\"If you really want to, try throwing it.\"</span>")
		return TRUE
	if(user.drop_item() && uses)
		user.visible_message("<span class='warning'>[user] drops [I] into [src]!</span>", "<span class='danger'>You drop [I] into [src]!</span>")
		pass_through_gateway(I, TRUE)
		return TRUE
	return ..()

/obj/effect/clockwork/spatial_gateway/ex_act(severity)
	if(severity == 1 && uses)
		uses = 0
		visible_message("<span class='warning'>[src] is disrupted!</span>")
		animate(src, alpha = 0, transform = matrix()*2, time = 10)
		deltimer(timerid)
		timerid = QDEL_IN(src, 10)
		linked_gateway.uses = 0
		linked_gateway.visible_message("<span class='warning'>[linked_gateway] is disrupted!</span>")
		animate(linked_gateway, alpha = 0, transform = matrix()*2, time = 10)
		deltimer(linked_gateway.timerid)
		linked_gateway.timerid = QDEL_IN(linked_gateway, 10)
		return TRUE
	return FALSE

/obj/effect/clockwork/spatial_gateway/Bumped(atom/A)
	..()
	if(A && !QDELETED(A))
		pass_through_gateway(A)

/obj/effect/clockwork/spatial_gateway/proc/pass_through_gateway(atom/movable/A, no_cost)
	if(!linked_gateway)
		qdel(src)
		return FALSE
	if(!sender)
		visible_message("<span class='warning'>[A] bounces off of [src]!</span>")
		return FALSE
	if(!uses)
		return FALSE
	if(isliving(A))
		var/mob/living/user = A
		to_chat(user, "<span class='warning'><b>You pass through [src] and appear elsewhere!</b></span>")
	linked_gateway.visible_message("<span class='warning'>A shape appears in [linked_gateway] before emerging!</span>")
	playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)
	playsound(linked_gateway, 'sound/effects/EMPulse.ogg', 50, 1)
	transform = matrix() * 1.5
	animate(src, transform = matrix() / 1.5, time = 10)
	linked_gateway.transform = matrix() * 1.5
	animate(linked_gateway, transform = matrix() / 1.5, time = 10)
	A.forceMove(get_turf(linked_gateway))
	if(!no_cost)
		uses = max(0, uses - 1)
		linked_gateway.uses = max(0, linked_gateway.uses - 1)
	addtimer(CALLBACK(src, .proc/check_uses), 10)
	return TRUE

/obj/effect/clockwork/spatial_gateway/proc/check_uses()
	if(!uses)
		qdel(src)
		qdel(linked_gateway)

//This proc creates and sets up a gateway from invoker input.
/atom/movable/proc/procure_gateway(mob/living/invoker, time_duration, gateway_uses, two_way)
	var/list/possible_targets = list()
	var/list/teleportnames = list()

	for(var/obj/structure/destructible/clockwork/powered/clockwork_obelisk/O in all_clockwork_objects)
		if(!O.Adjacent(invoker) && O != src && (O.z <= ZLEVEL_SPACEMAX) && O.anchored) //don't list obelisks that we're next to
			var/area/A = get_area(O)
			var/locname = initial(A.name)
			possible_targets[avoid_assoc_duplicate_keys("[locname] [O.name]", teleportnames)] = O

	for(var/mob/living/L in living_mob_list)
		if(!L.stat && is_servant_of_ratvar(L) && !L.Adjacent(invoker) && (L.z <= ZLEVEL_SPACEMAX)) //People right next to the invoker can't be portaled to, for obvious reasons
			possible_targets[avoid_assoc_duplicate_keys("[L.name] ([L.real_name])", teleportnames)] = L

	if(!possible_targets.len)
		to_chat(invoker, "<span class='warning'>There are no other eligible targets for a Spatial Gateway!</span>")
		return FALSE
	var/input_target_key = input(invoker, "Choose a target to form a rift to.", "Spatial Gateway") as null|anything in possible_targets
	var/atom/movable/target = possible_targets[input_target_key]
	if(!src || !input_target_key || !invoker || !invoker.canUseTopic(src, !issilicon(invoker)) || !is_servant_of_ratvar(invoker) || (istype(src, /obj/item) && invoker.get_active_held_item() != src) || !invoker.can_speak_vocal())
		return FALSE //if any of the involved things no longer exist, the invoker is stunned, too far away to use the object, or does not serve ratvar, or if the object is an item and not in the mob's active hand, fail
	if(!target) //if we have no target, but did have a key, let them retry
		to_chat(invoker, "<span class='warning'>That target no longer exists!</span>")
		return procure_gateway(invoker, time_duration, gateway_uses, two_way)
	if(isliving(target))
		var/mob/living/L = target
		if(!is_servant_of_ratvar(L))
			to_chat(invoker, "<span class='warning'>That target is no longer a Servant!</span>")
			return procure_gateway(invoker, time_duration, gateway_uses, two_way)
		if(L.stat != CONSCIOUS)
			to_chat(invoker, "<span class='warning'>That Servant is no longer conscious!</span>")
			return procure_gateway(invoker, time_duration, gateway_uses, two_way)
	var/istargetobelisk = istype(target, /obj/structure/destructible/clockwork/powered/clockwork_obelisk)
	var/issrcobelisk = istype(src, /obj/structure/destructible/clockwork/powered/clockwork_obelisk)
	if(issrcobelisk && !anchored)
		to_chat(invoker, "<span class='warning'>[src] is no longer secured!</span>")
		return FALSE
	if(istargetobelisk)
		if(!target.anchored)
			to_chat(invoker, "<span class='warning'>That [target.name] is no longer secured!</span>")
			return procure_gateway(invoker, time_duration, gateway_uses, two_way)
		var/obj/structure/destructible/clockwork/powered/clockwork_obelisk/CO = target
		var/efficiency = CO.get_efficiency_mod()
		gateway_uses = round(gateway_uses * (2 * efficiency), 1)
		time_duration = round(time_duration * (2 * efficiency), 1)
	invoker.visible_message("<span class='warning'>The air in front of [invoker] ripples before suddenly tearing open!</span>", \
	"<span class='brass'>With a word, you rip open a [two_way ? "two-way":"one-way"] rift to [input_target_key]. It will last for [time_duration / 10] seconds and has [gateway_uses] use[gateway_uses > 1 ? "s" : ""].</span>")
	var/obj/effect/clockwork/spatial_gateway/S1 = new(issrcobelisk ? get_turf(src) : get_step(get_turf(invoker), invoker.dir))
	var/obj/effect/clockwork/spatial_gateway/S2 = new(istargetobelisk ? get_turf(target) : get_step(get_turf(target), target.dir))

	//Set up the portals now that they've spawned
	S1.setup_gateway(S2, time_duration, gateway_uses, two_way)
	S2.visible_message("<span class='warning'>The air in front of [target] ripples before suddenly tearing open!</span>")
	return TRUE
