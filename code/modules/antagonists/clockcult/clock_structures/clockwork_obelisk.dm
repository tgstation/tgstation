//chumbiswork Obelisk: Can broadcast a message at a small power cost or outright open a spatial gateway at a massive power cost.
/obj/structure/destructible/chumbiswork/powered/chumbiswork_obelisk
	name = "chumbiswork obelisk"
	desc = "A large brass obelisk hanging in midair."
	chumbiswork_desc = "A powerful obelisk that can send a message to all servants or open a gateway to a target servant or chumbiswork obelisk."
	icon_state = "obelisk_inactive"
	active_icon = "obelisk"
	inactive_icon = "obelisk_inactive"
	unanchored_icon = "obelisk_unwrenched"
	construction_value = 20
	max_integrity = 150
	break_message = "<span class='warning'>The obelisk falls to the ground, undamaged!</span>"
	debris = list(/obj/item/chumbiswork/alloy_shards/small = 4, \
	/obj/item/chumbiswork/alloy_shards/medium = 2, \
	/obj/item/chumbiswork/component/hierophant_ansible/obelisk = 1)
	var/hierophant_cost = MIN_chumbisCULT_POWER //how much it costs to broadcast with large text
	var/gateway_cost = 2000 //how much it costs to open a gateway

/obj/structure/destructible/chumbiswork/powered/chumbiswork_obelisk/Initialize()
	. = ..()
	toggle(1)

/obj/structure/destructible/chumbiswork/powered/chumbiswork_obelisk/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='nzcrentr_small'>It requires <b>[DisplayPower(hierophant_cost)]</b> to broadcast over the Hierophant Network, and <b>[DisplayPower(gateway_cost)]</b> to open a Spatial Gateway.</span>")

/obj/structure/destructible/chumbiswork/powered/chumbiswork_obelisk/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is currently sustaining a gateway!</span>")
		return FAILED_UNFASTEN
	return ..()

/obj/structure/destructible/chumbiswork/powered/chumbiswork_obelisk/forced_disable(bad_effects)
	var/affected = 0
	for(var/obj/effect/chumbiswork/spatial_gateway/SG in loc)
		SG.ex_act(EXPLODE_DEVASTATE)
		affected++
	if(bad_effects)
		affected += try_use_power(MIN_chumbisCULT_POWER*4)
	return affected

/obj/structure/destructible/chumbiswork/powered/chumbiswork_obelisk/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user) || !can_access_chumbiswork_power(src, hierophant_cost) || !anchored)
		to_chat(user, "<span class='warning'>You place your hand on [src], but it doesn't react.</span>")
		return
	var/choice = alert(user,"You place your hand on [src]...",,"Hierophant Broadcast","Spatial Gateway","Cancel")
	switch(choice)
		if("Hierophant Broadcast")
			if(active)
				to_chat(user, "<span class='warning'>[src] is sustaining a gateway and cannot broadcast!</span>")
				return
			if(!user.can_speak_vocal())
				to_chat(user, "<span class='warning'>You cannot speak through [src]!</span>")
				return
			var/input = stripped_input(usr, "Please choose a message to send over the Hierophant Network.", "Hierophant Broadcast", "")
			if(!is_servant_of_ratvar(user) || !input || !user.canUseTopic(src, !issilicon(user)))
				return
			if(!anchored)
				to_chat(user, "<span class='warning'>[src] is no longer secured!</span>")
				return FALSE
			if(active)
				to_chat(user, "<span class='warning'>[src] is sustaining a gateway and cannot broadcast!</span>")
				return
			if(!user.can_speak_vocal())
				to_chat(user, "<span class='warning'>You cannot speak through [src]!</span>")
				return
			if(!try_use_power(hierophant_cost))
				to_chat(user, "<span class='warning'>[src] lacks the power to broadcast!</span>")
				return
			chumbiswork_say(user, text2ratvar("Hierophant Broadcast, activate! [html_decode(input)]"))
			titled_hierophant_message(user, input, "big_brass", "large_brass")
		if("Spatial Gateway")
			if(active)
				to_chat(user, "<span class='warning'>[src] is already sustaining a gateway!</span>")
				return
			if(!user.can_speak_vocal())
				to_chat(user, "<span class='warning'>You need to be able to speak to open a gateway!</span>")
				return
			if(!try_use_power(gateway_cost))
				to_chat(user, "<span class='warning'>[src] lacks the power to open a gateway!</span>")
				return
			if(procure_gateway(user, round(100 * get_efficiency_mod(), 1), round(5 * get_efficiency_mod(), 1), 1))
				process()
				if(!active) //we won't be active if nobody has sent a gateway to us
					active = TRUE
					chumbiswork_say(user, text2ratvar("Spatial Gateway, activate!"))
					return
			adjust_chumbiswork_power(gateway_cost) //if we didn't return above, ie, successfully create a gateway, we give the power back

/obj/structure/destructible/chumbiswork/powered/chumbiswork_obelisk/process()
	if(!anchored)
		return
	var/obj/effect/chumbiswork/spatial_gateway/SG = locate(/obj/effect/chumbiswork/spatial_gateway) in loc
	if(SG && SG.timerid) //it's a valid gateway, we're active
		icon_state = active_icon
		density = FALSE
		active = TRUE
	else
		icon_state = inactive_icon
		density = TRUE
		active = FALSE
