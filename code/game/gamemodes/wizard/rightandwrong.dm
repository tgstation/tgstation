

/mob/proc/rightandwrong()
	usr << "<B>You summoned guns!</B>"
	message_admins("[key_name_admin(usr, 1)] summoned guns!")
	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue
		if(prob(25))
			ticker.mode.traitors += H.mind
			H.mind.special_role = "traitor"
			var/datum/objective/survive/survive = new
			survive.owner = H.mind
			H.mind.objectives += survive
			H.attack_log += "\[[time_stamp()]\] <font color='red'>Was made into a survivor, and trusts no one!</font>"
			H << "<B>You are the survivor! Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...</B>"
			var/obj_count = 1
			for(var/datum/objective/OBJ in H.mind.objectives)
				H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
				obj_count++
		var/randomize = pick("taser","egun","laser","revolver","detective","smg","nuclear","deagle","gyrojet","pulse","silenced","cannon","doublebarrel","shotgun","combatshotgun","mateba","smg","uzi","crossbow","saw")
		switch (randomize)
			if("taser")
				new /obj/item/weapon/gun/energy/taser(get_turf(H))
			if("egun")
				new /obj/item/weapon/gun/energy/gun(get_turf(H))
			if("laser")
				new /obj/item/weapon/gun/energy/laser(get_turf(H))
			if("revolver")
				new /obj/item/weapon/gun/projectile/revolver(get_turf(H))
			if("detective")
				new /obj/item/weapon/gun/projectile/revolver/detective(get_turf(H))
			if("smg")
				new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(H))
			if("nuclear")
				new /obj/item/weapon/gun/energy/gun/nuclear(get_turf(H))
			if("deagle")
				new /obj/item/weapon/gun/projectile/automatic/deagle/camo(get_turf(H))
			if("gyrojet")
				new /obj/item/weapon/gun/projectile/automatic/gyropistol(get_turf(H))
			if("pulse")
				new /obj/item/weapon/gun/energy/pulse_rifle(get_turf(H))
			if("silenced")
				new /obj/item/weapon/gun/projectile/automatic/pistol(get_turf(H))
				new /obj/item/weapon/silencer(get_turf(H))
			if("cannon")
				new /obj/item/weapon/gun/energy/lasercannon(get_turf(H))
			if("doublebarrel")
				new /obj/item/weapon/gun/projectile/revolver/doublebarrel(get_turf(H))
			if("shotgun")
				new /obj/item/weapon/gun/projectile/shotgun/(get_turf(H))
			if("combatshotgun")
				new /obj/item/weapon/gun/projectile/shotgun/combat(get_turf(H))
			if("mateba")
				new /obj/item/weapon/gun/projectile/revolver/mateba(get_turf(H))
			if("smg")
				new /obj/item/weapon/gun/projectile/automatic(get_turf(H))
			if("uzi")
				new /obj/item/weapon/gun/projectile/automatic/mini_uzi(get_turf(H))
			if("crossbow")
				new /obj/item/weapon/gun/energy/crossbow(get_turf(H))
			if("saw")
				new /obj/item/weapon/gun/projectile/automatic/l6_saw(get_turf(H))