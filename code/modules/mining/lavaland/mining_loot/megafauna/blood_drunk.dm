// Cleaving saw

/obj/item/melee/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	icon_state = "cleaving_saw"
	inhand_icon_state = "cleaving_saw"
	worn_icon_state = "cleaving_saw"
	attack_verb_continuous = list("attacks", "saws", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "saw", "slice", "tear", "lacerate", "rip", "dice", "cut")
	force = 12
	throwforce = 20
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	/// List of factions we deal bonus damage to
	var/list/nemesis_factions = list(FACTION_MINING, FACTION_BOSS)
	/// Amount of damage we deal to the above factions
	var/faction_bonus_force = 30
	/// Whether the cleaver is actively AoE swiping something.
	var/swiping = FALSE
	/// Amount of bleed stacks gained per hit
	var/bleed_stacks_per_hit = 3
	/// Force when the saw is opened.
	var/open_force = 20
	/// Throwforce when the saw is opened.
	var/open_throwforce = 20

/obj/item/melee/cleaving_saw/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		transform_cooldown_time = (CLICK_CD_MELEE * 0.25), \
		force_on = open_force, \
		throwforce_on = open_throwforce, \
		sharpness_on = sharpness, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		attack_verb_continuous_on = list("cleaves", "swipes", "slashes", "chops"), \
		attack_verb_simple_on = list("cleave", "swipe", "slash", "chop"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/cleaving_saw/examine(mob/user)
	. = ..()
	. += span_notice("It is [HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].")
	. += span_notice("Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.")
	. += span_notice("Transforming it immediately after an attack causes the next attack to come out faster.")

/obj/item/melee/cleaving_saw/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is [HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!"))
	attack_self(user)
	return BRUTELOSS

/obj/item/melee/cleaving_saw/melee_attack_chain(mob/user, atom/target, list/modifiers)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/cleaving_saw/attack(mob/living/target, mob/living/carbon/human/user)
	var/is_open = HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE)
	if(!is_open || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!is_open)
			faction_bonus_force = 0
		var/is_nemesis_faction = FALSE
		for(var/found_faction in target.faction)
			if(found_faction in nemesis_factions)
				is_nemesis_faction = TRUE
				force += faction_bonus_force
				nemesis_effects(user, target)
				break
		. = ..()
		if(is_nemesis_faction)
			force -= faction_bonus_force
		if(!is_open)
			faction_bonus_force = initial(faction_bonus_force)
		return

	var/turf/user_turf = get_turf(user)
	var/dir_to_target = get_dir(user_turf, get_turf(target))
	swiping = TRUE
	var/static/list/cleaving_saw_cleave_angles = list(0, -45, 45) //so that the animation animates towards the target clicked and not towards a side target
	for(var/i in cleaving_saw_cleave_angles)
		var/turf/turf = get_step(user_turf, turn(dir_to_target, i))
		for(var/mob/living/living_target in turf)
			if(user.Adjacent(living_target) && living_target.body_position != LYING_DOWN)
				melee_attack_chain(user, living_target)
	swiping = FALSE

/*
 * If we're attacking [target]s in our nemesis list, apply unique effects.
 *
 * user - the mob attacking with the saw
 * target - the mob being attacked
 */
/obj/item/melee/cleaving_saw/proc/nemesis_effects(mob/living/user, mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite))
		return
	var/datum/status_effect/stacking/saw_bleed/existing_bleed = target.has_status_effect(/datum/status_effect/stacking/saw_bleed)
	if(existing_bleed)
		existing_bleed.add_stacks(bleed_stacks_per_hit)
	else
		target.apply_status_effect(/datum/status_effect/stacking/saw_bleed, bleed_stacks_per_hit)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback and makes the nextmove after transforming much quicker.
 */
/obj/item/melee/cleaving_saw/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	user.changeNext_move(CLICK_CD_MELEE * 0.25)
	if(user)
		balloon_alert(user, "[active ? "opened" : "closed"] [src]")
	playsound(src, 'sound/effects/magic/clockwork/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (active * 30000))
	return COMPONENT_NO_DEFAULT_MESSAGE

// Wildhunter's butchering knife

/obj/item/knife/hunting/wildhunter
	name = "wildhunter's butchering knife"
	desc = "A magical knife made out of ashen stone. It was used to butcher local fauna by best hunters. Cuts everything to the simplest."
	icon = 'icons/obj/weapons/stabby_wide.dmi'
	inhand_icon_state = "wildhuntingknife"
	icon_state = "wildhuntingknife"
	icon_angle = 180
	force = 20
	wound_bonus = 15
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slices", "hunts", "butchers", "pierces")
	attack_verb_simple = list("slice", "hunt", "butcher", "pierce")

//best butchering tool
/obj/item/knife/hunting/wildhunter/set_butchering()
	AddComponent(\
		/datum/component/butchering, \
		speed = 1.5 SECONDS , \
		effectiveness = 110, \
		bonus_modifier = 0, \
	)

/obj/item/knife/hunting/wildhunter/make_stabby()
	return

//cut those trophies
/obj/item/knife/hunting/wildhunter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/crusher_trophy))
		return NONE
	var/obj/item/crusher_trophy/trophy = interacting_with
	if(isnull(trophy.wildhunter_drop))
		return NONE
	balloon_alert(user, "cutting trophy...")
	if(!do_after(user, 4 SECONDS, trophy))
		return ITEM_INTERACT_BLOCKING
	new trophy.wildhunter_drop(trophy.drop_location())
	qdel(trophy)
	return ITEM_INTERACT_SUCCESS
