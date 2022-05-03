/// Consume things that run into the supermatter from the tram. The tram calls forceMove (doesn't call Bump/ed) and not Move, and I'm afraid changing it will do something chaotic
/obj/machinery/power/supermatter_crystal/proc/tram_contents_consume(datum/source, list/tram_contents)
	SIGNAL_HANDLER

	for(var/atom/thing_to_consume as anything in tram_contents)
		Bumped(thing_to_consume)

/obj/machinery/power/supermatter_crystal/bullet_act(obj/projectile/projectile)
	var/turf/local_turf = loc
	var/kiss_power = 0
	switch(projectile.type)
		if(/obj/projectile/kiss)
			kiss_power = 60
		if(/obj/projectile/kiss/death)
			kiss_power = 20000
	if(!istype(local_turf))
		return FALSE
	if(!istype(projectile.firer, /obj/machinery/power/emitter) && power_changes)
		investigate_log("has been hit by [projectile] fired by [key_name(projectile.firer)]", INVESTIGATE_ENGINE)
	if(projectile.armor_flag != BULLET || kiss_power)
		if(kiss_power)
			psyCoeff = 1
			psy_overlay = TRUE
		if(power_changes) //This needs to be here I swear
			power += projectile.damage * bullet_energy + kiss_power
			if(!has_been_powered)
				var/fired_from_str = projectile.fired_from ? " with [projectile.fired_from]" : ""
				investigate_log(
					projectile.firer \
						? "has been powered for the first time by [key_name(projectile.firer)][fired_from_str]." \
						: "has been powered for the first time.",
					INVESTIGATE_ENGINE
				)
				message_admins(
					projectile.firer \
						? "[src] [ADMIN_JMP(src)] has been powered for the first time by [ADMIN_FULLMONTY(projectile.firer)][fired_from_str]." \
						: "[src] [ADMIN_JMP(src)] has been powered for the first time."
				)
				has_been_powered = TRUE
	else if(takes_damage)
		damage += (projectile.damage * bullet_energy) * clamp((emergency_point - damage) / emergency_point, 0, 1)
		if(damage > damage_penalty_point)
			visible_message(span_notice("[src] compresses under stress, resisting further impacts!"))
	return BULLET_ACT_HIT

/obj/machinery/power/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("consumed by singularity.", INVESTIGATE_ENGINE)
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message(span_userdanger("[src] is consumed by the singularity!"))
	for(var/mob/hearing_mob as anything in GLOB.player_list)
		if(hearing_mob.z != z)
			continue
		SEND_SOUND(hearing_mob, 'sound/effects/supermatter.ogg') //everyone goan know bout this
		to_chat(hearing_mob, span_boldannounce("A horrible screeching fills your ears, and a wave of dread washes over you..."))
	qdel(src)
	return gain

/obj/machinery/power/supermatter_crystal/blob_act(obj/structure/blob/blob)
	if(!blob || isspaceturf(loc)) //does nothing in space
		return
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	damage += blob.get_integrity() * 0.5 //take damage equal to 50% of remaining blob health before it tried to eat us
	if(blob.get_integrity() > 100)
		blob.visible_message(span_danger("\The [blob] strikes at \the [src] and flinches away!"),
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
		blob.take_damage(100, BURN)
	else
		blob.visible_message(span_danger("\The [blob] strikes at \the [src] and rapidly flashes to ash."),
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
		Consume(blob)

/obj/machinery/power/supermatter_crystal/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a really dense idea."))
	jedi.ghostize()
	var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in jedi.internal_organs
	if(rip_u)
		rip_u.Remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/machinery/power/supermatter_crystal/attack_paw(mob/user, list/modifiers)
	dust_mob(user, cause = "monkey attack")

/obj/machinery/power/supermatter_crystal/attack_alien(mob/user, list/modifiers)
	dust_mob(user, cause = "alien attack")

/obj/machinery/power/supermatter_crystal/attack_animal(mob/living/simple_animal/user, list/modifiers)
	var/murder
	if(!user.melee_damage_upper && !user.melee_damage_lower)
		murder = user.friendly_verb_continuous
	else
		murder = user.attack_verb_continuous
	dust_mob(user, \
	span_danger("[user] unwisely [murder] [src], and [user.p_their()] body burns brilliantly before flashing into ash!"), \
	span_userdanger("You unwisely touch [src], and your vision glows brightly as your body crumbles to dust. Oops."), \
	"simple animal attack")

/obj/machinery/power/supermatter_crystal/attack_robot(mob/user)
	if(Adjacent(user))
		dust_mob(user, cause = "cyborg attack")

/obj/machinery/power/supermatter_crystal/attack_ai(mob/user)
	return

/obj/machinery/power/supermatter_crystal/attack_hulk(mob/user)
	dust_mob(user, cause = "hulk attack")

/obj/machinery/power/supermatter_crystal/attack_larva(mob/user)
	dust_mob(user, cause = "larva attack")

/obj/machinery/power/supermatter_crystal/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.incorporeal_move || user.status_flags & GODMODE)
		return

	. = TRUE
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		dust_mob(user, cause = "hand")
		return

	if(!user.is_mouth_covered())
		if(user.combat_mode)
			dust_mob(user,
				span_danger("As [user] tries to take a bite out of [src] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash."),
				span_userdanger("You try to take a bite out of [src], but find [p_them()] far too hard to get anywhere before everything starts burning and your ears fill with ringing!"),
				"attempted bite"
			)
			return

		var/obj/item/organ/tongue/licking_tongue = user.getorganslot(ORGAN_SLOT_TONGUE)
		if(licking_tongue)
			dust_mob(user,
				span_danger("As [user] hesitantly leans in and licks [src] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash!"),
				span_userdanger("You tentatively lick [src], but you can't figure out what it tastes like before everything starts burning and your ears fill with ringing!"),
				"attempted lick"
			)
			return

	var/obj/item/bodypart/head/forehead = user.get_bodypart(BODY_ZONE_HEAD)
	if(forehead)
		dust_mob(user,
			span_danger("As [user]'s forehead bumps into [src], inducing a resonance... Everything goes silent before [user.p_their()] [forehead] flashes to ash!"),
			span_userdanger("You feel your forehead bump into [src] and everything suddenly goes silent. As your head fills with ringing you come to realize that that was not a wise decision."),
			"failed lick"
		)
		return

	dust_mob(user,
		span_danger("[user] leans in and tries to lick [src], inducing a resonance... [user.p_their()] body starts to glow and burst into flames before flashing into dust!"),
		span_userdanger("You lean in and try to lick [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\""),
		"failed lick"
	)


/obj/machinery/power/supermatter_crystal/proc/dust_mob(mob/living/nom, vis_msg, mob_msg, cause)
	if(nom.incorporeal_move || nom.status_flags & GODMODE) //try to keep supermatter sliver's + hemostat's dust conditions in sync with this too
		return
	if(!vis_msg)
		vis_msg = span_danger("[nom] reaches out and touches [src], inducing a resonance... [nom.p_their()] body starts to glow and burst into flames before flashing into dust!")
	if(!mob_msg)
		mob_msg = span_userdanger("You reach out and touch [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	investigate_log("has been attacked ([cause]) by [key_name(nom)]", INVESTIGATE_ENGINE)
	add_memory_in_range(src, 7, MEMORY_SUPERMATTER_DUSTED, list(DETAIL_PROTAGONIST = nom, DETAIL_WHAT_BY = src), story_value = STORY_VALUE_OKAY, memory_flags = MEMORY_CHECK_BLIND_AND_DEAF)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(nom)

/obj/machinery/power/supermatter_crystal/attackby(obj/item/item, mob/living/user, params)
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
			user.visible_message(span_danger("The [item] flashes out of existence on contact with \the [src], resonating with a horrible sound..."),\
				span_danger("Oops! The [item] flashes out of existence on contact with \the [src], taking your arm with it! That was clumsy of you!"))
			playsound(src, 'sound/effects/supermatter.ogg', 150, TRUE)
			Consume(dust_arm)
			qdel(item)
			return
		if(cig.lit || user.combat_mode)
			user.visible_message(span_danger("A hideous sound echoes as [item] is ashed out on contact with \the [src]. That didn't seem like a good idea..."))
			playsound(src, 'sound/effects/supermatter.ogg', 150, TRUE)
			Consume(item)
			radiation_pulse(src, max_range = 3, threshold = 0.1, chance = 50)
			return ..()
		else
			cig.light()
			user.visible_message(span_danger("As [user] lights \their [item] on \the [src], silence fills the room..."),\
				span_danger("Time seems to slow to a crawl as you touch \the [src] with \the [item].</span>\n<span class='notice'>\The [item] flashes alight with an eerie energy as you nonchalantly lift your hand away from \the [src]. Damn."))
			playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
			radiation_pulse(src, max_range = 1, threshold = 0, chance = 100)
			return
	if(istype(item, /obj/item/scalpel/supermatter))
		var/obj/item/scalpel/supermatter/scalpel = item
		to_chat(user, span_notice("You carefully begin to scrape \the [src] with \the [item]..."))
		if(item.use_tool(src, user, 60, volume=100))
			if (scalpel.usesLeft)
				to_chat(user, span_danger("You extract a sliver from \the [src]. \The [src] begins to react violently!"))
				new /obj/item/nuke_core/supermatter_sliver(drop_location())
				matter_power += 800
				scalpel.usesLeft--
				if (!scalpel.usesLeft)
					to_chat(user, span_notice("A tiny piece of \the [item] falls off, rendering it useless!"))
			else
				to_chat(user, span_warning("You fail to extract a sliver from \The [src]! \the [item] isn't sharp enough anymore."))
	else if(user.dropItemToGround(item))
		user.visible_message(span_danger("As [user] touches \the [src] with \a [item], silence fills the room..."),\
			span_userdanger("You touch \the [src] with \the [item], and everything suddenly goes silent.</span>\n<span class='notice'>\The [item] flashes into dust as you flinch away from \the [src]."),\
			span_hear("Everything suddenly goes silent."))
		investigate_log("has been attacked ([item]) by [key_name(user)]", INVESTIGATE_ENGINE)
		Consume(item)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)

		radiation_pulse(src, max_range = 3, threshold = 0.1, chance = 50)

	else if(Adjacent(user)) //if the item is stuck to the person, kill the person too instead of eating just the item.
		var/vis_msg = span_danger("[user] reaches out and touches [src] with [item], inducing a resonance... [item] starts to glow briefly before the light continues up to [user]'s body. [user.p_they(TRUE)] bursts into flames before flashing into dust!")
		var/mob_msg = span_userdanger("You reach out and touch [src] with [item]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
		dust_mob(user, vis_msg, mob_msg)

/obj/machinery/power/supermatter_crystal/wrench_act(mob/user, obj/item/tool)
	. = ..()
	if (moveable)
		default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/supermatter_crystal/Bumped(atom/movable/hit_object)
	if(isliving(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] slams into \the [src] inducing a resonance... [hit_object.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	else if(isobj(hit_object) && !iseffect(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] smacks into \the [src] and rapidly flashes to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(hit_object)

/obj/machinery/power/supermatter_crystal/Bump(atom/bumped_atom)
	. = ..()
	if(isturf(bumped_atom))
		var/turf/bumped_turf = bumped_atom
		var/bumped_name = "\the [bumped_atom]"
		var/bumped_text = span_danger("\The [src] smacks into [bumped_name] and [bumped_atom.p_they()] rapidly flashes to ash!")
		if(!bumped_turf.Melt())
			return

		visible_message(
			bumped_text,
			null,
			span_hear("You hear a loud crack as you are washed with a wave of heat.")
		)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)

		var/suspicion = null
		if (fingerprintslast)
			suspicion = "- and was last touched by [fingerprintslast]"
			message_admins("\The [src] has consumed [bumped_name][suspicion].")
		investigate_log("has consumed [bumped_name][suspicion].")

		radiation_pulse(src, max_range = 6, threshold = 0.2, chance = 50)
		return

	if(isliving(bumped_atom))
		visible_message(
			span_danger("\The [src] slams into \the [bumped_atom] inducing a resonance... [bumped_atom.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("\The [src] slams into you as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you.")
		)
	else if(isobj(bumped_atom) && !iseffect(bumped_atom))
		visible_message(
			span_danger("\The [src] smacks into \the [bumped_atom] and [bumped_atom.p_they()] rapidly flashes to ash."),
			null,
			span_hear("You hear a loud crack as you are washed with a wave of heat.")
		)
	else
		return

	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(bumped_atom)

/obj/machinery/power/supermatter_crystal/intercept_zImpact(list/falling_movables, levels)
	. = ..()
	for(var/atom/movable/hit_object as anything in falling_movables)
		Bumped(hit_object)
	. |= FALL_STOP_INTERCEPTING | FALL_INTERCEPTED

/obj/machinery/power/supermatter_crystal/proc/Consume(atom/movable/consumed_object)
	var/object_size
	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		object_size = consumed_mob.mob_size + 2
		if(consumed_mob.status_flags & GODMODE)
			return
		message_admins("[src] has consumed [key_name_admin(consumed_mob)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.dust(force = TRUE)
		if(power_changes)
			matter_power += 100 * object_size
		if(takes_damage && is_clown_job(consumed_mob.mind?.assigned_role))
			damage += rand(-300, 300) // HONK
			damage = max(damage, 0)
	else if(consumed_object.flags_1 & SUPERMATTER_IGNORES_1)
		return
	else if(isobj(consumed_object))
		if(!iseffect(consumed_object))
			var/suspicion = ""
			if(consumed_object.fingerprintslast)
				suspicion = "last touched by [consumed_object.fingerprintslast]"
				message_admins("[src] has consumed [consumed_object], [suspicion] [ADMIN_JMP(src)].")
			investigate_log("has consumed [consumed_object] - [suspicion].", INVESTIGATE_ENGINE)
		qdel(consumed_object)
	if(!iseffect(consumed_object) && isitem(consumed_object) && power_changes)
		var/obj/item/consumed_item = consumed_object
		object_size = consumed_item.w_class
		matter_power += 70 * object_size

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(src, max_range = 6, threshold = 1.2 / object_size, chance = 10 * object_size)
	for(var/mob/living/near_mob in range(10))
		investigate_log("has irradiated [key_name(near_mob)] after consuming [consumed_object].", INVESTIGATE_ENGINE)
		if (HAS_TRAIT(near_mob, TRAIT_RADIMMUNE) || issilicon(near_mob))
			continue
		if(ishuman(near_mob) && SSradiation.wearing_rad_protected_clothing(near_mob))
			continue
		if(near_mob in view())
			near_mob.show_message(span_danger("As \the [src] slowly stops resonating, you find your skin covered in new radiation burns."), MSG_VISUAL,
				span_danger("The unearthly ringing subsides and you find your skin covered in new radiation burns."), MSG_AUDIBLE)
		else
			near_mob.show_message(span_hear("An unearthly ringing fills your ears, and you find your skin covered in new radiation burns."), MSG_AUDIBLE)
//Do not blow up our internal radio
/obj/machinery/power/supermatter_crystal/contents_explosion(severity, target)
	return
