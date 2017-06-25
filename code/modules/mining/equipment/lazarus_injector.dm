/**********************Lazarus Injector**********************/
/obj/item/weapon/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1
	var/malfunctioning = 0
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it
	origin_tech = "biotech=4;magnets=6"

/obj/item/weapon/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	if(!loaded)
		return
	if(isliving(target) && proximity_flag)
		if(isanimal(target))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				to_chat(user, "<span class='info'>[src] does not work on this sort of creature.</span>")
				return
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.revive(full_heal = 1, admin_revive = 1)
				if(ishostile(target))
					var/mob/living/simple_animal/hostile/H = M
					if(malfunctioning)
						H.faction |= list("lazarus", "\ref[user]")
						H.robust_searching = 1
						H.friends += user
						H.attack_same = 1
						log_game("[user] has revived hostile mob [target] with a malfunctioning lazarus injector")
					else
						H.attack_same = 0
				loaded = 0
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				SSblackbox.add_details("lazarus_injector", "[M.type]")
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return
			else
				to_chat(user, "<span class='info'>[src] is only effective on the dead.</span>")
				return
		else
			to_chat(user, "<span class='info'>[src] is only effective on lesser beings.</span>")
			return

/obj/item/weapon/lazarus_injector/emp_act()
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/weapon/lazarus_injector/examine(mob/user)
	..()
	if(!loaded)
		to_chat(user, "<span class='info'>[src] is empty.</span>")
	if(malfunctioning)
		to_chat(user, "<span class='info'>The display on [src] seems to be flickering.</span>")
