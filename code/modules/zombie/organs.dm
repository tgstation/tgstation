/obj/item/organ/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and vicera."
	zone = "head"
	slot = "zombie_infection"
	icon_state = "blacktumor"
	origin_tech = "biotech=5"
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 3
	var/converts_living = FALSE

	var/revive_time_min = 450
	var/revive_time_max = 700
	var/timer_id

/obj/item/organ/zombie_infection/Initialize()
	. = ..()
	if(iscarbon(loc))
		Insert(loc)
	GLOB.zombie_infection_list += src

/obj/item/organ/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/zombie_infection/Insert(var/mob/living/carbon/M, special = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/zombie_infection/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(iszombie(M) && old_species)
		M.set_species(old_species)
	if(timer_id)
		deltimer(timer_id)

/obj/item/organ/zombie_infection/on_find(mob/living/finder)
	to_chat(finder, "<span class='warning'>Inside the head is a disgusting black \
		web of pus and vicera, bound tightly around the brain like some \
		biological harness.</span>")

/obj/item/organ/zombie_infection/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		Remove(owner)

	if(timer_id)
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if(!iszombie(owner))
		to_chat(owner, "<span class='narsiesmall'>You can feel your heart stopping, but something isn't right... \
		life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
		not even death can stop, you will rise again!</span>")
	var/revive_time = rand(revive_time_min, revive_time_max)
	var/flags = TIMER_STOPPABLE
	timer_id = addtimer(CALLBACK(src, .proc/zombify), revive_time, flags)

/obj/item/organ/zombie_infection/proc/zombify()
	timer_id = null

	if(!iszombie(owner))
		old_species = owner.dna.species.type
		owner.set_species(/datum/species/zombie/infectious)

	if(!converts_living && owner.stat != DEAD)
		return

	var/stand_up = (owner.stat == DEAD) || (owner.stat == UNCONSCIOUS)

	if(!owner.revive(full_heal = TRUE))
		return

	owner.grab_ghost()
	owner.visible_message("<span class='danger'>[owner] suddenly convulses, as [owner.p_they()][stand_up ? " stagger to [owner.p_their()] feet and" : ""] gain a ravenous hunger in [owner.p_their()] eyes!</span>", "<span class='alien'>You HUNGER!</span>")
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	owner.do_jitter_animation(living_transformation_time * 10)
	owner.Stun(living_transformation_time)
	to_chat(owner, "<span class='alertalien'>You are now a zombie!</span>")
