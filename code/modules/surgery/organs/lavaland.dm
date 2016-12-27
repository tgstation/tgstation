/obj/item/organ/vocal_cords/colossus
	name = "divine vocal cords"
	icon_state = "voice_of_god"
	zone = "mouth"
	slot = "vocal_cords"
	actions_types = list(/datum/action/item_action/organ_action/colossus)
	var/next_command = 0
	var/cooldown_stun = 900
	var/cooldown_damage = 600
	var/cooldown_meme = 300
	var/cooldown_none = 150
	var/base_multiplier = 1
	spans = list("colossus","yell")

/datum/action/item_action/organ_action/colossus
	name = "Voice of God"
	var/obj/item/organ/vocal_cords/colossus/cords = null

/datum/action/item_action/organ_action/colossus/New()
	..()
	cords = target

/datum/action/item_action/organ_action/colossus/IsAvailable()
	if(world.time < cords.next_command)
		return FALSE
	if(!owner)
		return FALSE
	if(!owner.can_speak())
		return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return FALSE
	return TRUE

/datum/action/item_action/organ_action/colossus/Trigger()
	. = ..()
	if(!IsAvailable())
		if(world.time < cords.next_command)
			owner << "<span class='notice'>You must wait [(cords.next_command - world.time)/10] seconds before Speaking again.</span>"
		return
	var/command = stripped_input(owner, "Speak with the Voice of God", "Command", max_length = 140)
	if(!command)
		return
	owner.say(".x[command]")

/obj/item/organ/vocal_cords/colossus/can_speak_with()
	if(world.time < next_command)
		owner << "<span class='notice'>You must wait [(next_command - world.time)/10] seconds before Speaking again.</span>"
		return FALSE
	if(!owner)
		return FALSE
	if(!owner.can_speak())
		owner << "<span class='warning'>You are unable to speak!</span>"
		return FALSE
	if(owner.stat)
		return FALSE
	return TRUE

/obj/item/organ/vocal_cords/colossus/speak_with(message)
	var/spoken = uppertext(message)
	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)

	var/mob/living/list/listeners = list()
	for(var/mob/living/L in get_hearers_in_view(8, owner))
		if(!L.ear_deaf && L != owner && L.stat != DEAD)
			listeners += L

	if(!listeners.len)
		next_command = world.time + cooldown_none
		return

	var/power_multiplier = base_multiplier
	spans = initial(spans) //reset spans, just in case someone gets deculted or the cords change owner

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

	//Cultists are closer to their gods and are more powerful, but they'll give themselves away
	if(iscultist(owner))
		power_multiplier *= 2
		spans = list("narsie")
	else if (is_servant_of_ratvar(owner))
		power_multiplier *= 2
		spans = list("ratvar")

	for(var/V in listeners)
		var/mob/living/L = V
		var/start
		if(L.mind && L.mind.devilinfo && findtext(message, L.mind.devilinfo.truename))
			start = findtext(message, L.mind.devilinfo.truename)
			listeners = list(L)
			power_multiplier *= 5 //if you're a devil and god himself addressed you, you fucked up
			//Cut out the name so it doesn't trigger commands
			message = copytext(message, 0, start)+copytext(message, start + length(L.mind.devilinfo.truename), length(message) + 1)
			break
		else if(findtext(message, L.real_name))
			start = findtext(message, L.real_name)
			listeners = list(L) //focus on a particular person
			power_multiplier *= 2
			//Cut out the name so it doesn't trigger commands
			message = copytext(message, 0, start)+copytext(message, start + length(L.real_name), length(message) + 1)
			break

	//STUN
	if(text_in_list(message, list("stop","wait","stand still","hold on","halt")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Stun(3 * power_multiplier)
		next_command = world.time + cooldown_stun

	//WEAKEN
	else if(text_in_list(message, list("drop","fall")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Weaken(3 * power_multiplier)
		next_command = world.time + cooldown_stun

	//SLEEP
	else if(text_in_list(message, list("sleep")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Sleeping(3 * power_multiplier)
		next_command = world.time + cooldown_stun

	//VOMIT
	else if(text_in_list(message, list("vomit","throw up")))
		for(var/mob/living/carbon/C in listeners)
			C.vomit(10 * power_multiplier)
		next_command = world.time + cooldown_stun

	//SILENCE
	else if(text_in_list(message, list("shut up","silence","ssh","quiet","hush")))
		for(var/mob/living/carbon/C in listeners)
			if(owner.mind && (owner.mind.assigned_role == "Librarian" || owner.mind.assigned_role == "Mime"))
				power_multiplier *= 3
			C.silent += (10 * power_multiplier)
		next_command = world.time + cooldown_stun

	//HALLUCINATE
	else if(text_in_list(message, list("see the truth","hallucinate")))
		for(var/V in listeners)
			var/mob/living/L = V
			new /obj/effect/hallucination/delusion(get_turf(L),L,duration=150 * power_multiplier,skip_nearby=0)
		next_command = world.time + cooldown_damage

	//WAKE UP
	else if(text_in_list(message, list("wake up","awaken")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.SetSleeping(0)
		next_command = world.time + cooldown_damage

	//HEAL
	else if(text_in_list(message, list("live","heal","survive","mend","heroes never die")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier, 0, 0)
		next_command = world.time + cooldown_damage

	//BRUTE DAMAGE
	else if(text_in_list(message, list("die","suffer")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.apply_damage(15 * power_multiplier, def_zone = "chest")
		next_command = world.time + cooldown_damage

	//BLEED
	else if(text_in_list(message, list("bleed")))
		for(var/mob/living/carbon/human/H in listeners)
			H.bleed_rate += (5 * power_multiplier)
		next_command = world.time + cooldown_damage

	//FIRE
	else if(text_in_list(message, list("burn","ignite","hell")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.adjust_fire_stacks(1 * power_multiplier)
			L.IgniteMob()
		next_command = world.time + cooldown_damage

	//REPULSE
	else if(text_in_list(message, list("shoo","go away","leave me alone","begone","flee","fus ro dah")))
		for(var/V in listeners)
			var/mob/living/L = V
			var/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
			L.throw_at_fast(throwtarget, 3 * power_multiplier, 1)
		next_command = world.time + cooldown_damage

	//WHO ARE YOU?
	else if(text_in_list(message, list("who are you","say your name","state your name","identify")))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.mind && L.mind.devilinfo)
				L.say("[L.mind.devilinfo.truename]")
			else
				L.say("[L.real_name]")
		next_command = world.time + cooldown_meme

	//SAY MY NAME
	else if(text_in_list(message, list("say my name")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("[owner.name]!") //"Unknown!"
		next_command = world.time + cooldown_meme

	//KNOCK KNOCK
	else if(text_in_list(message, list("knock knock")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("Who's there?")
		next_command = world.time + cooldown_meme

	//STATE LAWS
	else if(text_in_list(message, list("state laws","state your laws")))
		for(var/mob/living/silicon/S in listeners)
			S.statelaws()
		next_command = world.time + cooldown_meme

	//MOVE
	else if(text_in_list(message, list("move")))
		for(var/V in listeners)
			var/mob/living/L = V
			step(L, pick(cardinal))
		next_command = world.time + cooldown_meme

	//WALK
	else if(text_in_list(message, list("walk","slow down")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.m_intent = MOVE_INTENT_WALK
		next_command = world.time + cooldown_meme

	//RUN
	else if(text_in_list(message, list("run")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.m_intent = MOVE_INTENT_RUN
		next_command = world.time + cooldown_meme

	//HELP INTENT
	else if(text_in_list(message, list("help")))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HELP)
		next_command = world.time + cooldown_meme

	//DISARM INTENT
	else if(text_in_list(message, list("disarm")))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_DISARM)
		next_command = world.time + cooldown_meme

	//GRAB INTENT
	else if(text_in_list(message, list("grab")))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_GRAB)
		next_command = world.time + cooldown_meme

	//HARM INTENT
	else if(text_in_list(message, list("harm","fight")))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HARM)
		next_command = world.time + cooldown_meme

	//THROW/CATCH
	else if(text_in_list(message, list("throw","catch")))
		for(var/mob/living/carbon/C in listeners)
			C.throw_mode_on()
		next_command = world.time + cooldown_meme

	//FLIP
	else if(text_in_list(message, list("flip","rotate","revolve","roll","somersault")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("flip")
		next_command = world.time + cooldown_meme

	//REST
	else if(text_in_list(message, list("rest")))
		for(var/V in listeners)
			var/mob/living/L = V
			if(!L.resting)
				L.lay_down()
		next_command = world.time + cooldown_meme

	//GET UP
	else if(text_in_list(message, list("get up")))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.resting)
				L.lay_down() //aka get up
			L.SetStunned(0)
			L.SetWeakened(0)
			L.SetParalysis(0) //i said get up i don't care if you're being tazed
		next_command = world.time + cooldown_damage

	//SIT
	else if(text_in_list(message, list("sit")))
		for(var/V in listeners)
			var/mob/living/L = V
			for(var/obj/structure/chair/chair in get_turf(L))
				chair.buckle_mob(L)
				break
		next_command = world.time + cooldown_meme

	//STAND UP
	else if(text_in_list(message, list("stand")))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.buckled && istype(L.buckled, /obj/structure/chair))
				L.buckled.unbuckle_mob(L)
		next_command = world.time + cooldown_meme

	//DANCE
	else if(text_in_list(message, list("dance")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("dance")
		next_command = world.time + cooldown_meme

	//JUMP
	else if(text_in_list(message, list("jump")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("HOW HIGH?!!")
			L.emote("jump")
		next_command = world.time + cooldown_meme

	//SALUTE
	else if(text_in_list(message, list("salute")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("salute")
		next_command = world.time + cooldown_meme

	//PLAY DEAD
	else if(text_in_list(message, list("play dead")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("deathgasp")
		next_command = world.time + cooldown_meme

	//PLEASE CLAP
	else if(text_in_list(message, list("clap","applaud")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("clap")
		next_command = world.time + cooldown_meme

	//HONK
	else if(text_in_list(message, list("honk")))
		addtimer(GLOBAL_PROC, "playsound", 25, TIMER_NORMAL, get_turf(owner), "sound/items/bikehorn.ogg", 300, 1)
		if(owner.mind && owner.mind.assigned_role == "Clown")
			for(var/mob/living/carbon/C in listeners)
				C.slip(0,7 * power_multiplier)
		next_command = world.time + cooldown_meme

	//RIGHT ROUND
	else if(text_in_list(message, list("like a record baby")))
		for(var/V in listeners)
			var/mob/living/L = V
			L.SpinAnimation(speed = 10, loops = 5)
		next_command = world.time + cooldown_meme

	else
		next_command = world.time + cooldown_none

	return spoken

