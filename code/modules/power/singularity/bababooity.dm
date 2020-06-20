/obj/singularity/bababooity //I have become death, destroyer of codebases.
	name = "The Spirit of Bababooey"
	desc = "You hath spewed bababooey into the void, and it hath spewed it back."
	icon = 'icons/obj/baba.dmi'
	icon_state = "booey"
	pixel_x = -176
	pixel_y = -176
	density = FALSE
	current_size = 9 
	contained = 0 
	dissipate = 0 
	move_self = 1 
	grav_pull = 5 
	consume_range = 4 



/obj/singularity/bababooity/Initialize()
	. = ..()
	send_to_playing_players("<span class='narsie'>BABABOOEY</span>")
	sound_to_playing_players('sound/creatures/bababooeyrisen.ogg')

/obj/singularity/bababooity/process()
	eat()
	if(!target || prob(5))
		pickcultist()
	move()
	if(prob(25))
		mezzer()
	if(prob(80))
		playsound(src,'sound/creatures/bababoo.ogg', 100, TRUE, 40)



/obj/singularity/bababooity/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(T == loc)
		T = get_step(A, A.dir)
	forceMove(T)

/obj/singularity/bababooity/ex_act()
	return


/obj/singularity/bababooity/proc/pickcultist()
	var/list/cultists = list()
	var/list/noncultists = list()

	for(var/mob/living/carbon/food in GLOB.alive_mob_list)
		var/turf/pos = get_turf(food)
		if(!pos || (pos.z != z))
			continue

		if(iscultist(food))
			cultists += food
		else
			noncultists += food

		if(cultists.len) //cultists get higher priority
			acquire(pick(cultists))
			return

		if(noncultists.len)
			acquire(pick(noncultists))
			return

	//no living humans, follow a ghost instead.
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		var/turf/pos = get_turf(ghost)
		if(!pos || (pos.z != z))
			continue
		cultists += ghost
	if(cultists.len)
		acquire(pick(cultists))
		return


/obj/singularity/bababooity/proc/acquire(atom/food)
	if(food == target)
		return
	to_chat(target, "<span class='narsie'>BABABOOEY.</span>")
	target = food
	if(ishuman(target))
		to_chat(target, "<span class='narsie'>BABABOOEY.</span>")
	else
		to_chat(target, "<span class='narsie'>BABABOOEY.</span>")
