

/datum/status_effect/kleptomania
	id = "kleptomania"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/kleptomania_chance = 2.5

/datum/status_effect/kleptomania/tick()
	if(prob(kleptomania_chance) && owner.m_intent == MOVE_INTENT_RUN && !owner.get_active_held_item() && !(owner.incapacitated()) && owner.has_active_hand())
		if(prob(25)) //we pick pockets
			for(var/mob/living/carbon/human/victim in view(1, owner))
				var/pockets = victim.get_pockets()
				if(victim != owner && length(pockets))
					var/obj/item/I = pick(pockets)
					owner.visible_message("<span class='warning'>[owner] attempts to remove [I] from [victim]'s pocket!</span>","<span class='warning'>You attempt to remove [I] from [victim]'s pocket.</span>", FALSE, 1)
					if(do_mob(owner, victim, I.strip_delay) && victim.temporarilyRemoveItemFromInventory(I))
						owner.visible_message("<span class='warning'>[owner] removes [I] from [victim]'s pocket!</span>","<span class='warning'>You remove [I] from [victim]'s pocket.</span>", FALSE, 1)
						log_admin("[key_name(usr)] picked [victim.name]'s pockets with Kleptomania trait.")
						if(!QDELETED(I) && !owner.putItemFromInventoryInHandIfPossible(I, owner.active_hand_index, TRUE, TRUE))
							I.forceMove(owner.drop_location())
						break
					else
						owner.visible_message("<span class='warning'>[owner] fails to pickpocket [victim].</span>","<span class='warning'>You fail to pick [victim]'s pocket.</span>", FALSE, 1)
		else //we pick stuff off the ground
			var/mob/living/carbon/C = owner
			for(var/obj/item/I in oview(1, C))
				if(!I.anchored && !(I in C.get_all_gear()) && I.Adjacent(C)) //anything that's not nailed down or worn
					I.attack_hand(C)
					break
