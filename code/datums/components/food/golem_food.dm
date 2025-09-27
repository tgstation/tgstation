/// Component which allows something to be eaten by a golem
/datum/component/golem_food
	/// Whether to destroy our item when we eat it
	var/consume_on_eat
	/// Reference to the kind of food we provide
	var/datum/golem_food_buff/snack_type
	/// Our abstract fake food item
	var/obj/item/food/golem_food/golem_snack
	/// Any extra checks which need to be done when seeing if this is edible
	var/datum/callback/extra_validation

/datum/component/golem_food/Initialize(consume_on_eat = TRUE, golem_food_key, datum/callback/extra_validation)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if (!golem_food_key || !is_path_in_list(golem_food_key, GLOB.golem_stack_food_directory))
		CRASH("Golem food type not specified, this is a required parameter.")

	src.consume_on_eat = consume_on_eat
	snack_type = GLOB.golem_stack_food_directory[golem_food_key]
	src.extra_validation = extra_validation


/datum/component/golem_food/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/golem_food/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ATOM_EXAMINE))
	return ..()

/datum/component/golem_food/Destroy(force)
	QDEL_NULL(golem_snack)
	snack_type = null
	extra_validation = null
	return ..()

/// Attempt to feed this item to golem
/datum/component/golem_food/proc/on_attack(atom/source, mob/living/target, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if (user.combat_mode || !HAS_TRAIT(target, TRAIT_ROCK_EATER))
		return
	if (extra_validation && !extra_validation.Invoke())
		source.balloon_alert(user, "not edible!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if (!snack_type.can_consume(target))
		source.balloon_alert(user, "can't consume!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if (isnull(golem_snack))
		create_golem_snack(source)
	golem_snack.attack(target, user, modifiers)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Creates our golem snack atom instance
/datum/component/golem_food/proc/create_golem_snack(atom/source)
	golem_snack = new(null)
	golem_snack.setup(
		name = source.name,
		consume_food = consume_on_eat,
		food_buff = snack_type,
		owner = parent,
	)
	RegisterSignal(golem_snack, COMSIG_QDELETING, PROC_REF(on_food_destroyed))

/// Reference handling for abstract food object
/datum/component/golem_food/proc/on_food_destroyed()
	SIGNAL_HANDLER
	golem_snack = null

/// Add extra examine text to people who have golem brains
/datum/component/golem_food/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(user, TRAIT_ROCK_METAMORPHIC))
		return
	examine_text += span_notice(snack_type.added_info)

/// Abstract food item used to feed golems
/obj/item/food/golem_food
	name = "temporary golem material snack item"
	desc = "You shouldn't be able to see this. This is an abstract item which exists to allow you to eat rocks."
	bite_consumption = 2
	food_reagents = list(/datum/reagent/consumable/nutriment/mineral = INFINITY) // Destroyed when stack runs out, not when reagents do
	foodtypes = STONE
	/// If we use up a stack of food on use or not
	var/consume_food = TRUE
	/// A reference to whatever it is we represent
	var/atom/owner
	/// Golem food buff to apply on consumption
	var/datum/golem_food_buff/food_buff

/// Set up some properties based on a passed-in item that the golem will pretend to eat
/obj/item/food/golem_food/proc/setup(
	name,
	consume_food = TRUE,
	datum/golem_food_buff/food_buff,
	atom/owner,
)
	src.name = name
	src.consume_food = consume_food
	src.food_buff = food_buff
	src.owner = owner
	RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(on_parent_destroyed))

/// Clean ourselves up if our parent dies
/obj/item/food/golem_food/proc/on_parent_destroyed(datum/destroyed_thing)
	SIGNAL_HANDLER
	qdel(src)

/obj/item/food/golem_food/make_edible()
	. = ..()
	AddComponentFrom(SOURCE_EDIBLE_INNATE, /datum/component/edible, after_eat = CALLBACK(src, PROC_REF(took_bite)), volume = INFINITY)

/// Called when someone bites this food, subtract one charge from our material stack
/obj/item/food/golem_food/proc/took_bite(mob/eater)
	if (!owner)
		qdel(src)
		return

	food_buff.on_consumption(eater, owner)
	if (!consume_food)
		qdel(src)
		return

	if (isstack(owner))
		var/obj/item/stack/stack_owner = owner
		stack_owner.use(used = 1)
	else
		qdel(owner)
