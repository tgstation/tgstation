#define START_TIMER reanimation_timer = world.time + rand(600,1200)

/obj/item/organ/body_egg/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and vicera."
	zone = "head"
	slot = "zombie_infection"
	var/reanimation_timer
	var/datum/species/old_species
	var/living_transformation_time = 5
	var/converts_living = FALSE

/obj/item/organ/body_egg/zombie_infection/New()
	. = ..()
	zombie_infection_list += src

/obj/item/organ/body_egg/zombie_infection/Destroy()
	zombie_infection_list -= src
	. = ..()

/obj/item/organ/body_egg/zombie_infection/on_find(mob/living/finder)
	finder << "<span class='warning'>Inside the head is a disgusting black \
		web of pus and vicera, bound tightly around the brain like some \
		biological harness.</span>"

/obj/item/organ/body_egg/zombie_infection/egg_process()
	if(!ishuman(owner)) // We do not support monkey or xeno zombies. Yet.
		qdel(src)
		return
	else if(reanimation_timer && (reanimation_timer < world.time))
		zombify() // Rise and shine, Mr Romero... rise and shine.
		reanimation_timer = null
	else if(owner.stat == DEAD && (!reanimation_timer))
		START_TIMER
	else if(converts_living && !iszombie(owner) && !reanimation_timer)
		START_TIMER

/obj/item/organ/body_egg/zombie_infection/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	CHECK_DNA_AND_SPECIES(M)
	if(iszombie(M) && old_species)
		M.set_species(old_species)

/obj/item/organ/body_egg/zombie_infection/proc/zombify()
	CHECK_DNA_AND_SPECIES(owner)
	if(!iszombie(owner))
		old_species = owner.dna.species.type

	owner.grab_ghost()
	owner.set_species(/datum/species/zombie/infectious)
	var/old_stat = owner.stat // Save for the message
	owner.revive(full_heal = TRUE)
	switch(old_stat)
		if(DEAD, UNCONSCIOUS)
			owner.visible_message("<span class='danger'>[owner] staggers to [owner.p_their()] feet!</span>")
			owner << "<span class='danger'>You stagger to your feet!</span>"
		// Conscious conversions will generally only happen for an event
		// or for a converts_living=TRUE infection
		if(CONSCIOUS)
			owner.visible_message("<span class='danger'>[owner] suddenly convulses, as [owner.p_they()] gain a ravenous hunger in [owner.p_their()] eyes!</span>",
				"<span class='alien'>You HUNGER!</span>")
			playsound(owner.loc, 'sound/hallucinations/growl3.ogg', 50, 1)
			owner.do_jitter_animation(living_transformation_time)
			owner.Stun(living_transformation_time)
			owner << "<span class='alertalien'>You are now a zombie!</span>"

#undef START_TIMER
