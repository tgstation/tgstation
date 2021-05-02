/obj/effect/proc_holder/spell/aimed/lightningbolt/lesser
	name = "Lesser Lightning Bolt"
	desc = "Fire a lightning bolt at your foes! It will jump between targets, but can't knock them down."
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
	invocation = "LIGHTNING FORM!!"
	clear_invocation = TRUE
	invocation_type = INVOCATION_SHOUT
	range = 7
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
