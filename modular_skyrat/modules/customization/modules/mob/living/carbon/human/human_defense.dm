/mob/living/carbon/human/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	var/informed = FALSE
	var/affects_leg = FALSE
	var/stun_time = 0
	for(var/obj/item/bodypart/L in src.bodyparts)
		if(L.status == BODYPART_ROBOTIC)
			if(!informed)
				to_chat(src, "<span class='userdanger'>You feel a sharp pain as your robotic limbs overload.</span>")
				informed = TRUE
			switch(severity)
				if(1)
					L.receive_damage(0,6)
					stun_time += 40
				if(2)
					L.receive_damage(0,3)
					stun_time += 20
			if(L.body_zone == BODY_ZONE_L_LEG || L.body_zone == BODY_ZONE_R_LEG)
				affects_leg = TRUE


			if(L.body_zone == BODY_ZONE_L_ARM || L.body_zone == BODY_ZONE_R_ARM)
				dropItemToGround(get_item_for_held_index(L.held_index), 1)

	if(stun_time)
		Paralyze(stun_time)
	if(affects_leg)
		switch(severity)
			if(1)
				Knockdown(100)
			if(2)
				Knockdown(50)
