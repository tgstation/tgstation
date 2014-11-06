/obj/mecha/combat
	force = 30
	var/melee_cooldown = 10
	var/melee_can_hit = 1
	var/list/destroyable_obj = list(/obj/mecha, /obj/structure/window, /obj/structure/grille, /obj/structure/wall)
	internal_damage_threshold = 50
	damage_absorption = list("brute"=0.7,"fire"=1,"bullet"=0.7,"laser"=0.85,"energy"=1,"bomb"=0.8)
	var/am = "d3c2fbcadca903a41161ccc9df9cf948"

/obj/mecha/combat/melee_action(target as obj|mob|turf)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = safepick(oview(1,src))
	if(!melee_can_hit || !istype(target, /atom)) return
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(src.occupant.a_intent == "harm")
			if(damtype == "brute")
				step_away(M,src,15)
			if(istype(target, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = target
				var/obj/item/organ/limb/temp = H.get_organ(pick("chest", "chest", "chest", "head"))
				if(temp)
					var/update = 0
					switch(damtype)
						if("brute")
							H.Paralyse(1)
							update |= temp.take_damage(rand(force/2, force), 0)
							playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
						if("fire")
							update |= temp.take_damage(0, rand(force/2, force))
							playsound(src, 'sound/items/Welder.ogg', 50, 1)
						if("tox")
							playsound(src, 'sound/effects/spray2.ogg', 50, 1)
							if(H.reagents)
								if(H.reagents.get_reagent_amount("cryptobiolin") + force < force*2)
									H.reagents.add_reagent("cryptobiolin", force/2)
								if(H.reagents.get_reagent_amount("toxin") + force < force*2)
									H.reagents.add_reagent("toxin", force/2.5)
						else
							return
					if(update)	H.update_damage_overlays(0)
				H.updatehealth()

			else
				switch(damtype)
					if("brute")
						M.Paralyse(1)
						M.take_overall_damage(rand(force/2, force))
						playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
					if("fire")
						M.take_overall_damage(0, rand(force/2, force))
						playsound(src, 'sound/items/Welder.ogg', 50, 1)
					if("tox")
						playsound(src, 'sound/effects/spray2.ogg', 50, 1)
						if(M.reagents)
							if(M.reagents.get_reagent_amount("cryptobiolin") + force < force*2)
								M.reagents.add_reagent("cryptobiolin", force/2)
							if(M.reagents.get_reagent_amount("toxin") + force < force*2)
								M.reagents.add_reagent("toxin", force/2.5)
					else
						return
				M.updatehealth()
			src.occupant_message("You hit [target].")
			src.visible_message("<span class='userdanger'>[src.name] hits [target].</span>")
			add_logs(occupant, M, "attacked", object=src, addition="(INTENT: [uppertext(occupant.a_intent)]) (DAMTYE: [uppertext(damtype)])")
		else
			step_away(M,src)
			src.occupant_message("You push [target] out of the way.")
			src.visible_message("[src] pushes [target] out of the way.")

		melee_can_hit = 0
		if(do_after(melee_cooldown))
			melee_can_hit = 1
		return

	else
		if(damtype == "brute")
			for(var/target_type in src.destroyable_obj)
				if(istype(target, target_type) && hascall(target, "attackby"))
					src.occupant_message("You hit [target].")
					src.visible_message("<span class='userdanger'>[src.name] hits [target]</span>")
					if(!istype(target, /obj/structure/wall))
						target:attackby(src,src.occupant)
					else if(prob(5))
						target:dismantle_wall(1)
						src.occupant_message("<span class='notice'>You smash through the wall.</span>")
						src.visible_message("<b>[src.name] smashes through the wall</b>")
						playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
					melee_can_hit = 0
					if(do_after(melee_cooldown))
						melee_can_hit = 1
					break
	return

/obj/mecha/combat/moved_inside(var/mob/living/carbon/human/H as mob)
	if(..())
		if(H.client)
			H.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0

/obj/mecha/combat/mmi_moved_inside(var/obj/item/device/mmi/mmi_as_oc as obj,mob/user as mob)
	if(..())
		if(occupant.client)
			occupant.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0


/obj/mecha/combat/go_out()
	if(src.occupant && src.occupant.client)
		src.occupant.client.mouse_pointer_icon = initial(src.occupant.client.mouse_pointer_icon)
	..()
	return

/obj/mecha/combat/Topic(href,href_list)
	..()
	var/datum/topic_input/filter = new (href,href_list)
	if(filter.get("close"))
		am = null
		return
	/*
	if(filter.get("saminput"))
		if(md5(filter.get("saminput")) == am)
			occupant_message("From the lies of the Antipath, Circuit preserve us.")
		am = null
	return
	*/