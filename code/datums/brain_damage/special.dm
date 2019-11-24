//Brain traumas that are rare and/or somewhat beneficial;
//they are the easiest to cure, which means that if you want
//to keep them, you can't cure your other traumas
/datum/brain_trauma/special

/datum/brain_trauma/special/godwoken
	name = "Godwoken Syndrome"
	desc = "Patient occasionally and uncontrollably channels an eldritch god when speaking."
	scan_desc = "god delusion"
	gain_text = "<span class='notice'>You feel a higher power inside your mind...</span>"
	lose_text = "<span class='warning'>The divine presence leaves your head, no longer interested.</span>"

/datum/brain_trauma/special/godwoken/on_life()
	..()
	if(prob(4))
		if(prob(33) && (owner.IsStun() || owner.IsParalyzed() || owner.IsUnconscious()))
			speak("unstun", TRUE)
		else if(prob(60) && owner.health <= owner.crit_threshold)
			speak("heal", TRUE)
		else if(prob(30) && owner.a_intent == INTENT_HARM)
			speak("aggressive")
		else
			speak("neutral", prob(25))

/datum/brain_trauma/special/godwoken/on_gain()
	ADD_TRAIT(owner, TRAIT_HOLY, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/godwoken/on_lose()
	REMOVE_TRAIT(owner, TRAIT_HOLY, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/godwoken/proc/speak(type, include_owner = FALSE)
	var/message
	switch(type)
		if("unstun")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_unstun")
		if("heal")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_heal")
		if("neutral")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")
		if("aggressive")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_aggressive")
		else
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")

	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 5)
	voice_of_god(message, owner, list("colossus","yell"), 2.5, include_owner, FALSE)

/datum/brain_trauma/special/bluespace_prophet
	name = "Bluespace Prophecy"
	desc = "Patient can sense the bob and weave of bluespace around them, showing them passageways no one else can see."
	scan_desc = "bluespace attunement"
	gain_text = "<span class='notice'>You feel the bluespace pulsing around you...</span>"
	lose_text = "<span class='warning'>The faint pulsing of bluespace fades into silence.</span>"
	var/next_portal = 0

/datum/brain_trauma/special/bluespace_prophet/on_life()
	if(world.time > next_portal)
		next_portal = world.time + 100
		var/list/turf/possible_turfs = list()
		for(var/turf/T in range(owner, 8))
			if(!T.density)
				var/clear = TRUE
				for(var/obj/O in T)
					if(O.density)
						clear = FALSE
						break
				if(clear)
					possible_turfs += T

		if(!LAZYLEN(possible_turfs))
			return

		var/turf/first_turf = pick(possible_turfs)
		if(!first_turf)
			return

		possible_turfs -= (possible_turfs & range(first_turf, 3))

		var/turf/second_turf = pick(possible_turfs)
		if(!second_turf)
			return

		var/obj/effect/hallucination/simple/bluespace_stream/first = new(first_turf, owner)
		var/obj/effect/hallucination/simple/bluespace_stream/second = new(second_turf, owner)

		first.linked_to = second
		second.linked_to = first
		first.seer = owner
		second.seer = owner

/obj/effect/hallucination/simple/bluespace_stream
	name = "bluespace stream"
	desc = "You see a hidden pathway through bluespace..."
	image_icon = 'icons/effects/effects.dmi'
	image_state = "bluestream"
	image_layer = ABOVE_MOB_LAYER
	var/obj/effect/hallucination/simple/bluespace_stream/linked_to
	var/mob/living/carbon/seer

/obj/effect/hallucination/simple/bluespace_stream/Initialize()
	. = ..()
	QDEL_IN(src, 300)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/hallucination/simple/bluespace_stream/attack_hand(mob/user)
	if(user != seer || !linked_to)
		return
	var/slip_in_message = pick("slides sideways in an odd way, and disappears", "jumps into an unseen dimension",\
		"sticks one leg straight out, wiggles [user.p_their()] foot, and is suddenly gone", "stops, then blinks out of reality", \
		"is pulled into an invisible vortex, vanishing from sight")
	var/slip_out_message = pick("silently fades in", "leaps out of thin air","appears", "walks out of an invisible doorway",\
		"slides out of a fold in spacetime")
	to_chat(user, "<span class='notice'>You try to align with the bluespace stream...</span>")
	if(do_after(user, 20, target = src))
		new /obj/effect/temp_visual/bluespace_fissure(get_turf(src))
		new /obj/effect/temp_visual/bluespace_fissure(get_turf(linked_to))
		user.forceMove(get_turf(linked_to))
		user.visible_message("<span class='warning'>[user] [slip_in_message].</span>", null, null, null, user)
		user.visible_message("<span class='warning'>[user] [slip_out_message].</span>", "<span class='notice'>...and find your way to the other side.</span>")

/datum/brain_trauma/special/psychotic_brawling
	name = "Violent Psychosis"
	desc = "Patient fights in unpredictable ways, ranging from helping his target to hitting them with brutal strength."
	scan_desc = "violent psychosis"
	gain_text = "<span class='warning'>You feel unhinged...</span>"
	lose_text = "<span class='notice'>You feel more balanced.</span>"
	var/datum/martial_art/psychotic_brawling/psychotic_brawling

/datum/brain_trauma/special/psychotic_brawling/on_gain()
	..()
	psychotic_brawling = new(null)
	if(!psychotic_brawling.teach(owner, TRUE))
		to_chat(owner, "<span class='notice'>But your martial knowledge keeps you grounded.</span>")
		qdel(src)

/datum/brain_trauma/special/psychotic_brawling/on_lose()
	..()
	psychotic_brawling.remove(owner)
	QDEL_NULL(psychotic_brawling)

/datum/brain_trauma/special/psychotic_brawling/bath_salts
	name = "Chemical Violent Psychosis"
	clonable = FALSE

/datum/brain_trauma/special/tenacity
	name = "Tenacity"
	desc = "Patient is psychologically unaffected by pain and injuries, and can remain standing far longer than a normal person."
	scan_desc = "traumatic neuropathy"
	gain_text = "<span class='warning'>You suddenly stop feeling pain.</span>"
	lose_text = "<span class='warning'>You realize you can feel pain again.</span>"

/datum/brain_trauma/special/tenacity/on_gain()
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAUMA_TRAIT)
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/tenacity/on_lose()
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAUMA_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/death_whispers
	name = "Functional Cerebral Necrosis"
	desc = "Patient's brain is stuck in a functional near-death state, causing occasional moments of lucid hallucinations, which are often interpreted as the voices of the dead."
	scan_desc = "chronic functional necrosis"
	gain_text = "<span class='warning'>You feel dead inside.</span>"
	lose_text = "<span class='notice'>You feel alive again.</span>"
	var/active = FALSE

/datum/brain_trauma/special/death_whispers/on_life()
	..()
	if(!active && prob(2))
		whispering()

/datum/brain_trauma/special/death_whispers/on_lose()
	if(active)
		cease_whispering()
	..()

/datum/brain_trauma/special/death_whispers/proc/whispering()
	ADD_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	active = TRUE
	addtimer(CALLBACK(src, .proc/cease_whispering), rand(50, 300))

/datum/brain_trauma/special/death_whispers/proc/cease_whispering()
	REMOVE_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	active = FALSE

/datum/brain_trauma/special/existential_crisis
	name = "Existential Crisis"
	desc = "Patient's hold on reality becomes faint, causing occasional bouts of non-existence."
	scan_desc = "existential crisis"
	gain_text = "<span class='notice'>You feel less real.</span>"
	lose_text = "<span class='warning'>You feel more substantial again.</span>"
	var/obj/effect/abstract/sync_holder/veil/veil
	var/next_crisis = 0

/datum/brain_trauma/special/existential_crisis/on_life()
	..()
	if(!veil && world.time > next_crisis && prob(3))
		if(isturf(owner.loc))
			fade_out()

/datum/brain_trauma/special/existential_crisis/on_lose()
	if(veil)
		fade_in()
	..()

/datum/brain_trauma/special/existential_crisis/proc/fade_out()
	if(veil)
		return
	var/duration = rand(50, 450)
	veil = new(owner.drop_location())
	to_chat(owner, "<span class='warning'>[pick("You stop thinking for a moment. Therefore you are not.",\
												"To be or not to be...",\
												"Why exist?",\
												"You stop keeping it real.",\
												"Your grip on existence slips.",\
												"Do you even exist?",\
												"You simply fade away.")]</span>")
	owner.forceMove(veil)
	SEND_SIGNAL(owner, COMSIG_MOVABLE_SECLUDED_LOCATION)
	for(var/thing in owner)
		var/atom/movable/AM = thing
		SEND_SIGNAL(AM, COMSIG_MOVABLE_SECLUDED_LOCATION)
	next_crisis = world.time + 600
	addtimer(CALLBACK(src, .proc/fade_in), duration)

/datum/brain_trauma/special/existential_crisis/proc/fade_in()
	QDEL_NULL(veil)
	to_chat(owner, "<span class='notice'>You fade back into reality.</span>")
	next_crisis = world.time + 600

//base sync holder is in desynchronizer.dm
/obj/effect/abstract/sync_holder/veil
	name = "non-existence"
	desc = "Existence is just a state of mind."

/datum/brain_trauma/special/beepsky
	name = "Criminal"
	desc = "Patient seems to be a criminal."
	scan_desc = "criminal mind"
	gain_text = "<span class='warning'>Justice is coming for you.</span>"
	lose_text = "<span class='notice'>You were absolved for your crimes.</span>"
	clonable = FALSE
	random_gain = FALSE
	var/obj/effect/hallucination/simple/securitron/beepsky

/datum/brain_trauma/special/beepsky/on_gain()
	create_securitron()
	..()

/datum/brain_trauma/special/beepsky/proc/create_securitron()
	var/turf/where = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z)
	beepsky = new(where, owner)
	beepsky.victim = owner

/datum/brain_trauma/special/beepsky/on_lose()
	QDEL_NULL(beepsky)
	..()

/datum/brain_trauma/special/beepsky/on_life()
	if(QDELETED(beepsky) || !beepsky.loc || beepsky.z != owner.z)
		QDEL_NULL(beepsky)
		if(prob(30))
			create_securitron()
		else
			return
	if(get_dist(owner, beepsky) >= 10 && prob(20))
		QDEL_NULL(beepsky)
		create_securitron()
	if(owner.stat != CONSCIOUS)
		if(prob(20))
			owner.playsound_local(beepsky, 'sound/voice/beepsky/iamthelaw.ogg', 50)
		return
	if(get_dist(owner, beepsky) <= 1)
		owner.playsound_local(owner, 'sound/weapons/egloves.ogg', 50)
		owner.visible_message("<span class='warning'>[owner]'s body jerks as if it was shocked.</span>", "<span class='userdanger'>You feel the fist of the LAW.</span>")
		owner.take_bodypart_damage(0,0,rand(40, 70))
		QDEL_NULL(beepsky)
	if(prob(20) && get_dist(owner, beepsky) <= 8)
		owner.playsound_local(beepsky, 'sound/voice/beepsky/criminal.ogg', 40)
	..()

/obj/effect/hallucination/simple/securitron
	name = "Securitron"
	desc = "The LAW is coming."
	image_icon = 'icons/mob/aibots.dmi'
	image_state = "secbot-c"
	var/victim

/obj/effect/hallucination/simple/securitron/New()
	name = pick ( "officer Beepsky", "officer Johnson", "officer Pingsky")
	START_PROCESSING(SSfastprocess,src)
	..()

/obj/effect/hallucination/simple/securitron/process()
	if(prob(60))
		forceMove(get_step_towards(src, victim))
		if(prob(5))
			to_chat(victim, "<span class='name'>[name]</span> exclaims, \"<span class='robotic'>Level 10 infraction alert!\"</span>")

/obj/effect/hallucination/simple/securitron/Destroy()
	STOP_PROCESSING(SSfastprocess,src)
	return ..()


/datum/brain_trauma/special/photo_friend
	name = "Techno-Brain Virus"
	desc = "Patient made contact with Capone."
	scan_desc = "spectrally-connected mind"
	gain_text = "<span class='warning'>You feel like you're being watched...</span>"
	lose_text = "<span class='notice'>You feel alone again.</span>"
	clonable = FALSE
	random_gain = FALSE

	var/obj/effect/hallucination/simple/capone/capone
	var/obj/item/camera/brain/brain_cam // it's like a little birdhouse in ur soul except it's a camera in ur brain :D
	var/obj/item/pda/owner_pda

	var/last_snap
	var/min_snap_delay = 10 SECONDS
	var/capone_appear_delay
	var/turf/saved_location

	var/snap_delay = 45 SECONDS
	var/snap_delta = 5 SECONDS
	var/snapping = FALSE


/datum/brain_trauma/special/photo_friend/on_gain()
	for(var/obj/item/pda/P in GLOB.PDAs)
		if(P.owner == owner.real_name)
			owner_pda = P
			break
	if(!owner_pda || owner_pda.toff)
		testing("Owner has no linked PDA open to messages")
		QDEL_NULL(src)
		return

	brain_cam = new(owner)
	last_snap = world.time // give them 2 minutes without getting harassed by pix
	capone_appear_delay = world.time + 180 SECONDS // give them 3 minutes before capone shows up in person
	..()

/datum/brain_trauma/special/photo_friend/on_lose()
	QDEL_NULL(brain_cam)
	QDEL_NULL(capone)
	..()

/datum/brain_trauma/special/photo_friend/proc/start_snap()
	testing("Starting snap: delay [snap_delay]")
	snapping = TRUE
	saved_location = get_turf(owner)
	addtimer(CALLBACK(src, .proc/send_snap), snap_delay)

/datum/brain_trauma/special/photo_friend/proc/send_snap()
	testing("Sending?")
	last_snap = world.time
	snapping = FALSE
	snap_delay = max(min_snap_delay, snap_delay - snap_delta)

	var/pic_size = rand(2, 4)
	var/datum/picture/selfie = brain_cam.captureimage(target=saved_location, user=null, size_x=pic_size, size_y=pic_size)

	var/datum/signal/subspace/messaging/pda/signal = new(owner, list(
		"name" = "???",
		"job" = "???",
		"message" = " ",
		"targets" = list("[owner_pda.owner] ([owner_pda.ownjob])"),
		"photo" = selfie
	))

	signal.send_to_receivers()

/datum/brain_trauma/special/photo_friend/proc/create_capone()
	if(world.time < capone_appear_delay)
		return

	var/list/turfs = list()
	for(var/obj/structure/window/W in orange(owner, 6))
		var/w_dist = get_dist(owner, W)
		for(var/turf/open/O in orange(W, 1))
			if(O in turfs)
				continue
			if(O.density)
				continue
			if(get_dist(owner, O) <= w_dist)
				continue
			if(locate(/obj/structure/window) in O.contents)
				continue
			turfs += O

	if(turfs.len == 0)
		return 

	var/turf/open/where = pick(turfs)
	capone = new(where, owner)
	capone.victim = owner

/datum/brain_trauma/special/photo_friend/on_life()
	//&& (world.time > last_snap + snap_delay) 
	if(!snapping && prob(30))
		QDEL_NULL(capone)
		start_snap()

	if(QDELETED(capone) || !capone.loc || capone.z != owner.z)
		QDEL_NULL(capone)
		create_capone()
		return

	if(get_dist(owner, capone) >= 9 && prob(10))
		QDEL_NULL(capone)
		create_capone()

	if(get_dist(owner, capone) <= 3)
		//2do: some other effect for this
		QDEL_NULL(capone)

	if(prob(5))
		QDEL_NULL(capone)

	..()

/obj/effect/hallucination/simple/capone
	name = "Your Best Friend"
	desc = "Good to see you again!"
	image_icon = 'icons/mob/human_face.dmi'
	image_state = "lips_spray_face"
	var/victim

/obj/effect/hallucination/simple/capone/New()
	START_PROCESSING(SSprocessing,src)
	..()

/obj/effect/hallucination/simple/capone/process()
	setDir(get_dir(src, victim)) //doesnt actually do anything rn

/obj/effect/hallucination/simple/capone/Destroy()
	STOP_PROCESSING(SSprocessing,src)
	return ..()





/datum/brain_trauma/special/photo_friend/cute
	name = "Techno-Brain Virus"
	desc = "Patient made friends with Capone."
	scan_desc = "spectrally-connected mind"
	gain_text = "<span class='warning'>You feel like you're being watched...</span>"
	lose_text = "<span class='notice'>You feel alone again.</span>"
	clonable = FALSE
	random_gain = FALSE

	//var/obj/effect/hallucination/simple/capone/capone
	//var/obj/item/camera/brain/brain_cam // it's like a little birdhouse in ur soul except it's a camera in ur brain :D
	//var/obj/item/pda/owner_pda

	//var/last_snap
	//var/min_snap_delay = 60 SECONDS
	//var/capone_appear_delay

/datum/brain_trauma/special/photo_friend/cute/on_gain()
	for(var/obj/item/pda/P in GLOB.PDAs)
		if(P.owner == owner.real_name)
			owner_pda = P
			break
	if(!owner_pda || owner_pda.toff)
		testing("Owner has no linked PDA open to messages")
		QDEL_NULL(src)
		return

	brain_cam = new(owner)
	last_snap = world.time + 120 SECONDS // give them 2 minutes without getting harassed by pix
	capone_appear_delay = world.time + 180 SECONDS // give them 3 minutes before capone shows up in person
	..()

/datum/brain_trauma/special/photo_friend/cute/on_lose()
	QDEL_NULL(brain_cam)
	QDEL_NULL(capone)
	..()

/datum/brain_trauma/special/photo_friend/cute/send_snap()
	var/pic_size = rand(2, 4)
	var/datum/picture/selfie = brain_cam.captureimage(target=owner, user=owner, size_x=pic_size, size_y=pic_size)
	var/list/messages = list(":)", "hey friend, lookin good!", "hey pal, arent we cute??", "look at the 2 of us... so nice tgthr...", "feelin cute, mite delete latr")

	var/datum/signal/subspace/messaging/pda/signal = new(owner, list(
		"name" = "???",
		"job" = "???",
		"message" = pick(messages),
		"targets" = list("[owner_pda.owner] ([owner_pda.ownjob])"),
		"automated" = 1,
		"photo" = selfie
	))

	signal.send_to_receivers()

/datum/brain_trauma/special/photo_friend/cute/create_capone()
	if(world.time < capone_appear_delay)
		return

	var/list/turfs = list()
	for(var/obj/structure/window/W in orange(owner, 6))
		var/w_dist = get_dist(owner, W)
		for(var/turf/open/O in orange(W, 1))
			if(O in turfs)
				continue
			if(O.density)
				continue
			if(get_dist(owner, O) <= w_dist)
				continue
			if(locate(/obj/structure/window) in O.contents)
				continue
			turfs += O

	if(turfs.len == 0)
		return 

	var/turf/open/where = pick(turfs)
	capone = new(where, owner)
	capone.victim = owner

/datum/brain_trauma/special/photo_friend/cute/on_life()
	if((world.time > last_snap + min_snap_delay) && prob(2))
		QDEL_NULL(capone)
		send_snap()

	if(QDELETED(capone) || !capone.loc || capone.z != owner.z)
		QDEL_NULL(capone)
		create_capone()
		return

	if(get_dist(owner, capone) >= 9 && prob(10))
		QDEL_NULL(capone)
		create_capone()

	if(get_dist(owner, capone) <= 3)
		//2do: some other effect for this
		QDEL_NULL(capone)

	if(prob(5))
		QDEL_NULL(capone)

	..()
