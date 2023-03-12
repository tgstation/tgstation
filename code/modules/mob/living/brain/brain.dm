/mob/living/brain
	var/obj/item/mmi/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/datum/dna/stored/stored_dna // dna var for brain. Used to store dna, brain dna is not considered like actual dna, brain.has_dna() returns FALSE.
	stat = DEAD //we start dead by default
	see_invisible = SEE_INVISIBLE_LIVING
	speech_span = SPAN_ROBOT

/mob/living/brain/Initialize(mapload)
	. = ..()
	create_dna(src)
	stored_dna.initialize_dna(random_blood_type())
	if(isturf(loc)) //not spawned in an MMI or brain organ (most likely adminspawned)
		var/obj/item/organ/internal/brain/OB = new(loc) //we create a new brain organ for it.
		OB.brainmob = src
		forceMove(OB)
	if(!container?.mecha) //Unless inside a mecha, brains are rather helpless.
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, BRAIN_UNAIDED)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, BRAIN_UNAIDED)


/mob/living/brain/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	var/obj/item/organ/internal/brain/brain_loc = loc
	if(brain_loc && isnull(new_turf) && brain_loc.owner) //we're actively being put inside a new body.
		return ..(old_turf, get_turf(brain_loc.owner), same_z_layer, notify_contents)
	return ..()

/mob/living/brain/proc/create_dna()
	stored_dna = new /datum/dna/stored(src)
	if(!stored_dna.species)
		var/rando_race = pick(get_selectable_species())
		stored_dna.species = new rando_race()

/mob/living/brain/Destroy()
	if(key) //If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat != DEAD)
			death(TRUE)
		if(mind) //You aren't allowed to return to brains that don't exist
			mind.set_current(null)
		ghostize() //Ghostize checks for key so nothing else is necessary.
	container = null
	QDEL_NULL(stored_dna)
	return ..()

/// Override parent here because... the blind message doesn't really work given what's happen when a brain suicides. Can't hear a brain going grey. So, we omit the "blind" message.
/mob/living/brain/send_applicable_messages()
	visible_message(span_danger(get_visible_suicide_message()), span_userdanger(get_visible_suicide_message()))

/mob/living/brain/get_visible_suicide_message()
	return "[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live."

/mob/living/brain/apply_suicide_damage(obj/item/suicide_tool, damage_type = NONE) // we don't really care about applying damage to the brain mob and is just needless work.
	return FALSE

/mob/living/brain/ex_act() //you cant blow up brainmobs because it makes transfer_to() freak out when borgs blow up.
	return FALSE

/mob/living/brain/blob_act(obj/structure/blob/B)
	return

/mob/living/brain/get_eye_protection()//no eyes
	return 2

/mob/living/brain/get_ear_protection()//no ears
	return 2

/mob/living/brain/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash, length = 25)
	return // no eyes, no flashing

/mob/living/brain/can_be_revived()
	if(!container || health <= HEALTH_THRESHOLD_DEAD)
		return FALSE
	return TRUE

/mob/living/brain/fully_replace_character_name(oldname,newname)
	..()
	if(stored_dna)
		stored_dna.real_name = real_name

/mob/living/brain/forceMove(atom/destination)
	if(container)
		return container.forceMove(destination)
	else if (istype(loc, /obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/B = loc
		B.forceMove(destination)
	else if (istype(destination, /obj/item/organ/internal/brain))
		doMove(destination)
	else if (istype(destination, /obj/item/mmi))
		doMove(destination)
	else
		CRASH("Brainmob without a container [src] attempted to move to [destination].")

/mob/living/brain/update_mouse_pointer()
	if (!client)
		return
	client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
	if(!container)
		return
	if (container.mecha)
		var/obj/vehicle/sealed/mecha/M = container.mecha
		if(M.mouse_pointer)
			client.mouse_pointer_icon = M.mouse_pointer

/mob/living/brain/proc/get_traumas()
	. = list()
	if(istype(loc, /obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/B = loc
		. = B.traumas

/mob/living/brain/get_policy_keywords()
	. = ..()

	if(container)
		. += "[container.type]"
