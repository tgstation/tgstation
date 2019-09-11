/*
Slimecrossing Mobs
	Mobs and effects added by the slimecrossing system.
	Collected here for clarity.
*/

//Slime transformation power - Burning Black
/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform
	name = "Slime Transformation"
	desc = "Transform from a human to a slime, or back again!"
	action_icon_state = "transformslime"
	cooldown_min = 0
	charge_max = 0
	invocation_type = "none"
	shapeshift_type = /mob/living/simple_animal/slime/transformedslime
	convert_damage = TRUE
	convert_damage_type = CLONE
	var/remove_on_restore = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform/Restore(mob/living/M)
	if(remove_on_restore)
		if(M.mind)
			M.mind.RemoveSpell(src)
	..()

//Transformed slime - Burning Black
/mob/living/simple_animal/slime/transformedslime

/mob/living/simple_animal/slime/transformedslime/Reproduce() //Just in case.
	to_chat(src, "<span class='warning'>I can't reproduce...</span>")
	return

//Slime corgi - Chilling Pink
/mob/living/simple_animal/pet/dog/corgi/puppy/slime
	name = "\improper slime corgi puppy"
	real_name = "slime corgi puppy"
	desc = "An unbearably cute pink slime corgi puppy."
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	nofur = TRUE
	gold_core_spawnable = NO_SPAWN
	speak_emote = list("blorbles", "bubbles", "borks")
	emote_hear = list("bubbles!", "splorts.", "splops!")
	emote_see = list("gets goop everywhere.", "flops.", "jiggles!")

//Hostile Copy - Destabilized Cerulean
/mob/living/simple_animal/hostile/clone
	name = "hostile clone"
	real_name = "hostile clone"
	desc = "How familiar..."
	maxHealth = 100
	health = 100
	melee_damage_lower = 0 //Human punch damage range
	melee_damage_upper = 9
	obj_damage = 5
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	var/atom/movable/form = null

/mob/living/simple_animal/hostile/clone/Initialize(mapload, atom/movable/target, mob/creator)
	. = ..()
	adaptForm(target)
	friends += creator

/mob/living/simple_animal/hostile/clone/examine(mob/user)
	if(form)
		form.examine(user)
		if(get_dist(user,src)<=3)
			to_chat(user, "<span class='warning'>It doesn't look quite right...</span>")
	else
		..()
	return

/mob/living/simple_animal/hostile/clone/proc/adaptForm(atom/movable/target)
	form = target
	appearance = target.appearance
	copy_overlays(target)
	alpha = max(alpha, 150)
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)

/mob/living/simple_animal/hostile/clone/death(gibbed)
	. = ..()
	if(!gibbed)
		var/mob/living/simple_animal/hostile/morph/M = new(get_turf(src))
		M.gib()
		qdel(src)

/mob/living/simple_animal/hostile/clone/CanAttack(atom/the_target)
	. = ..()
	for(var/atom/A in friends)
		if(the_target == A)
			return FALSE