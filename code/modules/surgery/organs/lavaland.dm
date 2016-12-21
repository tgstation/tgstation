/obj/item/organ/colossus
	name = "Voice of God"
	icon_state = "voice_of_god"
	zone = "mouth"
	slot = "vocal_cords"
	actions_types = list(/datum/action/item_action/organ_action/colossus)

/datum/action/item_action/organ_action/colossus
	name = "Voice of God"
	var/next_command = null
	var/cooldown_stun = 900
	var/cooldown_damage = 750
	var/cooldown_meme = 450
	var/cooldown_none = 150

/datum/action/item_action/organ_action/colossus/IsAvailable()
	if(world.time < next_command)
		return 0
	if(!owner)
		return 0
	if(!owner.can_speak())
		return 0
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return 0
	return 1

/datum/action/item_action/organ_action/colossus/Trigger()
	. = ..()
	var/command = stripped_input(owner, "Speak with the Voice of God", "Command", max_length = 140)
	if(!command)
		return
	var/mob/living/list/listeners = list()
	for(var/mob/living/L in get_hearers_in_view(8, owner))
		if(!L.ear_deaf && L != owner && L.stat != DEAD)
			listeners += L
	if(!IsAvailable())
		owner << "<span class='notice'>You must wait [(next_command - world.time)/10] seconds before Speaking again.</span>"
		return
	var/spoken = uppertext(command)
	owner.say(spoken, spans = list("colossus","yell"))
	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)

	//STUN
	if(findtext(command, "stop") || findtext(command, "wait") || findtext(command, "stand still") || findtext(command, "hold on") || findtext(command, "halt"))
		for(var/mob/living/L in listeners)
			L.Stun(3)
		next_command = world.time + cooldown_stun

	//WEAKEN
	else if(findtext(command, "drop") || findtext(command, "fall"))
		for(var/mob/living/L in listeners)
			L.Weaken(3)
		next_command = world.time + cooldown_stun

	//SLEEP
	else if(findtext(command, "sleep"))
		for(var/mob/living/L in listeners)
			L.Sleeping(3)
		next_command = world.time + cooldown_stun

	//VOMIT
	else if(findtext(command, "vomit") || findtext(command, "throw up"))
		for(var/mob/living/carbon/C in listeners)
			C.vomit(10)
		next_command = world.time + cooldown_stun

	//SILENCE
	else if(findtext(command, "shut up") || findtext(command, "silence") || findtext(command, "ssh") || findtext(command, "quiet"))
		for(var/mob/living/carbon/C in listeners)
			C.silent += 10
		next_command = world.time + cooldown_stun

	//WAKE UP
	else if(findtext(command, "wake up") || findtext(command, "awaken"))
		for(var/mob/living/L in listeners)
			L.SetSleeping(0)
		next_command = world.time + cooldown_damage

	//BRUTE DAMAGE
	else if(findtext(command, "die"))
		for(var/mob/living/L in listeners)
			L.apply_damage(15, def_zone = "chest")
		next_command = world.time + cooldown_damage

	//BLEED
	else if(findtext(command, "bleed"))
		for(var/mob/living/carbon/human/H in listeners)
			H.bleed_rate += 5
		next_command = world.time + cooldown_damage

	//FIRE
	else if(findtext(command, "burn") || findtext(command, "ignite") || findtext(command, "hell"))
		for(var/mob/living/L in listeners)
			L.adjust_fire_stacks(0.8)
			L.IgniteMob()
		next_command = world.time + cooldown_damage

	//HEAL
	else if(findtext(command, "live") || findtext(command, "heal") || findtext(command, "survive"))
		for(var/mob/living/L in listeners)
			L.heal_overall_damage(10, 10, 0, 0)
		next_command = world.time + cooldown_damage

	//REPULSE
	else if(findtext(command, "shoo") || findtext(command, "go away") || findtext(command, "leave me alone") || findtext(command, "begone") || findtext(command, "flee") || findtext(command, "fus ro dah"))
		for(var/mob/living/L in listeners)
			var/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
			L.throw_at_fast(throwtarget, 3, 1)
		next_command = world.time + cooldown_damage

	//MOVE
	else if(findtext(command, "move"))
		for(var/mob/living/L in listeners)
			var/turf/T = get_step(L,pick(cardinal))
			L.Move(T)
		next_command = world.time + cooldown_meme

	//WALK
	else if(findtext(command, "walk") || findtext(command, "slow down"))
		for(var/mob/living/L in listeners)
			L.m_intent = MOVE_INTENT_WALK
		next_command = world.time + cooldown_meme

	//RUN
	else if(findtext(command, "run"))
		for(var/mob/living/L in listeners)
			L.m_intent = MOVE_INTENT_RUN
		next_command = world.time + cooldown_meme

	//HELP INTENT
	else if(findtext(command, "help"))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HELP)
		next_command = world.time + cooldown_meme

	//DISARM INTENT
	else if(findtext(command, "disarm"))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_DISARM)
		next_command = world.time + cooldown_meme

	//GRAB INTENT
	else if(findtext(command, "grab"))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_GRAB)
		next_command = world.time + cooldown_meme

	//HARM INTENT
	else if(findtext(command, "harm") || findtext(command, "fight"))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HARM)
		next_command = world.time + cooldown_meme

	//THROW/CATCH
	else if(findtext(command, "throw") || findtext(command, "catch"))
		for(var/mob/living/carbon/C in listeners)
			C.throw_mode_on()
		next_command = world.time + cooldown_meme

	//FLIP
	else if(findtext(command, "flip") || findtext(command, "rotate") || findtext(command, "revolve") || findtext(command, "roll"))
		for(var/mob/living/L in listeners)
			L.emote("flip")
		next_command = world.time + cooldown_meme

	//SIT
	else if(findtext(command, "sit"))
		for(var/mob/living/L in listeners)
			for(var/obj/structure/chair/chair in get_turf(L))
				chair.buckle_mob(L)
				break
		next_command = world.time + cooldown_meme

	//STAND UP
	else if(findtext(command, "stand"))
		for(var/mob/living/L in listeners)
			if(L.buckled && istype(L.buckled, /obj/structure/chair))
				L.buckled.unbuckle_mob(L)
		next_command = world.time + cooldown_meme

	//DANCE
	else if(findtext(command, "dance"))
		for(var/mob/living/L in listeners)
			L.emote("dance")
		next_command = world.time + cooldown_meme

	//JUMP
	else if(findtext(command, "jump"))
		for(var/mob/living/L in listeners)
			L.say("HOW HIGH?!!")
			L.emote("jump")
		next_command = world.time + cooldown_meme

	//SALUTE
	else if(findtext(command, "salute"))
		for(var/mob/living/L in listeners)
			L.emote("salute")
		next_command = world.time + cooldown_meme

	//PLAY DEAD
	else if(findtext(command, "play dead"))
		for(var/mob/living/L in listeners)
			L.emote("deathgasp")
		next_command = world.time + cooldown_meme

	//PLEASE CLAP
	else if(findtext(command, "clap"))
		for(var/mob/living/L in listeners)
			L.emote("clap")
		next_command = world.time + cooldown_meme

	//HONK
	else if(findtext(command, "honk"))
		playsound(get_turf(owner), "sound/items/bikehorn.ogg", 300, 1)
		if(owner.mind && owner.mind.assigned_role == "Clown")
			for(var/mob/living/carbon/C in listeners)
				C.slip(0,5)
		next_command = world.time + cooldown_meme

	//RIGHT ROUND
	else if(findtext(command, "like a record baby"))
		for(var/mob/living/L in listeners)
			L.SpinAnimation(speed = 10, loops = 5)
		next_command = world.time + cooldown_meme

	else
		next_command = world.time + cooldown_none

