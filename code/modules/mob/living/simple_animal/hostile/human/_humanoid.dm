/mob/living/simple_animal/hostile/humanoid
	name = "human"

	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 7
	attacktext = "punches"
	a_intent = I_HURT

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15

	status_flags = CANPUSH

	var/obj/effect/landmark/corpse/corpse = /obj/effect/landmark/corpse
	var/list/items_to_drop = list()

	var/list/visible_items = list()

/mob/living/simple_animal/hostile/humanoid/New()
	..()

	for(var/I in visible_items)
		var/image/new_img = image(I, icon_state = visible_items[I], layer = MOB_LAYER)
		overlays.Add(new_img)

/mob/living/simple_animal/hostile/humanoid/Die()
	..()
	if(corpse)
		new corpse(loc)

	if(items_to_drop.len)

		for(var/object in items_to_drop)

			if(ispath(object))
				new object (get_turf(src))
			else if(istype(object, /atom/movable))
				var/atom/movable/A = object
				A.forceMove(get_turf(src))

	qdel(src)
	return
