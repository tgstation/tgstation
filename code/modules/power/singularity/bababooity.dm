/obj/singularity/bababooity //I have become death, destroyer of codebases.
	name = "The Spirit of Bababooey"
	desc = "Bababooey."
	icon = 'icons/obj/baba.dmi'
	icon_state = "booey"
	pixel_x = -176
	pixel_y = -176
	density = FALSE
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?
	move_self = 1 //Do we move on our own?
	grav_pull = 5 //How many tiles out do we pull?
	consume_range = 4 //How many tiles out do we eat



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
		T = get_step(A, A.dir) //please don't slam into a window like a bird, Nar'Sie
	forceMove(T)

/obj/singularity/bababooity/ex_act() //No throwing bombs at her either.
	return


/obj/singularity/bababooity/proc/pickcultist()
	var/list/cultists = list()
	var/list/noncultists = list()

	for(var/mob/living/carbon/food in GLOB.alive_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
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
	to_chat(target, "<span class='cultsmall'>NAR'SIE HAS LOST INTEREST IN YOU.</span>")
	target = food
	if(ishuman(target))
		to_chat(target, "<span class='cult'>NAR'SIE HUNGERS FOR YOUR SOUL.</span>")
	else
		to_chat(target, "<span class='cult'>NAR'SIE HAS CHOSEN YOU TO LEAD HER TO HER NEXT MEAL.</span>")