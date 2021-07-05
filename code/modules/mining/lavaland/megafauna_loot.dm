//This file contains all Lavaland megafauna loot. Does not include crusher trophies.


//Hierophant: Hierophant Club

#define HIEROPHANT_BLINK_RANGE 5
#define HIEROPHANT_BLINK_COOLDOWN 15 SECONDS

/datum/action/innate/dash/hierophant
	current_charges = 1
	max_charges = 1
	charge_rate = HIEROPHANT_BLINK_COOLDOWN
	recharge_sound = null
	phasein = /obj/effect/temp_visual/hierophant/blast/visual
	phaseout = /obj/effect/temp_visual/hierophant/blast/visual
	// It's a simple purple beam, works well enough for the purple hiero effects.
	beam_effect = "plasmabeam"

/datum/action/innate/dash/hierophant/Teleport(mob/user, atom/target)
	var/dist = get_dist(user, target)
	if(dist > HIEROPHANT_BLINK_RANGE)
		to_chat(user, span_hierophant_warning("Blink destination out of range."))
		return
	var/turf/target_turf = get_turf(target)
	if(target_turf.is_blocked_turf_ignore_climbable())
		to_chat(user, span_hierophant_warning("Blink destination blocked."))
		return
	. = ..()
	if(!current_charges)
		var/obj/item/hierophant_club/club = src.target
		if(istype(club))
			club.blink_charged = FALSE
			club.update_appearance()

/datum/action/innate/dash/hierophant/charge()
	var/obj/item/hierophant_club/club = target
	if(istype(club))
		club.blink_charged = TRUE
		club.update_appearance()

	current_charges = clamp(current_charges + 1, 0, max_charges)
	owner.update_action_buttons_icon()

	if(recharge_sound)
		playsound(dashing_item, recharge_sound, 50, TRUE)
	to_chat(owner, span_notice("[src] now has [current_charges]/[max_charges] charges."))

/obj/item/hierophant_club
	name = "hierophant club"
	desc = "The strange technology of this large club allows various nigh-magical teleportation feats. It used to beat you, but now you can set the beat."
	icon_state = "hierophant_club_ready_beacon"
	inhand_icon_state = "hierophant_club_ready_beacon"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	attack_verb_continuous = list("clubs", "beats", "pummels")
	attack_verb_simple = list("club", "beat", "pummel")
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall)
	/// Linked teleport beacon for the group teleport functionality.
	var/obj/effect/hierophant/beacon
	/// TRUE if currently doing a teleport to the beacon, FALSE otherwise.
	var/teleporting = FALSE //if we ARE teleporting
	/// Action enabling the blink-dash functionality.
	var/datum/action/innate/dash/hierophant/blink
	/// Whether the blink ability is activated. IF TRUE, left clicking a location will blink to it. If FALSE, this is disabled.
	var/blink_activated = TRUE
	/// Whether the blink is charged. Set and unset by the blink action. Used as part of setting the appropriate icon states.
	var/blink_charged = TRUE

/obj/item/hierophant_club/Initialize()
	. = ..()
	blink = new(src)

/obj/item/hierophant_club/Destroy()
	. = ..()
	QDEL_NULL(blink)

/obj/item/hierophant_club/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/hierophant_club/examine(mob/user)
	. = ..()
	. += span_hierophant_warning("The[beacon ? " beacon is not currently":"re is a beacon"] attached.")

/obj/item/hierophant_club/suicide_act(mob/living/user)
	say("Xverwpsgexmrk...", forced = "hierophant club suicide")
	user.visible_message(span_suicide("[user] holds [src] into the air! It looks like [user.p_theyre()] trying to commit suicide!"))
	new/obj/effect/temp_visual/hierophant/telegraph(get_turf(user))
	playsound(user,'sound/machines/airlockopen.ogg', 75, TRUE)
	user.visible_message(span_hierophant_warning("[user] fades out, leaving [user.p_their()] belongings behind!"))
	for(var/obj/item/I in user)
		if(I != src)
			user.dropItemToGround(I)
	for(var/turf/T in RANGE_TURFS(1, user))
		new /obj/effect/temp_visual/hierophant/blast/visual(T, user, TRUE)
	user.dropItemToGround(src) //Drop us last, so it goes on top of their stuff
	qdel(user)

/obj/item/hierophant_club/attack_self(mob/user)
	blink_activated = !blink_activated
	to_chat(user, span_notice("You [blink_activated ? "enable" : "disable"] the blink function on [src]."))

/obj/item/hierophant_club/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	// If our target is the beacon and the hierostaff is next to the beacon, we're trying to pick it up.
	if((target == beacon) && target.Adjacent(src))
		return
	if(blink_activated)
		blink.Teleport(user, target)

/obj/item/hierophant_club/update_icon_state()
	icon_state = inhand_icon_state = "hierophant_club[blink_charged ? "_ready":""][(!QDELETED(beacon)) ? "":"_beacon"]"
	return ..()

/obj/item/hierophant_club/ui_action_click(mob/user, action)
	if(!user.is_holding(src)) //you need to hold the staff to teleport
		to_chat(user, span_warning("You need to hold the club in your hands to [beacon ? "teleport with it":"detach the beacon"]!"))
		return
	if(!beacon || QDELETED(beacon))
		if(isturf(user.loc))
			user.visible_message(span_hierophant_warning("[user] starts fiddling with [src]'s pommel..."), \
			span_notice("You start detaching the hierophant beacon..."))
			if(do_after(user, 50, target = user) && !beacon)
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/blind.ogg', 200, TRUE, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
				beacon = new/obj/effect/hierophant(T)
				user.update_action_buttons_icon()
				user.visible_message(span_hierophant_warning("[user] places a strange machine beneath [user.p_their()] feet!"), \
				"[span_hierophant("You detach the hierophant beacon, allowing you to teleport yourself and any allies to it at any time!")]\n\
				[span_notice("You can remove the beacon to place it again by striking it with the club.")]")
		else
			to_chat(user, span_warning("You need to be on solid ground to detach the beacon!"))
		return
	if(get_dist(user, beacon) <= 2) //beacon too close abort
		to_chat(user, span_warning("You are too close to the beacon to teleport to it!"))
		return
	var/turf/beacon_turf = get_turf(beacon)
	if(beacon_turf?.is_blocked_turf(TRUE))
		to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("You don't have enough space to teleport from here!"))
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message(span_hierophant_warning("[user] starts to glow faintly..."))
	beacon.icon_state = "hierophant_tele_on"
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE1 = new /obj/effect/temp_visual/hierophant/telegraph/edge(user.loc)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE2 = new /obj/effect/temp_visual/hierophant/telegraph/edge(beacon.loc)
	if(do_after(user, 40, target = user) && user && beacon)
		var/turf/T = get_turf(beacon)
		var/turf/source = get_turf(user)
		if(T.is_blocked_turf(TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
			user.update_action_buttons_icon()
			beacon.icon_state = "hierophant_tele_off"
			return
		new /obj/effect/temp_visual/hierophant/telegraph(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph(source, user)
		playsound(T,'sound/magic/wand_teleport.ogg', 200, TRUE)
		playsound(source,'sound/machines/airlockopen.ogg', 200, TRUE)
		if(!do_after(user, 3, target = user) || !user || !beacon || QDELETED(beacon)) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			if(beacon)
				beacon.icon_state = "hierophant_tele_off"
			return
		if(T.is_blocked_turf(TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
			user.update_action_buttons_icon()
			beacon.icon_state = "hierophant_tele_off"
			return
		user.log_message("teleported self from [AREACOORD(source)] to [beacon]", LOG_GAME)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, user)
		for(var/t in RANGE_TURFS(1, T))
			new /obj/effect/temp_visual/hierophant/blast/visual(t, user, TRUE)
		for(var/t in RANGE_TURFS(1, source))
			new /obj/effect/temp_visual/hierophant/blast/visual(t, user, TRUE)
		for(var/mob/living/L in range(1, source))
			INVOKE_ASYNC(src, .proc/teleport_mob, source, L, T, user)
		sleep(6) //at this point the blasts detonate
		if(beacon)
			beacon.icon_state = "hierophant_tele_off"
	else
		qdel(TE1)
		qdel(TE2)
	if(beacon)
		beacon.icon_state = "hierophant_tele_off"
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/hierophant_club/proc/teleport_mob(turf/source, mob/teleporting, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, teleporting)) //get position relative to caster
	if(!turf_to_teleport_to || turf_to_teleport_to.is_blocked_turf(TRUE))
		return
	animate(teleporting, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(1)
	if(!teleporting)
		return
	teleporting.visible_message(span_hierophant_warning("[teleporting] fades out!"))
	sleep(2)
	if(!teleporting)
		return
	var/success = do_teleport(teleporting, turf_to_teleport_to, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	sleep(1)
	if(!teleporting)
		return
	animate(teleporting, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(1)
	if(!teleporting)
		return
	teleporting.visible_message(span_hierophant_warning("[teleporting] fades in!"))
	if(user != teleporting && success)
		log_combat(user, teleporting, "teleported", null, "from [AREACOORD(source)]")

/obj/item/hierophant_club/pickup(mob/living/user)
	. = ..()
	blink.Grant(user, src)
	user.update_icons()

/obj/item/hierophant_club/dropped(mob/user)
	. = ..()
	blink.Remove(user)
	user.update_icons()

#undef HIEROPHANT_BLINK_RANGE
#undef HIEROPHANT_BLINK_COOLDOWN

//Bubblegum: Mayhem in a Bottle, Demon Lungs

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/target in range(7,user))
		target.apply_status_effect(STATUS_EFFECT_MAYHEM)
	to_chat(user, span_notice("You shatter the bottle!"))
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
	message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(user)] has activated a bottle of mayhem!"))
	user.log_message("activated a bottle of mayhem", LOG_ATTACK)
	qdel(src)

//Ash Drake: Spectral Blade, Lava Staff, Dragon's Blood

/obj/item/melee/ghost_sword
	name = "\improper spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon_state = "spectral"
	inhand_icon_state = "spectral"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/Initialize()
	. = ..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	AddComponent(/datum/component/butchering, 150, 90)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = GLOB.observer_default_invisibility
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, span_warning("You just recently called out for aid. You don't want to annoy the spirits!"))
		return
	to_chat(user, span_notice("You call out for aid, attempting to summon spirits to your side."))

	notify_ghosts("[user] is raising [user.p_their()] [src], calling for your help!",
		enter_link="<a href=?src=[REF(src)];orbit=1>(Click to help)</a>",
		source = user, ignore_key = POLL_IGNORE_SPECTRAL_BLADE, header = "Spectral blade")

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.GetAllContents()
	var/mob/dead/observer/current_spirits = list()
	for(var/thing in contents)
		var/atom/A = thing
		A.transfer_observers_to(src)
	for(var/i in orbiters?.orbiter_list)
		if(!isobserver(i))
			continue
		var/mob/dead/observer/G = i
		ghost_counter++
		G.invisibility = 0
		current_spirits |= G
	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = GLOB.observer_default_invisibility
	spirits = current_spirits
	return ghost_counter

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()
	force = clamp((ghost_counter * 4), 0, 75)
	user.visible_message(span_danger("[user] strikes with the force of [ghost_counter] vengeful spirits!"))
	..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/ghost_counter = ghost_check()
	final_block_chance += clamp((ghost_counter * 5), 0, 75)
	owner.visible_message(span_danger("[owner] is protected by a ring of [ghost_counter] ghosts!"))
	return ..()

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/consumer = user
	var/random = rand(1,4)

	switch(random)
		if(1)
			to_chat(user, span_danger("Your appearance morphs to that of a very small humanoid ash dragon! You get to look like a freak without the cool abilities."))
			consumer.dna.features = list("mcolor" = "A02720", "tail_lizard" = "Dark Tiger", "tail_human" = "None", "snout" = "Sharp", "horns" = "Curled", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "Long", "body_markings" = "Dark Tiger Body", "legs" = "Digitigrade Legs")
			consumer.eye_color = "fee5a3"
			consumer.set_species(/datum/species/lizard)
		if(2)
			to_chat(user, span_danger("Your flesh begins to melt! Miraculously, you seem fine otherwise."))
			consumer.set_species(/datum/species/skeleton)
		if(3)
			to_chat(user, span_danger("Power courses through you! You can now shift your form at will."))
			if(user.mind)
				var/obj/effect/proc_holder/spell/targeted/shapeshift/dragon/dragon_shapeshift = new
				user.mind.AddSpell(dragon_shapeshift)
		if(4)
			to_chat(user, span_danger("You feel like you could walk straight through lava now."))
			LAZYOR(consumer.weather_immunities, WEATHER_LAVA)

	playsound(user,'sound/items/drink.ogg', 30, TRUE)
	qdel(src)

/obj/item/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "lavastaff"
	inhand_icon_state = "staffofstorms"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 18
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hitsound = 'sound/weapons/sear.ogg'
	var/turf_type = /turf/open/lava/smooth/weak
	var/transform_string = "lava"
	var/reset_turf_type = /turf/open/floor/plating/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 10 SECONDS
	var/create_delay = 3 SECONDS
	var/reset_cooldown = 5 SECONDS
	var/timer = 0
	var/static/list/banned_turfs = typecacheof(list(/turf/open/space/transit, /turf/closed))

/obj/item/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(timer > world.time)
		return
	if(is_type_in_typecache(target, banned_turfs))
		return
	if(target in view(user.client.view, get_turf(user)))
		var/turf/open/T = get_turf(target)
		if(!istype(T))
			return
		if(!istype(T, turf_type))
			var/obj/effect/temp_visual/lavastaff/L = new /obj/effect/temp_visual/lavastaff(T)
			L.alpha = 0
			animate(L, alpha = 255, time = create_delay)
			user.visible_message(span_danger("[user] points [src] at [T]!"))
			timer = world.time + create_delay + 1
			if(do_after(user, create_delay, target = T))
				var/old_name = T.name
				if(T.TerraformTurf(turf_type, flags = CHANGETURF_INHERIT_AIR))
					user.visible_message(span_danger("[user] turns \the [old_name] into [transform_string]!"))
					message_admins("[ADMIN_LOOKUPFLW(user)] fired the lava staff at [ADMIN_VERBOSEJMP(T)]")
					log_game("[key_name(user)] fired the lava staff at [AREACOORD(T)].")
					timer = world.time + create_cooldown
					playsound(T,'sound/magic/fireball.ogg', 200, TRUE)
			else
				timer = world.time
			qdel(L)
		else
			var/old_name = T.name
			if(T.TerraformTurf(reset_turf_type, flags = CHANGETURF_INHERIT_AIR))
				user.visible_message(span_danger("[user] turns \the [old_name] into [reset_string]!"))
				timer = world.time + reset_cooldown
				playsound(T,'sound/magic/fireball.ogg', 200, TRUE)

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50

/turf/open/lava/smooth/weak
	lava_damage = 10
	lava_firestacks = 10
	temperature_damage = 2500

//Blood-Drunk Miner: Cleaving Saw

/obj/item/melee/transforming/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	force = 12
	force_on = 20 //force when active
	throwforce = 20
	throwforce_on = 20
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	icon_state = "cleaving_saw"
	icon_state_on = "cleaving_saw_open"
	worn_icon_state = "cleaving_saw"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_off = list("attacks", "saws", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_on = list("cleaves", "swipes", "slashes", "chops")
	hitsound = 'sound/weapons/bladeslice.ogg'
	hitsound_on = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	faction_bonus_force = 30
	nemesis_factions = list("mining", "boss")
	var/transform_cooldown
	var/swiping = FALSE
	var/bleed_stacks_per_hit = 3

/obj/item/melee/transforming/cleaving_saw/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [active ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].\n"+\
	"Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.\n"+\
	"Transforming it immediately after an attack causes the next attack to come out faster.</span>"

/obj/item/melee/transforming/cleaving_saw/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is [active ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!"))
	transform_cooldown = 0
	transform_weapon(user, TRUE)
	return BRUTELOSS

/obj/item/melee/transforming/cleaving_saw/transform_weapon(mob/living/user, supress_message_text)
	if(transform_cooldown > world.time)
		return FALSE
	. = ..()
	if(.)
		transform_cooldown = world.time + (CLICK_CD_MELEE * 0.5)
		user.changeNext_move(CLICK_CD_MELEE * 0.25)

/obj/item/melee/transforming/cleaving_saw/transform_messages(mob/living/user, supress_message_text)
	if(!supress_message_text)
		if(active)
			to_chat(user, span_notice("You open [src]. It will now cleave enemies in a wide arc and deal additional damage to fauna."))
		else
			to_chat(user, span_notice("You close [src]. It will now attack rapidly and cause fauna to bleed."))
	playsound(user, 'sound/magic/clockwork/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (active * 30000))

/obj/item/melee/transforming/cleaving_saw/clumsy_transform_effect(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("You accidentally cut yourself with [src], like a doofus!"))
		user.take_bodypart_damage(10)

/obj/item/melee/transforming/cleaving_saw/melee_attack_chain(mob/user, atom/target, params)
	..()
	if(!active)
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/transforming/cleaving_saw/nemesis_effects(mob/living/user, mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite))
		return
	var/datum/status_effect/stacking/saw_bleed/B = target.has_status_effect(STATUS_EFFECT_SAWBLEED)
	if(!B)
		target.apply_status_effect(STATUS_EFFECT_SAWBLEED,bleed_stacks_per_hit)
	else
		B.add_stacks(bleed_stacks_per_hit)

/obj/item/melee/transforming/cleaving_saw/attack(mob/living/target, mob/living/carbon/human/user)
	if(!active || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!active)
			faction_bonus_force = 0
		..()
		if(!active)
			faction_bonus_force = initial(faction_bonus_force)
	else
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

//Legion: Staff of Storms

/obj/item/storm_staff
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	inhand_icon_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 20
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20
	var/max_thunder_charges = 3
	var/thunder_charges = 3
	var/thunder_charge_time = 15 SECONDS
	var/static/list/excluded_areas = list(/area/space)
	var/list/targetted_turfs = list()

/obj/item/storm_staff/examine(mob/user)
	. = ..()
	. += span_notice("It has [thunder_charges] charges remaining.")
	. += span_notice("Use it in hand to dispel storms.")
	. += span_notice("Use it on targets to summon thunderbolts from the sky.")
	. += span_notice("The thunderbolts are boosted if in an area with weather effects.")

/obj/item/storm_staff/attack_self(mob/user)
	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_area || !user_turf || (is_type_in_list(user_area, excluded_areas)))
		to_chat(user, span_warning("Something is preventing you from using the staff here."))
		return
	var/datum/weather/affected_weather
	for(var/datum/weather/weather as anything in SSweather.processing)
		if((user_turf.z in weather.impacted_z_levels) && ispath(user_area.type, weather.area_type))
			affected_weather = weather
			break
	if(!affected_weather)
		return
	if(affected_weather.stage == END_STAGE)
		balloon_alert(user, "already ended!")
		return
	if(affected_weather.stage == WIND_DOWN_STAGE)
		balloon_alert(user, "already ending!")
		return
	balloon_alert(user, "you hold the staff up...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	user.visible_message(span_warning("[user] holds [src] skywards as an orange beam travels into the sky!"), \
	span_notice("You hold [src] skyward, dispelling the storm!"))
	playsound(user, 'sound/magic/staff_change.ogg', 200, FALSE)
	var/old_color = user.color
	var/old_transform = user.transform
	user.color = rgb(400,300,0)
	user.transform.Scale(1.3)
	animate(user, color = old_color, transform = old_transform, time = 1 SECONDS)
	affected_weather.wind_down()
	log_game("[user] ([key_name(user)]) has dispelled a storm at [AREACOORD(user_turf)]")

/obj/item/storm_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!thunder_charges)
		balloon_alert(user, "needs to charge!")
		return
	var/turf/target_turf = get_turf(target)
	var/area/target_area = get_area(target)
	if(!target_turf || !target_area || (is_type_in_list(target_area, excluded_areas)))
		balloon_alert(user, "can't bolt here!")
		return
	if(target_turf in targetted_turfs)
		balloon_alert(user, "already targetted!")
		return
	var/power_boosted = FALSE
	for(var/datum/weather/weather as anything in SSweather.processing)
		if(weather.stage != MAIN_STAGE)
			continue
		if((target_turf.z in weather.impacted_z_levels) && ispath(target_area.type, weather.area_type))
			power_boosted = TRUE
			break
	playsound(src, 'sound/magic/lightningshock.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	targetted_turfs += target
	balloon_alert(user, "you aim at [target_turf]...")
	new /obj/effect/temp_visual/telegraphing/thunderbolt(target_turf)
	addtimer(CALLBACK(src, .proc/throw_thunderbolt, target_turf, power_boosted), 1.5 SECONDS)
	thunder_charges--
	addtimer(CALLBACK(src, .proc/recharge), thunder_charge_time)

/obj/item/storm_staff/proc/recharge(mob/user)
	thunder_charges = min(thunder_charges+1, max_thunder_charges)
	playsound(src, 'sound/magic/charge.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)

/obj/item/storm_staff/proc/throw_thunderbolt(turf/target, boosted)
	targetted_turfs -= target
	new /obj/effect/temp_visual/thunderbolt(target)
	var/list/affected_turfs = list(target)
	if(boosted)
		for(var/direction in GLOB.alldirs)
			var/turf_to_add = get_step(target, direction)
			if(!turf_to_add)
				continue
			affected_turfs += turf_to_add
	for(var/turf/turf as anything in affected_turfs)
		new /obj/effect/temp_visual/electricity(turf)
		for(var/mob/living/hit_mob in turf)
			to_chat(hit_mob, span_userdanger("You've been struck by lightning!"))
			hit_mob.electrocute_act(15 * (isanimal(hit_mob) ? 3 : 1) * (turf == target ? 2 : 1)* (boosted ? 2 : 1), src, flags = SHOCK_TESLA|SHOCK_NOSTUN)
		for(var/obj/hit_thing in turf)
			hit_thing.take_damage(20, BURN, ENERGY, FALSE)
	playsound(target, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	target.visible_message(span_danger("A thunderbolt strikes [target]!"))
	explosion(target, light_impact_range = (boosted ? 1 : 0), flame_range = (boosted ? 2 : 1), silent = TRUE)
