
/// We haven't finished setting up the challenge yet
#define AWRASSLE_STAGE_INITIALIZING		0
/// The arm is on the table and ready to be picked up by a challenger
#define AWRASSLE_STAGE_CHALLENGING		1
/// We're in the battle now
#define AWRASSLE_STAGE_BATTLE			2

/datum/component/arm_wrassle
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Check the AWRASSLE_STAGE defines, this is how far into the setup we are
	var/stage = AWRASSLE_STAGE_INITIALIZING
	/// How many updates we've done for the contest once it's started
	var/battle_ticks = 0

	/// We need a table to conduct this contest on, this is it
	var/obj/structure/table/arena
	/// The [/obj/item/arm_wrassle] that represents the owner's arm and created this component
	var/obj/item/arm_wrassle/arm_item
	/// The actual arm the above arm_item represents on the owner
	var/obj/item/bodypart/owner_arm
	/// The carbon who picked up the arm_item and started the contest
	var/mob/living/carbon/challenger
	/// The actual arm the challenger is using in this contest
	var/obj/item/bodypart/challenger_arm

	/// Based on the owner's traits, how much of a modifier they get to the stamina damage they take each update (positive = more, negative = less)
	var/owner_stamina_mod = 0
	/// Based on the challenger's traits, how much of a modifier they get to the stamina damage they take each update (positive = more, negative = less)
	var/challenger_stamina_mod = 0

/datum/component/arm_wrassle/Initialize(obj/item/arm_wrassle/the_arm, obj/structure/table/the_table)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	arm_item = the_arm
	arena = the_table

	var/mob/living/carbon/owner = parent
	switch(owner.get_held_index_of_item(arm_item))
		if(LEFT_HANDS)
			owner_arm = owner.get_bodypart(BODY_ZONE_L_ARM)
		if(RIGHT_HANDS)
			owner_arm = owner.get_bodypart(BODY_ZONE_R_ARM)
		else
			qdel(src)
			return

	RegisterSignal(arm_item, COMSIG_MOVABLE_MOVED, .proc/check_moved_arm)
	RegisterSignal(arm_item, COMSIG_ATOM_ATTACK_HAND, .proc/check_grab_correct_hand)
	RegisterSignal(arm_item, COMSIG_ITEM_EQUIPPED, .proc/check_arm_equipped)
	RegisterSignal(arm_item, COMSIG_PARENT_QDELETING, .proc/void)

	RegisterSignal(arena, COMSIG_PARENT_QDELETING, .proc/void)
	RegisterSignal(owner_arm, COMSIG_PARENT_QDELETING, .proc/void)
	RegisterSignal(challenger_arm, COMSIG_PARENT_QDELETING, .proc/void)

	owner.visible_message("<span class='notice'>[owner] sets [owner.p_their()] [owner_arm.name] on \the [arena], awaiting a challenger!</span>")
	owner.transferItemToLoc(arm_item, arena.drop_location(), force=TRUE, silent = FALSE)

/datum/component/arm_wrassle/Destroy(force, silent)
	if(parent)
		REMOVE_TRAIT(parent, TRAIT_IMMOBILIZED, ARM_WRASSLIN_TRAIT)
	if(challenger)
		REMOVE_TRAIT(challenger, TRAIT_IMMOBILIZED, ARM_WRASSLIN_TRAIT)
	QDEL_NULL(arm_item)
	arena = null
	return ..()

/datum/component/arm_wrassle/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_owner_move)
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/void)

/datum/component/arm_wrassle/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))

/// Someone picked up the arm item. If it was the owner, we cancel the challenge, otherwise if it's a carbon (which it should be) we start the contest
/datum/component/arm_wrassle/proc/check_arm_equipped(obj/item/source, mob/user, slot, initial)
	var/mob/living/carbon/owner = parent
	if(user == owner)
		owner.visible_message("<span class='notice'>[owner] removes [owner.p_their()] [owner_arm.name] from \the [arena].</span>")
		qdel(src)
		return
	if(iscarbon(user))
		battle(user)

/// One of the pieces of the puzzle got deleted, so cancel everything
/datum/component/arm_wrassle/proc/void()
	SIGNAL_HANDLER
	if(!QDELING(src))
		qdel(src)

/// A possible challenger has clicked on the arm_item with an empty hand, check if they're using the correct sided hand
/datum/component/arm_wrassle/proc/check_grab_correct_hand(obj/item/source, mob/living/carbon/potential_challenger)
	SIGNAL_HANDLER

	if(!istype(potential_challenger))
		return

	var/mob/living/carbon/owner = parent
	if(potential_challenger.active_hand_index != owner_arm.held_index)
		potential_challenger.visible_message("<span class='warning'>[potential_challenger] tries grabbing [owner]'s [owner_arm.name] with the wrong hand!</span>")
		return COMPONENT_NO_ATTACK_HAND // idiot
	return

/// Here's where we start the battle and set off the bells and whistles announcing it, then move the party over to [/datum/component/arm_wrassle/proc/update_battle]
/datum/component/arm_wrassle/proc/battle(mob/living/carbon/user)
	stage = AWRASSLE_STAGE_BATTLE
	var/mob/living/carbon/owner = parent
	challenger = user
	challenger_arm = challenger.get_bodypart()
	challenger.visible_message("<span class='notice'>[challenger] takes [owner]'s arm on \the [arena]!</span>")
	challenger.do_alert_animation(challenger)
	playsound(get_turf(arena), 'sound/machines/chime.ogg', 50, TRUE)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, ARM_WRASSLIN_TRAIT)
	ADD_TRAIT(challenger, TRAIT_IMMOBILIZED, ARM_WRASSLIN_TRAIT)

	check_modifiers()
	update_battle()

/// A proc where we set owner_stamina_mod and challenger_stamina_mod at the beginning so we don't have to keep checking them
/datum/component/arm_wrassle/proc/check_modifiers()
	var/mob/living/carbon/owner = parent
	if(HAS_TRAIT(owner, TRAIT_GIANT))
		challenger_stamina_mod++
	if(HAS_TRAIT(owner, TRAIT_DWARF))
		owner_stamina_mod++

	if(HAS_TRAIT(challenger, TRAIT_GIANT))
		owner_stamina_mod++
	if(HAS_TRAIT(challenger, TRAIT_DWARF))
		challenger_stamina_mod++

/// A proc that we repeat a few times, narrating the ongoing battle and dealing stamina damage to each participant
/datum/component/arm_wrassle/proc/update_battle()
	battle_ticks++

	var/mob/living/carbon/owner = parent
	challenger.adjustStaminaLoss(rand(5, 10) + challenger_stamina_mod)
	owner.adjustStaminaLoss(rand(5, 10) + owner_stamina_mod)

	if(HAS_TRAIT(challenger, TRAIT_FLOORED)) // tie goes to the owner
		resolve(owner, challenger)
		return
	else if(HAS_TRAIT(owner, TRAIT_FLOORED))
		resolve(challenger, owner)
		return

	if(prob(25))
		challenger.visible_message("<span class='notice'>[owner] struggles with [challenger]!</span>")
	addtimer(CALLBACK(src, .proc/update_battle), 0.75 SECONDS)

/// The end of the battle, this is where the fanfare and decision takes place
/datum/component/arm_wrassle/proc/resolve(mob/living/carbon/winner, mob/living/carbon/loser)
	winner.visible_message("<span class='notice'>[winner] slams [loser] to the floor, winning the arm wrestling contest!</span>")
	playsound(get_turf(arena), 'sound/effects/tableslam.ogg', 90, TRUE)
	qdel(src)

/// The arm_item moved. This means someone's either picked it up, or something had launched the arm_item away.
/datum/component/arm_wrassle/proc/check_moved_arm(obj/item/source, atom/OldLoc, Dir)
	SIGNAL_HANDLER

	if(ismob(arm_item.loc))
		return

	var/mob/living/carbon/owner = parent

	if(!owner.Adjacent(arm_item))
		// If our limbs can be attached easily, we'll pull a cartoon funny and literally pull their arm off if it goes astray
		if(HAS_TRAIT(owner, TRAIT_LIMBATTACHMENT)) // easy come, easy go
			owner_arm.dismember()
			owner_arm.throw_at(arm_item.loc)
		qdel(src)

/// The owner is allowed to move while making the challenge, as long as they're still adjacent to the table the arm_item is on
/datum/component/arm_wrassle/proc/check_owner_move(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	var/mob/living/carbon/owner = parent
	if(!owner.Adjacent(arm_item))
		if(stage > AWRASSLE_STAGE_INITIALIZING && arena)
			owner.visible_message("<span class='notice'>[owner] walks away from \the [arena].</span>")
		qdel(src)
		return

	return ..()


#undef AWRASSLE_STAGE_INITIALIZING
#undef AWRASSLE_STAGE_CHALLENGING
#undef AWRASSLE_STAGE_BATTLE
