/obj/effect/proc_holder/spell/targeted/shapeshift
	name = "Shapechange"
	desc = "Take on the shape of another for a time to use their natural abilities. Once you've made your choice it cannot be changed."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 200
	cooldown_min = 50
	range = -1
	include_user = TRUE
	invocation = "RAC'WA NO!"
	invocation_type = "shout"
	action_icon_state = "shapeshift"

	var/revert_on_death = TRUE
	var/die_with_shapeshifted_form = TRUE
	var/convert_damage = TRUE //If you want to convert the caster's health to the shift, and vice versa.
	var/convert_damage_type = BRUTE //Since simplemobs don't have advanced damagetypes, what to convert damage back into.

	var/shapeshift_type
	var/list/possible_shapes = list(/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/pet/dog/corgi,\
		/mob/living/simple_animal/hostile/carp/ranged/chaos,\
		/mob/living/simple_animal/bot/ed209,\
		/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper,\
		/mob/living/simple_animal/hostile/construct/armored)

/obj/effect/proc_holder/spell/targeted/shapeshift/cast(list/targets,mob/user = usr)
	if(src in user.mob_spell_list)
		user.mob_spell_list.Remove(src)
		user.mind.AddSpell(src)
	if(user.buckled)
		user.buckled.unbuckle_mob(src,force=TRUE)
	for(var/mob/living/M in targets)
		if(!shapeshift_type)
			var/list/animal_list = list()
			for(var/path in possible_shapes)
				var/mob/living/simple_animal/A = path
				animal_list[initial(A.name)] = path
			var/new_shapeshift_type = input(M, "Choose Your Animal Form!", "It's Morphing Time!", null) as null|anything in animal_list
			if(shapeshift_type)
				return
			shapeshift_type = new_shapeshift_type
			if(!shapeshift_type) //If you aren't gonna decide I am!
				shapeshift_type = pick(animal_list)
			shapeshift_type = animal_list[shapeshift_type]

		var/obj/shapeshift_holder/S = locate() in M
		if(S)
			Restore(M)
		else
			Shapeshift(M)


/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/H = locate() in caster
	if(H)
		to_chat(caster, "<span class='warning'>You're already shapeshifted!</span>")
		return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	H = new(shape,src,caster)

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Restore(mob/living/shape)
	var/obj/shapeshift_holder/H = locate() in shape
	if(!H)
		return

	H.restore()

	clothes_req = initial(clothes_req)
	human_req = initial(human_req)

/obj/effect/proc_holder/spell/targeted/shapeshift/dragon
	name = "Dragon Form"
	desc = "Take on the shape a lesser ash drake."
	invocation = "RAAAAAAAAWR!"
	convert_damage = FALSE
	

	shapeshift_type = /mob/living/simple_animal/hostile/megafauna/dragon/lesser


/obj/shapeshift_holder
	name = "Shapeshift holder"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF
	var/mob/living/stored
	var/mob/living/shape
	var/restoring = FALSE
	var/datum/soullink/shapeshift/slink
	var/obj/effect/proc_holder/spell/targeted/shapeshift/source

/obj/shapeshift_holder/Initialize(mapload,obj/effect/proc_holder/spell/targeted/shapeshift/source,mob/living/caster)
	. = ..()
	src.source = source
	shape = loc
	if(!istype(shape))
		CRASH("shapeshift holder created outside mob/living")
	stored = caster
	if(stored.mind)
		stored.mind.transfer_to(shape)
	stored.forceMove(src)
	stored.notransform = TRUE
	if(source.convert_damage)
		var/damapply = (stored.maxHealth - (stored.health + stored.maxHealth)/2) //Carbons go from -100 to 100 naturally, while simplemobs only go from 0 to 100. Can't do a direct conversion.
		shape.apply_damage(damapply, source.convert_damage_type)
	slink = soullink(/datum/soullink/shapeshift, stored , shape)
	slink.source = src

/obj/shapeshift_holder/Destroy()
	if(!restoring)
		restore()
	stored = null
	shape = null
	. = ..()

/obj/shapeshift_holder/Moved()
	. = ..()
	if(!restoring || QDELETED(src))
		restore()

/obj/shapeshift_holder/handle_atom_del(atom/A)
	if(A == stored && !restoring)
		restore()

/obj/shapeshift_holder/Exited(atom/movable/AM)
	if(AM == stored && !restoring)
		restore()

/obj/shapeshift_holder/proc/casterDeath()
	//Something kills the stored caster through direct damage.
	if(source.revert_on_death)
		restore(death=TRUE)
	else
		shape.death()

/obj/shapeshift_holder/proc/shapeDeath()
	//Shape dies.
	if(source.die_with_shapeshifted_form)
		if(source.revert_on_death)
			restore(death=TRUE)
	else
		restore()

/obj/shapeshift_holder/proc/restore(death=FALSE)
	restoring = TRUE
	qdel(slink)
	stored.forceMove(get_turf(src))
	stored.notransform = FALSE
	if(shape.mind)
		shape.mind.transfer_to(stored)
	if(death)
		stored.death()
	else if(source.convert_damage)
		stored.revive(full_heal = TRUE)
		var/damapply = (shape.maxHealth - 2*shape.health) //Since we halved incoming damage, double outgoing.
		stored.apply_damage(damapply, source.convert_damage_type)
	qdel(shape)
	qdel(src)

/datum/soullink/shapeshift
	var/obj/shapeshift_holder/source

/datum/soullink/shapeshift/ownerDies(gibbed, mob/living/owner)
	if(source)
		source.casterDeath(gibbed)

/datum/soullink/shapeshift/sharerDies(gibbed, mob/living/sharer)
	if(source)
		source.shapeDeath(gibbed)