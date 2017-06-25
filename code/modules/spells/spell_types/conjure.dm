/obj/effect/proc_holder/spell/aoe_turf/conjure
	name = "Conjure"
	desc = "This spell conjures objs of the specified types in range."

	var/list/summon_type = list() //determines what exactly will be summoned
	//should be text, like list("/mob/living/simple_animal/bot/ed209")

	var/summon_lifespan = 0 // 0=permanent, any other time in deciseconds
	var/summon_amt = 1 //amount of objects summoned
	var/summon_ignore_density = 0 //if set to 1, adds dense tiles to possible spawn places
	var/summon_ignore_prev_spawn_points = 0 //if set to 1, each new object is summoned on a new spawn point

	var/list/newVars = list() //vars of the summoned objects will be replaced with those where they meet
	//should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example

	var/cast_sound = 'sound/items/welder.ogg'

/obj/effect/proc_holder/spell/aoe_turf/conjure/cast(list/targets,mob/user = usr)
	playsound(get_turf(user), cast_sound, 50,1)
	for(var/turf/T in targets)
		if(T.density && !summon_ignore_density)
			targets -= T

	for(var/i=0,i<summon_amt,i++)
		if(!targets.len)
			break
		var/summoned_object_type = pick(summon_type)
		var/spawn_place = pick(targets)
		if(summon_ignore_prev_spawn_points)
			targets -= spawn_place
		if(ispath(summoned_object_type,/turf))
			var/turf/O = spawn_place
			var/N = summoned_object_type
			O.ChangeTurf(N)
		else
			var/atom/summoned_object = new summoned_object_type(spawn_place)

			for(var/varName in newVars)
				if(varName in summoned_object.vars)
					summoned_object.vars[varName] = newVars[varName]
			summoned_object.admin_spawned = TRUE
			if(summon_lifespan)
				QDEL_IN(summoned_object, summon_lifespan)

			post_summon(summoned_object, user)

/obj/effect/proc_holder/spell/aoe_turf/conjure/proc/post_summon(atom/summoned_object, mob/user)
	return

/obj/effect/proc_holder/spell/aoe_turf/conjure/summonEdSwarm //test purposes - Also a lot of fun
	name = "Dispense Wizard Justice"
	desc = "This spell dispenses wizard justice."

	summon_type = list(/mob/living/simple_animal/bot/ed209)
	summon_amt = 10
	range = 3
	newVars = list("emagged" = 2, "remote_disabled" = 1,"shoot_sound" = 'sound/weapons/laser.ogg',"projectile" = /obj/item/projectile/beam/laser, "declare_arrests" = 0,"name" = "Wizard's Justicebot")

/obj/effect/proc_holder/spell/targeted/conjure_item
	name = "Summon weapon"
	desc = "A generic spell that should not exist.  This summons an instance of a specific type of item, or if one already exists, un-summons it.  Summons into hand if possible."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	var/obj/item/item
	var/item_type = /obj/item/weapon/banhammer
	school = "conjuration"
	charge_max = 150
	cooldown_min = 10

/obj/effect/proc_holder/spell/targeted/conjure_item/cast(list/targets, mob/user = usr)
	if (item && !QDELETED(item))
		qdel(item)
		item = null
	else
		for(var/mob/living/carbon/C in targets)
			if(C.drop_item())
				item = make_item()
				C.put_in_hands(item)

/obj/effect/proc_holder/spell/targeted/conjure_item/Destroy()
	if(item)
		qdel(item)
	return ..()

/obj/effect/proc_holder/spell/targeted/conjure_item/proc/make_item()
	return new item_type
