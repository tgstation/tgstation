/datum/action/item_action/ninjanet
	name = "Energy Net (40E)"
	desc = "Captures a fallen opponent in a net of energy."
	button_icon_state = "energynet"
	icon_icon = 'icons/effects/effects.dmi'

/**
 * Proc called to ensnare a person in a energy net.
 *
 * Used to ensnare a target in an energy net, preventing them from moving until the net is broken.
 * Costs 40E, which is 40% of the default battery's max charge.  Intended as a means of reliably locking down an opponent when ninja stars won't suffice.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjanet()
	var/mob/living/carbon/human/ninja = affecting
	var/mob/living/net_target = input("Select who to capture:","Capture who?",null) as null|mob in sortNames(oview(ninja))

	if(QDELETED(net_target)||!(net_target in oview(ninja)))
		return

	if(locate(/obj/structure/energy_net) in get_turf(net_target))//Check if they are already being affected by an energy net.
		to_chat(ninja, "<span class='warning'>[net_target.p_they(TRUE)] are already trapped inside an energy net!</span>")
		return
	for(var/turf/between_turf in getline(get_turf(ninja), get_turf(net_target)))
		if(between_turf.density)//Don't want them shooting nets through walls. It's kind of cheesy.
			to_chat(ninja, "<span class='warning'>You may not use an energy net through solid obstacles!</span>")
			return
	if(!ninjacost(400,N_STEALTH_CANCEL))
		ninja.Beam(net_target, "n_beam", time = 15)
		ninja.say("Get over here!", forced = "ninja net")
		var/obj/structure/energy_net/net = new /obj/structure/energy_net(net_target.drop_location())
		net.affecting = net_target
		ninja.visible_message("<span class='danger'>[ninja] caught [net_target] with an energy net!</span>","<span class='notice'>You caught [net_target] with an energy net!</span>")

		if(net_target.buckled)
			net_target.buckled.unbuckle_mob(affecting,TRUE)
		net.buckle_mob(net_target, TRUE) //No moving for you!
