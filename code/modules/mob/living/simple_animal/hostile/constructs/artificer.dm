/mob/living/simple_animal/hostile/construct/artificer
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining the Cult of Nar'Sie's armies."
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm_continuous = "viciously beats"
	response_harm_simple = "viciously beat"
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 5
	melee_damage_upper = 5
	retreat_distance = 10
	minimum_distance = 10 //AI artificers will flee like fuck
	attack_verb_continuous = "rams"
	attack_verb_simple = "ram"
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = 'sound/weapons/punch2.ogg'
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)
	playstyle_string = "<b>You are an Artificer. You are incredibly weak and fragile, \
		but you are able to construct fortifications, use magic missile, and repair allied constructs, shades, \
		and yourself (by clicking on them). Additionally, <i>and most important of all,</i> you can create new constructs \
		by producing soulstones to capture souls, and shells to place those soulstones into.</b>"

	can_repair = TRUE
	can_repair_self = TRUE
	///The health HUD applied to this mob.
	var/health_hud = DATA_HUD_MEDICAL_ADVANCED

/mob/living/simple_animal/hostile/construct/artificer/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/datahud = GLOB.huds[health_hud]
	datahud.show_to(src)

/mob/living/simple_animal/hostile/construct/artificer/Found(atom/thing) //what have we found here?
	if(!isconstruct(thing)) //is it a construct?
		return FALSE
	var/mob/living/simple_animal/hostile/construct/cultie = thing
	if(cultie.health < cultie.maxHealth) //is it hurt? let's go heal it if it is
		return TRUE

/mob/living/simple_animal/hostile/construct/artificer/CanAttack(atom/the_target)
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE
	if(Found(the_target) || ..()) //If we Found it or Can_Attack it normally, we Can_Attack it as long as it wasn't invisible
		return TRUE //as a note this shouldn't be added to base hostile mobs because it'll mess up retaliate hostile mobs
	return FALSE

/mob/living/simple_animal/hostile/construct/artificer/MoveToTarget(list/possible_targets)
	..()
	if(!isliving(target))
		return

	var/mob/living/victim = target
	if(isconstruct(victim) && victim.health >= victim.maxHealth) //is this target an unhurt construct? stop trying to heal it
		LoseTarget()
		return
	if(victim.health <= melee_damage_lower+melee_damage_upper) //ey bucko you're hurt as fuck let's go hit you
		retreat_distance = null
		minimum_distance = 1

/mob/living/simple_animal/hostile/construct/artificer/Aggro()
	..()
	if(isconstruct(target)) //oh the target is a construct no need to flee
		retreat_distance = null
		minimum_distance = 1

/mob/living/simple_animal/hostile/construct/artificer/LoseAggro()
	..()
	retreat_distance = initial(retreat_distance)
	minimum_distance = initial(minimum_distance)

/mob/living/simple_animal/hostile/construct/artificer/hostile //actually hostile, will move around, hit things, heal other constructs
	AIStatus = AI_ON
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES //only token destruction, don't smash the cult wall NO STOP

/////////////////////////////Artificer-alts/////////////////////////
/mob/living/simple_animal/hostile/construct/artificer/angelic
	desc = "A bulbous construct dedicated to building and maintaining holy armies."
	theme = THEME_HOLY
	loot = list(/obj/item/ectoplasm/angelic)
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/soulstone/purified,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)
/mob/living/simple_animal/hostile/construct/artificer/mystic
	theme = THEME_WIZARD
	loot = list(/obj/item/ectoplasm/mystic)
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone/mystic,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)

/mob/living/simple_animal/hostile/construct/artificer/noncult
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone/noncult,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)
