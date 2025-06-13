/mob/living/basic/snail
	name = "snail"
	desc = "Is petting this thing sanitary?"
	icon_state = "snail"
	icon_living = "snail"
	icon_dead = "snail_dead"
	base_icon_state = "snail"
	held_state = "snail"
	head_icon = 'icons/mob/clothing/head/pets_head.dmi'
	icon = 'icons/mob/simple/pets.dmi'
	butcher_results = list(/obj/item/food/meat/slab/bugmeat = 1)
	mob_biotypes = MOB_ORGANIC
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	health = 30
	maxHealth = 30
	speed = 6
	verb_say = "gurgles"
	verb_ask = "gurgles curiously"
	can_be_held = TRUE
	verb_exclaim = "gurgles loudly"
	verb_yell = "gurgles loudly"
	worn_slot_flags = ITEM_SLOT_HEAD
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list(FACTION_NEUTRAL, FACTION_MAINT_CREATURES)
	ai_controller = /datum/ai_controller/basic_controller/snail
	/// What do we turn into if effected by a regal rat?
	var/minion_path = /mob/living/basic/snail/angry

/mob/living/basic/snail/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)
	var/static/list/eatable_food = list(
		/obj/item/food/grown,
		/obj/item/food/appleslice,
	)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/shell_retreat = BB_SNAIL_RETREAT_ABILITY,
	)

	grant_actions_by_list(innate_actions)
	AddElement(/datum/element/ai_retaliate)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(eatable_food))
	AddElement(/datum/element/basic_eating, food_types = eatable_food)
	create_reagents(100, REAGENT_HOLDER_ALIVE)
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagents_update))
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SNAIL, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

	if (minion_path)
		AddElement(/datum/element/regal_rat_minion, converted_path = minion_path, success_balloon = "gurgle", pet_commands = GLOB.regal_rat_minion_commands)

/mob/living/basic/snail/proc/on_entered(datum/source, obj/effect/decal/cleanable/food/salt/potential_salt)
	SIGNAL_HANDLER
	if(istype(potential_salt))
		on_salt_exposure() //immediately perish

/mob/living/basic/snail/proc/on_reagents_update(datum/source)
	SIGNAL_HANDLER
	if(reagents.has_reagent(/datum/reagent/consumable/salt))
		on_salt_exposure()

/mob/living/basic/snail/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!isturf(loc))
		return
	if(locate(/obj/effect/decal/cleanable/food/salt) in loc.contents)
		on_salt_exposure()

/mob/living/basic/snail/proc/on_salt_exposure()
	if(stat == DEAD)
		return
	visible_message(
		span_danger("[src] shows a strong reaction after tasting some salt!"),
		span_userdanger("You show a strong reaction after tasting some salt."),
	)
	apply_damage(500) //ouch

/mob/living/basic/snail/mob_pickup(mob/living/user)
	var/obj/item/clothing/head/mob_holder/snail/holder = new(get_turf(src), src, held_state, head_icon, held_lh, held_rh, worn_slot_flags)
	var/display_message = "[user] [HAS_TRAIT(src, TRAIT_MOVE_FLOATING) ? "scoops up [src]" : "peels [src] off the ground"]!"
	user.visible_message(span_warning(display_message))
	user.put_in_hands(holder)

/mob/living/basic/snail/update_icon_state()
	if(stat != DEAD)
		icon_state = HAS_TRAIT(src, TRAIT_SHELL_RETREATED) ? "snail_shell" : "[base_icon_state]"
	return ..()


/// This snail is going to try and beat you up
/mob/living/basic/snail/angry
	name = "sewer snail"
	gold_core_spawnable = HOSTILE_SPAWN
	icon_state = "snail_maints"
	icon_living = "snail_maints"
	icon_dead = "snail_maints_dead"
	base_icon_state = "snail_maints"
	health = 40
	maxHealth = 40
	melee_damage_lower = 5
	melee_damage_upper = 8
	obj_damage = 8
	can_be_held = FALSE
	minion_path = null
	ai_controller = /datum/ai_controller/basic_controller/snail/trash


///snail's custom holder object
/obj/item/clothing/head/mob_holder/snail

/obj/item/clothing/head/mob_holder/snail/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/hydroponics))
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(held_mob.stat == DEAD)
		user.balloon_alert(user, "it's dead!")
		return

	if(locate(type) in interacting_with)
		user.balloon_alert(user, "already has snail!")
		return

	if(!do_after(user, 2 SECONDS, interacting_with))
		return

	forceMove(interacting_with)
	return ITEM_INTERACT_SUCCESS
