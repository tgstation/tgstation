/obj/effect/proc_holder/spell/aimed/lightningbolt/lesser
	name = "Lesser Lightning Bolt"
	desc = "Fire a lightning bolt at your foes! It will jump between targets, damaging them."
	charge_max = 10 SECONDS
	invocation = "LET THE POWER FLOW!!"
	clear_invocation = TRUE
	invocation_type = INVOCATION_SHOUT
	cooldown_min = 20
	projectile_var_overrides = list("zap_range" = 10, "zap_power" = 10000, "zap_flags" = ZAP_MOB_DAMAGE | ZAP_MOB_STUN)
	active_msg = "You energize your hands with arcane lightning!"
	deactive_msg = "You let the energy flow out of your hands back into yourself..."
	projectile_type = /obj/projectile/magic/aoe/lightning

/obj/effect/proc_holder/spell/pointed/lightning_jaunt
	name = "Lightning Jaunt"
	desc = "Transform yourself into lightning and use this form to teleport to any location in your view."
	charge_max = 5 SECONDS
	clothes_req = FALSE
	invocation = "SHOCK!!"
	clear_invocation = TRUE
	invocation_type = INVOCATION_SHOUT
	action_icon_state = "ian_lightning"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'

/obj/effect/proc_holder/spell/pointed/lightning_jaunt/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE

	if(!can_target(targets[1], user))
		return FALSE

	var/atom/targeted = targets[1]
	var/turf/teleport_to = get_turf(targeted)
	var/turf/initial_turf = get_turf(user)

	playsound(teleport_to, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	initial_turf.Beam(teleport_to, icon_state="lightning[rand(1,12)]", time = 5)
	user.forceMove(teleport_to)
	tesla_zap(user, 3, 1000, ZAP_DEFAULT_FLAGS)

/obj/effect/proc_holder/spell/self/lightning_form
	name = "Lightning Form"
	desc = "Turn yourself into a ball of pure energy for a brief moment! When you are in space, this form won't degrade as much so you would be able to hold onto it for much longer."
	charge_max = 20 SECONDS
	clothes_req = FALSE
	invocation = "LIGHTNING FORM!!"
	clear_invocation = TRUE
	invocation_type = INVOCATION_SHOUT

	action_icon_state = "lightningball"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'

/obj/effect/proc_holder/spell/self/lightning_form/cast(list/targets, mob/living/user = usr)
	if(istype(user.loc, /obj/effect/ianiser_ball))
		var/obj/effect/ianiser_ball/ball = user.loc
		qdel(ball)
		return FALSE //Refunds
	var/obj/effect/ianiser_ball/ball = new(get_turf(user))
	user.forceMove(ball)
	ball.ianiser = user
	user.status_flags |= GODMODE

/obj/effect/ianiser_ball //I wanted to make it a rod but there are too much differences.
	name = "lightning ball"
	desc = "A ball of pure energy and fur."
	icon = 'icons/obj/guns/projectiles.dmi'
	icon_state = "lightningball"

	move_force = INFINITY
	move_resist = INFINITY
	pull_force = INFINITY
	density = TRUE
	anchored = TRUE

	var/mob/living/ianiser
	var/time_left = 1.5 SECONDS

/obj/effect/ianiser_ball/Bump(atom/crashed_into)
	. = ..()
	playsound(src, 'sound/effects/bang.ogg', 100, TRUE)
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	if(ianiser)
		shake_camera(ianiser, 2, 3)
		ianiser.forceMove(get_turf(src))
		ianiser.visible_message("<span class='boldwarning'>[src] transforms into [ianiser] as it crashes into [crashed_into]!</span>", "<span class='boldwarning'>You are suddenly knocked out of your energy form as you crash into [crashed_into]!</span>")
		ianiser.Paralyze(6 SECONDS)
		ianiser.adjustBruteLoss(25)
	qdel(src)

/obj/effect/ianiser_ball/singularity_act()
	return

/obj/effect/ianiser_ball/singularity_pull()
	return

/obj/effect/ianiser_ball/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/ianiser_ball/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(ianiser)
		ianiser.forceMove(get_turf(src))
		ianiser.status_flags &= ~GODMODE
	. = ..()

/obj/effect/ianiser_ball/process(delta_time)
	var/turf/open/turf = get_turf(src)
	if(!istype(turf))
		return

	var/datum/gas_mixture/air = turf.air
	var/pressure = air.return_pressure()
	if(pressure > 20)
		time_left -= delta_time

	if(time_left <= 0)
		qdel(src)

	walk_towards(src, get_step(src, dir), 1)

/obj/effect/ianiser_ball/relaymove(mob/living/user, direction)
	if(user != ianiser)
		return ..()

	dir = direction
	. = ..()
