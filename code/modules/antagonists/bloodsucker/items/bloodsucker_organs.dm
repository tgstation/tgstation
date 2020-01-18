

/datum/antagonist/bloodsucker/proc/CheckVampOrgans()
	// Do I have any parts that need replacing?
	var/obj/item/organ/O

	// Heart
	O = owner.current.getorganslot(ORGAN_SLOT_HEART)
	if (!istype(O, /obj/item/organ/heart/vampheart))
		qdel(O)
		var/obj/item/organ/heart/vampheart/H = new
		H.Insert(owner.current)
		H.Stop() // Now...stop beating!

	// Eyes
	O = owner.current.getorganslot(ORGAN_SLOT_EYES)
	if (!istype(O, /obj/item/organ/eyes/vampeyes))
		qdel(O)
		var/obj/item/organ/eyes/vampeyes/E = new
		E.Insert(owner.current)


/datum/antagonist/bloodsucker/proc/RemoveVampOrgans()

	// Heart
	var/obj/item/organ/heart/H = new
	H.Insert(owner.current)
	// Eyes
	var/obj/item/organ/eyes/E = new
	E.Insert(owner.current)



// 		HEART: OVERWRITE	//

/obj/item/organ/heart/proc/HeartStrengthMessage()
	if (beating)
		return "a healthy"
	return "<span class='danger'>an unstable</span>"


// 		HEART 		//

/obj/item/organ/heart/vampheart
	beating = 0
	var/fakingit = 0

/obj/item/organ/heart/vampheart/prepare_eat()
	..()
	// Do cool stuff for eating vamp heart?

/obj/item/organ/heart/vampheart/Restart()
	beating = 0	// DONT run ..(). We don't want to start beating again.
	return 0

/obj/item/organ/heart/vampheart/Stop()
	fakingit = 0
	return ..()

/obj/item/organ/heart/vampheart/proc/FakeStart()
	fakingit = 1 // We're pretending to beat, to fool people.

/obj/item/organ/heart/vampheart/HeartStrengthMessage()
	if (fakingit)
		return "a healthy"
	return "<span class='danger'>no</span>"	// Bloodsuckers don't have a heartbeat at all when stopped (default is "an unstable")


// 		EYES 		//

/obj/item/organ/eyes/vampeyes
	lighting_alpha = 180 //  LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE  <--- This is too low a value at 128. We need to SEE what the darkness is so we can hide in it.
	see_in_dark = 8
	flash_protect = -1
	//sight_flags = SEE_TURFS // Taken from augmented_eyesight.dm


/*
//		LIVER		//
/obj/item/organ/liver/vampliver
	// Livers run on_life(), which calls reagents.metabolize() in holder.dm, which calls on_mob_life.dm in the cheam (medicine_reagents.dm)
	//															Holder also calls reagents.reaction_mob for the moment it happens

/obj/item/organ/liver/vampliver/on_life()
	var/mob/living/carbon/C = owner

	if(!istype(C))
		return

*/