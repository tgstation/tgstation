/obj/item/weapon/syndieborg_teleport
	name = "Syndicate Cyborg Teleporter"
	desc = "A single-use teleporter used to deploy a Syndicate Cyborg on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/used = 0
	var/TC_cost = 25

/obj/item/weapon/syndieborg_teleport/attack_self(mob/user as mob)
	if(used)
		user << "The teleporter is out of power."
		return
	var/list/borg_candicates = get_candidates(BE_OPERATIVE)
	if(borg_candicates.len > 0)
		used = 1
		var/client/C = pick(borg_candicates)
		var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
		S.set_up(4, 1, src)
		S.start()
		var/mob/living/silicon/robot/R = new /mob/living/silicon/robot/syndicate(loc)
		R.key = C.key
		ticker.mode.traitors += R.mind
		R.mind.special_role = "syndicate"
	else
		user << "<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>"
