///Simple animals 2.0, This time, let's really try to keep it simple. This basetype should purely be used as a base-level for implementing simplified behaviours for things such as damage and attacks. Everything else should be in components or AI behaviours.
/mob/living/basic
	name = "basic mob"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL
	living_flags = MOVES_ON_ITS_OWN
	status_flags = CANPUSH


	////////THIS SECTION COULD BE ITS OWN ELEMENT
	///Icon to use
	var/icon_living = ""
	///Icon when the animal is dead. Don't use animated icons for this.
	var/icon_dead = ""
	///We only try to show a gibbing animation if this exists.
	var/icon_gib = null
	///Flip the sprite upside down on death. Mostly here for things lacking custom dead sprites.
	var/flip_on_death = FALSE

	////ALL IN THIS SECTION SHOULD BE BASIC MOB FLAGS
	var/basic_mob_flags = NONE

	///Environmental info, this could become an element? Might lower the amount of mobs we're going through as a lot of mobs dont care about environment.

	///Atmos checks
	///Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	///Leaving something at 0 means it's off - has no maximum.
	var/list/atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	///This damage is taken when atmos doesn't fit all the requirements above.
	var/unsuitable_atmos_damage = 1


	///var/stop_automated_movement = 0
	///Does the mob wander around when idle?
	///var/wander = 1
	///When set to 1 this stops the animal from moving when someone is pulling it.

	///Verbs used for speaking e.g. "Says" or "Chitters"
	var/list/speak_emote = list()


	///When someone interacts with the simple animal.
	///Help-intent verb in present continuous tense.
	var/response_help_continuous = "pokes"
	///Help-intent verb in present simple tense.
	var/response_help_simple = "poke"
	///Disarm-intent verb in present continuous tense.
	var/response_disarm_continuous = "shoves"
	///Disarm-intent verb in present simple tense.
	var/response_disarm_simple = "shove"
	///Harm-intent verb in present continuous tense.
	var/response_harm_continuous = "hits"
	///Harm-intent verb in present simple tense.
	var/response_harm_simple = "hit"


	///Basic mob's own attacks verbs,
	///Attacking verb in present continuous tense.
	var/attack_verb_continuous = "attacks"
	///Attacking verb in present simple tense.
	var/attack_verb_simple = "attack"
	///Attacking, but without damage, verb in present continuous tense.
	var/friendly_verb_continuous = "nuzzles"
	///Attacking, but without damage, verb in present simple tense.
	var/friendly_verb_simple = "nuzzle"

	///Minimum force required to deal any damage to the mob.
	var/force_threshold = 0
	///How much stamina the mob recovers per second
	var/stamina_recovery = 5
	///Healable by medical stacks? Defaults to yes.
	var/healable = TRUE


	///how much damage this basic mob does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	///How much wounding power it has
	var/wound_bonus = CANT_WOUND
	///How much bare wounding power it has
	var/bare_wound_bonus = 0
	///If the attacks from this are sharp
	var/sharpness = NONE


	/// 1 for full damage , 0 for none , -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)

	/// Sound played when the critter attacks.
	var/attack_sound
	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_vis_effect

	///What kind of objects this mob can smash.
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	///Defines how fast the basic mob can move.
	var/speed = 1

	///If the mob can be spawned with a gold slime core. HOSTILE_SPAWN are spawned with plasma, FRIENDLY_SPAWN are spawned with blood.
	var/gold_core_spawnable = NO_SPAWN


	///Sentience type, for slime potions. Future element perhaps?
	var/sentience_type = SENTIENCE_ORGANIC

	///List of things spawned at mob's loc when it dies. This should be an element.
	var/list/loot = list()

	///Message when the mob dies
	var/deathmessage = ""

	///Played when someone punches the creature.
	var/attacked_sound = "punch" //This should be an element

	///What kind of footstep this mob should have. Null if it shouldn't have any.
	var/footstep_type



/mob/living/basic/Initialize(mapload)
	. = ..()

	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)

	if(!real_name)
		real_name = name

	if(!loc)
		stack_trace("Basic mob being instantiated in nullspace")

	update_simplemob_varspeed()

	if(speak_emote)
		speak_emote = string_list(speak_emote)

/mob/living/basic/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	///Automatic stamina re-gain
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * delta_time, FALSE, TRUE)

/mob/living/basic/say_mod(input, list/message_mods = list())
	if(length(speak_emote))
		verb_say = pick(speak_emote)
	return ..()

/mob/living/basic/death(gibbed)
	. = ..()
	if(basic_mob_flags & DEL_ON_DEATH)
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		if(flip_on_death)
			transform = transform.Turn(180)
		set_density(FALSE)

/mob/living/basic/proc/melee_attack(atom/target)
	src.face_atom(target)
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	var/result = target.attack_animal(src)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/mob/living/basic/proc/set_varspeed(var_value)
	speed = var_value
	update_simplemob_varspeed()

/mob/living/basic/proc/update_simplemob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed)
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed, multiplicative_slowdown = speed)

