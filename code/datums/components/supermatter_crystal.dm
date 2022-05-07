/datum/component/supermatter_crystal

	///Callback for the wrench act call
	var/datum/callback/tool_act_callback
	///Callback used by the SM to get the damage and matter power increase/decrease
	var/datum/callback/consume_callback

/datum/component/supermatter_crystal/Initialize(datum/callback/tool_act_callback, datum/callback/consume_callback)

	RegisterSignal(parent, COMSIG_ATOM_BLOB_ACT, .proc/blob_hit)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_PAW, .proc/paw_hit)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, .proc/animal_hit)
	RegisterSignal(parent, COMSIG_ATOM_HULK_ATTACK, .proc/hulk_hit)
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, .proc/unarmed_hit)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/hand_hit)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby_hit)
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), .proc/tool_hit)
	RegisterSignal(parent, COMSIG_ATOM_BUMPED, .proc/bumped_hit)
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, .proc/bump_hit)
	RegisterSignal(parent, COMSIG_ATOM_INTERCEPT_Z_FALL, .proc/intercept_z_fall)

	src.tool_act_callback = tool_act_callback
	src.consume_callback = consume_callback

/datum/component/supermatter_crystal/UnregisterFromParent(force, silent)
	var/list/signals_to_remove = list(
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH),
		COMSIG_ATOM_BUMPED,
		COMSIG_MOVABLE_BUMP,
		COMSIG_ATOM_INTERCEPT_Z_FALL,
	)

	UnregisterSignal(parent, signals_to_remove)

/datum/component/supermatter_crystal/proc/blob_hit(datum/source, obj/structure/blob/blob)
	SIGNAL_HANDLER
	var/atom/atom_source = source
	if(!blob || isspaceturf(atom_source)) //does nothing in space
		return
	playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume_returns(damage_increase = blob.get_integrity() * 0.5)
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
	if(isalien(user))
		dust_mob(source, user, cause = "alien attack")
		return
	dust_mob(source, user, cause = "monkey attack")

/datum/component/supermatter_crystal/proc/animal_hit(datum/source, mob/living/simple_animal/user, list/modifiers)
	SIGNAL_HANDLER
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
	var/atom/atom_source = source
	if(user.incorporeal_move || user.status_flags & GODMODE)
		return

	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		dust_mob(source, user, cause = "hand")
		return

	if(!user.is_mouth_covered())
		if(user.combat_mode)
			dust_mob(source, user,
				span_danger("As [user] tries to take a bite out of [atom_source] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash."),
				span_userdanger("You try to take a bite out of [atom_source], but find [p_them()] far too hard to get anywhere before everything starts burning and your ears fill with ringing!"),
				"attempted bite"
			)
			return

		var/obj/item/organ/tongue/licking_tongue = user.getorganslot(ORGAN_SLOT_TONGUE)
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
	if(istype(item, /obj/item/melee/roastingstick))
		return FALSE
	if(istype(item, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/cig = item
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
		var/vis_msg = span_danger("[user] reaches out and touches [atom_source] with [item], inducing a resonance... [item] starts to glow briefly before the light continues up to [user]'s body. [user.p_they(TRUE)] bursts into flames before flashing into dust!")
		var/mob_msg = span_userdanger("You reach out and touch [atom_source] with [item]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
		dust_mob(source, user, vis_msg, mob_msg)

/datum/component/supermatter_crystal/proc/tool_hit(datum/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(tool_act_callback)
		tool_act_callback.Invoke(user, tool)
		return
	attackby_hit(source, tool, user)

/datum/component/supermatter_crystal/proc/bumped_hit(datum/source, atom/movable/hit_object)
	SIGNAL_HANDLER
	var/atom/atom_source = source
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

/datum/component/supermatter_crystal/proc/bump_hit(datum/source, atom/bumped_atom)
	SIGNAL_HANDLER
	var/atom/atom_source = source
	if(isturf(bumped_atom))
		var/turf/bumped_turf = bumped_atom
		var/bumped_name = "\the [bumped_atom]"
		var/bumped_text = span_danger("\The [atom_source] smacks into [bumped_name] and [bumped_atom.p_they()] rapidly flashes to ash!")
		if(!bumped_turf.Melt())
			return

		atom_source.visible_message(
			bumped_text,
			null,
			span_hear("You hear a loud crack as you are washed with a wave of heat.")
		)
		playsound(atom_source, 'sound/effects/supermatter.ogg', 50, TRUE)

		var/suspicion = null
		if (atom_source.fingerprintslast)
			suspicion = "- and was last touched by [atom_source.fingerprintslast]"
			message_admins("\The [atom_source] has consumed [bumped_name][suspicion].")
		atom_source.investigate_log("has consumed [bumped_name][suspicion].")

		radiation_pulse(atom_source, max_range = 6, threshold = 0.2, chance = 50)
		return

	if(isliving(bumped_atom))
		atom_source.visible_message(
			span_danger("\The [atom_source] slams into \the [bumped_atom] inducing a resonance... [bumped_atom.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("\The [atom_source] slams into you as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you.")
		)
	else if(isobj(bumped_atom) && !iseffect(bumped_atom))
		atom_source.visible_message(
			span_danger("\The [atom_source] smacks into \the [bumped_atom] and [bumped_atom.p_they()] rapidly flashes to ash."),
			null,
			span_hear("You hear a loud crack as you are washed with a wave of heat.")
		)
	else
		return

	playsound(atom_source, 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(atom_source, bumped_atom)

/datum/component/supermatter_crystal/proc/intercept_z_fall(datum/source, list/falling_movables, levels)
	SIGNAL_HANDLER
	for(var/atom/movable/hit_object as anything in falling_movables)
		bumped_hit(hit_object)

/datum/component/supermatter_crystal/proc/dust_mob(datum/source, mob/living/nom, vis_msg, mob_msg, cause)
	var/atom/atom_source = source
	if(nom.incorporeal_move || nom.status_flags & GODMODE) //try to keep supermatter sliver's + hemostat's dust conditions in sync with this too
		return
	if(!vis_msg)
		vis_msg = span_danger("[nom] reaches out and touches [atom_source], inducing a resonance... [nom.p_their()] body starts to glow and burst into flames before flashing into dust!")
	if(!mob_msg)
		mob_msg = span_userdanger("You reach out and touch [atom_source]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	atom_source.investigate_log("has been attacked ([cause]) by [key_name(nom)]", INVESTIGATE_ENGINE)
	add_memory_in_range(atom_source, 7, MEMORY_SUPERMATTER_DUSTED, list(DETAIL_PROTAGONIST = nom, DETAIL_WHAT_BY = atom_source), story_value = STORY_VALUE_OKAY, memory_flags = MEMORY_CHECK_BLIND_AND_DEAF)
	playsound(get_turf(atom_source), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(atom_source, nom)

/datum/component/supermatter_crystal/proc/consume(atom/source, atom/movable/consumed_object)
	var/atom/atom_source = source
	var/object_size = 0
	var/matter_increase = 0
	var/damage_increase = 0
	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		object_size = consumed_mob.mob_size + 2
		if(consumed_mob.status_flags & GODMODE)
			return
		message_admins("[atom_source] has consumed [key_name_admin(consumed_mob)] [ADMIN_JMP(atom_source)].")
		atom_source.investigate_log("has consumed [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.dust(force = TRUE)
		matter_increase += 100 * object_size
		if(is_clown_job(consumed_mob.mind?.assigned_role))
			damage_increase += rand(-300, 300) // HONK
		consume_returns(matter_increase, damage_increase)
	else if(consumed_object.flags_1 & SUPERMATTER_IGNORES_1)
		return
	else if(isobj(consumed_object))
		if(!iseffect(consumed_object))
			var/suspicion = ""
			if(consumed_object.fingerprintslast)
				suspicion = "last touched by [consumed_object.fingerprintslast]"
				message_admins("[atom_source] has consumed [consumed_object], [suspicion] [ADMIN_JMP(atom_source)].")
			atom_source.investigate_log("has consumed [consumed_object] - [suspicion].", INVESTIGATE_ENGINE)
		qdel(consumed_object)
	if(!iseffect(consumed_object) && isitem(consumed_object))
		var/obj/item/consumed_item = consumed_object
		object_size = consumed_item.w_class
		matter_increase += 70 * object_size

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

/datum/component/supermatter_crystal/proc/consume_returns(matter_increase = 0, damage_increase = 0)
	if(consume_callback)
		consume_callback.Invoke(matter_increase, damage_increase)
