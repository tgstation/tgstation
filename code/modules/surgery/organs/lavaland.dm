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
	var/command = stripped_input(owner, "Speak with the Voice of God", "Command", max_length = 64)
	if(!command)
		return
	var/mob/living/list/listeners = list()
	for(var/mob/living/L in get_hearers_in_view(8, owner))
		if(!L.ear_deaf && L != owner)
			listeners += L
	if(!IsAvailable())
		owner << "<span class='notice'>You must wait [(next_command - world.time)/10] seconds before Speaking again.</span>"
		return
	var/spoken = uppertext(command)
	owner.say(spoken, spans = list("colossus","yell"))
	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)

	//STUN
	if(findtext(command, "stop") || findtext(command, "wait") || findtext(command, "stand still") || findtext(command, "hold on"))
		for(var/mob/living/L in listeners)
			L.Stun(2)
		next_command = world.time + cooldown_stun

	//WEAKEN
	else if(findtext(command, "drop") || findtext(command, "fall"))
		for(var/mob/living/L in listeners)
			L.Weaken(2)
		next_command = world.time + cooldown_stun

	//SILENCE
	else if(findtext(command, "shut up") || findtext(command, "silence") || findtext(command, "ssh"))
		for(var/mob/living/L in listeners)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.silent += 10
		next_command = world.time + cooldown_stun

	//BRUTE DAMAGE
	else if(findtext(command, "die") || findtext(command, "bleed"))
		for(var/mob/living/L in listeners)
			L.apply_damage(10, def_zone = "chest")
		next_command = world.time + cooldown_damage

	//FIRE
	else if(findtext(command, "burn"))
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
	else if(findtext(command, "shoo") || findtext(command, "go away") || findtext(command, "leave me alone"))
		for(var/mob/living/L in listeners)
			var/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
			L.throw_at_fast(throwtarget, 3, 1)
		next_command = world.time + cooldown_damage

	//FLIP
	else if(findtext(command, "flip") || findtext(command, "rotate") || findtext(command, "revolve"))
		for(var/mob/living/L in listeners)
			L.emote("flip")
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

	//PLAY DEAD
	else if(findtext(command, "play dead"))
		for(var/mob/living/L in listeners)
			L.emote("deathgasp")
		next_command = world.time + cooldown_meme

	//PLEASE CLAP
	else if(findtext(command, "please clap"))
		for(var/mob/living/L in listeners)
			L.emote("clap")
		next_command = world.time + cooldown_meme

	else
		next_command = world.time + cooldown_none

