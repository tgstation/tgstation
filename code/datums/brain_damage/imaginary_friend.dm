/datum/brain_trauma/special/imaginary_friend
	name = "Imaginary Friend"
	desc = "Patient can see and hear an imaginary person."
	scan_desc = "partial schizophrenia"
	gain_text = "<span class='notice'>You feel in good company, for some reason.</span>"
	lose_text = "<span class='warning'>You feel lonely again.</span>"
	var/mob/camera/imaginary_friend/friend
	var/friend_initialized = FALSE

/datum/brain_trauma/special/imaginary_friend/on_gain()
	..()
	make_friend()
	get_ghost()

/datum/brain_trauma/special/imaginary_friend/on_life()
	if(get_dist(owner, friend) > 9)
		friend.yank()
	if(!friend)
		qdel(src)
		return
	if(!friend.client && friend_initialized)
		addtimer(CALLBACK(src, .proc/reroll_friend), 600)

/datum/brain_trauma/special/imaginary_friend/on_lose()
	..()
	QDEL_NULL(friend)

//If the friend goes afk, make a brand new friend. Plenty of fish in the sea of imagination.
/datum/brain_trauma/special/imaginary_friend/proc/reroll_friend()
	if(friend.client) //reconnected
		return
	friend_initialized = FALSE
	QDEL_NULL(friend)
	make_friend()
	get_ghost()

/datum/brain_trauma/special/imaginary_friend/proc/make_friend()
	friend = new(get_turf(src), src)

/datum/brain_trauma/special/imaginary_friend/proc/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [owner]'s imaginary friend?", ROLE_PAI, null, null, 75, friend)
	if(LAZYLEN(candidates))
		var/client/C = pick(candidates)
		friend.key = C.key
		friend_initialized = TRUE
	else
		qdel(src)

/mob/camera/imaginary_friend
	name = "imaginary friend"
	real_name = "imaginary friend"
	move_on_shuttle = TRUE
	desc = "A wonderful yet fake friend."
	see_in_dark = 0
	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	sight = NONE
	see_invisible = SEE_INVISIBLE_LIVING
	var/icon/human_image
	var/image/current_image
	var/mob/living/carbon/owner
	var/datum/brain_trauma/special/imaginary_friend/trauma

/mob/camera/imaginary_friend/Login()
	..()
	to_chat(src, "<span class='notice'><b>You are the imaginary friend of [owner]!</b></span>")
	to_chat(src, "<span class='notice'>You are absolutely loyal to your friend, no matter what.</span>")
	to_chat(src, "<span class='notice'>You cannot directly influence the world around you, but you can see what [owner] cannot.</span>")

/mob/camera/imaginary_friend/Initialize(mapload, _trauma)
	. = ..()
	var/gender = pick(MALE, FEMALE)
	real_name = random_unique_name(gender)
	name = real_name
	trauma = _trauma
	owner = trauma.owner
	human_image = get_flat_human_icon(null, pick(SSjob.occupations))
	Show()

/mob/camera/imaginary_friend/proc/Show()
	if(!client) //nobody home
		return

	//Remove old image from owner and friend
	if(owner.client)
		owner.client.images.Remove(current_image)

	client.images.Remove(current_image)

	//Generate image from the static icon and the current dir
	current_image = image(human_image, src, , MOB_LAYER, dir=src.dir)
	current_image.override = TRUE
	current_image.name = name

	//Add new image to owner and friend
	if(owner.client)
		owner.client.images |= current_image

	client.images |= current_image

/mob/camera/imaginary_friend/Destroy()
	if(owner.client)
		owner.client.images.Remove(human_image)
	if(client)
		client.images.Remove(human_image)
	return ..()

/mob/camera/imaginary_friend/proc/yank()
	if(!client) //don't bother if the friend is braindead
		return
	forceMove(get_turf(owner))
	Show()

/mob/camera/imaginary_friend/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	friend_talk(message)

/mob/camera/imaginary_friend/proc/friend_talk(message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	log_talk(src,"[key_name(src)] : [message]",LOGSAY)

	var/rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[say_quote(message)]</span></span>"
	var/dead_rendered = "<span class='game say'><span class='name'>[name] (Imaginary friend of [owner])</span> <span class='message'>[say_quote(message)]</span></span>"

	to_chat(owner, "[rendered]")
	to_chat(src, "[rendered]")

	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, owner)
		to_chat(M, "[link] [dead_rendered]")

/mob/camera/imaginary_friend/emote(act,m_type=1,message = null)
	return

/mob/camera/imaginary_friend/forceMove(atom/destination)
	dir = get_dir(get_turf(src), destination)
	loc = destination
	if(get_dist(src, owner) > 9)
		yank()
		return
	Show()

/mob/camera/imaginary_friend/movement_delay()
	return 2
