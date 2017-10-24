
/obj/item/storage/book/bible/bless(mob/living/carbon/human/H, mob/living/user)
	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1)

	if(LAZYLEN(hurt_limbs))
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.status == BODYPART_ROBOTIC)
				if(item_heal_robotic(H, user, heal_amt ,0))//You may only heal one bodypart at a time using this proc so you do have to hit them more often.
					H.visible_message("<span class='notice'>[user] mends the dents of [H] with the power of [deity_name]!</span>")
					to_chat(H, "<span class='boldnotice'>May the power of [deity_name] find your metal unwanting!</span>")
					playsound(src.loc, 'sound/items/drill_use.ogg', 25, 1, -1)
					return TRUE
				else if(item_heal_robotic(H, user, 0, heal_amt ))
					H.visible_message("<span class='notice'>[user] fixes the wiring of [H] with the power of [deity_name]!</span>")
					to_chat(H, "<span class='boldnotice'>May the power of [deity_name] restore your currents!</span>")
					playsound(src.loc, 'sound/items/drill_use.ogg', 25, 1, -1)
					return TRUE
			else if(affecting.heal_damage(heal_amt, heal_amt))
				H.update_damage_overlays()
				H.visible_message("<span class='notice'>[user] heals [H] with the power of [deity_name]!</span>")
				playsound(src.loc, "punch", 25, 1, -1)
				return TRUE