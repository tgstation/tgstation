

/client/proc/rightandwrong()
	set category = "Spells"
	set desc = "Summon Guns"
	set name = "Wizards: No sense of right and wrong!"

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue
		if(prob(25))
			ticker.mode.traitors += H.mind
			H.mind.special_role = "traitor"
			var/datum/objective/survive/survive = new
			survive.owner = H.mind
			H.mind.objectives += survive
			H << "<B>You are the survivor! Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...</B>"
			var/obj_count = 1
			for(var/datum/objective/OBJ in H.mind.objectives)
				H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
				obj_count++
		var/randomize = pick("taser","egun","laser","revolver","smg","nuclear","deagle","gyrojet","pulse","silenced","cannon","shotgun","mateba","uzi","crossbow")
		switch (randomize)
			if("taser")
				new /obj/item/weapon/gun/energy/taser(get_turf(H))
			if("egun")
				new /obj/item/weapon/gun/energy/gun(get_turf(H))
			if("laser")
				new /obj/item/weapon/gun/energy/laser(get_turf(H))
			if("revolver")
				new /obj/item/weapon/gun/projectile(get_turf(H))
			if("smg")
				new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(H))
			if("nuclear")
				new /obj/item/weapon/gun/energy/gun/nuclear(get_turf(H))
			if("deagle")
				new /obj/item/weapon/gun/projectile/deagle/camo(get_turf(H))
			if("gyrojet")
				new /obj/item/weapon/gun/projectile/gyropistol(get_turf(H))
			if("pulse")
				new /obj/item/weapon/gun/energy/pulse_rifle(get_turf(H))
			if("silenced")
				new /obj/item/weapon/gun/projectile/silenced(get_turf(H))
			if("cannon")
				new /obj/item/weapon/gun/energy/lasercannon(get_turf(H))
			if("shotgun")
				new /obj/item/weapon/gun/projectile/shotgun/pump/combat(get_turf(H))
			if("mateba")
				new /obj/item/weapon/gun/projectile/mateba(get_turf(H))
			if("uzi")
				new /obj/item/weapon/gun/projectile/automatic/mini_uzi(get_turf(H))
			if("crossbow")
				new /obj/item/weapon/gun/energy/crossbow(get_turf(H))
	usr.verbs -= /client/proc/rightandwrong
