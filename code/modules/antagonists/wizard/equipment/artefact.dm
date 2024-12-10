
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "bone_blade"
	inhand_icon_state = "bone_blade"
	worn_icon_state = "bone_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	var/charges = 1
	var/spawn_type = /obj/tear_in_reality
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."
	var/spawn_fast = FALSE //if TRUE, ignores checking for mobs on loc before spawning

/obj/item/veilrender/attack_self(mob/user)
	if(charges > 0)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc, spawn_fast)
		charges--
		user.visible_message(span_bolddanger("[src] hums with power as [user] deals a blow to [activate_descriptor] itself!"))
	else
		to_chat(user, span_danger("The unearthly energies that powered the blade are now dormant."))

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/effects/effects.dmi'
	icon_state = "rift"
	density = TRUE
	anchored = TRUE
	var/spawn_path = /mob/living/basic/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20
	var/spawn_fast = FALSE

/obj/effect/rend/Initialize(mapload, spawn_type, spawn_amt, desc, spawn_fast)
	. = ..()
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc
	src.spawn_fast = spawn_fast
	START_PROCESSING(SSobj, src)

/obj/effect/rend/process()
	if(!spawn_fast)
		if(locate(/mob) in loc)
			return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)
		return PROCESS_KILL

/obj/effect/rend/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/nullrod))
		user.visible_message(span_danger("[user] seals \the [src] with \the [I]."))
		qdel(src)
		return
	else
		return ..()

/obj/effect/rend/singularity_act()
	return

/obj/effect/rend/singularity_pull(atom/singularity, current_size)
	return

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/basic/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/basic/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "banana_blade"
	inhand_icon_state = "banana_blade"
	worn_icon_state = "render"

/obj/item/veilrender/honkrender/honkhulkrender
	name = "superior honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus. This one gleams with a special light."
	spawn_type = /mob/living/basic/clown/clownhulk
	spawn_amt = 5
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of mirthful grunting."

#define TEAR_IN_REALITY_CONSUME_RANGE 3
#define TEAR_IN_REALITY_SINGULARITY_SIZE STAGE_FOUR

/// Tear in reality, spawned by the veil render
/obj/tear_in_reality
	name = "tear in the fabric of reality"
	desc = "This isn't right."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	pixel_x = -96
	pixel_y = -96
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	plane = MASSIVE_OBJ_PLANE
	plane = ABOVE_LIGHTING_PLANE
	light_range = 6
	appearance_flags = LONG_GLIDE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/tear_in_reality/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/singularity, \
		consume_range = TEAR_IN_REALITY_CONSUME_RANGE, \
		notify_admins = !mapload, \
		roaming = FALSE, \
		singularity_size = TEAR_IN_REALITY_SINGULARITY_SIZE, \
	)

/obj/tear_in_reality/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/jedi = user
	if(jedi.mob_mood.sanity < 15)
		return //they've already seen it and are about to die, or are just too insane to care
	to_chat(jedi, span_userdanger("OH GOD! NONE OF IT IS REAL! NONE OF IT IS REEEEEEEEEEEEEEEEEEEEEEEEAL!"))
	jedi.mob_mood.sanity = 0
	for(var/lore in typesof(/datum/brain_trauma/severe))
		jedi.gain_trauma(lore)
	addtimer(CALLBACK(src, PROC_REF(deranged), jedi), 10 SECONDS)

/obj/tear_in_reality/proc/deranged(mob/living/carbon/C)
	if(!C || C.stat == DEAD)
		return
	C.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 0, distance = 3)
	C.spew_organ(3, 2)
	C.investigate_log("has died from using telekinesis on a tear in reality.", INVESTIGATE_DEATHS)
	C.death()

#undef TEAR_IN_REALITY_CONSUME_RANGE
#undef TEAR_IN_REALITY_SINGULARITY_SIZE

/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, merely holding it gives you vision and hearing beyond mortal means, and staring into it lets you see the entire universe."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/tools/welder2.ogg'

	var/mob/current_owner

/obj/item/scrying/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/scrying/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scrying/process()
	var/mob/holder = get(loc, /mob)
	if(current_owner && current_owner != holder)

		to_chat(current_owner, span_notice("Your otherworldly vision fades..."))

		current_owner.remove_traits(list(TRAIT_SIXTHSENSE, TRAIT_XRAY_VISION), SCRYING_ORB)
		current_owner.update_sight()

		current_owner = null

	if(!current_owner && holder)
		current_owner = holder

		to_chat(current_owner, span_notice("You can see...everything!"))

		current_owner.add_traits(list(TRAIT_SIXTHSENSE, TRAIT_XRAY_VISION), SCRYING_ORB)
		current_owner.update_sight()

/obj/item/scrying/attack_self(mob/user)
	visible_message(span_danger("[user] stares into [src], their eyes glazing over."))
	user.ghostize(1)

/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "necrostone"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	///Allow for unlimited thralls to be produced.
	var/unlimited = FALSE
	///Which species the resurected humanoid will be.
	var/applied_species = /datum/species/skeleton
	///The outfit the resurected humanoid will wear.
	var/applied_outfit = /datum/outfit/roman
	///Maximum number of thralls that can be created.
	var/max_thralls = 3

/obj/item/necromantic_stone/unlimited
	unlimited = 1

/obj/item/necromantic_stone/attack(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(!istype(target))
		return ..()

	if(!istype(user) || !user.can_perform_action(target))
		return

	if(target.stat != DEAD)
		to_chat(user, span_warning("This artifact can only affect the dead!"))
		return

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) //excludes new players
		if(ghost.mind && ghost.mind.current == target && ghost.client)  //the dead mobs list can contain clientless mobs
			ghost.reenter_corpse()
			break

	if(!target.mind || !target.client)
		to_chat(user, span_warning("There is no soul connected to this body..."))
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= max_thralls && !unlimited)
		to_chat(user, span_warning("This artifact can only affect [convert_integer_to_words(max_thralls)] thralls at a time!"))
		return
	if(applied_species)
		target.set_species(applied_species, icon_update=0)
	target.revive(ADMIN_HEAL_ALL)
	spooky_scaries |= target
	to_chat(target, span_userdanger("You have been revived by <B>[user.real_name]</B>!"))
	to_chat(target, span_userdanger("[user.p_Theyre()] your master now, assist [user.p_them()] even if it costs you your new life!"))
	var/datum/antagonist/wizard/antag_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(antag_datum)
		if(!antag_datum.wiz_team)
			antag_datum.create_wiz_team()
		target.mind.add_antag_datum(/datum/antagonist/wizard_minion, antag_datum.wiz_team)

	equip_revived_servant(target)

/obj/item/necromantic_stone/examine(mob/user)
	. = ..()
	if(!unlimited)
		. += span_notice("[spooky_scaries.len]/[max_thralls] active thralls.")

/obj/item/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			H.dust(TRUE)
			spooky_scaries.Remove(X)
			continue
	list_clear_nulls(spooky_scaries)

/obj/item/necromantic_stone/proc/equip_revived_servant(mob/living/carbon/human/human)
	if(!applied_outfit)
		return
	for(var/obj/item/worn_item in human)
		human.dropItemToGround(worn_item)

	human.equipOutfit(applied_outfit)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
/datum/outfit/roman
	name = "Roman"
	head = /obj/item/clothing/head/helmet/roman
	uniform = /obj/item/clothing/under/costume/roman
	shoes = /obj/item/clothing/shoes/roman
	back = /obj/item/spear
	r_hand = /obj/item/claymore
	l_hand = /obj/item/shield/roman

/datum/outfit/roman/pre_equip(mob/living/carbon/human/H, visuals_only)
	. = ..()
	head = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionnaire)

//Provides a decent heal, need to pump every 6 seconds
/obj/item/organ/heart/cursed/wizard
	pump_delay = 6 SECONDS
	heal_brute = 25
	heal_burn = 25
	heal_oxy = 25

///Warp whistle, spawns a tornado that teleports you
/obj/item/warp_whistle
	name = "warp whistle"
	desc = "Calls a cloud to come pick you up and drop you at a random location on the station."
	icon = 'icons/obj/art/musician.dmi'
	icon_state = "whistle"

	/// Person using the warp whistle
	var/mob/living/whistler

/obj/item/warp_whistle/attack_self(mob/user)
	if(whistler)
		to_chat(user, span_warning("[src] is on cooldown."))
		return

	whistler = user
	var/turf/current_turf = get_turf(user)
	var/turf/spawn_location = locate(user.x + pick(-7, 7), user.y, user.z)
	playsound(current_turf,'sound/effects/magic/warpwhistle.ogg', 200, TRUE)
	new /obj/effect/temp_visual/teleporting_tornado(spawn_location, src)

///Teleporting tornado, spawned by warp whistle, teleports the user if they manage to pick them up.
/obj/effect/temp_visual/teleporting_tornado
	name = "tornado"
	desc = "This thing sucks!"
	icon = 'icons/effects/magic.dmi'
	icon_state = "tornado"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	randomdir = FALSE
	duration = 8 SECONDS
	movement_type = PHASING

	/// Reference to the whistle
	var/obj/item/warp_whistle/whistle
	/// List of all mobs currently held by the tornado.
	var/list/pickedup_mobs = list()

/obj/effect/temp_visual/teleporting_tornado/Initialize(mapload, obj/item/warp_whistle/whistle)
	. = ..()
	src.whistle = whistle
	if(!whistle)
		qdel(src)
		return
	RegisterSignal(src, COMSIG_MOVABLE_CROSS_OVER, PROC_REF(check_teleport))
	GLOB.move_manager.move_towards(src, get_turf(whistle.whistler))

/// Check if anything the tornado crosses is the creator.
/obj/effect/temp_visual/teleporting_tornado/proc/check_teleport(datum/source, atom/movable/crossed)
	SIGNAL_HANDLER
	if(crossed != whistle.whistler || (crossed in pickedup_mobs))
		return

	pickedup_mobs += crossed
	buckle_mob(crossed, TRUE, FALSE)
	ADD_TRAIT(crossed, TRAIT_INCAPACITATED, WARPWHISTLE_TRAIT)
	animate(src, alpha = 20, pixel_y = 400, time = 3 SECONDS)
	animate(crossed, pixel_y = 400, time = 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(send_away)), 2 SECONDS)

/obj/effect/temp_visual/teleporting_tornado/proc/send_away()
	var/turf/ending_turfs = get_safe_random_station_turf()
	for(var/mob/stored_mobs as anything in pickedup_mobs)
		do_teleport(stored_mobs, ending_turfs, channel = TELEPORT_CHANNEL_MAGIC)
		animate(stored_mobs, pixel_y = null, time = 1 SECONDS)
		stored_mobs.log_message("warped with [whistle].", LOG_ATTACK, color = "red")
		REMOVE_TRAIT(stored_mobs, TRAIT_INCAPACITATED, WARPWHISTLE_TRAIT)

/// Destroy the tornado and teleport everyone on it away.
/obj/effect/temp_visual/teleporting_tornado/Destroy()
	if(whistle)
		whistle.whistler = null
		whistle = null
	return ..()

/////////////////////////////////////////Scepter of Vendormancy///////////////////
#define RUNIC_SCEPTER_MAX_CHARGES 3
#define RUNIC_SCEPTER_MAX_RANGE 7

/obj/item/runic_vendor_scepter
	name = "scepter of runic vendormancy"
	desc = "This scepter allows you to conjure, force push and detonate Runic Vendors. It can hold up to 3 charges that can be recovered with a simple magical channeling. A modern spin on the old Geomancy spells."
	icon_state = "vendor_staff"
	inhand_icon_state = "vendor_staff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon = 'icons/obj/weapons/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	damtype = BRUTE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	attack_verb_continuous = list("smacks", "clubs", "wacks")
	attack_verb_simple = list("smack", "club", "wack")

	/// Range cap on where you can summon vendors.
	var/max_summon_range = RUNIC_SCEPTER_MAX_RANGE
	/// Channeling time to summon a vendor.
	var/summoning_time = 1 SECONDS
	/// Checks if the scepter is channeling a vendor already.
	var/scepter_is_busy_summoning = FALSE
	/// Checks if the scepter is busy channeling recharges
	var/scepter_is_busy_recharging = FALSE
	///Number of summoning charges left.
	var/summon_vendor_charges = RUNIC_SCEPTER_MAX_CHARGES

/obj/item/runic_vendor_scepter/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED, PROC_REF(on_magic_charge))
	var/static/list/loc_connections = list(
		COMSIG_ITEM_MAGICALLY_CHARGED = PROC_REF(on_magic_charge),
	)

/obj/item/runic_vendor_scepter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/runic_vendor_scepter/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(scepter_is_busy_recharging)
		user.balloon_alert(user, "busy!")
		return ITEM_INTERACT_BLOCKING
	if(!check_allowed_items(interacting_with, not_inside = TRUE))
		return NONE
	if(istype(interacting_with, /obj/machinery/vending/runic_vendor))
		var/obj/machinery/vending/runic_vendor/runic_explosion_target = interacting_with
		runic_explosion_target.runic_explosion()
		return ITEM_INTERACT_SUCCESS
	var/turf/afterattack_turf = get_turf(interacting_with)
	var/obj/machinery/vending/runic_vendor/vendor_on_turf = locate() in afterattack_turf
	if(vendor_on_turf)
		vendor_on_turf.runic_explosion()
		return  ITEM_INTERACT_SUCCESS
	if(!summon_vendor_charges)
		user.balloon_alert(user, "no charges!")
		return ITEM_INTERACT_BLOCKING
	if(get_dist(afterattack_turf,src) > max_summon_range)
		user.balloon_alert(user, "too far!")
		return ITEM_INTERACT_BLOCKING
	if(get_turf(src) == afterattack_turf)
		user.balloon_alert(user, "too close!")
		return ITEM_INTERACT_BLOCKING
	if(scepter_is_busy_summoning)
		user.balloon_alert(user, "already summoning!")
		return ITEM_INTERACT_BLOCKING
	if(afterattack_turf.is_blocked_turf(TRUE))
		user.balloon_alert(user, "blocked!")
		return ITEM_INTERACT_BLOCKING
	if(summoning_time)
		scepter_is_busy_summoning = TRUE
		user.balloon_alert(user, "summoning...")
		if(!do_after(user, summoning_time, target = interacting_with))
			scepter_is_busy_summoning = FALSE
			return ITEM_INTERACT_BLOCKING
		scepter_is_busy_summoning = FALSE
	if(summon_vendor_charges)
		playsound(src,'sound/items/weapons/resonator_fire.ogg',50,TRUE)
		user.visible_message(span_warning("[user] summons a runic vendor!"))
		new /obj/machinery/vending/runic_vendor(afterattack_turf)
		summon_vendor_charges--
		user.changeNext_move(CLICK_CD_MELEE)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/runic_vendor_scepter/attack_self(mob/user, modifiers)
	. = ..()
	user.balloon_alert(user, "recharging...")
	scepter_is_busy_recharging = TRUE
	if(!do_after(user, 5 SECONDS))
		scepter_is_busy_recharging = FALSE
		return
	user.balloon_alert(user, "fully charged")
	scepter_is_busy_recharging = FALSE
	summon_vendor_charges = RUNIC_SCEPTER_MAX_CHARGES

/obj/item/runic_vendor_scepter/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/runic_vendor_scepter/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	var/turf/afterattack_secondary_turf = get_turf(interacting_with)
	var/obj/machinery/vending/runic_vendor/vendor_on_turf = locate() in afterattack_secondary_turf
	if(istype(interacting_with, /obj/machinery/vending/runic_vendor))
		var/obj/machinery/vending/runic_vendor/vendor_being_throw = interacting_with
		vendor_being_throw.throw_at(get_edge_target_turf(interacting_with, get_cardinal_dir(src, interacting_with)), 4, 20, user)
		return ITEM_INTERACT_SUCCESS
	if(vendor_on_turf)
		vendor_on_turf.throw_at(get_edge_target_turf(interacting_with, get_cardinal_dir(src, interacting_with)), 4, 20, user)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/runic_vendor_scepter/proc/on_magic_charge(datum/source, datum/action/cooldown/spell/charge/spell, mob/living/caster)
	SIGNAL_HANDLER

	if(!ismovable(loc))
		return

	. = COMPONENT_ITEM_CHARGED

	summon_vendor_charges = RUNIC_SCEPTER_MAX_CHARGES
	return .

#undef RUNIC_SCEPTER_MAX_CHARGES
#undef RUNIC_SCEPTER_MAX_RANGE
