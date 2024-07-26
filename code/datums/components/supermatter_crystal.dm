/datum/component/supermatter_crystal

	///Callback for the wrench act call
	var/datum/callback/tool_act_callback
	///Callback used by the SM to get the damage and matter power increase/decrease
	var/datum/callback/consume_callback
	// A whitelist of items that can interact with the SM without dusting the user
	var/static/list/sm_item_whitelist = typecacheof(list(
		/obj/item/melee/roastingstick,
		/obj/item/toy/crayon/spraycan
	))

/datum/component/supermatter_crystal/Initialize(datum/callback/tool_act_callback, datum/callback/consume_callback)

	RegisterSignal(parent, COMSIG_ATOM_BLOB_ACT, PROC_REF(blob_hit))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_PAW, PROC_REF(paw_hit))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(animal_hit))
	RegisterSignal(parent, COMSIG_ATOM_HULK_ATTACK, PROC_REF(hulk_hit))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(unarmed_hit))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(hand_hit))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attackby_hit))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(tool_hit))
	RegisterSignal(parent, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WRENCH), PROC_REF(tool_hit))
	RegisterSignal(parent, COMSIG_ATOM_BUMPED, PROC_REF(bumped_hit))
	RegisterSignal(parent, COMSIG_ATOM_INTERCEPT_Z_FALL, PROC_REF(intercept_z_fall))
	RegisterSignal(parent, COMSIG_ATOM_ON_Z_IMPACT, PROC_REF(on_z_impact))

	src.tool_act_callback = tool_act_callback
	src.consume_callback = consume_callback

/datum/component/supermatter_crystal/Destroy(force)
	tool_act_callback = null
	consume_callback = null
	return ..()

/datum/component/supermatter_crystal/UnregisterFromParent(force, silent)
	var/list/signals_to_remove = list(
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH),
		COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WRENCH),
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_INTERCEPT_Z_FALL,
		COMSIG_ATOM_ON_Z_IMPACT,
	)

	UnregisterSignal(parent, signals_to_remove)

/datum/component/supermatter_crystal/proc/blob_hit(datum/source, obj/structure/blob/blob)
	SIGNAL_HANDLER
	var/atom/atom_source = source
	if(!blob || isspaceturf(atom_source)) //does nothing in space
		return
	playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume_returns(damage_increase = blob.get_integrity() * 0.05)
	if(blob.get_integrity() > 100)
		blob.visible_message(span_danger("\The [blob] strikes at \the [atom_source] and flinches away!"),
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
		blob.take_damage(100, BURN)
	else
		blob.visible_message(span_danger("\The [blob] strikes at \the [atom_source] and rapidly flashes to ash."),
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
		consume(atom_source, blob)

/datum/component/supermatter_crystal/proc/paw_hit(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(isliving(user))
		var/mob/living/living_mob = user
		if(living_mob.incorporeal_move || living_mob.status_flags & GODMODE)
			return
	if(isalien(user))
		dust_mob(source, user, cause = "alien attack")
		return
	dust_mob(source, user, cause = "monkey attack")

/datum/component/supermatter_crystal/proc/animal_hit(datum/source, mob/living/simple_animal/user, list/modifiers)
	SIGNAL_HANDLER
	if(user.incorporeal_move || user.status_flags & GODMODE)
		return
	var/atom/atom_source = source
	var/murder
	if(!user.melee_damage_upper && !user.melee_damage_lower)
		murder = user.friendly_verb_continuous
	else
		murder = user.attack_verb_continuous
	dust_mob(source, user, \
	span_danger("[user] unwisely [murder] [atom_source], and [user.p_their()] body burns brilliantly before flashing into ash!"), \
	span_userdanger("You unwisely touch [atom_source], and your vision glows brightly as your body crumbles to dust. Oops."), \
	"simple animal attack")

/datum/component/supermatter_crystal/proc/hulk_hit(datum/source, mob/user)
	SIGNAL_HANDLER
	dust_mob(source, user, cause = "hulk attack")

/datum/component/supermatter_crystal/proc/unarmed_hit(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(isliving(user))
		var/mob/living/living_mob = user
		if(living_mob.incorporeal_move || living_mob.status_flags & GODMODE)
			return
	var/atom/atom_source = source
	if(iscyborg(user) && atom_source.Adjacent(user))
		dust_mob(source, user, cause = "cyborg attack")
		return
	if(isaicamera(user))
		return
	if(islarva(user))
		dust_mob(source, user, cause = "larva attack")
		return

/datum/component/supermatter_crystal/proc/hand_hit(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(user.incorporeal_move || user.status_flags & GODMODE)
		return
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		dust_mob(source, user, cause = "hand")
		return
	var/atom/atom_source = source
	if(!user.is_mouth_covered())
		if(user.combat_mode)
			dust_mob(source, user,
				span_danger("As [user] tries to take a bite out of [atom_source] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash."),
				span_userdanger("You try to take a bite out of [atom_source], but find [p_them()] far too hard to get anywhere before everything starts burning and your ears fill with ringing!"),
				"attempted bite"
			)
			return

		var/obj/item/organ/internal/tongue/licking_tongue = user.get_organ_slot(ORGAN_SLOT_TONGUE)
		if(licking_tongue)
			dust_mob(source, user,
				span_danger("As [user] hesitantly leans in and licks [atom_source] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash!"),
				span_userdanger("You tentatively lick [atom_source], but you can't figure out what it tastes like before everything starts burning and your ears fill with ringing!"),
				"attempted lick"
			)
			return

	var/obj/item/bodypart/head/forehead = user.get_bodypart(BODY_ZONE_HEAD)
	if(forehead)
		dust_mob(source, user,
			span_danger("As [user]'s forehead bumps into [atom_source], inducing a resonance... Everything goes silent before [user.p_their()] [forehead] flashes to ash!"),
			span_userdanger("You feel your forehead bump into [atom_source] and everything suddenly goes silent. As your head fills with ringing you come to realize that that was not a wise decision."),
			"failed lick"
		)
		return

	dust_mob(source, user,
		span_danger("[user] leans in and tries to lick [atom_source], inducing a resonance... [user.p_their()] body starts to glow and burst into flames before flashing into dust!"),
		span_userdanger("You lean in and try to lick [atom_source]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\""),
		"failed lick"
	)

/datum/component/supermatter_crystal/proc/attackby_hit(datum/source, obj/item/item, mob/living/user, params)
	SIGNAL_HANDLER
	var/atom/atom_source = source
	if(!istype(item) || (item.item_flags & ABSTRACT) || !istype(user))
		return
	if(is_type_in_typecache(item, sm_item_whitelist))
		return FALSE
	if(istype(item, /obj/item/cigarette))
		var/obj/item/cigarette/cig = item
		var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
		if(clumsy)
			var/which_hand = BODY_ZONE_L_ARM
			if(!(user.active_hand_index % 2))
				which_hand = BODY_ZONE_R_ARM
			var/obj/item/bodypart/dust_arm = user.get_bodypart(which_hand)
			dust_arm.dismember()
			user.visible_message(span_danger("The [item] flashes out of existence on contact with \the [atom_source], resonating with a horrible sound..."),\
				span_danger("Oops! The [item] flashes out of existence on contact with \the [atom_source], taking your arm with it! That was clumsy of you!"))
			playsound(atom_source, 'sound/effects/supermatter.ogg', 150, TRUE)
			consume(atom_source, dust_arm)
			qdel(item)
			return
		if(cig.lit || user.combat_mode)
			user.visible_message(span_danger("A hideous sound echoes as [item] is ashed out on contact with \the [atom_source]. That didn't seem like a good idea..."))
			playsound(atom_source, 'sound/effects/supermatter.ogg', 150, TRUE)
			consume(atom_source, item)
			radiation_pulse(atom_source, max_range = 3, threshold = 0.1, chance = 50)
			return
		else
			cig.light()
			user.visible_message(span_danger("As [user] lights \their [item] on \the [atom_source], silence fills the room..."),\
				span_danger("Time seems to slow to a crawl as you touch \the [atom_source] with \the [item].</span>\n<span class='notice'>\The [item] flashes alight with an eerie energy as you nonchalantly lift your hand away from \the [atom_source]. Damn."))
			playsound(atom_source, 'sound/effects/supermatter.ogg', 50, TRUE)
			radiation_pulse(atom_source, max_range = 1, threshold = 0, chance = 100)
			return

	if(user.dropItemToGround(item))
		user.visible_message(span_danger("As [user] touches \the [atom_source] with \a [item], silence fills the room..."),\
			span_userdanger("You touch \the [atom_source] with \the [item], and everything suddenly goes silent.</span>\n<span class='notice'>\The [item] flashes into dust as you flinch away from \the [atom_source]."),\
			span_hear("Everything suddenly goes silent."))
		user.investigate_log("has been attacked ([item]) by [key_name(user)]", INVESTIGATE_ENGINE)
		consume(atom_source, item)
		playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)

		radiation_pulse(atom_source, max_range = 3, threshold = 0.1, chance = 50)
		return

	if(atom_source.Adjacent(user)) //if the item is stuck to the person, kill the person too instead of eating just the item.
		if(user.incorporeal_move || user.status_flags & GODMODE)
			return
		var/vis_msg = span_danger("[user] reaches out and touches [atom_source] with [item], inducing a resonance... [item] starts to glow briefly before the light continues up to [user]'s body. [user.p_They()] burst[user.p_s()] into flames before flashing into dust!")
		var/mob_msg = span_userdanger("You reach out and touch [atom_source] with [item]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
		dust_mob(source, user, vis_msg, mob_msg)

/datum/component/supermatter_crystal/proc/tool_hit(datum/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(tool_act_callback)
		tool_act_callback.Invoke(user, tool)
		return ITEM_INTERACT_BLOCKING
	attackby_hit(source, tool, user)

/datum/component/supermatter_crystal/proc/bumped_hit(datum/source, atom/movable/hit_object)
	SIGNAL_HANDLER
	if(isliving(hit_object))
		var/mob/living/hit_mob = hit_object
		if(hit_mob.incorporeal_move || hit_mob.status_flags & GODMODE)
			return
	var/atom/atom_source = source
	var/obj/machinery/power/supermatter_crystal/our_supermatter = parent // Why is this a component?
	if(istype(our_supermatter))
		our_supermatter.log_activation(who = hit_object)
	if(isliving(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] slams into \the [atom_source] inducing a resonance... [hit_object.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("You slam into \the [atom_source] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	else if(isobj(hit_object) && !iseffect(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] smacks into \the [atom_source] and rapidly flashes to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
	else
		return

	playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(atom_source, hit_object)

/datum/component/supermatter_crystal/proc/intercept_z_fall(datum/source, list/falling_movables, levels)
	SIGNAL_HANDLER
	for(var/atom/movable/hit_object as anything in falling_movables)
		if(parent == hit_object)
			return

		bumped_hit(parent, hit_object)
	return FALL_INTERCEPTED | FALL_NO_MESSAGE

/datum/component/supermatter_crystal/proc/on_z_impact(datum/source, turf/impacted_turf, levels)
	SIGNAL_HANDLER

	var/atom/atom_source = source

	for(var/mob/living/poor_target in impacted_turf)
		consume(atom_source, poor_target)
		playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
		poor_target.visible_message(span_danger("\The [atom_source] slams into \the [poor_target] out of nowhere inducing a resonance... [poor_target.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("\The [atom_source] slams into you out of nowhere as your ears are filled with unearthly ringing. Your last thought is \"The fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))

	for(var/atom/movable/hit_object as anything in impacted_turf)
		if(parent == hit_object)
			return

		if(iseffect(hit_object))
			continue

		consume(atom_source, hit_object)
		playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
		atom_source.visible_message(span_danger("\The [atom_source], smacks into the plating out of nowhere, reducing everything below to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))

/datum/component/supermatter_crystal/proc/dust_mob(datum/source, mob/living/nom, vis_msg, mob_msg, cause)
	if(nom.incorporeal_move || nom.status_flags & GODMODE) //try to keep supermatter sliver's + hemostat's dust conditions in sync with this too
		return
	var/atom/atom_source = source
	if(!vis_msg)
		vis_msg = span_danger("[nom] reaches out and touches [atom_source], inducing a resonance... [nom.p_their()] body starts to glow and burst into flames before flashing into dust!")
	if(!mob_msg)
		mob_msg = span_userdanger("You reach out and touch [atom_source]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	atom_source.investigate_log("has been attacked ([cause]) by [key_name(nom)]", INVESTIGATE_ENGINE)
	add_memory_in_range(atom_source, 7, /datum/memory/witness_supermatter_dusting, protagonist = nom, antagonist = atom_source)
	playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(atom_source, nom)

/datum/component/supermatter_crystal/proc/consume(atom/source, atom/movable/consumed_object)
	if(consumed_object.flags_1 & SUPERMATTER_IGNORES_1)
		return
	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		if(consumed_mob.status_flags & GODMODE)
			return

	var/atom/atom_source = source
	SEND_SIGNAL(consumed_object, COMSIG_SUPERMATTER_CONSUMED, atom_source)

	var/object_size = 0
	var/matter_increase = 0
	var/damage_increase = 0

	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		object_size = consumed_mob.mob_size + 2
		message_admins("[atom_source] has consumed [key_name_admin(consumed_mob)] [ADMIN_JMP(atom_source)].")
		atom_source.investigate_log("has consumed [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.investigate_log("has been dusted by [atom_source].", INVESTIGATE_DEATHS)
		if(istype(consumed_mob, /mob/living/basic/parrot/poly)) // Dusting Poly creates a power surge
			force_event(/datum/round_event_control/supermatter_surge/poly, "Poly's revenge")
			notify_ghosts(
				"[consumed_mob] has been dusted by [atom_source]!",
				source = atom_source,
				header = "Polytechnical Difficulties",
			)
		consumed_mob.dust(force = TRUE)
		matter_increase += 100 * object_size
		if(is_clown_job(consumed_mob.mind?.assigned_role))
			damage_increase += rand(-30, 30) // HONK
		consume_returns(matter_increase, damage_increase)
	else if(isobj(consumed_object))
		if(!iseffect(consumed_object))
			var/suspicion = ""
			if(consumed_object.fingerprintslast)
				suspicion = "last touched by [consumed_object.fingerprintslast]"
				message_admins("[atom_source] has consumed [consumed_object], [suspicion] [ADMIN_JMP(atom_source)].")
			atom_source.investigate_log("has consumed [consumed_object] - [suspicion].", INVESTIGATE_ENGINE)
		qdel(consumed_object)
	if(!iseffect(consumed_object) && !isliving(consumed_object))
		if(isitem(consumed_object))
			var/obj/item/consumed_item = consumed_object
			object_size = consumed_item.w_class
			matter_increase += 70 * object_size
		else
			matter_increase += min(0.5 * consumed_object.max_integrity, 1000)

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(atom_source, max_range = 6, threshold = 1.2 / max(object_size, 1), chance = 10 * object_size)
	for(var/mob/living/near_mob in range(10))
		atom_source.investigate_log("has irradiated [key_name(near_mob)] after consuming [consumed_object].", INVESTIGATE_ENGINE)
		if (HAS_TRAIT(near_mob, TRAIT_RADIMMUNE) || issilicon(near_mob))
			continue
		if(ishuman(near_mob) && SSradiation.wearing_rad_protected_clothing(near_mob))
			continue
		if(near_mob in view())
			near_mob.show_message(span_danger("As \the [atom_source] slowly stops resonating, you find your skin covered in new radiation burns."), MSG_VISUAL,
				span_danger("The unearthly ringing subsides and you find your skin covered in new radiation burns."), MSG_AUDIBLE)
		else
			near_mob.show_message(span_hear("An unearthly ringing fills your ears, and you find your skin covered in new radiation burns."), MSG_AUDIBLE)
	consume_returns(matter_increase, damage_increase)
	var/obj/machinery/power/supermatter_crystal/our_crystal = parent
	if(istype(our_crystal))
		our_crystal.log_activation(who = consumed_object)

/datum/component/supermatter_crystal/proc/consume_returns(matter_increase = 0, damage_increase = 0)
	if(consume_callback)
		consume_callback.Invoke(matter_increase, damage_increase)
