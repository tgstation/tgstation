/datum/brain_trauma/severe/tulpa
	name = "Trauma-created Tulpa"
	desc = "A secondary consciousness is in the patient's brain, able to talk to the patient, but not much else."
	gain_text = "<span class='warning'>You feel a burst of emotions...</span>"
	lose_text = "<span class='notice'>You feel alone again.</span>"
	var/mob/living/tulpa/tulpa_mob

/datum/brain_trauma/severe/tulpa/on_gain()
	tulpa_mob = new(owner, src)
	tulpa_mob.language_holder = owner.language_holder.copy(tulpa_mob)
	get_ghost()

/datum/brain_trauma/severe/tulpa/on_lose()
	QDEL_NULL(tulpa_mob)
	return ..()

/datum/brain_trauma/severe/tulpa/proc/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [owner]'s tulpa?", ROLE_PAI, null, null, 75, tulpa_mob)
	if(LAZYLEN(candidates))
		var/client/C = pick(candidates)
		tulpa_mob.key = C.key
		addtimer(CALLBACK(tulpa_mob, /mob/living/tulpa.proc/choose_name), 5)
		log_game("[key_name(tulpa_mob)] became [key_name(owner)]'s tulpa.")
		message_admins("[key_name_admin(tulpa_mob)] became [key_name_admin(owner)]'s tulpa.")
	else
		qdel(src)









/mob/living/tulpa
	name = "tulpa"
	desc = "If you're actually able to examine this, tell a coder or admin ASAP!"
	var/mob/living/carbon/host
	var/datum/brain_trauma/severe/tulpa/trauma

/mob/living/tulpa/emote(message)
	return

/mob/living/tulpa/Life()
	. = ..()
	if(QDELETED(host))
		qdel(src) //in case trauma deletion doesn't already do it
	if(host.stat == DEAD)
		qdel(trauma)
		qdel(src)

/mob/living/tulpa/Initialize(mapload, _trauma)
	if(iscarbon(loc))
		host = loc
		trauma = _trauma
	return ..()

/mob/living/tulpa/proc/choose_name()
	var/input = stripped_input(src,"What are you named?", ,"", MAX_NAME_LEN)
	real_name = input
	name = input

/mob/living/tulpa/say(message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	var/msg = "<i><b>[name]</b>: [message]</i>"
	to_chat(host, host)
	for(var/_M in GLOB.dead_mob_list)
		var/mob/M = _M
		to_chat(M, "[FOLLOW_LINK(M, host)] [msg]")
