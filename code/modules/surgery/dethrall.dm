/datum/surgery/dethrall
	name = "dethralling"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/dethrall)
	possible_locs = list("head")

/datum/surgery/dethrall/can_start(mob/user, mob/living/carbon/target)
	return is_thrall(target)

/datum/surgery_step/dethrall
	name = "search head"
	accept_hand = 1
	time = 70
	var/obj/item/organ/internal/brain/B = null

/datum/surgery_step/dethrall/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	B = target.getorgan(/obj/item/organ/internal/brain)
	if(B)
		user.visible_message("[user] begins looking around in [target]'s head.", "<span class='notice'>You begin looking for foreign influences on [target]'s brain...")

/datum/surgery_step/dethrall/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(B)
		if(!is_thrall(target))
			user << "<span class='warning'>You are unable to locate anything on [target]'s brain.</span>"
			return 1
		sleep(30)

		user.visible_message("[user] begins removing something from [target]'s head.</span>", \
							 "<span class='notice'>You begin carefully extracting the tumor...</span>")
		if(!do_mob(user, target, 50))
			if(prob(50))
				user.visible_message("<span class='warning'>[user] slips and rips the tumor out from [target]'s head!</span>", \
									 "<span class='warning'><b>You fumble and tear out [target]'s tumor!</span>")
				ticker.mode.remove_thrall(target.mind,1)
				return 1
			else
				user.visible_message("<span class='warning'>[user] screws up!</span>")
			return 0
		if(target.dna.species.id == "l_shadowling")
			target << "<span class='shadowling'><b><i>NOT LIKE THIS!</i></b></span>"
			user.visible_message("<span class='warning'><b>[target] suddenly slams upward and knocks down [user]!</span>", \
								 "<span class='userdanger'>[target] suddenly bolts up and slams you with tremendous force!")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.Weaken(6)
				C.apply_damage(20, "brute", "chest")
			else if(issilicon(user))
				var/mob/living/silicon/S = user
				S.Weaken(8)
				S.apply_damage(20, "brute")
				playsound(S, 'sound/effects/bang.ogg', 50, 1)
			return

		user.visible_message("<span class='notice'>[user] carefully extracts the tumor from [target]'s brain!</span>", \
							 "<span class='notice'>You extract the black tumor from [target]'s head. It quickly shrivels and burns away.</span>")
		ticker.mode.remove_thrall(target.mind,0)
	else
		user << "<span class='warning'>[target] has no brain!</span>"
	return 1
