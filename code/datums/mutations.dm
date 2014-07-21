/datum/mutations
	var/list/mutation_list = list()
	var/list/disability_list = list()
	var/list/condition_list = list()
	var/mob/holder = null

/datum/mutations/New(var/mob/holder)
	src.holder = holder

/datum/mutations/proc/add_mutation(var/mut, var/message=null, var/silent=0) // return 0 = already had; return 1 = given succesfully
	if (mut in mutation_list)
		return 0
	mutation_list.Add(mut)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(mut)
				if (TK)
					holder << "<span class='notice'>You feel smarter.</span>"
				if (COLD_RESISTANCE)
					holder << "<span class='notice'>Your body feels warm.</span>"
				if (XRAY)
					holder << "<span class='notice'>The walls suddenly disappear.</span>"
				if (HULK)
					holder << "<span class='notice'>Your muscles hurt.</span>"
				if (LASER)
					holder << "<span class='notice'>You feel pressure building behind your eyes.</span>"
				if (HEAL)
					holder << "<span class='notice'>You feel a pleasant warmth pulse throughout your body.</span>"
		//X-ray needs extra edits
		if (mut == XRAY)
			holder.sight |= SEE_MOBS|SEE_OBJS|SEE_TURFS
			holder.see_in_dark = 8
			holder.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		holder.update_mutations()

/datum/mutations/proc/has_mutation(var/mut)
	if (mut in mutation_list)
		return 1
	return 0

/datum/mutations/proc/remove_mutation(var/mut, var/message = null, var/silent=0)
	if (!(mut in mutation_list))
		return 0
	mutation_list.Remove(mut)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(mut)
				if (TK)
					holder << "<span class='danger'>You feel like you forget something.</span>"
				if (COLD_RESISTANCE)
					holder << "<span class='danger'>You feel a shiver go down your body.</span>"
				if (XRAY)
					holder << "<span class='danger'>Your vision suddenly gets foggy.</span>"
				if (HULK)
					holder << "<span class='danger'>You suddenly feel very weak.</span>"
				if (LASER)
					holder << "<span class='danger'>You feel your eyes relax.</span>"
				if (HEAL)
					holder << "<span class='danger'>You feel a cold pulse throughout your body.</span>"
		holder.update_mutations()

/datum/mutations/proc/clear_mutations()
	for (var/i in mutation_list)
		remove_mutation(i)

/datum/mutations/proc/add_disability(var/dis, var/message=null, var/silent=0)
	if (dis in disability_list)
		return 0
	disability_list.Add(dis)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(dis)
				if (CLUMSY)
					holder << "<span class='danger'>You feel lightheaded.</span>"
				if (NEARSIGHTED)
					holder << "<span class='danger'>Your eyes feel strange.</span>"
				if (EPILEPSY)
					holder << "<span class='danger'>You get a headache.</span>"
				if (COUGHING)
					holder << "<span class='danger'>You start coughing.</span>"
				if (TOURETTES)
					holder << "<span class='danger'>You twitch.</span>"
				if (NERVOUS)
					holder << "<span class='danger'>You feel nervous.</span>"
				if (BLIND)
					holder << "<span class='danger'>You can't seem to see anything.</span>"
				if (MUTE)
					holder << "<span class='danger'>You can't seem to say anything.</span>"
				if (DEAF)
					holder << "<span class='danger'>You can't seem to hear anything.</span>"
		if (dis == DEAF)
			holder.ear_deaf = 1
		holder.update_mutations()

/datum/mutations/proc/has_disability(var/dis)
	if (dis in disability_list)
		return 1
	return 0

/datum/mutations/proc/remove_disability(var/dis, var/message = null, var/silent=0)
	if (!(dis in disability_list))
		return 0
	disability_list.Remove(dis)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(dis)
				if (CLUMSY)
					holder << "<span class='notice'>You feel concentrated.</span>"
				if (NEARSIGHTED)
					holder << "<span class='notice'>Your eyes feel better.</span>"
				if (EPILEPSY)
					holder << "<span class='notice'>Your headache passes.</span>"
				if (COUGHING)
					holder << "<span class='notice'>You stop coughing.</span>"
				if (TOURETTES)
					holder << "<span class='notice'>You stop twitching.</span>"
				if (NERVOUS)
					holder << "<span class='notice'>You feel calmer.</span>"
				if (BLIND)
					holder << "<span class='notice'>You can see again.</span>"
				if (MUTE)
					holder << "<span class='notice'>You can talk again.</span>"
				if (DEAF)
					holder << "<span class='notice'>You can hear again.</span>"
		holder.update_mutations()

/datum/mutations/proc/clear_disabilities()
	for (var/i in disability_list)
		remove_disability(i)

/datum/mutations/proc/add_condition(var/con, var/message=null, var/silent=0)
	if (con in condition_list)
		return 0
	condition_list.Add(con)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(con) // Yeah, only one option, keeping switch in case more get added
				if (FAT)
					holder << "<span class='danger'>You suddenly feel blubbery!</span>"
		holder.update_mutations()

/datum/mutations/proc/has_condition(var/con)
	if (con in condition_list)
		return 1
	return 0

/datum/mutations/proc/remove_condition(var/con, var/message = null, var/silent=0)
	if (!(con in condition_list))
		return 0
	condition_list.Remove(con)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(con)
				if (FAT)
					holder << "<span class='notice'>You feel fit again!</span>"
		holder.update_mutations()

/datum/mutations/proc/clear_conditions()
	for (var/i in condition_list)
		remove_condition(i)

/datum/mutations/proc/RangedAttack(var/atom/A, var/params)
	if((has_mutation(LASER)) && holder.a_intent == "harm")
		holder.LaserEyes(A)
	else if(has_mutation(TK))
		A.attack_tk(holder)

/datum/mutations/proc/thick_fingers()
	if (has_mutation(HULK))
		return 1
	return 0

/datum/mutations/proc/stun_immune()
	if (has_mutation(HULK))
		return 1
	return 0

/datum/mutations/proc/wall_smash(var/turf/simulated/wall/wall)
	if (has_mutation(HULK))
		if (prob(wall.hardness))
			playsound(wall, 'sound/effects/meteorimpact.ogg', 100, 1)
			holder << text("<span class='notice'>You smash through the wall.</span>")
			holder.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			wall.dismantle_wall(1)
		else
			playsound(wall, 'sound/effects/bang.ogg', 50, 1)
			holder << text("<span class='notice'>You punch the wall.</span>")
		return 1
	return 0

/datum/mutations/proc/table_smash(var/obj/structure/table/table)
	if(has_mutation(HULK))
		holder.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		table.visible_message("<span class='danger'>[holder] smashes the table apart!</span>")
		if(istype(table, /obj/structure/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced(table.loc)
		else if(istype(table, /obj/structure/table/woodentable))
			new/obj/item/weapon/table_parts/wood(table.loc)
		else
			new /obj/item/weapon/table_parts(table.loc)
		table.density = 0
		qdel(table)
		return 1
	return 0

/datum/mutations/proc/rack_smash(var/obj/structure/rack/rack)
	if(has_mutation(HULK))
		holder.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		rack.visible_message("<span class='danger'>[holder] smashes [rack] apart!</span>")
		new /obj/item/weapon/rack_parts(rack.loc)
		rack.density = 0
		qdel(rack)

/datum/mutations/proc/bonus_damage()
	var/i = 0
	if (has_mutation(HULK))
		i += 5
	return i

/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	changeNext_move(4)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)

	var/obj/item/projectile/beam/LE = new /obj/item/projectile/beam( loc )
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)

	LE.firer = src
	LE.def_zone = get_organ_target()
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	spawn( 1 )
		LE.process()

/mob/living/carbon/human/LaserEyes()
	if(nutrition>0)
		..()
		nutrition = max(nutrition - rand(1,5),0)
		handle_regular_hud_updates()
	else
		src << "\red You're out of energy!  You need food!"