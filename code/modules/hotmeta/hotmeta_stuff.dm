/// ~ Ruin Keys ~

/obj/item/keycard/hotmeta
	name = "omninous key"
	desc = "This feels like it belongs to a door."
	icon = 'icons/obj/fluff/hotmeta_keys.dmi'
	puzzle_id = "omninous"

/obj/item/keycard/hotmeta/lizard
	name = "green key"
	icon_state = "lizard_key"
	puzzle_id = "lizard"

/obj/item/keycard/hotmeta/drake
	name = "red key"
	icon_state = "drake_key"
	puzzle_id = "drake"

/obj/item/keycard/hotmeta/hierophant
	name = "purple key"
	icon_state = "hiero_key"
	puzzle_id = "hiero"

/obj/item/keycard/hotmeta/legion
	name = "blue key"
	icon_state = "legion_key"
	puzzle_id = "legion"

/obj/machinery/door/puzzle/keycard/hotmeta
	name = "wooden door"
	desc = "A dusty, scratched door with a thick lock attached."
	icon = 'icons/obj/doors/puzzledoor/wood.dmi'
	puzzle_id = "omninous"
	open_message = "The door opens with a loud creak."

/obj/machinery/door/puzzle/keycard/hotmeta/lizard
	puzzle_id = "lizard"
	color = "#044116"
	desc = "A dusty, scratched door with a thick green lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/drake
	puzzle_id = "drake"
	color = "#830c0c"
	desc = "A dusty, scratched door with a thick red lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/hierophant
	puzzle_id = "hiero"
	color = "#770a65"
	desc = "A dusty, scratched door with a thick purple lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/legion
	puzzle_id = "legion"
	color = "#2b0496"
	desc = "A dusty, scratched door with a thick blue lock attached."

// ~ Ruin Mega fauna ~ //

/mob/living/simple_animal/hostile/megafauna/hierophant/hotmeta
	loot = list(/obj/item/hierophant_club, /obj/item/keycard/hotmeta/hierophant)
	icon = 'icons/mob/simple/lavaland/hotmeta_hierophant.dmi'

/mob/living/simple_animal/hostile/megafauna/hierophant/hotmeta/Initialize(mapload)
	. = ..()
	spawned_beacon_ref = WEAKREF(new /obj/effect/hierophant(loc))
	AddComponent(/datum/component/boss_music, 'sound/music/boss/hiero_old.ogg', 154 SECONDS)

/mob/living/simple_animal/hostile/megafauna/hierophant/hotmeta/Destroy()
	QDEL_NULL(spawned_beacon_ref)
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/hotmeta
	loot = list(/obj/structure/closet/crate/necropolis/dragon, /obj/item/keycard/hotmeta/drake)

/mob/living/simple_animal/hostile/megafauna/dragon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boss_music, 'sound/music/boss/triumph.ogg', 138 SECONDS)

/mob/living/simple_animal/hostile/megafauna/legion/hotmeta
	loot = list(/obj/item/keycard/hotmeta/legion)

/mob/living/simple_animal/hostile/megafauna/legion/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boss_music, 'sound/music/boss/revenge.ogg', 293 SECONDS)

// ~ Hotmeta Spefific Lockers ~ //

/obj/structure/closet/secure_closet/hotmeta
// ~ Hos ~ //
/obj/structure/closet/secure_closet/hotmeta/hos
	name = "head of security's locker"
	icon_state = "hos"
	req_access = list(ACCESS_HOS)

/obj/structure/closet/secure_closet/hotmeta/hos/PopulateContents()
	..()
	new /obj/item/computer_disk/command/hos(src)
	new /obj/item/radio/headset/heads/hos(src)
	new /obj/item/radio/headset/heads/hos/alt(src)
	new /obj/item/clothing/shoes/russian(src)
	new /obj/item/clothing/under/syndicate/rus_army(src)
	new /obj/item/clothing/suit/armor/vest/russian(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/melee/baton(src)
	new /obj/item/storage/lockbox/medal/sec(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/storage/lockbox/loyalty(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/shield/riot/tele(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/circuitboard/machine/techfab/department/security(src)
	new /obj/item/storage/photo_album/hos(src)

/obj/structure/closet/secure_closet/hotmeta/hos/populate_contents_immediate()
	. = ..()

	// Traitor steal objectives
	new /obj/item/gun/energy/e_gun/hos/hotmeta(src)
	new /obj/item/pinpointer/nuke(src)

// ~ Security Officer ~ //
/obj/structure/closet/secure_closet/hotmeta/security
	name = "security officer's locker"
	icon_state = "sec"
	req_access = list(ACCESS_BRIG)

/obj/structure/closet/secure_closet/hotmeta/security/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/shoes/russian(src)
	new /obj/item/clothing/under/syndicate/rus_army(src)
	new /obj/item/clothing/suit/armor/vest/russian(src)
	new /obj/item/clothing/head/helmet/rus_helmet(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/melee/baton(src)
	new /obj/item/gun/ballistic/automatic/battle_rifle(src)
	new /obj/item/ammo_box/magazine/m38/hotshot(src)
	new /obj/item/ammo_box/magazine/m38/iceblox(src)

// ~ Warden ~ //
/obj/structure/closet/secure_closet/hotmeta/warden
	name = "warden's locker"
	icon_state = "warden"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/hotmeta/warden/PopulateContents()
	..()
	new /obj/item/dog_bone(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/storage/box/zipties(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/door_remote/head_of_security(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/shoes/russian(src)
	new /obj/item/clothing/under/syndicate/rus_army(src)
	new /obj/item/clothing/suit/armor/vest/russian(src)
	new /obj/item/clothing/head/helmet/rus_helmet(src)
	new /obj/item/clothing/gloves/krav_maga/combatglovesplus(src)

// ~ sky bulge ~ //
/obj/item/spear/skybulge
	name = "\improper Sky Bulge"
	desc = "A legendary stick with a very pointy tip. Takes you to the skies!"
	icon_state = "dragoonpole0"
	icon_prefix = "dragoonpole"
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "gores", "lances")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "gore", "lance")
	throwforce = 24
	force_wielded = 21
	embed_type = null //no embedding

	custom_materials = list(
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/alloy/plastitaniumglass = SHEET_MATERIAL_AMOUNT,
	)
	action_slots = ITEM_SLOT_HANDS
	actions_types = list(/datum/action/item_action/skybulge)

///The action button the spear gives, usable once a minute.
/datum/action/item_action/skybulge
	name = "Dragoon Strike"
	desc = "Jump up into the skies and fall down upon your opponents to deal double damage."
	check_flags = parent_type::check_flags | AB_CHECK_IMMOBILE | AB_CHECK_PHASED
	///Ref to the addtimer we have between jumping up and falling down, used to cancel early if you're incapacitated mid-jump.
	var/jump_timer
	///Cooldown time between jumps.
	var/jump_cooldown_time = 1 MINUTES
	/**
	 * boolean we set every time we jump, to know if we should take away the passflags we give,
	 * so we don't give/take when they have it from other sources (since we don't have traits, we have
	 * no way to tell which pass flags they get from what source.)
	 */
	var/gave_pass_flags = FALSE

/datum/action/item_action/skybulge/do_effect(trigger_flags)
	if(!HAS_TRAIT(target, TRAIT_WIELDED))
		owner.balloon_alert(owner, "not dual-wielded!")
		return
	var/time_left = S_TIMER_COOLDOWN_TIMELEFT(target, COOLDOWN_SKYBULGE_JUMP)
	if(time_left)
		owner.balloon_alert(owner, "[FLOOR(time_left * 0.1, 0.1)]s cooldown!")
		return
	//do after shows the progress bar as feedback, so nothing here.
	if(LAZYACCESS(owner.do_afters, target))
		return

	owner.balloon_alert(owner, "charging up...")
	ADD_TRAIT(target, TRAIT_NEEDS_TWO_HANDS, ACTION_TRAIT)
	INVOKE_ASYNC(src, PROC_REF(jump_up))

///Sends the owner up in the air and calls them back down, calling land() for aftereffects.
/datum/action/item_action/skybulge/proc/jump_up()
	if(!do_after(owner, 2 SECONDS, target = owner, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		REMOVE_TRAIT(target, TRAIT_NEEDS_TWO_HANDS, ACTION_TRAIT)
		return
	playsound(owner, 'sound/effects/footstep/heavy1.ogg', 50, 1)
	S_TIMER_COOLDOWN_START(target, COOLDOWN_SKYBULGE_JUMP, jump_cooldown_time)
	new /obj/effect/temp_visual/telegraphing/exclamation/following(get_turf(owner), 2.5 SECONDS, owner)

	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_attack_during_jump))
	ADD_TRAIT(target, TRAIT_NODROP, ACTION_TRAIT)
	owner.add_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_MOVE_FLYING), ACTION_TRAIT)

	if(owner.pass_flags & PASSTABLE)
		gave_pass_flags = FALSE
	else
		gave_pass_flags = TRUE
		owner.pass_flags |= PASSTABLE

	owner.set_density(FALSE)
	owner.layer = ABOVE_ALL_MOB_LAYER

	animate(owner, pixel_y = owner.pixel_y + 60, time = (2 SECONDS), easing = CIRCULAR_EASING|EASE_OUT)
	animate(pixel_y = initial(owner.pixel_y), time = (1 SECONDS), easing = CIRCULAR_EASING|EASE_IN)

	jump_timer = addtimer(CALLBACK(src, PROC_REF(land), /*do_effects = */TRUE, /*mob_override = */owner), 3 SECONDS, TIMER_STOPPABLE)

/datum/action/item_action/skybulge/update_status_on_signal(datum/source, new_stat, old_stat)
	if(!isnull(jump_timer) && !IsAvailable())
		INVOKE_ASYNC(src, PROC_REF(land), /*do_effects = */FALSE, /*mob_override = */source)
		deltimer(jump_timer)
	return ..()

/**
 * ## land()
 *
 * Called by jump_up, this is the post-jump effects, damaging objects and mobs it lands on.
 * Args:
 * do_effects - Whether we'll do the attacking effects of the land (damaging mobs & sound),
 * we set this to false if we were forced out of the jump, they lost their ability to do the hit.
 * mob_doing_effects - This is who we use for aftereffects, passing the mob using the ability, with owner as fallback.
 * ourselves.
 */
/datum/action/item_action/skybulge/proc/land(do_effects = TRUE, mob/living/mob_doing_effects)
	if(!mob_doing_effects)
		mob_doing_effects = owner
	var/turf/landed_on = get_turf(mob_doing_effects)

	UnregisterSignal(target, COMSIG_ITEM_ATTACK)
	target.remove_traits(list(TRAIT_NEEDS_TWO_HANDS, TRAIT_NODROP), ACTION_TRAIT)
	mob_doing_effects.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_MOVE_FLYING), ACTION_TRAIT)
	if(gave_pass_flags)
		mob_doing_effects.pass_flags &= ~PASSTABLE
	mob_doing_effects.set_density(TRUE)
	mob_doing_effects.layer = initial(mob_doing_effects.layer)
	SET_PLANE(mob_doing_effects, initial(mob_doing_effects.plane), landed_on)

	if(!do_effects)
		return

	playsound(mob_doing_effects, 'sound/effects/explosion/explosion1.ogg', 40, 1)
	var/obj/item/skybulge_item = target
	skybulge_item.force *= 2 //we hit for double damage.

	for(var/atom/thing as anything in landed_on)
		if(thing == mob_doing_effects)
			continue

		if(isobj(thing))
			thing.take_damage(150)
			continue

		if(isliving(thing))
			skybulge_item.attack(thing, owner)
			var/mob/living/living_target = thing
			living_target.SetKnockdown(1 SECONDS)

	skybulge_item.force /= 2

///Called when the person holding us is trying to attack something mid-jump.
///You're technically in mid-air, so block any attempts at getting extra hits in.
/datum/action/item_action/skybulge/proc/on_attack_during_jump(atom/source, mob/living/target_mob, mob/living/user, params)
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_ATTACK_CHAIN

// ~ Dragoon Armour ~ //

/obj/item/clothing/head/helmet/dragoon
	name = "drachen helmet"
	desc = "A chainmail helmet with dragon scales attached to the skeleton, with ash-covered mythril plate reinforcement covering it."
	icon_state = "dragoonhelm"
	base_icon_state = "dragoonhelm"
	inhand_icon_state = "dragoonhelm"
	clothing_flags = SNUG_FIT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/obj/item/clothing/suit/armor/dragoon
	name = "drachen suit"
	desc = "A chainmail suit with dragon scales attached to the skeleton, with ash-covered mythril plate reinforcement covering it."
	icon_state = "dragoon"
	inhand_icon_state = "dragoon"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	allowed = list(/obj/item/spear/skybulge)
// ~ Hotmeta Spefific guns ~ //

/obj/item/gun/energy/e_gun/hos/hotmeta
	name = "\improper X-420 MultiPhase Energy Gun"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/ion/hos, /obj/item/ammo_casing/energy/electrode/hos)

/obj/item/ammo_casing/energy/electrode/hos
	projectile_type = /obj/projectile/energy/electrode
	select_name = "taser"
	e_cost = LASER_SHOTS(4, STANDARD_CELL_CHARGE)

// ~ Hotmeta Spefific Turfs ~ //

/turf/open/floor/iron/solarpanel/lava_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
