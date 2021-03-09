#define COOLDOWN_STUN 1200
#define COOLDOWN_DAMAGE 600
#define COOLDOWN_MEME 300
#define COOLDOWN_NONE 100

GLOBAL_LIST_INIT(voice_of_god_commands, init_voice_of_god_commands())

/proc/init_voice_of_god_commands()
	. = list()
	for(var/datum/voice_of_god_command/prototype in subtypesof(/datum/voice_of_god_command))
		if(initial(prototype.trigger))
			. += new prototype

//////////////////////////////////////
///////////VOICE OF GOD///////////////
//////////////////////////////////////

/*
 * The main proc for the voice of god power. it makes the user shout a message in an ominous way,
 * The first matching command (from a list of static datums) the listeners must obey,
 * and the return value of this proc the cooldown variable of the command dictates. (only relevant for things with cooldowns i guess)
 */
/proc/voice_of_god(message, mob/living/user, list/span_list, base_multiplier = 1, include_speaker = FALSE, message_admins = TRUE)
	var/log_message = uppertext(message)
	if(!span_list || !span_list.len)
		if(iscultist(user))
			span_list = list("narsiesmall")
		else
			span_list = list()

	if(!user.say(message, spans = span_list, sanitize = FALSE))
		return

	message = lowertext(message)
	var/list/mob/living/listeners = list()
	var/list/candidates = get_hearers_in_view(8, user) - (!include_speaker ? user : null)
	for(var/mob/living/L in candidates)
		if(L.can_hear() && !L.anti_magic_check(FALSE, TRUE) && L.stat != DEAD)
			listeners += L

	if(!listeners.len)
		return

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

	//Try to check if the speaker specified a name or a job to focus on
	var/list/specific_listeners = list()
	var/found_string = null

	//Get the proper job titles
	message = get_full_job_name(message)

	for(var/V in listeners)
		var/mob/living/L = V
		if(findtext(message, L.real_name, 1, length(L.real_name) + 1))
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.real_name

		else if(findtext(message, L.first_name(), 1, length(L.first_name()) + 1))
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.first_name()

		else if(L.mind && L.mind.assigned_role && findtext(message, L.mind.assigned_role, 1, length(L.mind.assigned_role) + 1))
			specific_listeners += L //focus on those with the specified job
			//Cut out the job so it doesn't trigger commands
			found_string = L.mind.assigned_role

	if(specific_listeners.len)
		listeners = specific_listeners
		power_multiplier *= (1 + (1/specific_listeners.len)) //2x on a single guy, 1.5x on two and so on
		message = copytext(message, length(found_string) + 1)

	for(var/datum/voice_of_god_command/command as anything in GLOB.voice_of_god_commands)
		if(findtext(message, command.trigger))
			. = command.execute(listeners, user, power_multiplier, message)

	if(message_admins)
		message_admins("[ADMIN_LOOKUPFLW(user)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	log_game("[key_name(user)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	SSblackbox.record_feedback("tally", "voice_of_god", 1, log_message)

/// Voice of god command datums that are used in [/proc/voice_of_god()]
/datum/voice_of_god_command
	///a text string or regex that triggers the command.
	var/trigger
	/// Is the trigger supposed to be a regex? If so, convert it to such on New()
	var/is_regex = FALSE
	/// cooldown variable which is then returned by [proc/voice_of_god]
	var/cooldown = COOLDOWN_MEME

/datum/voice_of_god_command/New()
	if(is_regex)
		trigger = regex(trigger)

/*
 * What happens when the command is triggered.
 * Args:
 * * listeners: the list of living mobs who are affected by the command.
 * * user: the one who casted Voice of God
 * * power_multiplier: multiplies the power of the command, most times.
 */
/datum/voice_of_god_command/proc/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	return

/datum/voice_of_god_command/stun
	trigger = "stop|wait|stand\\s*still|hold\\s*on|halt"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/stun/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	 // Ensure 'as anything' is not included for loops that don't target all living mob types.
	for(var/mob/living/target as anything in listeners)
		target.Stun(60 * power_multiplier)

/datum/voice_of_god_command/paralyze
	trigger = "drop|fall|trip|knockdown"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/paralyze/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.Paralyze(60 * power_multiplier)

/datum/voice_of_god_command/sleeping
	trigger = "sleep|slumber|rest"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/sleeping/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target as anything in listeners)
		target.Sleeping(40 * power_multiplier)

/datum/voice_of_god_command/vomit
	trigger = "vomit|throw\\s*up|sick"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/vomit/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target as anything in listeners)
		target.vomit(10 * power_multiplier, distance = power_multiplier)

/datum/voice_of_god_command/silence
	trigger = "shut\\s*up|silence|be\\s*silent|ssh|quiet|hush"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/silence/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	if(user.mind && (user.mind.assigned_role == "Curator" || user.mind.assigned_role == "Mime"))
		power_multiplier *= 3
	for(var/mob/living/carbon/target in listeners)
		target.silent += (10 * power_multiplier)

/datum/voice_of_god_command/hallucinate
	trigger = "see\\s*the\\s*truth|hallucinate"

/datum/voice_of_god_command/hallucinate/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target in listeners)
		new /datum/hallucination/delusion(target, TRUE, null, 150 * power_multiplier, 0)

/datum/voice_of_god_command/wake_up
	trigger = "wake\\s*up|awaken"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/wake_up/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.SetSleeping(0)

/datum/voice_of_god_command/heal
	trigger = "live|heal|survive|mend|life|heroes\\s*never\\s*die"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/heal/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier)

/datum/voice_of_god_command/brute
	trigger = "die|suffer|hurt|pain|death"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/brute/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.apply_damage(15 * power_multiplier, def_zone = BODY_ZONE_CHEST, wound_bonus=CANT_WOUND)

/datum/voice_of_god_command/bleed
	trigger = "bleed|there\\s*will\\s*be\\s*blood"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/bleed/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/human/target in listeners)
		var/obj/item/bodypart/chosen_part = pick(target.bodyparts)
		chosen_part.generic_bleedstacks += 5

/datum/voice_of_god_command/burn
	trigger = "burn|ignite"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/burn/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.adjust_fire_stacks(1 * power_multiplier)
		target.IgniteMob()

/datum/voice_of_god_command/hot
	trigger = "heat|hot|hell"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/hot/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.adjust_bodytemperature(50 * power_multiplier)

/datum/voice_of_god_command/cold
	trigger = "cold|chill|freeze"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/cold/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.adjust_bodytemperature(-50 * power_multiplier)

/datum/voice_of_god_command/repulse
	trigger = "shoo|go\\s*away|leave\\s*me\\s*alone|begone|flee|fus\\s*ro\\s*dah|get\\s*away|repulse"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/repulse/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		var/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(target, user)))
		target.throw_at(throwtarget, 3 * power_multiplier, 1 * power_multiplier)

/datum/voice_of_god_command/attract
	trigger = "come\\s*here|come\\s*to\\s*me|get\\s*over\\s*here|attract"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/attract/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.throw_at(get_step_towards(user, target), 3 * power_multiplier, 1 * power_multiplier)

/datum/voice_of_god_command/who_are_you
	trigger = "who\\s*are\\s*you|say\\s*your\\s*name|state\\s*your\\s*name|identify"

/datum/voice_of_god_command/who_are_you/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(target, /atom/movable/proc/say, target.real_name), 5 * iteration)
		iteration++

/datum/voice_of_god_command/say_my_name
	trigger = "say\\s*my\\s*name|who\\s*am\\s*i"

/datum/voice_of_god_command/say_my_name/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(target, /atom/movable/proc/say, user.name), 5 * iteration)
		iteration++

/datum/voice_of_god_command/knock_knock
	trigger = "knock\\s*knock"

/datum/voice_of_god_command/knock_knock/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(target, /atom/movable/proc/say, "Who's there?"), 5 * iteration)
		iteration++

/datum/voice_of_god_command/state_laws
	trigger = "state\\s*(your)?\\s*laws"

/datum/voice_of_god_command/state_laws/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/silicon/target in listeners)
		target.statelaws(force = 1)

/datum/voice_of_god_command/move
	trigger = "move|walk"
	var/static/up_words = regex("up|north|fore")
	var/static/down_words = regex("down|south|aft")
	var/static/left_words = regex("left|west|port")
	var/static/right_words = regex("right|east|starboard")

/datum/voice_of_god_command/move/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	var/direction
	if(findtext(message, up_words))
		direction = NORTH
	else if(findtext(message, down_words))
		direction = SOUTH
	else if(findtext(message, left_words))
		direction = WEST
	else if(findtext(message, right_words))
		direction = EAST
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/_step, target, direction? direction : pick(GLOB.cardinals)), 10 * (iteration - 1))
		iteration++

/datum/voice_of_god_command/walk
	trigger = "slow\\s*down"

/datum/voice_of_god_command/walk/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		if(target.m_intent != MOVE_INTENT_WALK)
			target.toggle_move_intent()

/datum/voice_of_god_command/run
	trigger = "run"
	is_regex = FALSE

/datum/voice_of_god_command/walk/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		if(target.m_intent != MOVE_INTENT_RUN)
			target.toggle_move_intent()

/datum/voice_of_god_command/throw_catch
	trigger = "throw|catch"

/datum/voice_of_god_command/throw_catch/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target in listeners)
		target.throw_mode_on(THROW_MODE_TOGGLE)

/datum/voice_of_god_command/speak
	trigger = "speak|say\\s*something"

/datum/voice_of_god_command/speak/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target in listeners)
		addtimer(CALLBACK(target, /atom/movable/proc/say, pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")), 5 * iteration)
		iteration++

/datum/voice_of_god_command/getup
	trigger = "get\\s*up"

/datum/voice_of_god_command/getup/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.set_resting(FALSE)
		target.SetAllImmobility(0)

/datum/voice_of_god_command/sit
	trigger = "sit"
	is_regex = FALSE

/datum/voice_of_god_command/sit/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		for(var/obj/structure/chair/chair in get_turf(target))
			chair.buckle_mob(target)
			break

/datum/voice_of_god_command/stand
	trigger = "stand"
	is_regex = FALSE

/datum/voice_of_god_command/stand/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		if(target.buckled && istype(target.buckled, /obj/structure/chair))
			target.buckled.unbuckle_mob(target)

/datum/voice_of_god_command/jump
	trigger = "jump"
	is_regex = FALSE

/datum/voice_of_god_command/jump/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		if(prob(25))
			addtimer(CALLBACK(target, /atom/movable/proc/say, "HOW HIGH?!!"), 5 * iteration)
		else
			addtimer(CALLBACK(target, /mob/living/.proc/emote, "jump"), 5 * iteration)
		iteration++

/datum/voice_of_god_command/honk
	trigger = "ho+nk"

/datum/voice_of_god_command/honk/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(user), 'sound/items/bikehorn.ogg', 300, 1), 25)
	if(user.mind && user.mind.assigned_role == "Clown")
		for(var/mob/living/carbon/target in listeners)
			target.slip(140 * power_multiplier)

/datum/voice_of_god_command/multispin
	trigger = "like\\s*a\\s*record\\s*baby|right\\s*round"

/datum/voice_of_god_command/multispin/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.SpinAnimation(speed = 10, loops = 5)

/// Supertype of all those commands who make people emote and nothing else. Fuck copypasta.
/datum/voice_of_god_command/emote
	/// The emote to run.
	var/emote_name = "dance"

/datum/voice_of_god_command/emote/execute(list/listeners = list(), mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(target, /mob/living/.proc/emote, emote_name), 5 * iteration)
		iteration++

/datum/voice_of_god_command/emote/flip
	trigger = "flip|rotate|revolve|roll|somersault"
	emote_name = "flip"

/datum/voice_of_god_command/emote/dance
	trigger = "dance"
	is_regex = FALSE

/datum/voice_of_god_command/emote/salute
	trigger = "salute"
	emote_name = "salute"
	is_regex = FALSE

/datum/voice_of_god_command/emote/play_dead
	trigger = "play\\s*dead"
	emote_name = "deathgasp"

/datum/voice_of_god_command/emote/clap
	trigger = "clap|applaud"
	emote_name = "clap"

#undef COOLDOWN_STUN
#undef COOLDOWN_DAMAGE
#undef COOLDOWN_MEME
#undef COOLDOWN_NONE
