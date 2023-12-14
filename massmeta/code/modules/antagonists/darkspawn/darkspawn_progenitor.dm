/mob/living/simple_animal/hostile/darkspawn_progenitor
	name = "cosmic progenitor"
	desc = "..."
	icon = 'massmeta/icons/mob/darkspawn_progenitor.dmi'
	icon_state = "darkspawn_progenitor"
	icon_living = "darkspawn_progenitor"
	health = INFINITY
	maxHealth = INFINITY
	attack_verb_continuous = "rips apart"
	attack_verb_simple = "rip apart"
	attack_sound = 'massmeta/sounds/creatures/progenitor_attack.ogg'
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	speak_emote = list("roars")
	armour_penetration = 100
	melee_damage_lower = 40
	melee_damage_upper = 40
	move_to_delay = 10
	speed = 1
	pixel_x = -48
	pixel_y = -32
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 100
	light_range = 15
	light_color = "#21007F"
	weather_immunities = list("lava", "ash")
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER
	movement_type = FLYING
	var/time_to_next_roar = 0

/mob/living/simple_animal/hostile/darkspawn_progenitor/Initialize()
	. = ..()
	var/datum/action/small_sprite/progenitor/smolgenitor_sprite = new /datum/action/small_sprite/progenitor
	smolgenitor_sprite.Grant(src)
	ADD_TRAIT(src, TRAIT_HOLY, "ohgodohfuck") //sorry no magic
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	alpha = 0
	animate(src, alpha = 255, time = 1 SECONDS)
	var/obj/item/radio/headset/silicon/ai/radio = new(src) //so the progenitor can hear people's screams over radio
	radio.wires.cut(WIRE_TX) //but not talk over it

/mob/living/simple_animal/hostile/darkspawn_progenitor/AttackingTarget()
	if(istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		playsound(target, 'massmeta/sounds/magic/pass_smash_door.ogg', 100, FALSE)
		obj_damage = 60
	. = ..()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Login()
	..()
	time_to_next_roar = world.time + 30 SECONDS

/mob/living/simple_animal/hostile/darkspawn_progenitor/Life()
	..()
	if(time_to_next_roar + 10 SECONDS <= world.time) //gives time to roar manually if you like want to do that
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(time_to_next_roar <= world.time)
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/roar()
	playsound(src, 'massmeta/sounds/creatures/progenitor_roar.ogg', 50, TRUE)
	for(var/mob/M in GLOB.player_list)
		if(get_dist(M, src) > 7)
			M.playsound_local(src, 'massmeta/sounds/creatures/progenitor_distant.ogg', 25, FALSE, falloff = 5)
		else if(isliving(M))
			var/mob/living/L = M
			if(L != src) //OH GOD OH FUCK I'M SCARING MYSELF
				to_chat(M, span_boldannounce("You stand paralyzed in the shadow of the cold as it descends from on high."))
				L.Stun(20)
	time_to_next_roar = world.time + 30 SECONDS

/datum/action/cooldown/spell/pointed/progenitor_curse
	name = "Viscerate Mind"
	desc = "Unleash a powerful psionic barrage into the mind of the target."
	cooldown_time = 5 SECONDS
	button_icon = 'massmeta/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "veil_mind"
	background_icon_state = "bg_alien"
	spell_requirements = NONE //Go fuck yourself

/datum/action/cooldown/spell/pointed/progenitor_curse/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/progenitor_curse/cast(mob/living/carbon/human/cast_on)
	var/zoinks = pick(0.1, 0.5, 1)//like, this isn't even my final form!
	usr.visible_message(span_warning("[usr]'s sigils flare as it glances at [cast_on]!"), \
						span_velvet("You direct [zoinks]% of your psionic power into [cast_on]'s mind!."))
	cast_on.apply_status_effect(STATUS_EFFECT_PROGENITORCURSE)

/mob/living/simple_animal/hostile/darkspawn_progenitor/narsie_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/singularity_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ex_act() //sorry no bombs
	return

/datum/action/small_sprite/progenitor
	small_icon = 'massmeta/icons/mob/mob.dmi'
	small_icon_state = "smol_progenitor"
