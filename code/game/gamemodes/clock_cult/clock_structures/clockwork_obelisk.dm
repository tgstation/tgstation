//Clockwork Obelisk: Can broadcast a message at a small power cost or outright open a spatial gateway at a massive power cost.
/obj/structure/destructible/clockwork/powered/clockwork_obelisk
	name = "clockwork obelisk"
	desc = "A large brass obelisk hanging in midair."
	clockwork_desc = "A powerful obelisk that can send a message to all servants or open a gateway to a target servant or clockwork obelisk."
	icon_state = "obelisk_inactive"
	active_icon = "obelisk"
	inactive_icon = "obelisk_inactive"
	unanchored_icon = "obelisk_unwrenched"
	construction_value = 20
	max_integrity = 150
	obj_integrity = 150
	break_message = "<span class='warning'>The obelisk falls to the ground, undamaged!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/small = 4, \
	/obj/item/clockwork/alloy_shards/medium = 2, \
	/obj/item/clockwork/component/hierophant_ansible/obelisk = 1)
	var/hierophant_cost = MIN_CLOCKCULT_POWER //how much it costs to broadcast with large text
	var/gateway_cost = 2000 //how much it costs to open a gateway

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/New()
	..()
	toggle(1)

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='nzcrentr_small'>It requires <b>[hierophant_cost]W</b> to broadcast over the Hierophant Network, and <b>[gateway_cost]W</b> to open a Spatial Gateway.</span>")

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is currently sustaining a gateway!</span>")
		return FAILED_UNFASTEN
	return ..()

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/forced_disable(bad_effects)
	var/affected = 0
	for(var/obj/effect/clockwork/spatial_gateway/SG in loc)
		SG.ex_act(1)
		affected++
	if(bad_effects)
		affected += try_use_power(MIN_CLOCKCULT_POWER*4)
	return affected

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user) || total_accessable_power() < hierophant_cost || !anchored)
		to_chat(user, "<span class='warning'>You place your hand on the obelisk, but it doesn't react.</span>")
		return
	var/choice = alert(user,"You place your hand on the obelisk...",,"Hierophant Broadcast","Spatial Gateway","Cancel")
	switch(choice)
		if("Hierophant Broadcast")
			if(active)
				to_chat(user, "<span class='warning'>The obelisk is sustaining a gateway and cannot broadcast!</span>")
				return
			if(!user.can_speak_vocal())
				to_chat(user, "<span class='warning'>You cannot speak through the obelisk!</span>")
				return
			var/input = stripped_input(usr, "Please choose a message to send over the Hierophant Network.", "Hierophant Broadcast", "")
			if(!is_servant_of_ratvar(user) || !input || !user.canUseTopic(src, !issilicon(user)))
				return
			if(active)
				to_chat(user, "<span class='warning'>The obelisk is sustaining a gateway and cannot broadcast!</span>")
				return
			if(!try_use_power(hierophant_cost))
				to_chat(user, "<span class='warning'>The obelisk lacks the power to broadcast!</span>")
				return
			if(!user.can_speak_vocal())
				to_chat(user, "<span class='warning'>You cannot speak through the obelisk!</span>")
				return
			clockwork_say(user, text2ratvar("Hierophant Broadcast, activate! [html_decode(input)]"))
			titled_hierophant_message(user, input, "big_brass", "large_brass")
		if("Spatial Gateway")
			if(active)
				to_chat(user, "<span class='warning'>The obelisk is already sustaining a gateway!</span>")
				return
			if(!try_use_power(gateway_cost))
				to_chat(user, "<span class='warning'>The obelisk lacks the power to open a gateway!</span>")
				return
			if(!user.can_speak_vocal())
				to_chat(user, "<span class='warning'>You need to be able to speak to open a gateway!</span>")
				return
			if(procure_gateway(user, round(100 * get_efficiency_mod(), 1), round(5 * get_efficiency_mod(), 1), 1) && !active)
				clockwork_say(user, text2ratvar("Spatial Gateway, activate!"))
			else
				return_power(gateway_cost)

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/process()
	if(!anchored)
		return
	if(locate(/obj/effect/clockwork/spatial_gateway) in loc)
		icon_state = active_icon
		density = 0
		active = TRUE
	else
		icon_state = inactive_icon
		density = 1
		active = FALSE
