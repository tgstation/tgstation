/// Deciseconds it takes to look through the saddlebags from the saddle and from the ground (Ratwood MiddleClick(): 10 and 30).
#define ROGUE_SADDLEBAG_RIDER_TIME rogue_value("mount_saddlebag_rider_time")
#define ROGUE_SADDLEBAG_TIME rogue_value("mount_saddlebag_time")
/// The choice Ratwood offers on a mount in both a caparison and a bard.
#define ROGUE_ADJUST_CAPARISON "Adjust caparison"
#define ROGUE_SADDLEBAGS "Look through the saddle bags"

/// Riding (Ratwood simple_animal.dm can_saddle, ssaddle, user_buckle_mob(), user_unbuckle_mob(), relaymove(), violent_dismount();
/// rogue/game/saiga.dm, farm/goat.dm, farm/hog.dm, creacher/beetle.dm tamed() and update_icon(); rogueitems/natural/animals.dm
/// the saddle; datums/components/riding.dm) on TG's ridable element and creature riding component. A saddle fits a grown saiga,
/// goat, billy goat, hog or beetle, and a saddled tamed one carries a rider - the saiga, the goats and the hog a passenger too.
/// The first rider steers; the pace is the mount's own less what the rider's riding skill takes off, a gallop (running) teaches
/// the skill, and a hurt mount slows down. Getting on and off takes the unskilled a while; a dismount cut short, a door ridden
/// through or a blow taken at a gallop throws the rider off. A caparison and a bard go over the saddle (husbandry/tack.dm).
/// An apple from the hand heals a mount for a while and keeps it from holding a grudge.
///
/// Saddle, caparison and bard go on by clicking the mount with them and come off, in that order back, by a right click with an
/// empty hand out of combat mode. A rider gets on by dragging themself onto the mount, or in combat mode by clicking it with an empty
/// hand, and off by resisting. Alt+click on a saddled mount (Ratwood's middle click, the module's kick) looks through the
/// saddlebags, or adjusts the caparison over or under the bard.
/mob/living/basic/rockhill
	/// Ratwood can_saddle and can_buckle: a grown beast of this kind takes a saddle, and saddled and tamed it carries riders.
	var/rogue_can_saddle = FALSE
	/// Ratwood move_to_delay of a mount: deciseconds a tile it goes under a rider before the rider's skill counts.
	var/rogue_mount_delay = 8
	/// How many ride it at once: a rider and a passenger behind (the beetle carries one).
	var/rogue_mount_seats = 2
	/// States of its saddle in its own sheet (Ratwood update_icon()): the part under the rider and the part over the rider.
	var/rogue_saddle_state = "saddle"
	var/rogue_saddle_front_state = "saddle-above"
	/// Its neck and head drawn over the rider while it is ridden (Ratwood "saiga_mounted" and the like); null - none.
	var/rogue_mounted_state
	/// Ratwood's saddled mounts come with a saddle on (saddled/Initialize()).
	var/rogue_start_saddled = FALSE

/// Where the riders sit (Ratwood set_riding_offsets()), by direction, list(x, y): the rider and the passenger behind. The saiga's.
/mob/living/basic/rockhill/proc/rogue_rider_offsets(pass_index)
	var/static/list/rider = list(TEXT_NORTH = list(0, 8), TEXT_SOUTH = list(0, 8), TEXT_EAST = list(-2, 8), TEXT_WEST = list(2, 8))
	var/static/list/passenger = list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 16), TEXT_EAST = list(-10, 8), TEXT_WEST = list(10, 8))
	return pass_index > 1 ? passenger : rider

/// The mount's layer while ridden, by direction, list(0, 0, layer) (Ratwood set_vehicle_dir_layer()): over its riders while it
/// faces the viewer, under them otherwise. The saiga's.
/mob/living/basic/rockhill/proc/rogue_mount_layers()
	var/static/list/layers = list(
		TEXT_NORTH = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_SOUTH = list(0, 0, ABOVE_MOB_LAYER),
		TEXT_EAST = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_WEST = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
	)
	return layers

/// Ratwood's saddlebags (storage/storage_types.dm concrete/roguetown/saddle): what is packed in a saddle rides with it.
/datum/storage/rogue_grid/roguetown/saddle
	screen_max_columns = 4
	screen_max_rows = 4
	max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/natural/saddle
	rogue_storage_type = /datum/storage/rogue_grid/roguetown/saddle

/// An overlay of a mount's tack in its own sheet, not tinted or faded with the mount (Ratwood RESET_ALPHA|RESET_COLOR).
/proc/rogue_tack_overlay(icon, state, layer = FLOAT_LAYER, color)
	var/mutable_appearance/look = mutable_appearance(icon, state, layer)
	look.appearance_flags |= RESET_ALPHA | RESET_COLOR
	look.color = color
	return look

/// The tack of a mount and its riding (Ratwood simple_animal.dm ssaddle, ccaparison, bbarding): the saddle that makes it ridable
/// (TG's ridable element), what lies over the saddle, and what befalls the riders.
/datum/component/rogue_mount
	var/obj/item/natural/saddle/saddle
	var/obj/item/caparison/caparison
	var/obj/item/clothing/barding/barding
	/// Ratwood caparison_over_barding: the caparison is drawn over the bard, not under it.
	var/caparison_over_barding = FALSE
	/// Tiles galloped towards the next riding experience (Ratwood riding_xp_move_counter).
	var/gallop_count = 0
	/// A hoof sounds every other tile (Ratwood do_footstep).
	var/hoof_step = FALSE
	/// Riders getting on or off right now: a second drag or resist neither starts another wait nor counts as a fall.
	var/list/busy_riders

/datum/component/rogue_mount/Initialize()
	if(!istype(parent, /mob/living/basic/rockhill))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/basic/rockhill/mount = parent
	mount.max_buckled_mobs = mount.rogue_mount_seats
	// TG's riding offsets a mount from its base_pixel_x; a ported beast has only pixel_x (a 48 pixel saiga stands 8 to the left).
	if(!mount.base_pixel_x && mount.pixel_x)
		mount.base_pixel_x = mount.pixel_x
	if(!mount.base_pixel_y && mount.pixel_y)
		mount.base_pixel_y = mount.pixel_y
	if(mount.rogue_start_saddled)
		set_saddle(new /obj/item/natural/saddle(mount))

/datum/component/rogue_mount/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_hand_secondary))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_buckle))
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_unbuckle))
	RegisterSignals(parent, list(COMSIG_MOB_STATCHANGE, COMSIG_LIVING_SET_BODY_POSITION), PROC_REF(on_posture))
	RegisterSignal(parent, COMSIG_MOB_PRE_EAT, PROC_REF(on_pre_eat))
	RegisterSignal(parent, COMSIG_MOB_ATE, PROC_REF(on_ate))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_damage_modifiers))
	RegisterSignal(parent, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(on_hurt))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_mount_deleting))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_click_alt))
	var/atom/mount = parent
	mount.update_appearance(UPDATE_OVERLAYS)

/datum/component/rogue_mount/UnregisterFromParent()
	var/atom/movable/mount = parent
	for(var/mob/living/rider as anything in mount.buckled_mobs)
		UnregisterSignal(rider, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_EXITED,
		COMSIG_MOVABLE_BUCKLE,
		COMSIG_MOVABLE_UNBUCKLE,
		COMSIG_MOB_STATCHANGE,
		COMSIG_LIVING_SET_BODY_POSITION,
		COMSIG_MOB_PRE_EAT,
		COMSIG_MOB_ATE,
		COMSIG_MOB_APPLY_DAMAGE_MODIFIERS,
		COMSIG_MOB_AFTER_APPLY_DAMAGE,
		COMSIG_QDELETING,
		COMSIG_CLICK_ALT,
	))

/datum/component/rogue_mount/Destroy(force)
	saddle = null
	caparison = null
	barding = null
	busy_riders = null
	return ..()

/// Saddled: the mount is ridable (TG's ridable element with the Ratwood seats of /datum/component/riding/creature/rockhill).
/datum/component/rogue_mount/proc/set_saddle(obj/item/natural/saddle/new_saddle)
	var/mob/living/basic/rockhill/mount = parent
	saddle = new_saddle
	mount.AddElement(/datum/element/ridable, /datum/component/riding/creature/rockhill)
	mount.update_appearance(UPDATE_OVERLAYS)

/// Whatever leaves the mount - taken off, dropped at its death, destroyed - is no longer on it; without the saddle nobody rides it.
/datum/component/rogue_mount/proc/on_exited(mob/living/basic/rockhill/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(gone == saddle)
		saddle = null
		source.unbuckle_all_mobs(force = TRUE)
		source.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/rockhill)
	else if(gone == caparison)
		caparison = null
	else if(gone == barding)
		barding = null
		update_barding_pace()
	else
		return
	source.update_appearance(UPDATE_OVERLAYS)

/// The tack does not go with a mount that is gone (Ratwood butcher() drops the saddle): it falls where the mount was.
/datum/component/rogue_mount/proc/on_mount_deleting(mob/living/basic/rockhill/source, force)
	SIGNAL_HANDLER
	var/turf/here = get_turf(source)
	for(var/obj/item/tack in list(saddle, caparison, barding))
		if(QDELETED(tack))
			continue
		if(here)
			tack.forceMove(here)
		else
			qdel(tack)

/datum/component/rogue_mount/proc/on_item_interaction(mob/living/basic/rockhill/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(istype(tool, /obj/item/natural/saddle))
		INVOKE_ASYNC(src, PROC_REF(put_on_saddle), user, tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/caparison))
		INVOKE_ASYNC(src, PROC_REF(fit_caparison), user, tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/clothing/barding))
		INVOKE_ASYNC(src, PROC_REF(fit_barding), user, tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/reagent_containers/food/snacks/grown/apple) && !user.combat_mode && source.has_status_effect(/datum/status_effect/rogue_mount_apple))
		to_chat(user, span_warning("[source] is still chewing on [source.p_their()] last meal! Try again in a few seconds when [source.p_they()] look[source.p_s()] hungry."))
		return ITEM_INTERACT_BLOCKING
	return NONE

/// Ratwood saddle attack(): the saddle goes on a beast nobody rides.
/datum/component/rogue_mount/proc/put_on_saddle(mob/living/user, obj/item/natural/saddle/new_saddle)
	var/mob/living/basic/rockhill/mount = parent
	if(saddle)
		to_chat(user, span_warning("[mount] is already saddled."))
		return
	if(mount.stat == DEAD || mount.has_buckled_mobs())
		return
	user.visible_message(span_warning("[user] tries to saddle [mount]..."), span_notice("I try to saddle [mount]..."))
	if(!do_after(user, ROGUE_SADDLE_TIME, target = mount))
		return
	if(saddle || mount.stat == DEAD || mount.has_buckled_mobs() || !user.is_holding(new_saddle))
		return
	if(!user.transferItemToLoc(new_saddle, mount))
		return
	playsound(mount, 'modular_redtard/husbandry/sound/saddledismount.ogg', 100, FALSE)
	set_saddle(new_saddle)
	user.visible_message(span_notice("[user] saddles [mount]."), span_notice("I saddle [mount]."))

/// Ratwood attack_right(): a right click with an empty hand takes off the caparison, then the bard, then the saddle.
/datum/component/rogue_mount/proc/on_hand_secondary(mob/living/basic/rockhill/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(user.combat_mode || !(saddle || caparison || barding))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(take_off_tack), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/rogue_mount/proc/take_off_tack(mob/living/user)
	var/mob/living/basic/rockhill/mount = parent
	if(user.buckled == mount)
		to_chat(user, span_warning("I need to get off [mount] first."))
		return
	if(caparison || barding)
		take_off_cover(user)
		return
	if(!saddle)
		return
	if(mount.has_buckled_mobs())
		to_chat(user, span_warning("I can't remove [mount]'s saddle while someone is mounted."))
		return
	user.visible_message(span_notice("[user] is removing the saddle from [mount]..."), span_notice("I start removing the saddle from [mount]..."))
	if(!do_after(user, ROGUE_UNSADDLE_TIME, target = mount))
		return
	var/obj/item/natural/saddle/old_saddle = saddle
	if(!old_saddle || caparison || barding || mount.has_buckled_mobs())
		return
	playsound(mount, 'modular_redtard/husbandry/sound/saddledismount.ogg', 100, FALSE)
	old_saddle.forceMove(mount.drop_location())
	user.put_in_hands(old_saddle)
	user.visible_message(span_notice("[user] removes the saddle from [mount]."), span_notice("I remove the saddle from [mount]."))

/// Ratwood MiddleClick() on a living saddled mount, here Alt+click: its saddlebags, or the caparison to adjust when a bard is on too.
/datum/component/rogue_mount/proc/on_click_alt(mob/living/basic/rockhill/source, mob/user)
	SIGNAL_HANDLER
	if(source.stat == DEAD || !saddle || !isliving(user) || !user.can_perform_action(source, SILENT_ADJACENCY))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(alt_tack), user)
	return CLICK_ACTION_SUCCESS

/// Ratwood MiddleClick(): with both a caparison and a bard on, the choice of adjusting the caparison or the saddlebags (the bags if
/// none is made); otherwise the saddlebags.
/datum/component/rogue_mount/proc/alt_tack(mob/living/user)
	var/mob/living/basic/rockhill/mount = parent
	if(caparison && barding)
		var/choice = tgui_alert(user, "What would you like to do?", mount.name, list(ROGUE_ADJUST_CAPARISON, ROGUE_SADDLEBAGS))
		if(QDELETED(src) || QDELETED(mount) || !user.can_perform_action(mount))
			return
		if(choice == ROGUE_ADJUST_CAPARISON)
			adjust_caparison(user)
			return
	open_saddlebags(user)

/// Ratwood "Adjust caparison": the caparison goes over the bard, or back under it.
/datum/component/rogue_mount/proc/adjust_caparison(mob/living/user)
	if(!caparison || !barding)
		return
	caparison_over_barding = !caparison_over_barding
	to_chat(user, span_info("I [caparison_over_barding ? "adjust [caparison] to cover [barding]" : "adjust [caparison] to be under [barding]"]."))
	var/mob/living/basic/rockhill/mount = parent
	mount.update_appearance(UPDATE_OVERLAYS)

/// Ratwood "Look through the saddle bags": the saddle's storage opens on the mount, a moment from the saddle and longer from the ground.
/datum/component/rogue_mount/proc/open_saddlebags(mob/living/user)
	var/mob/living/basic/rockhill/mount = parent
	if(!saddle?.atom_storage)
		return
	var/wait = user.buckled == mount ? ROGUE_SADDLEBAG_RIDER_TIME : ROGUE_SADDLEBAG_TIME
	if(!do_after(user, wait, target = mount) || QDELETED(src) || !saddle?.atom_storage)
		return
	saddle.atom_storage.open_storage(user)

/datum/component/rogue_mount/proc/on_examine(mob/living/basic/rockhill/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(saddle)
		examine_list += span_notice("This animal is saddled: [saddle.name].")
	if(caparison)
		examine_list += span_notice("This animal is wearing a caparison: [caparison.name].")
	if(barding)
		examine_list += span_notice("This animal is wearing a bard: [barding.name].")

/// Ratwood update_icon(): the saddle and, while it is ridden, the mount's neck over the rider; standing, the caparison and the bard.
/datum/component/rogue_mount/proc/on_update_overlays(mob/living/basic/rockhill/source, list/new_overlays)
	SIGNAL_HANDLER
	if(source.stat == DEAD)
		return
	if(saddle)
		new_overlays += rogue_tack_overlay(source.icon, source.rogue_saddle_state)
		new_overlays += rogue_tack_overlay(source.icon, source.rogue_saddle_front_state, ROGUE_TACK_FRONT_LAYER)
	if(source.rogue_mounted_state && source.has_buckled_mobs())
		new_overlays += mutable_appearance(source.icon, source.rogue_mounted_state, ROGUE_TACK_FRONT_LAYER)
	if(source.stat != STABLE || source.body_position == LYING_DOWN)
		return
	if(caparison)
		new_overlays += caparison.rogue_tack_overlays(source, caparison_over_barding ? ROGUE_TACK_HIGH_LAYER : ROGUE_TACK_LOW_LAYER)
	if(barding)
		new_overlays += barding.rogue_tack_overlays(source, caparison_over_barding ? ROGUE_TACK_LOW_LAYER : ROGUE_TACK_HIGH_LAYER)

/datum/component/rogue_mount/proc/on_posture(mob/living/basic/rockhill/source)
	SIGNAL_HANDLER
	source.update_appearance(UPDATE_OVERLAYS)

/datum/component/rogue_mount/proc/on_buckle(mob/living/basic/rockhill/source, mob/living/rider, force)
	SIGNAL_HANDLER
	RegisterSignal(rider, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(on_hurt))
	source.update_appearance(UPDATE_OVERLAYS)

/datum/component/rogue_mount/proc/on_unbuckle(mob/living/basic/rockhill/source, mob/living/rider, force)
	SIGNAL_HANDLER
	UnregisterSignal(rider, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	if(!source.has_buckled_mobs())
		gallop_count = 0
	source.update_appearance(UPDATE_OVERLAYS)

/// Ratwood check_sprint_dismount(): a blow to the mount or a rider while galloping throws the galloping riders off.
/datum/component/rogue_mount/proc/on_hurt(mob/living/source, damage_dealt, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER
	if(damage_dealt <= 0)
		return
	var/mob/living/basic/rockhill/mount = parent
	for(var/mob/living/rider as anything in mount.buckled_mobs?.Copy())
		if(rider.move_intent == MOVE_INTENT_RUN)
			throw_off(rider)

/// Ratwood violent_dismount(): the rider falls off and lies stunned.
/datum/component/rogue_mount/proc/throw_off(mob/living/rider)
	var/mob/living/basic/rockhill/mount = parent
	if(!(rider in mount.buckled_mobs))
		return
	mount.unbuckle_mob(rider, force = TRUE)
	rider.Paralyze(ROGUE_MOUNT_FALL_TIME)
	playsound(rider, 'modular_redtard/husbandry/sound/zfall.ogg', 100, FALSE)
	rider.visible_message(span_danger("[rider] falls off [mount]!"), span_userdanger("I fall off [mount]!"))

/// Ratwood user_buckle_mob(): who may get on - a human climbing up themself onto a saddled tamed mount that stands.
/datum/component/rogue_mount/proc/can_carry(mob/living/rider, mob/user)
	var/mob/living/basic/rockhill/mount = parent
	if(rider != user)
		to_chat(user, span_warning("[rider] has to climb onto [mount] [rider.p_themselves()]."))
		return FALSE
	if(!ishuman(rider) || !saddle || mount.stat != STABLE || LAZYFIND(busy_riders, rider))
		return FALSE
	if(!HAS_TRAIT(mount, TRAIT_TAMED))
		to_chat(rider, span_warning("[mount] won't let me ride [mount.p_them()]."))
		return FALSE
	return TRUE

/// Ratwood time2mount: at once for an expert, a moment with some riding skill, a while without it.
/datum/component/rogue_mount/proc/mount_time(mob/living/rider, dismount = FALSE)
	if(!rider.mind)
		return ROGUE_MOUNT_TIME
	var/rank = rider.rogue_learned_rank(/datum/attribute/skill/misc/riding)
	if(!rank)
		return dismount ? ROGUE_DISMOUNT_TIME_UNSKILLED : ROGUE_MOUNT_TIME_UNSKILLED
	return rank > ROGUE_MOUNT_QUICK_RANK ? 0 : ROGUE_MOUNT_TIME

/// Ratwood relaymove(): the mount's pace under this rider, deciseconds a tile. Its own pace (slower hurt or in a bard), less a
/// gallop, less the rider's skill, never faster than its own pace plus the hurt delay when hurt; combat mode and backing up with a
/// fixed eye slow it again.
/datum/component/rogue_mount/proc/ridden_delay(mob/living/rider, direction)
	var/mob/living/basic/rockhill/mount = parent
	var/hurt = !HAS_TRAIT(mount, TRAIT_IGNOREDAMAGESLOWDOWN) && mount.health <= mount.maxHealth * ROGUE_MOUNT_HURT_SHARE
	var/pace = mount.rogue_mount_delay + (hurt ? ROGUE_MOUNT_HURT_DELAY : 0)
	if(barding)
		pace *= barding.rogue_slowdown
	var/gallop = rider.move_intent == MOVE_INTENT_RUN
	var/delay = pace - (gallop ? ROGUE_MOUNT_GALLOP_BONUS : 0)
	if(rider.mind)
		var/rank = rider.rogue_learned_rank(/datum/attribute/skill/misc/riding)
		delay -= (rank ? (ROGUE_MOUNT_SKILL_BONUS + rank / ROGUE_MOUNT_RANK_DIVISOR) : ROGUE_MOUNT_UNSKILLED_BONUS)
	if(HAS_TRAIT(rider, TRAIT_STEPPE_RIDER))
		delay -= ROGUE_MOUNT_STEPPE_BONUS
	if(hurt)
		delay = max(delay, mount.rogue_mount_delay + ROGUE_MOUNT_HURT_DELAY)
	var/factor = 1
	if(rider.combat_mode)
		if(rider.rogue_fixed_eye)
			factor = gallop ? ROGUE_MOUNT_FIXED_GALLOP : ROGUE_MOUNT_FIXED_WALK
		else
			factor = gallop ? ROGUE_MOUNT_COMBAT_GALLOP : ROGUE_MOUNT_COMBAT_WALK
	else if(rider.rogue_fixed_eye && (direction & turn(rider.dir, 180)))
		factor = gallop ? ROGUE_MOUNT_FIXED_GALLOP : ROGUE_MOUNT_FIXED_WALK
	if(factor != 1)
		delay *= factor
		// With a fixed eye the skill does not buy the slowdown back (Ratwood: no faster than the mount's own pace times it).
		if(rider.rogue_fixed_eye)
			delay = max(delay, (gallop ? pace - ROGUE_MOUNT_GALLOP_BONUS : pace) * factor)
	return max(delay, ROGUE_MOUNT_MIN_DELAY)

/// Ratwood relaymove() after a step under a rider: a hoof every other tile, riding experience at a gallop, and a door that is not a
/// swing door or a window throws the riders off, unless the one steering is an Equestrian.
/datum/component/rogue_mount/proc/ridden_step(mob/living/rider)
	var/static/list/walk_sounds = list('modular_redtard/husbandry/sound/hoof_walk1.ogg', 'modular_redtard/husbandry/sound/hoof_walk2.ogg', 'modular_redtard/husbandry/sound/hoof_walk3.ogg')
	var/static/list/run_sounds = list('modular_redtard/husbandry/sound/hoof_run1.ogg', 'modular_redtard/husbandry/sound/hoof_run2.ogg', 'modular_redtard/husbandry/sound/hoof_run3.ogg')
	var/mob/living/basic/rockhill/mount = parent
	if(!(rider in mount.buckled_mobs))
		return
	var/gallop = rider.move_intent == MOVE_INTENT_RUN
	var/turf/open/ground = mount.loc
	if(!hoof_step && istype(ground) && ground.footstep)
		hoof_step = TRUE
		playsound(ground, pick(gallop ? run_sounds : walk_sounds), 100, TRUE)
	else
		hoof_step = FALSE
	if(gallop && rider.mind)
		gallop_count++
		if(gallop_count >= ROGUE_RIDING_XP_MOVES)
			gallop_count = 0
			var/experience = rider.rogue_stat(ROGUE_STAT_INTELLIGENCE) * ROGUE_RIDING_XP_PER_INTELLIGENCE
			var/rank = rider.rogue_learned_rank(/datum/attribute/skill/misc/riding)
			if(rank >= ROGUE_RANK_APPRENTICE)
				experience *= ROGUE_RIDING_XP_TRAINED
			else if(!rank)
				experience *= ROGUE_RIDING_XP_UNTRAINED
			INVOKE_ASYNC(rider, TYPE_PROC_REF(/mob/living, rogue_craft_experience), /datum/attribute/skill/misc/riding, experience)
	else
		gallop_count = 0
	var/obj/structure/mineral_door/door = locate() in mount.loc
	if(!door || istype(door, /obj/structure/mineral_door/rockhill/swing_door) || istype(door, /obj/structure/mineral_door/rockhill/wood/window) || HAS_TRAIT(rider, TRAIT_EQUESTRIAN))
		return
	for(var/mob/living/fallen as anything in mount.buckled_mobs?.Copy())
		throw_off(fallen)

/datum/component/rogue_mount/proc/on_pre_eat(mob/living/basic/rockhill/source, atom/food, mob/living/feeder, list/effect_mult)
	SIGNAL_HANDLER
	if(feeder && istype(food, /obj/item/reagent_containers/food/snacks/grown/apple) && source.has_status_effect(/datum/status_effect/rogue_mount_apple))
		return COMSIG_MOB_CANCEL_EAT
	return NONE

/// Ratwood simple_animal attackby(): an apple from the hand calms a mount and heals it for a while.
/datum/component/rogue_mount/proc/on_ate(mob/living/basic/rockhill/source, atom/food, mob/living/feeder)
	SIGNAL_HANDLER
	if(!feeder || !istype(food, /obj/item/reagent_containers/food/snacks/grown/apple))
		return
	source.apply_status_effect(/datum/status_effect/rogue_mount_apple)
	if(source.rogue_is_angry())
		source.rogue_calm_down()

/// Ratwood mount_apple_healing (status_effects/rogue/roguebuff.dm) and is_apple_pacified_mount(): while it chews a hand-fed apple a
/// mount heals a little every second and holds no grudge against whoever hits it.
/datum/status_effect/rogue_mount_apple
	id = "rogue_mount_apple"
	alert_type = null
	tick_interval = 1 SECONDS

/datum/status_effect/rogue_mount_apple/on_creation(mob/living/new_owner)
	duration = ROGUE_MOUNT_APPLE_TIME
	return ..()

/datum/status_effect/rogue_mount_apple/tick(seconds_between_ticks)
	if(owner.get_brute_loss() || owner.get_fire_loss())
		var/heal = ROGUE_MOUNT_APPLE_HEAL * seconds_between_ticks
		owner.heal_overall_damage(brute = heal, burn = heal)
		new /obj/effect/temp_visual/heal(get_turf(owner), "#FF6666")
	owner.ai_controller?.clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST)

/// TG's creature riding with Ratwood's seats and pace (datums/components/riding.dm, simple_animal.dm relaymove()): only the first
/// rider steers, nobody pulls a rider off by hand unless the rider is down, and a rider who loses their senses slides off.
/datum/component/riding/creature/rockhill
	other_unbuckle = CANNOT_FORCE_UNBUCKLE

/datum/component/riding/creature/rockhill/get_rider_offsets_and_layers(pass_index, mob/offsetter)
	var/mob/living/basic/rockhill/mount = parent
	return mount.rogue_rider_offsets(pass_index)

/datum/component/riding/creature/rockhill/get_parent_offsets_and_layers()
	var/mob/living/basic/rockhill/mount = parent
	return mount.rogue_mount_layers()

/datum/component/riding/creature/rockhill/get_move_delay(mob/living/living_parent, mob/living/user, direction)
	var/datum/component/rogue_mount/tack = living_parent.GetComponent(/datum/component/rogue_mount)
	return tack ? tack.ridden_delay(user, direction) : ..()

/datum/component/riding/creature/rockhill/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	if(length(movable_parent.buckled_mobs) && user != movable_parent.buckled_mobs[1])
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/datum/component/rogue_mount/tack = movable_parent.GetComponent(/datum/component/rogue_mount)
	if(tack)
		// TG glides the mount at vehicle_move_delay: keep it at the pace the step is taken at.
		vehicle_move_delay = tack.ridden_delay(user, direction)
	var/atom/old_loc = movable_parent.loc
	. = ..()
	if(tack && movable_parent.loc != old_loc)
		tack.ridden_step(user)

/datum/component/riding/creature/rockhill/ride_check(mob/living/rider, consequences = TRUE)
	. = ..()
	if(!. || (rider.stat == STABLE && !IS_UNCONSCIOUS(rider) && !rider.incapacitated))
		return
	. = FALSE
	if(!consequences)
		return
	var/mob/living/mount = parent
	rider.visible_message(span_warning("[rider] slides off [mount]!"), span_warning("I slide off [mount]!"))
	mount.unbuckle_mob(rider, force = TRUE)

/datum/component/riding/creature/rockhill/block_unbuckle(atom/movable/source, mob/living/unbuckler)
	for(var/mob/living/rider as anything in source.buckled_mobs)
		if(rider.stat != STABLE || IS_UNCONSCIOUS(rider) || rider.body_position == LYING_DOWN)
			return NONE
	return ..()

/// Ratwood user_buckle_mob(): getting on a mount takes a while without the riding skill.
/mob/living/basic/rockhill/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	var/datum/component/rogue_mount/tack = GetComponent(/datum/component/rogue_mount)
	if(!tack)
		return ..()
	if(!tack.can_carry(M, user))
		return FALSE
	var/wait = tack.mount_time(M)
	if(wait)
		LAZYADD(tack.busy_riders, M)
		var/steady = do_after(M, wait, target = src)
		if(QDELETED(tack))
			return FALSE
		LAZYREMOVE(tack.busy_riders, M)
		if(!steady || !tack.can_carry(M, user))
			return FALSE
	. = ..()
	if(.)
		playsound(src, 'modular_redtard/husbandry/sound/saddlemount.ogg', 100, TRUE)

/// Ratwood user_unbuckle_mob(): getting off takes a while without the riding skill, and a dismount cut short is a fall. Others
/// pull off only a rider who is down.
/mob/living/basic/rockhill/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	var/datum/component/rogue_mount/tack = GetComponent(/datum/component/rogue_mount)
	if(!tack || !(buckled_mob in buckled_mobs))
		return ..()
	if(user != buckled_mob)
		if(buckled_mob.stat == STABLE && !IS_UNCONSCIOUS(buckled_mob) && buckled_mob.body_position != LYING_DOWN)
			to_chat(user, span_warning("I can't pull [buckled_mob] off [src]!"))
			return null
		return ..()
	if(LAZYFIND(tack.busy_riders, buckled_mob))
		return null
	var/wait = tack.mount_time(buckled_mob, dismount = TRUE)
	if(wait)
		LAZYADD(tack.busy_riders, buckled_mob)
		var/steady = do_after(buckled_mob, wait, target = src)
		if(QDELETED(tack))
			return null
		LAZYREMOVE(tack.busy_riders, buckled_mob)
		if(!(buckled_mob in buckled_mobs))
			return null
		if(!steady)
			tack.throw_off(buckled_mob)
			return buckled_mob
	playsound(src, 'modular_redtard/husbandry/sound/saddledismount.ogg', 100, TRUE)
	return ..()

/mob/living/basic/rockhill/buckle_feedback(mob/living/being_buckled, mob/buckler)
	if(!GetComponent(/datum/component/rogue_mount))
		return ..()
	being_buckled.visible_message(span_notice("[being_buckled] mounts [src]."), span_notice("I mount [src]."))

/mob/living/basic/rockhill/unbuckle_feedback(mob/living/unbuckled_mob, mob/unbuckler)
	if(!GetComponent(/datum/component/rogue_mount))
		return ..()
	if(unbuckled_mob == unbuckler)
		unbuckled_mob.visible_message(span_notice("[unbuckled_mob] dismounts [src]."), span_notice("I dismount [src]."))
	else
		unbuckled_mob.visible_message(span_warning("[unbuckler] pulls [unbuckled_mob] off [src]."), span_warning("[unbuckler] pulls me off [src]."))

/// Ratwood simple_animal attack_hand(): in combat mode a click with an empty hand on a saddled tamed mount gets on it, whatever the
/// intent, instead of striking it.
/mob/living/carbon/human/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	if(combat_mode && !buckled && istype(attack_target, /mob/living/basic/rockhill) && !LAZYACCESS(modifiers, RIGHT_CLICK))
		var/mob/living/basic/rockhill/mount = attack_target
		var/datum/component/rogue_mount/tack = mount.GetComponent(/datum/component/rogue_mount)
		if(tack?.saddle && mount.can_buckle && mount.stat == STABLE && HAS_TRAIT(mount, TRAIT_TAMED))
			INVOKE_ASYNC(mount, TYPE_PROC_REF(/atom/movable, user_buckle_mob), src, src, FALSE)
			return TRUE
	return ..()

#undef ROGUE_SADDLEBAG_RIDER_TIME
#undef ROGUE_SADDLEBAG_TIME
#undef ROGUE_ADJUST_CAPARISON
#undef ROGUE_SADDLEBAGS
