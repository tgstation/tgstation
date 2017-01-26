/obj/item/organ/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and vicera."
	zone = "head"
	slot = "zombie_infection"
	origin_tech = "biotech=5"
	var/datum/species/old_species
	var/living_transformation_time = 5
	var/converts_living = FALSE

	var/revive_time_min = 600
	var/revive_time_max = 1200
	var/timer_id

/obj/item/organ/zombie_infection/New()
	. = ..()
	zombie_infection_list += src

/obj/item/organ/zombie_infection/Destroy()
	zombie_infection_list -= src
	. = ..()

/obj/item/organ/zombie_infection/on_find(mob/living/finder)
	finder << "<span class='warning'>Inside the head is a disgusting black \
		web of pus and vicera, bound tightly around the brain like some \
		biological harness.</span>"

/obj/item/organ/zombie_infection/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		Remove(owner)

	if(timer_id)
		return
	if(owner.stat != DEAD && !converts_living)
		return

	var/callback = CALLBACK(src, .proc/zombify)
	var/revive_time = rand(revive_time_min, revive_time_max)
	var/flags = TIMER_STOPPABLE
	timer_id = addtimer(callback, revive_time, flags)

/obj/item/organ/zombie_infection/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	CHECK_DNA_AND_SPECIES(M)
	if(iszombie(M) && old_species)
		M.set_species(old_species)
	if(timer_id)
		deltimer(timer_id)

/obj/item/organ/zombie_infection/proc/zombify()
	CHECK_DNA_AND_SPECIES(owner)
	if(!iszombie(owner))
		old_species = owner.dna.species.type

	if(!converts_living || owner.stat != DEAD)
		return

	var/stand_up = (owner.stat == DEAD) || (owner.stat == UNCONSCIOUS)

	owner.grab_ghost()
	owner.set_species(/datum/species/zombie/infectious)
	owner.revive(full_heal = TRUE)
	owner.visible_message("<span class='danger'>[owner] suddenly convulses, as [owner.p_they()][stand_up ? " stagger to [owner.p_their()] feet and" : ""] gain a ravenous hunger in [owner.p_their()] eyes!</span>", "<span class='alien'>You HUNGER!</span>")
	playsound(owner.loc, 'sound/hallucinations/growl3.ogg', 50, 1)
	owner.do_jitter_animation(living_transformation_time)
	owner.Stun(living_transformation_time)
	owner << "<span class='alertalien'>You are now a zombie!</span>"
