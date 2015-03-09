/*
Conjure spells spawn things (mobs, objs, turfs) in their summon_type
How they spawn stuff is decided by behaviour vars, which are explained below
*/

/spell/aoe_turf/conjure
	name = "Conjure"
	desc = "This spell conjures objs of the specified types in range."

	school = "conjuration" //funny, that

	var/list/summon_type = list() //determines what exactly will be summoned
	//should be text, like list("/obj/machinery/bot/ed209")

	range = 0		//default values: only spawn on the player tile
	selection_type = "view"

	duration = 0 // 0=permanent, any other time in deciseconds - how long the summoned objects last for
	var/summon_amt = 1 //amount of objects summoned
	var/summon_exclusive = 0 //spawn one of everything, instead of random things

	var/list/newVars = list() //vars of the summoned objects will be replaced with those where they meet
	//should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example

	cast_sound = 'sound/items/welder.ogg'

/spell/aoe_turf/conjure/cast(list/targets, mob/user)
	playsound(get_turf(user), cast_sound, 50, 1)

	for(var/i=1,i <= summon_amt,i++)
		if(!targets.len)
			break
		var/summoned_object_type
		if(summon_exclusive)
			if(!summon_type.len)
				break
			summoned_object_type = summon_type[1]
			summon_type -= summoned_object_type
		else
			summoned_object_type = pick(summon_type)
		var/turf/spawn_place = pick(targets)
		if(spell_flags & IGNOREPREV)
			targets -= spawn_place

		var/atom/summoned_object
		if(ispath(summoned_object_type,/turf))
			if(istype(get_turf(user),/turf/simulated/shuttle) || istype(spawn_place, /turf/simulated/shuttle))
				user << "<span class='warning>You can't build things on shuttles!</span>"
				continue
			spawn_place.ChangeTurf(summoned_object_type)
			summoned_object = spawn_place
		else
			summoned_object = new summoned_object_type(spawn_place)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(spawn_place)
		animation.name = "conjure"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/effects/effects.dmi'
		animation.layer = 3
		animation.master = summoned_object

		for(var/varName in newVars)
			if(varName in summoned_object.vars)
				summoned_object.vars[varName] = newVars[varName]

		if(duration)
			spawn(duration)
				if(summoned_object && !istype(summoned_object, /turf))
					qdel(summoned_object)
		conjure_animation(animation, spawn_place)
	return

/spell/aoe_turf/conjure/proc/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	del(animation)