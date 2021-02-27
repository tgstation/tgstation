// If an item has the food_trash element it will drop an item when it is consumed.
/datum/element/food_trash
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// The type of trash that is spawned by this element
	var/atom/trash
	///Flags of the trash element that change its behavior
	var/flags
	///Generate trash callback
	var/datum/callback/generate_trash_callback

/datum/element/food_trash/Attach(datum/target, atom/trash, flags, generate_trash)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	src.trash = trash
	src.flags = flags
	RegisterSignal(target, COMSIG_FOOD_CONSUMED, .proc/generate_trash)
	if(!src.generate_trash_callback && generate_trash)
		generate_trash_callback = CALLBACK(target, generate_trash)
	if(flags & FOOD_TRASH_OPENABLE)
		RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, .proc/open_trash)
	if(flags & FOOD_TRASH_POPABLE)
		RegisterSignal(target, COMSIG_FOOD_CROSSED, .proc/food_crossed)
	RegisterSignal(target, COMSIG_ITEM_ON_GRIND, .proc/generate_trash)
	RegisterSignal(target, COMSIG_ITEM_ON_JUICE, .proc/generate_trash)
	RegisterSignal(target, COMSIG_ITEM_ON_COMPOSTED, .proc/generate_trash)
	RegisterSignal(target, COMSIG_ITEM_SOLD_TO_CUSTOMER, .proc/generate_trash)

/datum/element/food_trash/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_FOOD_CONSUMED)

/datum/element/food_trash/proc/generate_trash(datum/source, mob/living/eater, mob/living/feeder)
	SIGNAL_HANDLER

	///cringy signal_handler shouldnt be needed if you dont want to return but oh well
	INVOKE_ASYNC(src, .proc/async_generate_trash, source)

/datum/element/food_trash/proc/async_generate_trash(datum/source)

	var/obj/item/trash_item =  generate_trash_callback ? generate_trash_callback.Invoke(source) : new trash()

	var/atom/edible_object = source

	var/mob/living/mob_location = edible_object.loc //The foods location

	if(istype(mob_location))
		mob_location.put_in_hands(trash_item)
	else
		trash_item.forceMove(get_turf(edible_object))

/datum/element/food_trash/proc/food_crossed(datum/source, mob/crosser, bitecount)
	SIGNAL_HANDLER

	if(!isliving(crosser) || bitecount) // can't pop opened chips
		return
	var/mob/living/popper = crosser
	if(popper.mob_size < MOB_SIZE_HUMAN)
		return

	playsound(source, 'sound/effects/chipbagpop.ogg', 100)

	popper.visible_message("<span class='danger'>[popper] steps on \the [source], popping the bag!</span>", "<span class='danger'>You step on \the [source], popping the bag!</span>", "<span class='danger'>You hear a sharp crack!</span>", COMBAT_MESSAGE_RANGE)
	INVOKE_ASYNC(src, .proc/async_generate_trash, source)
	qdel(source)


/datum/element/food_trash/proc/open_trash(datum/source, mob/user)
	SIGNAL_HANDLER

	to_chat(user, "<span class='notice'>You open the [source], revealing \a [initial(trash.name)].</span>")

	INVOKE_ASYNC(src, .proc/async_generate_trash, source)
	qdel(source)

