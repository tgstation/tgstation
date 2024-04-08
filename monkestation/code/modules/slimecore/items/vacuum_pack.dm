#define NORMAL_VACUUM_PACK_CAPACITY 3
#define UPGRADED_VACUUM_PACK_CAPACITY 6
#define ILLEGAL_VACUUM_PACK_CAPACITY 12

#define NORMAL_VACUUM_PACK_RANGE 3
#define UPGRADED_VACUUM_PACK_RANGE 4
#define ILLEGAL_VACUUM_PACK_RANGE 5

#define NORMAL_VACUUM_PACK_SPEED 12
#define UPGRADED_VACUUM_PACK_SPEED 8
#define ILLEGAL_VACUUM_PACK_SPEED 6

#define VACUUM_PACK_UPGRADE_STASIS "stasis"
#define VACUUM_PACK_UPGRADE_HEALING "healing"
#define VACUUM_PACK_UPGRADE_CAPACITY "capacity"
#define VACUUM_PACK_UPGRADE_RANGE "range"
#define VACUUM_PACK_UPGRADE_SPEED "speed"
#define VACUUM_PACK_UPGRADE_PACIFY "pacification"
#define VACUUM_PACK_UPGRADE_BIOMASS "biomass printer"

/datum/action/item_action/toggle_nozzle
	name = "Toggle Vacuum Nozzle"

/obj/item/vacuum_pack
	name = "backpack xenofauna storage"
	desc = "A Xynergy Solutions brand vacuum xenofauna storage with an extendable nozzle. Do not use to practice kissing."
	icon = 'monkestation/code/modules/slimecore/icons/equipment.dmi'
	icon_state = "vacuum_pack"
	inhand_icon_state = "vacuum_pack"
	worn_icon_state = "waterbackpackjani"
	lefthand_file = 'monkestation/code/modules/slimecore/icons/backpack_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/slimecore/icons/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	actions_types = list(/datum/action/item_action/toggle_nozzle)
	max_integrity = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/obj/item/vacuum_nozzle/nozzle
	var/nozzle_type = /obj/item/vacuum_nozzle
	var/list/stored = list()
	var/capacity = NORMAL_VACUUM_PACK_CAPACITY
	var/range = NORMAL_VACUUM_PACK_RANGE
	var/speed = NORMAL_VACUUM_PACK_SPEED
	var/illegal = FALSE
	var/list/upgrades = list()
	var/obj/machinery/biomass_recycler/linked
	var/give_choice = TRUE //If set to true the pack will give the owner a radial selection to choose which object they want to shoot
	var/check_backpack = TRUE //If it can only be used while worn on the back
	var/static/list/storable_objects = typecacheof(list(/mob/living/basic/slime,
														/mob/living/basic/cockroach/rockroach,
														))
	var/modified = FALSE //If the gun is modified to fight with revenants
	var/mob/living/basic/revenant/ghost_busting //Stores the revenant we're currently sucking in
	var/mob/living/ghost_buster //Stores the user
	var/busting_beam //Stores visual effects
	COOLDOWN_DECLARE(busting_throw_cooldown)

/obj/item/vacuum_pack/Initialize(mapload)
	. = ..()
	nozzle = new nozzle_type(src)

/obj/item/vacuum_pack/Destroy()
	QDEL_NULL(nozzle)
	if(VACUUM_PACK_UPGRADE_HEALING in upgrades)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/vacuum_pack/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	modified = !modified
	to_chat(user, span_notice("You turn the safety switch on [src] [modified ? "off" : "on"]."))

/obj/item/vacuum_pack/process(delta_time)
	if(!(VACUUM_PACK_UPGRADE_HEALING in upgrades))
		STOP_PROCESSING(SSobj, src)

	for(var/mob/living/basic/animal in stored)
		animal.adjustBruteLoss(-5 * delta_time)

/obj/item/vacuum_pack/examine(mob/user)
	. = ..()
	if(LAZYLEN(stored))
		. += span_notice("It has [LAZYLEN(stored)] creatures stored in it.")
	if(LAZYLEN(upgrades))
		for(var/upgrade in upgrades)
			. += span_notice("It has [upgrade] upgrade installed.")

/obj/item/vacuum_pack/attackby(obj/item/item, mob/living/user, params)
	if(item == nozzle)
		remove_nozzle()
		return

	if(user.istate & ISTATE_HARM)
		return ..()

	if(istype(item, /obj/item/disk/vacuum_upgrade))
		var/obj/item/disk/vacuum_upgrade/upgrade = item

		if(illegal)
			to_chat(user, span_warning("[src] has no slot to insert [upgrade] into!"))
			return

		if(upgrade.upgrade_type in upgrades)
			to_chat(user, span_warning("[src] already has a [upgrade.upgrade_type] upgrade!"))
			return

		upgrades += upgrade.upgrade_type
		upgrade.on_upgrade(src)
		to_chat(user, span_notice("You install a [upgrade.upgrade_type] upgrade into [src]."))
		playsound(user, 'sound/machines/click.ogg', 30, TRUE)
		qdel(upgrade)
		return

	return ..()

/obj/item/vacuum_pack/ui_action_click(mob/user)
	toggle_nozzle(user)

/obj/item/vacuum_pack/proc/toggle_nozzle(mob/living/user)
	if(!istype(user))
		return

	if(user.get_item_by_slot(user.getBackSlot()) != src && check_backpack)
		to_chat(user, span_warning("[src] must be worn properly to use!"))
		return

	if(user.incapacitated())
		return

	if(QDELETED(nozzle))
		nozzle = new nozzle_type(src)

	if(nozzle in src)
		if(!user.put_in_hands(nozzle))
			to_chat(user, span_warning("You need a free hand to hold [nozzle]!"))
			return
		else
			playsound(user, 'sound/mecha/mechmove03.ogg', 75, TRUE)
	else
		remove_nozzle()

/obj/item/vacuum_pack/item_action_slot_check(slot, mob/user)
	if(slot == user.getBackSlot())
		return TRUE

/obj/item/vacuum_pack/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_BACK)
		remove_nozzle()

/obj/item/vacuum_pack/proc/remove_nozzle()
	if(!QDELETED(nozzle))
		if(ismob(nozzle.loc))
			var/mob/wearer = nozzle.loc
			wearer.temporarilyRemoveItemFromInventory(nozzle, TRUE)
			playsound(loc, 'sound/mecha/mechmove03.ogg', 75, TRUE)
		nozzle.forceMove(src)

/obj/item/vacuum_pack/attack_hand(mob/user, list/modifiers)
	if (user.get_item_by_slot(user.getBackSlot()) == src)
		toggle_nozzle(user)
	else
		return ..()

/obj/item/vacuum_pack/MouseDrop(obj/over_object)
	var/mob/wearer = loc
	if(istype(wearer) && istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/hand = over_object
		wearer.putItemFromInventoryInHandIfPossible(src, hand.held_index)
	return ..()

/obj/item/vacuum_pack/dropped(mob/user)
	..()
	remove_nozzle()

/obj/item/vacuum_nozzle
	name = "vacuum pack nozzle"
	desc = "A large nozzle attached to a vacuum pack."
	icon = 'monkestation/code/modules/slimecore/icons/equipment.dmi'
	icon_state = "vacuum_nozzle"
	inhand_icon_state = "vacuum_nozzle"
	lefthand_file = 'monkestation/code/modules/slimecore/icons/mister_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/slimecore/icons/mister_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = NOBLUDGEON | ABSTRACT
	slot_flags = NONE

	var/obj/item/vacuum_pack/pack

/obj/item/vacuum_nozzle/Initialize(mapload)
	. = ..()
	pack = loc
	if(!istype(pack))
		return INITIALIZE_HINT_QDEL

/obj/item/vacuum_nozzle/doMove(atom/destination)
	if(destination && (destination != pack.loc || !ismob(destination)))
		if (loc != pack)
			to_chat(pack.loc, span_notice("[src] snaps back onto [pack]."))
		destination = pack
	. = ..()

/obj/item/vacuum_nozzle/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(pack.modified && pack.ghost_busting && target != pack.ghost_busting && COOLDOWN_FINISHED(pack, busting_throw_cooldown))
		pack.ghost_busting.throw_at(get_turf(target), get_dist(pack.ghost_busting, target), 3, user)
		COOLDOWN_START(pack, busting_throw_cooldown, 3 SECONDS)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!(VACUUM_PACK_UPGRADE_BIOMASS in pack.upgrades))
		to_chat(user, span_warning("[pack] does not posess a required upgrade!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!pack.linked)
		to_chat(user, span_warning("[pack] is not linked to a biomass recycler!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/list/items = list()
	var/list/item_names = list()

	for(var/printable_type in GLOB.biomass_unlocks)
		pack.linked.vacuum_printable_types |= printable_type
		pack.linked.vacuum_printable_types[printable_type] = GLOB.biomass_unlocks[printable_type]

	for(var/printable_type in pack.linked.vacuum_printable_types)
		var/atom/movable/printable = printable_type
		var/image/printable_image = image(icon = initial(printable.icon), icon_state = initial(printable.icon_state))
		items += list(initial(printable.name) = printable_image)
		item_names[initial(printable.name)] = printable_type


	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)

	if(!pick)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/spawn_type = item_names[pick]
	if(pack.linked.stored_matter < pack.linked.vacuum_printable_types[spawn_type])
		to_chat(user, span_warning("[pack.linked] does not have enough stored biomass for that! It currently has [pack.linked.stored_matter] out of [pack.linked.vacuum_printable_types[spawn_type]] unit\s required."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/atom/movable/spawned = new spawn_type(user.loc)
	spawned.AddComponent(/datum/component/vac_tagged, user)

	pack.linked.stored_matter -= pack.linked.vacuum_printable_types[spawn_type]
	playsound(user, 'sound/misc/moist_impact.ogg', 50, TRUE)
	spawned.transform = matrix().Scale(0.5)
	spawned.alpha = 0
	animate(spawned, alpha = 255, time = 8, easing = QUAD_EASING|EASE_OUT, transform = matrix(), flags = ANIMATION_PARALLEL)

	if(isturf(user.loc))
		ADD_TRAIT(spawned, VACPACK_THROW, "vacpack")
		spawned.pass_flags |= PASSMOB
		spawned.throw_at(target, min(get_dist(user, target), (pack.illegal ? 5 : 11)), 1, user, gentle = TRUE) //Gentle so eggs have 50% instead of 12.5% to spawn a chick

	user.visible_message(span_warning("[user] shoots [spawned] out their [src]!"), span_notice("You fabricate and shoot [spawned] out of your [src]."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/vacuum_nozzle/afterattack(atom/movable/target, mob/user, proximity, params)
	. = ..()
	if(pack.ghost_busting)
		return

	if(pack.modified && !pack.ghost_busting && isrevenant(target) && get_dist(user, target) < 4)
		start_busting(target, user)
		return

	if(istype(target, /obj/machinery/biomass_recycler) && target.Adjacent(user))
		if(!(VACUUM_PACK_UPGRADE_BIOMASS in pack.upgrades))
			to_chat(user, span_warning("[pack] does not posess a required upgrade!"))
			return
		pack.linked = target
		to_chat(user, span_notice("You link [pack] to [target]."))
		return

	if(pack.linked)
		var/can_recycle
		for(var/recycable_type in pack.linked.recyclable_types)
			if(istype(target, recycable_type))
				can_recycle = recycable_type
				break

		var/target_stat = FALSE
		if(isliving(target))
			var/mob/living/living_target = target
			target_stat = living_target.stat

		if(can_recycle && (!is_type_in_typecache(target, pack.storable_objects) || target_stat != CONSCIOUS))
			if(!(VACUUM_PACK_UPGRADE_BIOMASS in pack.upgrades))
				to_chat(user, span_warning("[pack] does not posess a required upgrade!"))
				return

			if(!pack.linked)
				to_chat(user, span_warning("[pack] is not linked to a biomass recycler!"))
				return

			if(target_stat == CONSCIOUS)
				to_chat(user, span_warning("[target] is struggling far too much for you to suck it in!"))
				return

			if(isliving(target))
				var/mob/living/living = target
				if(living.buckled)
					living.buckled.unbuckle_mob(target, TRUE)
			target.unbuckle_all_mobs(TRUE)

			if(!do_after(user, pack.speed, target, timed_action_flags = IGNORE_TARGET_LOC_CHANGE))
				return

			playsound(src, 'sound/effects/refill.ogg', 50, TRUE)
			var/matrix/animation_matrix = matrix()
			animation_matrix.Scale(0.5)
			animation_matrix.Translate((user.x - target.x) * 32, (user.y - target.y) * 32)
			animate(target, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, transform = animation_matrix, flags = ANIMATION_PARALLEL)
			sleep(8)
			user.visible_message(span_warning("[user] sucks [target] into their [pack]!"), span_notice("You successfully suck [target] into your [src] and recycle it."))
			qdel(target)
			playsound(user, 'sound/machines/juicer.ogg', 50, TRUE)
			pack.linked.use_power(500)
			pack.linked.stored_matter += pack.linked.cube_production * pack.linked.recyclable_types[can_recycle]
			return

	if(is_type_in_typecache(target, pack.storable_objects))
		if(get_dist(user, target) > pack.range)
			to_chat(user, span_warning("[target] is too far away!"))
			return

		if(!(target in view(user, pack.range)))
			to_chat(user, span_warning("You can't reach [target]!"))
			return

		if(target.anchored || target.move_resist > MOVE_FORCE_STRONG)
			to_chat(user, span_warning("You can't manage to suck [target] in!"))
			return

		if(isslime(target))
			var/mob/living/basic/slime/slime = target
			if(HAS_TRAIT(slime, TRAIT_SLIME_RABID) && !pack.illegal && !(VACUUM_PACK_UPGRADE_PACIFY in pack.upgrades))
				to_chat(user, span_warning("[slime] is wiggling far too much for you to suck it in!"))
				return

		if(LAZYLEN(pack.stored) >= pack.capacity)
			to_chat(user, span_warning("[pack] is already filled to the brim!"))
			return

		if(!do_after(user, pack.speed, target, timed_action_flags = IGNORE_TARGET_LOC_CHANGE|IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, .proc/suck_checks, target, user)))
			return

		if(SEND_SIGNAL(target, COMSIG_LIVING_VACUUM_PRESUCK, src, user) & COMPONENT_LIVING_VACUUM_CANCEL_SUCK)
			return

		suck_victim(target, user)
		return

	if(LAZYLEN(pack.stored) == 0)
		to_chat(user, span_warning("[pack] is empty!"))
		return

	var/mob/living/spewed

	if(pack.give_choice)
		var/list/items = list()
		var/list/items_stored = list()
		for(var/atom/movable/stored_obj in pack.stored)
			var/image/stored_image = image(icon = stored_obj.icon, icon_state = stored_obj.icon_state)
			stored_image.color = stored_obj.color
			items += list(stored_obj.name = stored_image)
			items_stored[stored_obj.name] = stored_obj

		var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)

		if(!pick)
			return
		spewed = items_stored[pick]
	else
		spewed = pick(pack.stored)

	playsound(user, 'sound/misc/moist_impact.ogg', 50, TRUE)
	spewed.transform = matrix().Scale(0.5)
	spewed.alpha = 0
	animate(spewed, alpha = 255, time = 8, easing = QUAD_EASING|EASE_OUT, transform = matrix(), flags = ANIMATION_PARALLEL)
	spewed.forceMove(user.loc)

	if(isturf(user.loc))
		ADD_TRAIT(spewed, VACPACK_THROW, "vacpack")
		spewed.pass_flags |= PASSMOB
		spewed.throw_at(target, min(get_dist(user, target), (pack.illegal ? 5 : 11)), 1, user)
		if(prob(99) && spewed.stat != DEAD)
			playsound(spewed, 'sound/misc/woohoo.ogg', 50, TRUE)

	if(istype(spewed, /mob/living/basic/slime))
		var/mob/living/basic/slime/slime = spewed
		slime.slime_flags &= ~STORED_SLIME
		if(slime.ai_controller)
			slime.ai_controller.set_ai_status(AI_STATUS_ON)
		if(VACUUM_PACK_UPGRADE_STASIS in pack.upgrades)
			REMOVE_TRAIT(slime, TRAIT_SLIME_STASIS, "vacuum_pack_stasis")

		if(pack.illegal)

			ADD_TRAIT(slime, TRAIT_SLIME_RABID, "syndicate_slimepack")

			user.changeNext_move(CLICK_CD_RAPID) //Like a machine gun

		else if(VACUUM_PACK_UPGRADE_PACIFY in pack.upgrades)
			REMOVE_TRAIT(slime, TRAIT_SLIME_RABID, null)


	pack.stored -= spewed
	user.visible_message(span_warning("[user] shoots [spewed] out their [src]!"), span_notice("You shoot [spewed] out of your [src]."))

/obj/item/vacuum_nozzle/proc/suck_checks(atom/movable/target, mob/user)
	if(get_dist(user, target) > pack.range)
		return FALSE

	if(!(target in view(user, pack.range)))
		return FALSE

	if(target.anchored || target.move_resist > MOVE_FORCE_STRONG)
		return FALSE

	if(isslime(target))
		var/mob/living/basic/slime/slime = target
		if(HAS_TRAIT(slime, TRAIT_SLIME_RABID) && !pack.illegal && !(VACUUM_PACK_UPGRADE_PACIFY in pack.upgrades))
			return FALSE

	if(LAZYLEN(pack.stored) >= pack.capacity)
		return FALSE

	return TRUE

/obj/item/vacuum_nozzle/proc/suck_victim(atom/movable/target, mob/user, silent = FALSE)
	if(!suck_checks(target, user))
		return

	if(!silent)
		playsound(user, 'sound/effects/refill.ogg', 50, TRUE)
	var/matrix/animation_matrix = target.transform
	animation_matrix.Scale(0.5)
	animation_matrix.Translate((user.x - target.x) * 32, (user.y - target.y) * 32)
	animate(target, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, transform = animation_matrix, flags = ANIMATION_PARALLEL)
	sleep(8)
	target.unbuckle_all_mobs(TRUE)
	target.forceMove(pack)
	pack.stored += target
	if((VACUUM_PACK_UPGRADE_STASIS in pack.upgrades) && isslime(target))
		var/mob/living/basic/slime/slime = target
		ADD_TRAIT(slime, TRAIT_SLIME_STASIS, "vacuum_pack_stasis")
	SEND_SIGNAL(target, COMSIG_ATOM_SUCKED)
	if(!silent)
		user.visible_message(span_warning("[user] sucks [target] into their [pack]!"), span_notice("You successfully suck [target] into your [src]."))
	var/mob/living/basic/slime/slime = target
	slime.slime_flags |= STORED_SLIME
	if(slime.ai_controller)
		slime.ai_controller.set_ai_status(AI_STATUS_OFF)
		slime.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, null)

/obj/item/vacuum_nozzle/proc/start_busting(mob/living/basic/revenant/revenant, mob/living/user)
	revenant.visible_message(span_warning("[user] starts sucking [revenant] into their [src]!"), span_userdanger("You are being sucked into [user]'s [src]!"))
	pack.ghost_busting = revenant
	pack.ghost_buster = user
	pack.busting_beam = user.Beam(revenant, icon_state="drain_life")
	bust_the_ghost()

/obj/item/vacuum_nozzle/proc/bust_the_ghost()
	while(check_busting())
		if(!do_after(pack.ghost_buster, 0.5 SECONDS, target = pack.ghost_busting, extra_checks = CALLBACK(src, .proc/check_busting), timed_action_flags = IGNORE_TARGET_LOC_CHANGE|IGNORE_USER_LOC_CHANGE))
			pack.ghost_busting = null
			pack.ghost_buster = null
			QDEL_NULL(pack.busting_beam)
			return

		//pack.ghost_busting.adjustHealth(5)
		//pack.ghost_busting.reveal(0.5 SECONDS, TRUE)

/obj/item/vacuum_nozzle/proc/check_busting()
	if(!pack.ghost_busting || !pack.ghost_busting.loc || QDELETED(pack.ghost_busting))
		return FALSE

	if(!pack.ghost_buster || !pack.ghost_buster.loc || QDELETED(pack.ghost_buster))
		return FALSE

	if(loc != pack.ghost_buster)
		return FALSE

	if(get_dist(pack.ghost_buster, pack.ghost_busting) > 3)
		return FALSE

	if(pack.ghost_busting.essence <= 0) //Means that the revenant is dead
		return FALSE

	return TRUE

/obj/item/disk/vacuum_upgrade
	name = "vacuum pack upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage."
	icon_state = "rndmajordisk"
	var/upgrade_type

/obj/item/disk/vacuum_upgrade/proc/on_upgrade(obj/item/vacuum_pack/pack)

/obj/item/disk/vacuum_upgrade/stasis
	name = "vacuum pack stasis upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to keep all slimes inside of it in stasis."
	upgrade_type = VACUUM_PACK_UPGRADE_STASIS

/obj/item/disk/vacuum_upgrade/healing
	name = "vacuum pack healing upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that makes the pack passively heal all the slimes inside of it."
	upgrade_type = VACUUM_PACK_UPGRADE_HEALING

/obj/item/disk/vacuum_upgrade/healing/on_upgrade(obj/item/vacuum_pack/pack)
	START_PROCESSING(SSobj, pack)

/obj/item/disk/vacuum_upgrade/capacity
	name = "vacuum pack capacity upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that expands it's internal slime storage."
	upgrade_type = VACUUM_PACK_UPGRADE_CAPACITY

/obj/item/disk/vacuum_upgrade/capacity/on_upgrade(obj/item/vacuum_pack/pack)
	pack.capacity = UPGRADED_VACUUM_PACK_CAPACITY

/obj/item/disk/vacuum_upgrade/range
	name = "vacuum pack range upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that strengthens it's pump and allows it to reach further."
	upgrade_type = VACUUM_PACK_UPGRADE_RANGE

/obj/item/disk/vacuum_upgrade/range/on_upgrade(obj/item/vacuum_pack/pack)
	pack.range = UPGRADED_VACUUM_PACK_RANGE

/obj/item/disk/vacuum_upgrade/speed
	name = "vacuum pack speed upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that upgrades it's motor and allows it to suck slimes up faster."
	upgrade_type = VACUUM_PACK_UPGRADE_SPEED

/obj/item/disk/vacuum_upgrade/speed/on_upgrade(obj/item/vacuum_pack/pack)
	pack.speed = UPGRADED_VACUUM_PACK_SPEED

/obj/item/disk/vacuum_upgrade/pacification
	name = "vacuum pack pacification upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to pacify all stored slimes."
	upgrade_type = VACUUM_PACK_UPGRADE_PACIFY

/obj/item/disk/vacuum_upgrade/biomass
	name = "vacuum pack biomass printer upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to automatically recycle dead biomass and make living creatures on right click."
	upgrade_type = VACUUM_PACK_UPGRADE_BIOMASS

/obj/item/vacuum_pack/syndicate
	name = "modified backpack xenofauna storage"
	desc = "An illegally modified vacuum backpack xenofauna storage that has much more power, capacity and will make every slime it shoots out rabid."
	icon_state = "vacuum_pack_syndicate"
	inhand_icon_state = "vacuum_pack_syndicate"
	range = ILLEGAL_VACUUM_PACK_RANGE
	capacity = ILLEGAL_VACUUM_PACK_CAPACITY
	speed = ILLEGAL_VACUUM_PACK_SPEED
	illegal = TRUE
	nozzle_type = /obj/item/vacuum_nozzle/syndicate
	upgrades = list(VACUUM_PACK_UPGRADE_HEALING, VACUUM_PACK_UPGRADE_STASIS, VACUUM_PACK_UPGRADE_BIOMASS)
	give_choice = FALSE

/obj/item/vacuum_nozzle/syndicate
	name = "modified vacuum pack nozzle"
	desc = "A large black and red nozzle attached to a vacuum pack."
	icon_state = "vacuum_nozzle_syndicate"
	inhand_icon_state = "vacuum_nozzle_syndicate"


#undef NORMAL_VACUUM_PACK_CAPACITY
#undef UPGRADED_VACUUM_PACK_CAPACITY
#undef ILLEGAL_VACUUM_PACK_CAPACITY

#undef NORMAL_VACUUM_PACK_RANGE
#undef UPGRADED_VACUUM_PACK_RANGE
#undef ILLEGAL_VACUUM_PACK_RANGE

#undef NORMAL_VACUUM_PACK_SPEED
#undef UPGRADED_VACUUM_PACK_SPEED
#undef ILLEGAL_VACUUM_PACK_SPEED

#undef VACUUM_PACK_UPGRADE_STASIS
#undef VACUUM_PACK_UPGRADE_HEALING
#undef VACUUM_PACK_UPGRADE_CAPACITY
#undef VACUUM_PACK_UPGRADE_RANGE
#undef VACUUM_PACK_UPGRADE_SPEED
#undef VACUUM_PACK_UPGRADE_PACIFY
#undef VACUUM_PACK_UPGRADE_BIOMASS
