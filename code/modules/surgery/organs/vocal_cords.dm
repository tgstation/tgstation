#define COOLDOWN_STUN 1200
#define COOLDOWN_DAMAGE 600
#define COOLDOWN_MEME 300
#define COOLDOWN_NONE 100

/obj/item/organ/vocal_cords //organs that are activated through speech with the :x channel
	name = "vocal cords"
	icon_state = "appendix"
	zone = "mouth"
	slot = "vocal_cords"
	gender = PLURAL
	var/list/spans = null

/obj/item/organ/vocal_cords/proc/can_speak_with() //if there is any limitation to speaking with these cords
	return TRUE

/obj/item/organ/vocal_cords/proc/speak_with(message) //do what the organ does
	return

/obj/item/organ/vocal_cords/proc/handle_speech(message) //actually say the message
	owner.say(message, spans = spans, sanitize = FALSE)

/obj/item/organ/adamantine_resonator
	name = "adamantine resonator"
	desc = "Fragments of adamantine exists in all golems, stemming from their origins as purely magical constructs. These are used to \"hear\" messages from their leaders."
	zone = "head"
	slot = "adamantine_resonator"
	icon_state = "adamantine_resonator"

/obj/item/organ/vocal_cords/adamantine
	name = "adamantine vocal cords"
	desc = "When adamantine resonates, it causes all nearby pieces of adamantine to resonate as well. Adamantine golems use this to broadcast messages to nearby golems."
	actions_types = list(/datum/action/item_action/organ_action/use/adamantine_vocal_cords)
	zone = "mouth"
	slot = "vocal_cords"
	icon_state = "adamantine_cords"

/datum/action/item_action/organ_action/use/adamantine_vocal_cords/Trigger()
	if(!IsAvailable())
		return
	var/message = input(owner, "Resonate a message to all nearby golems.", "Resonate")
	if(QDELETED(src) || QDELETED(owner) || !message)
		return
	owner.say(".x[message]")

/obj/item/organ/vocal_cords/adamantine/handle_speech(message)
	var/msg = "<span class='resonate'><span class='name'>[owner.real_name]</span> <span class='message'>resonates, \"[message]\"</span></span>"
	for(var/m in GLOB.player_list)
		if(iscarbon(m))
			var/mob/living/carbon/C = m
			if(C.getorganslot("adamantine_resonator"))
				to_chat(C, msg)
		if(isobserver(m))
			var/link = FOLLOW_LINK(m, owner)
			to_chat(m, "[link] [msg]")

//Colossus drop, forces the listeners to obey certain commands
/obj/item/organ/vocal_cords/colossus
	name = "divine vocal cords"
	desc = "They carry the voice of an ancient god."
	icon_state = "voice_of_god"
	zone = "mouth"
	slot = "vocal_cords"
	actions_types = list(/datum/action/item_action/organ_action/colossus)
	var/next_command = 0
	var/cooldown_mod = 1
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
			to_chat(owner, "<span class='notice'>You must wait [(cords.next_command - world.time)/10] seconds before Speaking again.</span>")
		return
	var/command = input(owner, "Speak with the Voice of God", "Command")
	if(QDELETED(src) || QDELETED(owner))
		return
	if(!command)
		return
	owner.say(".x[command]")

/obj/item/organ/vocal_cords/colossus/can_speak_with()
	if(world.time < next_command)
		to_chat(owner, "<span class='notice'>You must wait [(next_command - world.time)/10] seconds before Speaking again.</span>")
		return FALSE
	if(!owner)
		return FALSE
	if(!owner.can_speak())
		to_chat(owner, "<span class='warning'>You are unable to speak!</span>")
		return FALSE
	return TRUE

/obj/item/organ/vocal_cords/colossus/handle_speech(message)
	owner.say(uppertext(message), spans = spans, sanitize = FALSE)
	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)
	return //voice of god speaks for us

/obj/item/organ/vocal_cords/colossus/speak_with(message)
	var/cooldown = voice_of_god(message, owner, spans, base_multiplier)
	next_command = world.time + (cooldown * cooldown_mod)

//////////////////////////////////////
///////////VOICE OF GOD///////////////
//////////////////////////////////////

/proc/voice_of_god(message, mob/living/user, list/span_list, base_multiplier = 1)
	var/cooldown = 0

	if(!user || !user.can_speak() || user.stat)
		return 0 //no cooldown

	var/log_message = uppertext(message)
	if(!span_list || !span_list.len)
		if(iscultist(user))
			span_list = list("narsiesmall")
		else if (is_servant_of_ratvar(user))
			span_list = list("ratvar")
		else
			span_list = list()

	message = lowertext(message)
	var/mob/living/list/listeners = list()
	for(var/mob/living/L in get_hearers_in_view(8, user))
		if(L.can_hear() && !L.null_rod_check() && L != user && L.stat != DEAD)
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
					continue
			listeners += L

	if(!listeners.len)
		cooldown = COOLDOWN_NONE
		return cooldown

	var/power_multiplier = base_multiplier

	if(user.mind)
		//Chaplains are very good at speaking with the voice of god
		if(user.mind.assigned_role == "Chaplain")
			power_multiplier *= 2
		//Command staff has authority
		if(user.mind.assigned_role in GLOB.command_positions)
			power_multiplier *= 1.4
		//Why are you speaking
		if(user.mind.assigned_role == "Mime")
			power_multiplier *= 0.5

	//Cultists are closer to their gods and are more powerful, but they'll give themselves away
	if(iscultist(user))
		power_multiplier *= 2
	else if (is_servant_of_ratvar(user))
		power_multiplier *= 2

	//Try to check if the speaker specified a name or a job to focus on
	var/list/specific_listeners = list()
	var/found_string = null

	//Get the proper job titles
	message = get_full_job_name(message)

	for(var/V in listeners)
		var/mob/living/L = V
		if(L.mind && L.mind.devilinfo && findtext(message, L.mind.devilinfo.truename))
			var/start = findtext(message, L.mind.devilinfo.truename)
			listeners = list(L) //let's be honest you're never going to find two devils with the same name
			power_multiplier *= 5 //if you're a devil and god himself addressed you, you fucked up
			//Cut out the name so it doesn't trigger commands
			message = copytext(message, 0, start)+copytext(message, start + length(L.mind.devilinfo.truename), length(message) + 1)
			break
		else if(dd_hasprefix(message, L.real_name))
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.real_name

		else if(dd_hasprefix(message, L.first_name()))
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.first_name()

		else if(L.mind && dd_hasprefix(message, L.mind.assigned_role))
			specific_listeners += L //focus on those with the specified job
			//Cut out the job so it doesn't trigger commands
			found_string = L.mind.assigned_role

	if(specific_listeners.len)
		listeners = specific_listeners
		power_multiplier *= (1 + (1/specific_listeners.len)) //2x on a single guy, 1.5x on two and so on
		message = copytext(message, 0, 1)+copytext(message, 1 + length(found_string), length(message) + 1)

	var/static/regex/stun_words = regex("stop|wait|stand still|hold on|halt")
	var/static/regex/weaken_words = regex("drop|fall|trip|weaken")
	var/static/regex/sleep_words = regex("sleep|slumber|rest")
	var/static/regex/vomit_words = regex("vomit|throw up")
	var/static/regex/silence_words = regex("shut up|silence|ssh|quiet|hush")
	var/static/regex/hallucinate_words = regex("see the truth|hallucinate")
	var/static/regex/wakeup_words = regex("wake up|awaken")
	var/static/regex/heal_words = regex("live|heal|survive|mend|heroes never die")
	var/static/regex/hurt_words = regex("die|suffer|hurt|pain")
	var/static/regex/bleed_words = regex("bleed|there will be blood")
	var/static/regex/burn_words = regex("burn|ignite")
	var/static/regex/hot_words = regex("heat|hot|hell")
	var/static/regex/cold_words = regex("cold|cool down|chill|freeze")
	var/static/regex/repulse_words = regex("shoo|go away|leave me alone|begone|flee|fus ro dah|get away|repulse")
	var/static/regex/attract_words = regex("come here|come to me|get over here|attract")
	var/static/regex/whoareyou_words = regex("who are you|say your name|state your name|identify")
	var/static/regex/saymyname_words = regex("say my name|who am i|whoami")
	var/static/regex/knockknock_words = regex("knock knock")
	var/static/regex/statelaws_words = regex("state laws|state your laws")
	var/static/regex/move_words = regex("move|walk")
	var/static/regex/left_words = regex("left|west|port")
	var/static/regex/right_words = regex("right|east|starboard")
	var/static/regex/up_words = regex("up|north|fore")
	var/static/regex/down_words = regex("down|south|aft")
	var/static/regex/walk_words = regex("slow down")
	var/static/regex/run_words = regex("run")
	var/static/regex/helpintent_words = regex("help|hug")
	var/static/regex/disarmintent_words = regex("disarm")
	var/static/regex/grabintent_words = regex("grab")
	var/static/regex/harmintent_words = regex("harm|fight|punch")
	var/static/regex/throwmode_words = regex("throw|catch")
	var/static/regex/flip_words = regex("flip|rotate|revolve|roll|somersault")
	var/static/regex/speak_words = regex("speak|say something")
	var/static/regex/getup_words = regex("get up")
	var/static/regex/sit_words = regex("sit")
	var/static/regex/stand_words = regex("stand")
	var/static/regex/dance_words = regex("dance")
	var/static/regex/jump_words = regex("jump")
	var/static/regex/salute_words = regex("salute")
	var/static/regex/deathgasp_words = regex("play dead")
	var/static/regex/clap_words = regex("clap|applaud")
	var/static/regex/honk_words = regex("ho+nk") //hooooooonk
	var/static/regex/multispin_words = regex("like a record baby|right round")

	//STUN
	if(findtext(message, stun_words))
		cooldown = COOLDOWN_STUN
		for(var/V in listeners)
			var/mob/living/L = V
			L.Stun(3 * power_multiplier)

	//WEAKEN
	else if(findtext(message, weaken_words))
		cooldown = COOLDOWN_STUN
		for(var/V in listeners)
			var/mob/living/L = V
			L.Weaken(3 * power_multiplier)

	//SLEEP
	else if((findtext(message, sleep_words)))
		cooldown = COOLDOWN_STUN
		for(var/mob/living/carbon/C in listeners)
			C.Sleeping(2 * power_multiplier)

	//VOMIT
	else if((findtext(message, vomit_words)))
		cooldown = COOLDOWN_STUN
		for(var/mob/living/carbon/C in listeners)
			C.vomit(10 * power_multiplier)

	//SILENCE
	else if((findtext(message, silence_words)))
		cooldown = COOLDOWN_STUN
		for(var/mob/living/carbon/C in listeners)
			if(user.mind && (user.mind.assigned_role == "Curator" || user.mind.assigned_role == "Mime"))
				power_multiplier *= 3
			C.silent += (10 * power_multiplier)

	//HALLUCINATE
	else if((findtext(message, hallucinate_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			new /obj/effect/hallucination/delusion(get_turf(L),L,duration=150 * power_multiplier,skip_nearby=0)

	//WAKE UP
	else if((findtext(message, wakeup_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.SetSleeping(0)

	//HEAL
	else if((findtext(message, heal_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier, 0, 0)

	//BRUTE DAMAGE
	else if((findtext(message, hurt_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.apply_damage(15 * power_multiplier, def_zone = "chest")

	//BLEED
	else if((findtext(message, bleed_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/mob/living/carbon/human/H in listeners)
			H.bleed_rate += (5 * power_multiplier)

	//FIRE
	else if((findtext(message, burn_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.adjust_fire_stacks(1 * power_multiplier)
			L.IgniteMob()

	//HOT
	else if((findtext(message, hot_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.bodytemperature += (50 * power_multiplier)

	//COLD
	else if((findtext(message, cold_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.bodytemperature -= (50 * power_multiplier)

	//REPULSE
	else if((findtext(message, repulse_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			var/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(L, user)))
			L.throw_at(throwtarget, 3 * power_multiplier, 1 * power_multiplier)

	//ATTRACT
	else if((findtext(message, attract_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.throw_at(get_step_towards(user,L), 3 * power_multiplier, 1 * power_multiplier)

	//WHO ARE YOU?
	else if((findtext(message, whoareyou_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.mind && L.mind.devilinfo)
				L.say("[L.mind.devilinfo.truename]")
			else
				L.say("[L.real_name]")
			sleep(5) //So the chat flows more naturally

	//SAY MY NAME
	else if((findtext(message, saymyname_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("[user.name]!") //"Unknown!"
			sleep(5) //So the chat flows more naturally

	//KNOCK KNOCK
	else if((findtext(message, knockknock_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("Who's there?")
			sleep(5) //So the chat flows more naturally

	//STATE LAWS
	else if((findtext(message, statelaws_words)))
		cooldown = COOLDOWN_STUN
		for(var/mob/living/silicon/S in listeners)
			S.statelaws(force = 1)

	//MOVE
	else if((findtext(message, move_words)))
		cooldown = COOLDOWN_MEME
		var/direction
		if(findtext(message, up_words))
			direction = NORTH
		else if(findtext(message, down_words))
			direction = SOUTH
		else if(findtext(message, left_words))
			direction = WEST
		else if(findtext(message, right_words))
			direction = EAST
		for(var/i=1, i<=(5*power_multiplier), i++)
			for(var/V in listeners)
				var/mob/living/L = V
				step(L, direction ? direction : pick(GLOB.cardinal))
			sleep(10)

	//WALK
	else if((findtext(message, walk_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.m_intent != MOVE_INTENT_WALK)
				L.toggle_move_intent()

	//RUN
	else if((findtext(message, run_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.m_intent != MOVE_INTENT_RUN)
				L.toggle_move_intent()

	//HELP INTENT
	else if((findtext(message, helpintent_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HELP)
			H.click_random_mob()
			sleep(2) //delay to make it feel more natural

	//DISARM INTENT
	else if((findtext(message, disarmintent_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_DISARM)
			H.click_random_mob()
			sleep(2) //delay to make it feel more natural

	//GRAB INTENT
	else if((findtext(message, grabintent_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_GRAB)
			H.click_random_mob()
			sleep(2) //delay to make it feel more natural

	//HARM INTENT
	else if((findtext(message, harmintent_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HARM)
			H.click_random_mob()
			sleep(2) //delay to make it feel more natural

	//THROW/CATCH
	else if((findtext(message, throwmode_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/C in listeners)
			C.throw_mode_on()

	//FLIP
	else if((findtext(message, flip_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("flip")

	//SPEAK
	else if((findtext(message, speak_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.say(pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage"))
			sleep(5) //So the chat flows more naturally

	//GET UP
	else if((findtext(message, getup_words)))
		cooldown = COOLDOWN_DAMAGE //because stun removal
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.resting)
				L.lay_down() //aka get up
			L.SetStunned(0)
			L.SetWeakened(0)
			L.SetParalysis(0) //i said get up i don't care if you're being tazed

	//SIT
	else if((findtext(message, sit_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			for(var/obj/structure/chair/chair in get_turf(L))
				chair.buckle_mob(L)
				break

	//STAND UP
	else if((findtext(message, stand_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.buckled && istype(L.buckled, /obj/structure/chair))
				L.buckled.unbuckle_mob(L)

	//DANCE
	else if((findtext(message, dance_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("dance")
			sleep(5) //So the chat flows more naturally

	//JUMP
	else if((findtext(message, jump_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(prob(25))
				L.say("HOW HIGH?!!")
			L.emote("jump")
			sleep(5) //So the chat flows more naturally

	//SALUTE
	else if((findtext(message, salute_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("salute")
			sleep(5) //So the chat flows more naturally

	//PLAY DEAD
	else if((findtext(message, deathgasp_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("deathgasp")
			sleep(5) //So the chat flows more naturally

	//PLEASE CLAP
	else if((findtext(message, clap_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("clap")
			sleep(5) //So the chat flows more naturally

	//HONK
	else if((findtext(message, honk_words)))
		cooldown = COOLDOWN_MEME
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(user), 'sound/items/bikehorn.ogg', 300, 1), 25)
		if(user.mind && user.mind.assigned_role == "Clown")
			for(var/mob/living/carbon/C in listeners)
				C.slip(0,7 * power_multiplier)
			cooldown = COOLDOWN_MEME

	//RIGHT ROUND
	else if((findtext(message, multispin_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.SpinAnimation(speed = 10, loops = 5)

	else
		cooldown = COOLDOWN_NONE

	message_admins("[key_name_admin(user)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	log_game("[key_name(user)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")

	return cooldown


#undef COOLDOWN_STUN
#undef COOLDOWN_DAMAGE
#undef COOLDOWN_MEME
#undef COOLDOWN_NONE
