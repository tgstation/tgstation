/datum/brain_trauma/special

#define OWNER 0
#define STRANGER 1

/datum/brain_trauma/special/split_personality
	name = "Split Personality"
	desc = "Patient's brain is split into two personalities, which randomly switch control of the body."
	scan_desc = "complete lobe separation"
	gain_text = "<span class='warning'>You feel like your mind was split in two.</span>"
	lose_text = "<span class='notice'>You feel alone again.</span>"
	var/current_controller = OWNER
	var/initialized = FALSE //to prevent personalities deleting themselves while we wait for ghosts
	var/mob/living/split_personality/stranger_backseat //there's two so they can swap without overwriting
	var/mob/living/split_personality/owner_backseat


/datum/brain_trauma/special/split_personality/on_gain()
	..()
	stranger_backseat = new(owner, src)
	owner_backseat = new(owner, src)
	get_ghost()

/datum/brain_trauma/special/split_personality/proc/get_ghost()
	set waitfor = 0
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [owner]'s split personality?", null, null, null, 75, stranger_backseat)
	if(LAZYLEN(candidates))
		var/client/C = pick(candidates)
		stranger_backseat.key = C.key
	else
		qdel(src)

//no fiddling with genetics to get out of this one
/datum/brain_trauma/special/split_personality/on_life()
	if(owner.stat == DEAD)
		if(current_controller != OWNER)
			switch_personalities()
		qdel(src)
	else if(prob(2))
		switch_personalities()
	..()

/datum/brain_trauma/special/split_personality/on_lose()
	if(current_controller != OWNER) //it would be funny to cure a guy only to be left with the other personality, but it seems too cruel
		switch_personalities()
	QDEL_NULL(stranger_backseat)
	QDEL_NULL(owner_backseat)
	..()

/datum/brain_trauma/special/split_personality/proc/switch_personalities()
	if(QDELETED(owner) || owner.stat == DEAD || QDELETED(stranger_backseat) || QDELETED(owner_backseat))
		return

	var/mob/living/split_personality/current_backseat
	var/mob/living/split_personality/free_backseat
	if(current_controller == OWNER)
		current_backseat = stranger_backseat
		free_backseat = owner_backseat
	else
		current_backseat = owner_backseat
		free_backseat = stranger_backseat

	log_game("[current_backseat]/([current_backseat.ckey]) assumed control of [owner]/([owner.ckey] due to Split Personality. (Original owner: [current_controller == OWNER ? owner.ckey : current_backseat.ckey])")
	to_chat(owner, "<span class='userdanger'>You feel your control being taken away... your other personality is in charge now!</span>")
	to_chat(current_backseat, "<span class='userdanger'>You manage to take control of your own body!</span>")

	//Body to backseat

	var/h2b_id = owner.computer_id
	var/h2b_ip= owner.lastKnownIP
	owner.computer_id = null
	owner.lastKnownIP = null

	free_backseat.ckey = owner.ckey

	free_backseat.name = owner.name

	if(owner.mind)
		free_backseat.mind = owner.mind

	if(!free_backseat.computer_id)
		free_backseat.computer_id = h2b_id

	if(!free_backseat.lastKnownIP)
		free_backseat.lastKnownIP = h2b_ip

	//Backseat to body

	var/s2h_id = current_backseat.computer_id
	var/s2h_ip= current_backseat.lastKnownIP
	current_backseat.computer_id = null
	current_backseat.lastKnownIP = null

	owner.ckey = current_backseat.ckey
	owner.mind = current_backseat.mind

	if(!owner.computer_id)
		owner.computer_id = s2h_id

	if(!owner.lastKnownIP)
		owner.lastKnownIP = s2h_ip

	current_controller = !current_controller


/mob/living/split_personality
	name = "split personality"
	real_name = "unknown conscience"
	var/mob/living/carbon/body
	var/datum/brain_trauma/special/split_personality/trauma

/mob/living/split_personality/Initialize(mapload, _trauma)
	if(iscarbon(loc))
		body = loc
		name = body.real_name
		real_name = body.real_name
		trauma = _trauma
	return ..()

/mob/living/split_personality/Life()
	if(QDELETED(body))
		qdel(src) //in case trauma deletion doesn't already do it

	if((body.stat == DEAD && trauma.owner_backseat == src))
		trauma.switch_personalities()
		qdel(trauma)

	if(!body.ckey && trauma.initialized)
		trauma.switch_personalities()
		qdel(trauma)

	..()

/mob/living/split_personality/Login()
	..()
	to_chat(src, "<span class='notice'>As a split personality, you cannot do anything but observe. However, you will eventually gain control of your body, switching places with the current personality.</span>")

/mob/living/split_personality/say(message)
	to_chat(src, "<span class='warning'>You cannot speak, your other self is controlling your body!</span>")
	return FALSE

/mob/living/split_personality/emote(message)
	return

#undef OWNER
#undef STRANGER