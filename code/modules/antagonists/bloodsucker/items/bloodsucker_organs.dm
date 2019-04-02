

/datum/antagonist/bloodsucker/proc/CheckVampOrgans()

	// Heart
	var/obj/item/organ/O
	O = owner.current.getorganslot(ORGAN_SLOT_HEART)
	if (!istype(O, /obj/item/organ/heart/vampheart))
		var/obj/item/organ/heart/vampheart/H = new()
		H.Insert(owner.current)
	// Eyes
	O = owner.current.getorganslot(ORGAN_SLOT_EYES)
	if (!istype(O, /obj/item/organ/eyes/vampeyes))
		var/obj/item/organ/eyes/vampeyes/E = new()
		E.Insert(owner.current)


/datum/antagonist/bloodsucker/proc/RemoveVampOrgans()

	// Heart
	var/obj/item/organ/heart/H = new()
		H.Insert(owner.current)
	// Eyes
	var/obj/item/organ/eyes/E = new()
		E.Insert(owner.current)



// 		HEART: OVERWRITE	//

/obj/item/organ/heart/proc/HeartStrengthMessage()
	if (beating)
		return "a healthy"
	return "<span class='danger'>an unstable</span>"


// 		HEART 		//

/obj/item/organ/heart/vampheart
	beating = 0

/obj/item/organ/heart/vampheart/prepare_eat()
	..()
	// Do cool stuff for eating vamp heart?

/obj/item/organ/heart/vampheart/Restart()
	return 0

/obj/item/organ/heart/vampheart/proc/FakeStart()
	// We're pretending to beat, to fool people.

/obj/item/organ/heart/vampheart/HeartStrengthMessage()
	if (beating)
		return "a healthy"
	return "<span class='danger'>no</span>"	// Bloodsuckers don't have a heartbeat at all when stopped (default is "an unstable")



// 		EYES 		//

/obj/item/organ/eyes/vampeyes
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 8
	flash_protect = -1
	sight_flags = SEE_TURFS // Taken from augmented_eyesight.dm

