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
	var/cooldown_damage = 600
	var/cooldown_meme = 300
	var/cooldown_none = 150
	var/base_multiplier = 1

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
		if(world.time < next_command)
			owner << "<span class='notice'>You must wait [(next_command - world.time)/10] seconds before Speaking again.</span>"
		return

	var/spoken = uppertext(command)
	owner.say(spoken, spans = list("colossus","yell"))
	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)

	if(!listeners.len)
		next_command = world.time + cooldown_none
		return

	var/power_multiplier = base_multiplier

	if(owner.mind)
		//Chaplains are very good at speaking with the voice of god
		if(owner.mind.assigned_role == "Chaplain")
			power_multiplier *= 2
		//Command staff has authority
		if(owner.mind.assigned_role in command_positions)
			power_multiplier *= 1.4
		//Why are you speaking
		if(owner.mind.assigned_role == "Mime")
			power_multiplier *= 0.5

	//WGW
	if(findtext(command, "one day, while andy") || findtext(command, "one day while andy"))
		if(isliving(owner))
			var/mob/living/self = owner
			self.adjust_fire_stacks(20 * power_multiplier)
			self.IgniteMob()
		next_command = world.time + cooldown_meme

	//STUN
	else if(findtext(command, "stop") || findtext(command, "wait") || findtext(command, "stand still") || findtext(command, "hold on") || findtext(command, "halt"))
		for(var/mob/living/L in listeners)
			L.Stun(3 * power_multiplier)
		next_command = world.time + cooldown_stun

	//WEAKEN
	else if(findtext(command, "drop") || findtext(command, "fall"))
		for(var/mob/living/L in listeners)
			L.Weaken(3 * power_multiplier)
		next_command = world.time + cooldown_stun

	//SLEEP
	else if(findtext(command, "sleep"))
		for(var/mob/living/L in listeners)
			L.Sleeping(3 * power_multiplier)
		next_command = world.time + cooldown_stun

	//VOMIT
	else if(findtext(command, "vomit") || findtext(command, "throw up"))
		for(var/mob/living/carbon/C in listeners)
			C.vomit(10 * power_multiplier)
		next_command = world.time + cooldown_stun

	//SILENCE
	else if(findtext(command, "shut up") || findtext(command, "silence") || findtext(command, "ssh") || findtext(command, "quiet"))
		for(var/mob/living/carbon/C in listeners)
			C.silent += (10 * power_multiplier)
		next_command = world.time + cooldown_stun

	//HALLUCINATE
	else if(findtext(command, "see the truth") || findtext(command, "hallucinate"))
		for(var/mob/living/L in listeners)
			new /obj/effect/hallucination/delusion(get_turf(L),L,duration=150,skip_nearby=0)
		next_command = world.time + cooldown_damage

	//WAKE UP
	else if(findtext(command, "wake up") || findtext(command, "awaken"))
		for(var/mob/living/L in listeners)
			L.SetSleeping(0)
		next_command = world.time + cooldown_damage

	//BRUTE DAMAGE
	else if(findtext(command, "die") || findtext(command, "suffer"))
		for(var/mob/living/L in listeners)
			L.apply_damage(15 * power_multiplier, def_zone = "chest")
		next_command = world.time + cooldown_damage

	//BLEED
	else if(findtext(command, "bleed"))
		for(var/mob/living/carbon/human/H in listeners)
			H.bleed_rate += (5 * power_multiplier)
		next_command = world.time + cooldown_damage

	//FIRE
	else if(findtext(command, "burn") || findtext(command, "ignite") || findtext(command, "hell"))
		for(var/mob/living/L in listeners)
			L.adjust_fire_stacks(1 * power_multiplier)
			L.IgniteMob()
		next_command = world.time + cooldown_damage

	//HEAL
	else if(findtext(command, "live") || findtext(command, "heal") || findtext(command, "survive"))
		for(var/mob/living/L in listeners)
			L.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier, 0, 0)
		next_command = world.time + cooldown_damage

	//REPULSE
	else if(findtext(command, "shoo") || findtext(command, "go away") || findtext(command, "leave me alone") || findtext(command, "begone") || findtext(command, "flee") || findtext(command, "fus ro dah"))
		for(var/mob/living/L in listeners)
			var/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
			L.throw_at_fast(throwtarget, 3 * power_multiplier, 1)
		next_command = world.time + cooldown_damage

	//WHO ARE YOU?
	else if(findtext(command, "who are you?") || findtext(command, "say your name") || findtext(command, "state your name") || findtext(command, "identify"))
		for(var/mob/living/L in listeners)
			L.say("[L.real_name]")
		next_command = world.time + cooldown_meme

	//SAY MY NAME
	else if(findtext(command, "say my name"))
		for(var/mob/living/L in listeners)
			L.say("[owner.name]")
		next_command = world.time + cooldown_meme

	//KNOCK KNOCK
	else if(findtext(command, "knock knock"))
		for(var/mob/living/L in listeners)
			L.say("Who's there?")
		next_command = world.time + cooldown_meme

	//MOVE
	else if(findtext(command, "state laws") || findtext(command, "state your laws"))
		for(var/mob/living/silicon/S in listeners)
			S.statelaws()
		next_command = world.time + cooldown_meme

	//MOVE
	else if(findtext(command, "move"))
		for(var/mob/living/L in listeners)
			step(L, pick(cardinal))
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
	else if(findtext(command, "flip") || findtext(command, "rotate") || findtext(command, "revolve") || findtext(command, "roll") || findtext(command, "somersault"))
		for(var/mob/living/L in listeners)
			L.emote("flip")
		next_command = world.time + cooldown_meme

	//REST
	else if(findtext(command, "rest"))
		for(var/mob/living/L in listeners)
			L.resting = TRUE
		next_command = world.time + cooldown_meme

	//GET UP
	else if(findtext(command, "get up"))
		for(var/mob/living/L in listeners)
			L.resting = FALSE
			L.SetWeakened(0)
			L.SetParalysis(0)
		next_command = world.time + cooldown_damage

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
	else if(findtext(command, "clap") || findtext(command, "applaud"))
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

