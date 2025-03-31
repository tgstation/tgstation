/// The Greatest (animal) Of All Time. Cud chewing, shin-kicking, kitchen-dwelling nuisance.
/mob/living/basic/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"

	speak_emote = list("brays")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK

	butcher_results = list(/obj/item/food/meat/slab/grassfed = 4)

	faction = list(FACTION_NEUTRAL)
	mob_biotypes = MOB_ORGANIC | MOB_BEAST

	health = 40
	maxHealth = 40
	melee_damage_lower = 1
	melee_damage_upper = 2
	environment_smash = ENVIRONMENT_SMASH_NONE

	minimum_survivable_temperature = COLD_ROOM_TEMP - 75 // enough so that they can survive the cold room spawn with plenty of room for comfort

	blood_volume = BLOOD_VOLUME_NORMAL

	ai_controller = /datum/ai_controller/basic_controller/goat
	/// How often will we develop an evil gleam in our eye?
	var/gleam_delay = 20 SECONDS
	/// Time until we can next gleam evilly
	COOLDOWN_DECLARE(gleam_cooldown)
	/// List of stuff (flora) that we want to eat
	var/static/list/edibles = list(
		/obj/structure/alien/resin/flower_bud,
		/obj/structure/glowshroom,
		/obj/structure/spacevine,
	)

/mob/living/basic/goat/Initialize(mapload)
	. = ..()
	add_udder()
	AddElement(/datum/element/cliff_walking) //we walk the cliff
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)
	AddElement(/datum/element/ai_retaliate)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attack))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move))

	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

/// Called when we attack something in order to piece together the intent of the AI/user and provide desired behavior. The element might be okay here but I'd rather the fluff.
/// Goats are really good at beating up plants by taking bites out of them, but we use the default attack for everything else
/mob/living/basic/goat/proc/on_pre_attack(datum/source, atom/target)
	if(is_type_in_list(target, edibles))
		eat_plant(list(target))
		return COMPONENT_HOSTILE_NO_ATTACK

	if(!isliving(target))
		return

	var/mob/living/living_target = target
	if(!(living_target.mob_biotypes & MOB_PLANT))
		return

	living_target.adjustBruteLoss(20)
	playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)
	var/obj/item/bodypart/edible_bodypart

	if(ishuman(living_target))
		var/mob/living/carbon/human/plant_man = target
		edible_bodypart = pick(plant_man.bodyparts)
		edible_bodypart.dismember()

	living_target.visible_message(
		span_warning("[src] takes a big chomp out of [living_target]!"),
		span_userdanger("[src] takes a big chomp out of your [edible_bodypart || "body"]!"),
	)

	return COMPONENT_HOSTILE_NO_ATTACK

/// If we are being attacked by someone, give a nice fluff message. But only once in a while.
/mob/living/basic/goat/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	if (!COOLDOWN_FINISHED(src, gleam_cooldown))
		return
	visible_message(
		span_danger("[src] gets an evil-looking gleam in [p_their()] eye."),
	)
	COOLDOWN_START(src, gleam_cooldown, gleam_delay)

/// Handles automagically eating a plant when we move into a turf that has one.
/mob/living/basic/goat/proc/on_move(datum/source, atom/entering_loc)
	SIGNAL_HANDLER
	if(!isturf(entering_loc) || stat == DEAD)
		return

	var/list/edible_plants = list()
	for(var/obj/target in entering_loc)
		if(is_type_in_list(target, edibles))
			edible_plants += target

	INVOKE_ASYNC(src, PROC_REF(eat_plant), edible_plants)

/// When invoked, adds an udder when applicable. Male goats do not have udders.
/mob/living/basic/goat/proc/add_udder()
	if(gender == MALE)
		return
	AddComponent(/datum/component/udder)

/// Proc that handles dealing with the various types of plants we might eat. Assumes that a valid list of type(s) will be passed in.
/mob/living/basic/goat/proc/eat_plant(list/plants)
	var/eaten = FALSE

	for(var/atom/target as anything in plants)
		if(istype(target, /obj/structure/spacevine))
			var/obj/structure/spacevine/vine = target
			vine.eat(src)
			eaten = TRUE

		if(istype(target, /obj/structure/alien/resin/flower_bud))
			target.take_damage(rand(30, 50), BRUTE, 0)
			eaten = TRUE

		if(istype(target, /obj/structure/glowshroom))
			qdel(target)
			eaten = TRUE

	if(eaten && prob(10))
		say("Nom") // bon appetit
		playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)
