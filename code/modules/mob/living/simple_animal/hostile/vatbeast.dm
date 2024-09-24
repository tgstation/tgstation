///Vatbeasts are creatures from vatgrowing and are literaly a beast in a vat, yup. They are designed to be a powerful mount roughly equal to a gorilla in power.
/mob/living/simple_animal/hostile/vatbeast
	name = "vatbeast"
	desc = "A strange molluscoidal creature carrying a busted growing vat.\nYou wonder if this burden is a voluntary undertaking in order to achieve comfort and protection, or simply because the creature is fused to its metal shell?"
	icon = 'icons/mob/vatgrowing.dmi'
	icon_state = "vat_beast"
	icon_living = "vat_beast"
	icon_dead = "vat_beast_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mob_size = MOB_SIZE_LARGE
	gender = NEUTER
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	speak_emote = list("roars")
	atmos_requirements = null
	health = 250
	maxHealth = 250
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 1, STAMINA = 0, OXY = 1)
	melee_damage_lower = 25
	melee_damage_upper = 25
	obj_damage = 40
	// Greenish, seems about right for it
	lighting_cutoff_red = 10
	lighting_cutoff_green = 25
	lighting_cutoff_blue = 20
	attack_sound = 'sound/items/weapons/punch3.ogg'
	attack_verb_continuous = "slaps"
	attack_verb_simple = "slap"

/mob/living/simple_animal/hostile/vatbeast/Initialize(mapload)
	. = ..()
	GRANT_ACTION(/datum/action/cooldown/tentacle_slap)

	add_cell_sample()
	AddComponent(/datum/component/tameable, list(/obj/item/food/fries, /obj/item/food/cheesyfries, /obj/item/food/cornchips, /obj/item/food/carrotfries), tame_chance = 30, bonus_tame_chance = 0)

/mob/living/simple_animal/hostile/vatbeast/tamed(mob/living/tamer, obj/item/food)
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/vatbeast)
	faction = list(FACTION_NEUTRAL)

/mob/living/simple_animal/hostile/vatbeast/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_VATBEAST, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/// Ability that allows the owner to slap other mobs a short distance away.
/// For vatbeats, this ability is shared with the rider.
/datum/action/cooldown/tentacle_slap
	name = "Tentacle slap"
	desc = "Slap a creature with your tentacles."
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "tentacle_slap"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	cooldown_time = 12 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'

/datum/action/cooldown/tentacle_slap/update_button_name(atom/movable/screen/movable/action_button/button, force)
	if(button.our_hud.mymob != owner)
		// For buttons given to mobs which are not our owner, give it this alt name
		button.name = "Command Tentacle Slap"
		button.desc = "Command your steed to slap a creature with its tentacles."
		return

	return ..()

/datum/action/cooldown/tentacle_slap/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("You prepare your [on_who == owner ? "":"steed's "]pimp-tentacle. <b>Left-click to slap a target!</b>"))

/datum/action/cooldown/tentacle_slap/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("You stop preparing your [on_who == owner ? "":"steed's "]pimp-tentacle."))

/datum/action/cooldown/tentacle_slap/InterceptClickOn(mob/living/caller, params, atom/target)
	// Check if we can slap
	if(!isliving(target) || target == owner)
		return FALSE

	if(!owner.Adjacent(target))
		owner.balloon_alert(caller, "too far!")
		return FALSE

	// Do the slap
	. =  ..()
	if(!.)
		return FALSE

	// Give feedback from the slap.
	// Additional feedback for if a rider did it
	if(caller != owner)
		to_chat(caller, span_notice("You command [owner] to slap [target] with its tentacles."))

	return TRUE

/datum/action/cooldown/tentacle_slap/Activate(atom/to_slap)
	var/mob/living/living_to_slap = to_slap

	owner.visible_message(
		span_warning("[owner] slaps [to_slap] with its tentacle!"),
		span_notice("You slap [to_slap] with your tentacle."),
	)
	playsound(owner, 'sound/effects/emotes/assslap.ogg', 90)
	var/atom/throw_target = get_edge_target_turf(to_slap, owner.dir)
	living_to_slap.throw_at(throw_target, 6, 4, owner)
	living_to_slap.apply_damage(30, BRUTE)

	StartCooldown()
	return TRUE
