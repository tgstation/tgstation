
/datum/component/arm_wrassle
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/initialized = FALSE
	var/obj/structure/table/arena
	var/obj/item/arm_wrassle/arm_item
	var/obj/item/bodypart/owner_arm
	var/obj/item/bodypart/challenger_arm
	var/mob/living/carbon/challenger

// *extremely bad russian accent* no!
/datum/component/arm_wrassle/Initialize(obj/item/arm_wrassle/arm_item, obj/structure/table/the_table)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	src.arm_item = arm_item
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

	RegisterSignal(owner_arm, COMSIG_PARENT_QDELETING, .proc/void)
	RegisterSignal(challenger_arm, COMSIG_PARENT_QDELETING, .proc/void)

	post_up()


/datum/component/arm_wrassle/Destroy(force, silent)
	QDEL_NULL(arm_item)
	arena = null

/datum/component/arm_wrassle/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_owner_move)

/datum/component/arm_wrassle/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/arm_wrassle/proc/check_arm_equipped(obj/item/source, mob/user, slot, initial)
	var/mob/living/carbon/owner = parent
	if(user == owner)
		owner.visible_message("<span class='notice'>[owner] removes [owner.p_their()] [owner_arm.name] from \the [arena].</span>")
		qdel(src)
		return
	if(iscarbon(user))
		battle(user)


/datum/component/arm_wrassle/proc/post_up()
	var/mob/living/carbon/owner = parent
	owner.visible_message("<span class='notice'>[owner] sets [owner.p_their()] [owner_arm.name] on \the [arena], awaiting a challenger!</span>")
	owner.transferItemToLoc(src, arena.drop_location(), silent = FALSE)

/datum/component/arm_wrassle/proc/check_grab_correct_hand(obj/item/source, mob/living/carbon/potential_challenger)
	SIGNAL_HANDLER

	if(!istype(potential_challenger))
		return

	var/mob/living/carbon/owner = parent
	if(potential_challenger.active_hand_index != owner_arm.held_index)
		potential_challenger.visible_message("<span class='warning'>[potential_challenger] tries grabbing [owner]'s [owner_arm.name] with the wrong hand!</span>")
		return COMPONENT_NO_ATTACK_HAND // idiot
	return

/datum/component/arm_wrassle/proc/battle(mob/living/carbon/user)
	challenger = user
	challenger_arm = challenger.get_bodypart()
	challenger.visible_message("<span class='notice'>[challenger] takes [user]'s arm on \the [arena]!</span>")
	challenger.do_alert_animation(challenger)
	arena.do_alert_animation()
	playsound(get_turf(arena), 'sound/machines/chime.ogg', 50, TRUE)

/datum/component/arm_wrassle/proc/check_moved_arm(obj/item/source, atom/OldLoc, Dir)
	SIGNAL_HANDLER

	if(ismob(arm_item.loc))
		return

	var/mob/living/carbon/owner = parent
	if(!owner.Adjacent(arm_item))
		if(ishuman(owner))
			var/turf/our_turf = get_turf(src)
			var/mob/living/carbon/human/owner_human = owner
			if((owner_human.dna.species.species_traits & ~HAS_FLESH))
				owner_arm.dismember()
				owner_arm.throw_at(our_turf)
		qdel(src)

/datum/component/arm_wrassle/proc/check_owner_move(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER

	var/mob/living/carbon/owner = parent
	if(!Adjacent(owner, arm_item))
		owner.visible_message("<span class='notice'>[owner] walks away from \the [arena].</span>")
		qdel(src)


	return ..()
