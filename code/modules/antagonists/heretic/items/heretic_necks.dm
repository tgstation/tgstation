/obj/item/clothing/neck/heretic_focus
	name = "Amber Focus"
	desc = "An amber focusing glass that provides a link to the world beyond. The necklace seems to twitch, but only when you look at it from the corner of your eye."
	icon_state = "eldritch_necklace"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/heretic_focus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/neck/heretic_focus/crimson_focus
	name = "Crimson Focus"
	desc = "A blood-red focusing glass that provides a link to the world beyond, and worse. Its eye is constantly twitching and gazing in all directions. It almost seems to be silently screaming..."
	icon_state = "crimson_focus"
	/// The aura healing component. Used to delete it when taken off.
	var/datum/component/component
	/// If active or not, used to add and remove its cult and heretic buffs.
	var/active = FALSE

/obj/item/clothing/neck/heretic_focus/crimson_focus/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return

	var/team_color = COLOR_ADMIN_PINK
	if(IS_CULTIST(user))
		var/datum/action/innate/cult/blood_magic/magic_holder = locate() in user.actions
		team_color = COLOR_CULT_RED
		magic_holder.magic_enhanced = TRUE
	else if(IS_HERETIC_OR_MONSTER(user) && !active)
		for(var/datum/action/cooldown/spell/spell_action in user.actions)
			spell_action.cooldown_time *= 0.5
			active = TRUE
		team_color = COLOR_GREEN
	else
		team_color = pick(COLOR_CULT_RED, COLOR_GREEN)

	user.add_traits(list(TRAIT_MANSUS_TOUCHED, TRAIT_BLOODY_MESS), REF(src))
	to_chat(user, span_alert("Your heart takes on a strange yet soothing irregular rhythm, and your blood feels significantly less viscous than it used to be. You're not sure if that's a good thing."))
	component = user.AddComponent( \
		/datum/component/aura_healing, \
		range = 3, \
		brute_heal = 1, \
		burn_heal = 1, \
		blood_heal = 2, \
		suffocation_heal = 5, \
		simple_heal = 0.6, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_MANSUS_TOUCHED, \
		healing_color = team_color, \
	)

/obj/item/clothing/neck/heretic_focus/crimson_focus/dropped(mob/living/user)
	. = ..()

	if(!istype(user))
		return

	if(HAS_TRAIT_FROM(user, TRAIT_MANSUS_TOUCHED, REF(src)))
		to_chat(user, span_notice("Your heart and blood return to their regular old rhythm and flow."))

	if(IS_HERETIC_OR_MONSTER(user) && active)
		for(var/datum/action/cooldown/spell/spell_action in user.actions)
			spell_action.cooldown_time *= 2
			active = FALSE
	QDEL_NULL(component)
	user.remove_traits(list(TRAIT_MANSUS_TOUCHED, TRAIT_BLOODY_MESS), REF(src))

	// If boosted enable is set, to prevent false dropped() calls from repeatedly nuking the max spells.
	var/datum/action/innate/cult/blood_magic/magic_holder = locate() in user.actions
	// Remove the last spell if over new limit, as we will reduce our max spell amount. Done beforehand as it causes a index out of bounds runtime otherwise.
	if(magic_holder?.magic_enhanced)
		QDEL_NULL(magic_holder.spells[ENHANCED_BLOODCHARGE])
	magic_holder?.magic_enhanced = FALSE


/obj/item/clothing/neck/heretic_focus/crimson_focus/attack_self(mob/living/user, modifiers)
	. = ..()
	to_chat(user, span_danger("You start tightly squeezing [src]..."))
	if(!do_after(user, 1.25 SECONDS, src))
		return
	to_chat(user, span_danger("[src] explodes into a shower of gore and blood, drenching your arm. You can feel the blood seeping into your skin. You inmediately feel better, but soon, the feeling turns hollow as your veins itch."))
	new /obj/effect/gibspawner/generic(get_turf(src))
	var/heal_amt = user.adjustBruteLoss(-50)
	user.adjustFireLoss( -(50 - abs(heal_amt)) ) // no double dipping

	// I want it to poison the user but I also think it'd be neat if they got their juice as well. But that cancels most of the damage out. So I dunno.
	user.reagents?.add_reagent(/datum/reagent/fuel/unholywater, rand(6, 10))
	user.reagents?.add_reagent(/datum/reagent/eldritch, rand(6, 10))
	qdel(src)

/obj/item/clothing/neck/heretic_focus/crimson_focus/examine(mob/user)
	. = ..()

	var/magic_dude
	if(IS_CULTIST(user))
		. += span_cult_bold("This focus will allow you to store one extra spell and halve the empowering time, alongside providing a small regenerative effect.")
		magic_dude = TRUE
	if(IS_HERETIC_OR_MONSTER(user))
		. += span_notice("This focus will halve your spell cooldowns, alongside granting a small regenerative effect to any nearby heretics or monsters, including you.")
		magic_dude = TRUE

	if(magic_dude)
		. += span_red("You can also squeeze it to recover a large amount of health quickly, at a cost...")

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulsing of a thousand others."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// A secondary clothing trait only applied to heretics.
	var/heretic_only_trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return
	if(!ishuman(user) || !IS_HERETIC_OR_MONSTER(user))
		return

	ADD_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[REF(src)]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[REF(src)]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "Piercing Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into impossible shapes."
	heretic_only_trait = TRAIT_XRAY_VISION

// Cosmetic-only version
/obj/item/clothing/neck/fake_heretic_amulet
	name = "religious icon"
	desc = "A strange medallion, which makes its wearer look like they're part of some cult."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL


// The amulet conversion tool used by moon heretics
/obj/item/clothing/neck/heretic_focus/moon_amulet
	name = "Moonlight Amulet"
	desc = "A piece of the mind, the soul and the moon. Gazing into it makes your head spin and hear whispers of laughter and joy."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "moon_amulette"
	w_class = WEIGHT_CLASS_SMALL
	// How much damage does this item do to the targets sanity?
	var/sanity_damage = 20

/obj/item/clothing/neck/heretic_focus/moon_amulet/attack(mob/living/target, mob/living/user, params)
	var/mob/living/carbon/human/hit = target
	if(!IS_HERETIC_OR_MONSTER(user))
		user.balloon_alert(user, "you feel a presence watching you")
		user.add_mood_event("Moon Amulet Insanity", /datum/mood_event/amulet_insanity)
		user.mob_mood.set_sanity(user.mob_mood.sanity - 50)
		return
	if(hit.can_block_magic())
		return
	if(!hit.mob_mood)
		return
	if(hit.mob_mood.sanity_level < SANITY_LEVEL_UNSTABLE)
		user.balloon_alert(user, "their mind is too strong!")
		hit.add_mood_event("Moon Amulet Insanity", /datum/mood_event/amulet_insanity)
		hit.mob_mood.set_sanity(hit.mob_mood.sanity - sanity_damage)
	else
		user.balloon_alert(user, "their mind bends to see the truth!")
		hit.apply_status_effect(/datum/status_effect/moon_converted)
		user.log_message("made [target] insane.", LOG_GAME)
		hit.log_message("was driven insane by [user]")
	. = ..()
