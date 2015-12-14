/obj/effect/proc_holder/spell/targeted/shapeshift
	name = "Shapeshift"
	desc = "Change shapes"
	clothes_req = 0
	human_req = 0
	charge_max = 200
	cooldown_min = 50
	range = -1
	include_user = 1
	invocation = "RAC'WA NO!"
	invocation_type = "shout"
	action_icon_state = "shapeshift"

	var/shapeshift_type = /mob/living/simple_animal/hostile/retaliate/goat
	var/list/current_shapes = list()
	var/list/current_casters = list()

/obj/effect/proc_holder/spell/targeted/shapeshift/cast(list/targets,mob/user = usr)
	for(var/mob/living/M in targets)
		if(M in current_shapes)
			Restore(M)
		else
			Shapeshift(M)

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Shapeshift(mob/living/caster)
	for(var/mob/living/M in caster)
		if(M.status_flags & GODMODE)
			caster << "<span class='warning'>You're already shapeshifted!</span>"
			return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	caster.loc = shape
	caster.status_flags |= GODMODE

	current_shapes |= shape
	current_casters |= caster
	clothes_req = 0
	human_req = 0

	caster.mind.transfer_to(shape)

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Restore(mob/living/shape)
	var/mob/living/caster
	for(var/mob/living/M in shape)
		if(M in current_casters)
			caster = M
			break
	if(!caster)
		return
	caster.loc = shape.loc
	caster.status_flags &= ~GODMODE

	clothes_req = initial(clothes_req)
	human_req = initial(human_req)
	current_casters.Remove(caster)
	current_shapes.Remove(shape)

	shape.mind.transfer_to(caster)
	qdel(shape) //Gib it maybe ?

/obj/effect/proc_holder/spell/targeted/shapeshift/wild
	name = "Wild Shapeshift"
	desc = "Change into a variety of forms. Most of them deadly. Or inconspicious"

	var/list/possible_shapes = list(/mob/living/simple_animal/pet/dog/corgi,\
		/mob/living/simple_animal/hostile/poison/giant_spider/hunter,\
		/mob/living/simple_animal/hostile/carp/megacarp,\
		/mob/living/simple_animal/hostile/construct/armored)

/obj/effect/proc_holder/spell/targeted/shapeshift/wild/New()
	..()
	shapeshift_type = pick(possible_shapes)