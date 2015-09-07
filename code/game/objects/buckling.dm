

/obj
	var/can_buckle = 0
	var/buckle_lying = -1 //bed-like behaviour, forces mob.lying = buckle_lying if != -1
	var/buckle_requires_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/mob/living/buckled_mob = null


//Interaction
/obj/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && buckled_mob)
		user_unbuckle_mob(user)

/obj/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(can_buckle && istype(M))
		user_buckle_mob(M, user)


//Cleanup
/obj/Destroy()
	. = ..()
	unbuckle_mob()

//procs that handle the actual buckling and unbuckling
/obj/proc/buckle_mob(mob/living/M)
	if(!can_buckle || !istype(M) || (M.loc != loc) || M.buckled || (buckle_requires_restraints && !M.restrained()))
		return 0

	if (isslime(M) || isAI(M))
		if(M == usr)
			M << "<span class='warning'>You are unable to buckle yourself to the [src]!</span>"
		else
			usr << "<span class='warning'>You are unable to buckle [M] to the [src]!</span>"
		return 0

	M.buckled = src
	M.dir = dir
	buckled_mob = M
	M.update_canmove()
	post_buckle_mob(M)
	M.throw_alert("buckled", new_master = src)
	if(burn_state == 1) //Sets the mob on fire if you buckle them to a burning object
		M.adjust_fire_stacks(1)
		M.IgniteMob()
	return 1

/obj/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src)
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_canmove()
		buckled_mob.clear_alert("buckled")
		buckled_mob = null

		post_buckle_mob(.)


//Handle any extras after buckling/unbuckling
//Called on buckle_mob() and unbuckle_mob()
/obj/proc/post_buckle_mob(mob/living/M)
	return


//Wrapper procs that handle sanity and user feedback
/obj/proc/user_buckle_mob(mob/living/M, mob/user)
	if(!in_range(user, src) || user.stat || user.restrained())
		return

	add_fingerprint(user)
	unbuckle_mob()

	if(buckle_mob(M))
		if(M == user)
			M.visible_message(\
				"[M] buckles themself to [src].",\
				"<span class='notice'>You buckle yourself to [src].</span>",\
				"<span class='italics'>You hear metal clanking.</span>")
		else
			M.visible_message(\
				"<span class='warning'>[user] buckles [M] to [src]!</span>",\
				"<span class='warning'>[user] buckles you to [src]!</span>",\
				"<span class='italics'>You hear metal clanking.</span>")

/obj/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		if(M != user)
			M.visible_message(\
				"<span class='notice'>[user] unbuckles you from [src].",\
				"<span class='notice'>[user] unbuckles you from [src].</span>",\
				"<span class='italics'>You hear metal clanking.</span>")
		else
			M.visible_message(\
				"<span class='notice'>[M] unbuckles themselves from [src].</span>",\
				"<span class='notice'>You unbuckle yourself from [src].</span>",\
				"<span class='italics'>You hear metal clanking.</span>")
		add_fingerprint(user)
	return M


