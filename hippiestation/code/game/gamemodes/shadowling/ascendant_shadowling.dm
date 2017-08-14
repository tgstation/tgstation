/mob/living/simple_animal/ascendant_shadowling
	name = "ascendant shadowling"
	desc = "HOLY SHIT RUN THE FUCK AWAY- <span class='shadowling'>RAAAAAAA!</span>"
	icon = 'hippiestation/icons/mob/mob.dmi'
	icon_state = "shadowling_ascended"
	icon_living = "shadowling_ascended"
	verb_say = "telepathically thunders"
	verb_ask = "telepathically thunders"
	verb_exclaim = "telepathically thunders"
	verb_yell = "telepathically thunders"
	force_threshold = INFINITY //Can't die by normal means
	health = 9999
	maxHealth = 9999
	speed = 0
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM

	response_help   = "pokes"
	response_disarm = "flails at"
	response_harm   = "flails at"

	harm_intent_damage = 0
	melee_damage_lower = 60 //Was 35, buffed
	melee_damage_upper = 60
	attacktext = "rends"
	attack_sound = 'sound/weapons/slash.ogg'

	minbodytemp = 0
	maxbodytemp = INFINITY
	environment_smash = 3

	faction = list("faithless")

/mob/living/simple_animal/ascendant_shadowling/Process_Spacemove(movement_dir = 0)
	return 1 //copypasta from carp code

/mob/living/simple_animal/ascendant_shadowling/get_spans()
	return ..() | list(SPAN_REALLYBIG, SPAN_YELL) //MAKES THEM SHOUT WHEN THEY TALK

/mob/living/simple_animal/ascendant_shadowling/ex_act(severity)
	return 0 //You think an ascendant can be hurt by bombs? HA

/mob/living/simple_animal/ascendant_shadowling/singularity_act(args)
	to_chat(src, "<span class='shadowling>NO NO NO AAAAAAAAAAAAAAAAAAA-</span>")
	to_chat(world, "<span class='shadowling'><b>\"<font size=6>NO!</font> <font size=5>I will</font> <font size=4>not be.... destroyed</font> <font size=3>by a....</font> <font size=2>AAAAAAA-</font>\"</span>")
	for(var/mob/M in GLOB.mob_list)
		to_chat(M, "<span class='notice'><i><b>You feel a woosh as newly released energy temporarily distorts space itself...</b></i></span>")
		M.playsound_local(get_turf(src), 'sound/hallucinations/wail.ogg', 150, 1, pressure_affected = FALSE)
	. = ..(args)