/obj/item/weapon/cargo_exporter
	name = "shipping exporter remote"
	desc = "Hit objects with this to export them."
	icon = 'goon/icons/obj/cargo_pad.dmi'
	icon_state = "exporter"
	var/works_from_distance = 0

/obj/item/weapon/cargo_exporter/afterattack(atom/movable/T, mob/living/carbon/human/user, flag, params)
	if(flag)
		export(T, user)
		return
	else
		if(works_from_distance)
			if(istype(T))
				user.Beam(T,icon_state="cash_beam",icon='icons/effects/effects.dmi',time=5)
				export(T, user)
				playsound(src, 'sound/effects/sellaporter.wav', 50, 0)
	return

/obj/item/weapon/cargo_exporter/proc/export(atom/movable/O, mob/user)
	var/datum/shipping/S = SSshuttle.has_shipping_datum(O)
	if(S)
		user << "You export [O] for [S.value] credits."
		user.visible_message("[user] exports [O] to the space markets!")
		S.ship_obj(O)
		qdel(O)
	else
		user << "There is no market for [O]."


/obj/item/weapon/cargo_exporter/sellaporter
	name = "sell-a-porter"
	desc = "Using the power of CASH BEAM TECHNOLOGY you can now export goods from a distance with the Sell-A-Porter(tm)!"
	icon_state = "sell-a-porter"
	works_from_distance = 1
