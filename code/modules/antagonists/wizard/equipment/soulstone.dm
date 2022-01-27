/obj/item/soulstone
	name = "soulstone shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	layer = HIGH_OBJ_LAYER
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefact's power."
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	var/one_use = FALSE
	var/grab_sleeping = TRUE
	var/spent = FALSE
	/// This controls the color of the soulstone as well as restrictions for who can use it. THEME_CULT is red and is the default of cultist THEME_WIZARD is purple and is the default of wizard and THEME_HOLY is for purified soul stone
	var/theme = THEME_CULT
	/// Role check, if any needed
	var/required_role = /datum/antagonist/cult

/obj/item/soulstone/Initialize(mapload)
	. = ..()
	if(theme != THEME_HOLY)
		RegisterSignal(src, COMSIG_BIBLE_SMACKED, .proc/on_bible_smacked)

///signal called whenever a soulstone is smacked by a bible
/obj/item/soulstone/proc/on_bible_smacked(datum/source, mob/living/user, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/attempt_exorcism, user)

/**
 * attempt_exorcism: called from on_bible_smacked, takes time and if successful
 * resets the item to a pre-possessed state
 *
 * Arguments:
 * * exorcist: user who is attempting to remove the spirit
 */
/obj/item/soulstone/proc/attempt_exorcism(mob/exorcist)
	if(IS_CULTIST(exorcist) || theme == THEME_HOLY)
		return
	balloon_alert(exorcist, span_notice("exorcising [src]..."))
	playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,TRUE)
	if(!do_after(exorcist, 4 SECONDS, target = src))
		return
	playsound(src,'sound/effects/pray_chaplain.ogg',60,TRUE)
	required_role = null
	theme = THEME_HOLY
	icon_state = "purified_soulstone"
	for(var/mob/mob_cultist in contents)
		if(!mob_cultist.mind)
			continue
		icon_state = "purified_soulstone2"
		mob_cultist.mind.remove_antag_datum(/datum/antagonist/cult)
	for(var/mob/living/simple_animal/shade/sharded_shade in src)
		sharded_shade.icon_state = "ghost1"
		sharded_shade.name = "Purified [initial(sharded_shade.name)]"
	exorcist.visible_message(span_notice("[exorcist] purifies [src]!"))
	UnregisterSignal(src, COMSIG_BIBLE_SMACKED)

/obj/item/soulstone/proc/role_check(mob/who)
	return required_role ? (who.mind && who.mind.has_antag_datum(required_role, TRUE)) : TRUE

/obj/item/soulstone/proc/was_used()
	if(one_use)
		spent = TRUE
		name = "dull [name]"
		desc = "A fragment of the legendary treasure known simply as \
			the 'Soul Stone'. The shard lies still, dull and lifeless; \
			whatever spark it once held long extinguished."

/obj/item/soulstone/anybody
	required_role = null

/obj/item/soulstone/mystic
	icon_state = "mystic_soulstone"
	theme = THEME_WIZARD
	required_role = /datum/antagonist/wizard

/obj/item/soulstone/anybody/revolver
	one_use = TRUE
	grab_sleeping = FALSE

/obj/item/soulstone/anybody/purified
	icon_state = "purified_soulstone"
	theme = THEME_HOLY

/obj/item/soulstone/anybody/chaplain
	name = "mysterious old shard"
	one_use = TRUE
	grab_sleeping = FALSE

/obj/item/soulstone/anybody/chaplain/sparring
	icon_state = "purified_soulstone"
	theme = THEME_HOLY

/obj/item/soulstone/anybody/sparring/Initialize(mapload)
	. = ..()
	name = "[GLOB.deity]'s punishment"
	desc = "A prison for those who lost [GLOB.deity]'s game."

/obj/item/soulstone/anybody/mining
	grab_sleeping = FALSE

/obj/item/soulstone/pickup(mob/living/user)
	..()
	if(!role_check(user))
		to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you pick up [src]. It would be wise to be rid of this quickly."))

/obj/item/soulstone/examine(mob/user)
	. = ..()
	if(role_check(user) || isobserver(user))
		if(!grab_sleeping)
			. += span_cult("A soulstone, used to capture a soul, either from dead humans or from freed shades.")
		else
			. += span_cult("A soulstone, used to capture souls, either from unconscious or sleeping humans or from freed shades.")
		. += span_cult("The captured soul can be placed into a construct shell to produce a construct, or released from the stone as a shade.")
		if(spent)
			. += span_cult("This shard is spent; it is now just a creepy rock.")

/obj/item/soulstone/Destroy() //Stops the shade from being qdel'd immediately and their ghost being sent back to the arrival shuttle.
	for(var/mob/living/simple_animal/shade/shade in src)
		INVOKE_ASYNC(shade, /mob/living/proc/death)
	return ..()

/obj/item/soulstone/proc/hot_potato(mob/living/user)
	to_chat(user, span_userdanger("Holy magics residing in \the [src] burn your hand!"))
	var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
	affecting.receive_damage( 0, 10 ) // 10 burn damage
	user.emote("scream")
	user.update_damage_overlays()
	user.dropItemToGround(src)

//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/soulstone/attack(mob/living/carbon/human/M, mob/living/user)
	if(!role_check(user))
		user.Unconscious(100)
		to_chat(user, span_userdanger("Your body is wracked with debilitating pain!"))
		return
	if(spent)
		to_chat(user, span_warning("There is no power left in [src]."))
		return
	if(!ishuman(M))//If target is not a human.
		return ..()
	if(IS_CULTIST(M) && IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"Come now, do not capture your bretheren's soul.\""))
		return
	if(theme == THEME_HOLY && IS_CULTIST(user))
		hot_potato(user)
		return
	if(HAS_TRAIT(M, TRAIT_NO_SOUL))
		to_chat(user, span_warning("This body does not possess a soul to capture."))
		return
	log_combat(user, M, "captured [M.name]'s soul", src)
	capture_soul(M, user)

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/soulstone/attack_self(mob/living/user)
	if(!in_range(src, user))
		return
	if(!role_check(user))
		user.Unconscious(100)
		to_chat(user, span_userdanger("Your body is wracked with debilitating pain!"))
		return
	if(theme == THEME_HOLY && IS_CULTIST(user))
		hot_potato(user)
		return
	release_shades(user)

/obj/item/soulstone/proc/release_shades(mob/user, silent = FALSE)
	for(var/mob/living/simple_animal/shade/A in src)
		A.forceMove(get_turf(user))
		A.cancel_camera()
		switch(theme)
			if(THEME_HOLY)
				icon_state = "purified_soulstone"
				A.icon_state = "shade_holy"
				A.name = "Purified [initial(A.name)]"
				A.loot = list(/obj/item/ectoplasm/angelic)
			if(THEME_WIZARD)
				icon_state = "mystic_soulstone"
				A.icon_state = "shade_wizard"
				A.loot = list(/obj/item/ectoplasm/mystic)
			if(THEME_CULT)
				icon_state = "soulstone"
		name = initial(name)
		if(!silent)
			if(IS_CULTIST(user))
				to_chat(A, "<b>You have been released from your prison, but you are still bound to the cult's will. Help them succeed in their goals at all costs.</b>")
			else if(role_check(user))
				to_chat(A, "<b>You have been released from your prison, but you are still bound to [user.real_name]'s will. Help [user.p_them()] succeed in [user.p_their()] goals at all costs.</b>")
		was_used()

/obj/item/soulstone/pre_attack(atom/A, mob/living/user, params)
	var/mob/living/simple_animal/shade/occupant = (locate() in src)
	var/obj/item/storage/toolbox/mechanical/target_toolbox = A
	if(!occupant || !istype(target_toolbox) || target_toolbox.has_soul)
		return ..()

	if(theme == THEME_HOLY && IS_CULTIST(user))
		hot_potato(user)
		return
	if(!role_check(user))
		user.Unconscious(10 SECONDS)
		to_chat(user, span_userdanger("Your body is wracked with debilitating pain!"))
		return

	user.visible_message("<span class='notice'>[user] holds [src] above [user.p_their()] head and forces it into [target_toolbox] with a flash of light!", \
		span_notice("You hold [src] above your head briefly, then force it into [target_toolbox], transferring the [occupant]'s soul!"), ignored_mobs = occupant)
	to_chat(occupant, span_userdanger("[user] holds you up briefly, then forces you into [target_toolbox]!"))
	to_chat(occupant, span_deadsay("<b>Your eternal soul has been sacrificed to restore the soul of a toolbox. Them's the breaks!</b>"))

	occupant.client?.give_award(/datum/award/achievement/misc/toolbox_soul, occupant)
	occupant.deathmessage = "shrieks out in unholy pain as [occupant.p_their()] soul is absorbed into [target_toolbox]!"
	release_shades(user, TRUE)
	occupant.death()

	target_toolbox.name = "soulful toolbox"
	target_toolbox.icon = 'icons/obj/storage.dmi'
	target_toolbox.icon_state = "toolbox_blue_old"
	target_toolbox.has_soul = TRUE
	target_toolbox.has_latches = FALSE

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct_cult"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."

/obj/structure/constructshell/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || IS_WIZARD(user) || user.stat == DEAD)
		. += {"<span class='cult'>A construct shell, used to house bound souls from a soulstone.\n
		Placing a soulstone with a soul into this shell allows you to produce your choice of the following:\n
		An <b>Artificer</b>, which can produce <b>more shells and soulstones</b>, as well as fortifications.\n
		A <b>Wraith</b>, which does high damage and can jaunt through walls, though it is quite fragile.\n
		A <b>Juggernaut</b>, which is very hard to kill and can produce temporary walls, but is slow.</span>"}

/obj/structure/constructshell/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		if(!IS_CULTIST(user) && !IS_WIZARD(user) && !SS.theme == THEME_HOLY)
			to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you attempt to place [SS] into the shell. It would be wise to be rid of this quickly."))
			user.Dizzy(30)
			return
		if(SS.theme == THEME_HOLY && IS_CULTIST(user))
			SS.hot_potato(user)
			return
		SS.transfer_to_construct(src, user)
	else
		return ..()

/// Procs for moving soul in and out off stone

/// transfer the mind of a carbon mob (which is then dusted) into a shade mob inside src. If forced, sacrifical and stat checks are skipped.
/obj/item/soulstone/proc/capture_soul(mob/living/carbon/victim, mob/user, forced = FALSE)
	if(!iscarbon(victim)) //TODO: Add sacrifice stoning for non-organics, just because you have no body doesnt mean you dont have a soul
		return FALSE
	if(!forced)
		var/datum/antagonist/cult/C = user?.mind?.has_antag_datum(/datum/antagonist/cult,TRUE)
		if(C?.cult_team.is_sacrifice_target(victim.mind))
			to_chat(user, span_cult("<b>\"This soul is mine.</b></span> <span class='cultlarge'>SACRIFICE THEM!\""))
			return FALSE
	if(contents.len)
		return FALSE
	if(!forced && (grab_sleeping ? victim.stat == CONSCIOUS : victim.stat != DEAD))
		to_chat(user, "[span_userdanger("Capture failed!")]: Kill or maim the victim first!")
		return FALSE
	if(victim.client)
		victim.unequip_everything()
		init_shade(victim, user)
		return TRUE
	else
		to_chat(user, "[span_userdanger("Capture failed!")]: The soul has already fled its mortal frame. You attempt to bring it back...")
		INVOKE_ASYNC(src, .proc/getCultGhost, victim, user)
		return TRUE //it'll probably get someone ;)

///captures a shade that was previously released from a soulstone.
/obj/item/soulstone/proc/capture_shade(mob/living/simple_animal/shade/shade, mob/user)
	if(contents.len)
		to_chat(user, "[span_userdanger("Capture failed!")]: [src] is full! Free an existing soul to make room.")
		return FALSE
	shade.AddComponent(/datum/component/soulstoned, src)
	if(theme == THEME_HOLY)
		icon_state = "purified_soulstone2"
		shade.mind?.remove_antag_datum(/datum/antagonist/cult)
	if(theme == THEME_WIZARD)
		icon_state = "mystic_soulstone2"
	if(theme == THEME_CULT)
		icon_state = "soulstone2"
	name = "soulstone: Shade of [shade.real_name]"
	to_chat(shade, span_notice("Your soul has been captured by [src]. Its arcane energies are reknitting your ethereal form."))
	if(user != shade)
		to_chat(user, "[span_info("<b>Capture successful!</b>:")] [shade.real_name]'s soul has been captured and stored within [src].")
	return TRUE

///transfer the mind of the shade to a construct mob selected by the user, then deletes both the shade and src.
/obj/item/soulstone/proc/transfer_to_construct(obj/structure/constructshell/shell, mob/user)
	var/mob/living/simple_animal/shade/shade = locate() in src
	if(!shade)
		to_chat(user, "[span_userdanger("Creation failed!")]: [src] is empty! Go kill someone!")
		return FALSE
	var/construct_class = show_radial_menu(user, src, GLOB.construct_radial_images, custom_check = CALLBACK(src, .proc/check_menu, user, shell), require_near = TRUE, tooltips = TRUE)
	if(!shell || !construct_class)
		return FALSE
	make_new_construct_from_class(construct_class, theme, shade, user, FALSE, shell.loc)
	shade.mind?.remove_antag_datum(/datum/antagonist/cult)
	qdel(shell)
	qdel(src)
	return TRUE

/obj/item/soulstone/proc/check_menu(mob/user, obj/structure/constructshell/shell)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.is_holding(src) || !user.CanReach(shell, src))
		return FALSE
	return TRUE

/proc/make_new_construct_from_class(construct_class, theme, mob/target, mob/creator, cultoverride, loc_override)
	switch(construct_class)
		if(CONSTRUCT_JUGGERNAUT)
			if(IS_CULTIST(creator))
				makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut, target, creator, cultoverride, loc_override) // ignore themes, the actual giving of cult info is in the makeNewConstruct proc
				return
			switch(theme)
				if(THEME_WIZARD)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/mystic, target, creator, cultoverride, loc_override)
				if(THEME_HOLY)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/angelic, target, creator, cultoverride, loc_override)
				if(THEME_CULT)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/noncult, target, creator, cultoverride, loc_override)
		if(CONSTRUCT_WRAITH)
			if(IS_CULTIST(creator))
				makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith, target, creator, cultoverride, loc_override) // ignore themes, the actual giving of cult info is in the makeNewConstruct proc
				return
			switch(theme)
				if(THEME_WIZARD)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/mystic, target, creator, cultoverride, loc_override)
				if(THEME_HOLY)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/angelic, target, creator, cultoverride, loc_override)
				if(THEME_CULT)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/noncult, target, creator, cultoverride, loc_override)
		if(CONSTRUCT_ARTIFICER)
			if(IS_CULTIST(creator))
				makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer, target, creator, cultoverride, loc_override) // ignore themes, the actual giving of cult info is in the makeNewConstruct proc
				return
			switch(theme)
				if(THEME_WIZARD)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/mystic, target, creator, cultoverride, loc_override)
				if(THEME_HOLY)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/angelic, target, creator, cultoverride, loc_override)
				if(THEME_CULT)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/noncult, target, creator, cultoverride, loc_override)

/proc/makeNewConstruct(mob/living/simple_animal/hostile/construct/ctype, mob/target, mob/stoner = null, cultoverride = FALSE, loc_override = null)
	if(QDELETED(target))
		return
	var/mob/living/simple_animal/hostile/construct/newstruct = new ctype((loc_override) ? (loc_override) : (get_turf(target)))
	var/makeicon = newstruct.icon_state
	var/theme = newstruct.theme
	flick("make_[makeicon][theme]", newstruct)
	playsound(newstruct, 'sound/effects/constructform.ogg', 50)
	if(stoner)
		newstruct.faction |= "[REF(stoner)]"
		newstruct.master = stoner
		var/datum/action/innate/seek_master/SM = new()
		SM.Grant(newstruct)
	newstruct.key = target.key
	var/atom/movable/screen/alert/bloodsense/BS
	if(newstruct.mind && ((stoner && IS_CULTIST(stoner)) || cultoverride) && SSticker?.mode)
		newstruct.mind.add_antag_datum(/datum/antagonist/cult)
	if(IS_CULTIST(stoner) || cultoverride)
		to_chat(newstruct, "<b>You are still bound to serve the cult[stoner ? " and [stoner]":""], follow [stoner ? stoner.p_their() : "their"] orders and help [stoner ? stoner.p_them() : "them"] complete [stoner ? stoner.p_their() : "their"] goals at all costs.</b>")
	else if(stoner)
		to_chat(newstruct, "<b>You are still bound to serve your creator, [stoner], follow [stoner.p_their()] orders and help [stoner.p_them()] complete [stoner.p_their()] goals at all costs.</b>")
	newstruct.clear_alert("bloodsense")
	BS = newstruct.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	if(BS)
		BS.Cviewer = newstruct
	newstruct.cancel_camera()


/obj/item/soulstone/proc/init_shade(mob/living/carbon/human/victim, mob/user, message_user = FALSE, mob/shade_controller)
	if(!shade_controller)
		shade_controller = victim
	victim.stop_sound_channel(CHANNEL_HEARTBEAT)
	var/mob/living/simple_animal/shade/soulstone_spirit = new /mob/living/simple_animal/shade(src)
	soulstone_spirit.AddComponent(/datum/component/soulstoned, src)
	soulstone_spirit.name = "Shade of [victim.real_name]"
	soulstone_spirit.real_name = "Shade of [victim.real_name]"
	soulstone_spirit.key = shade_controller.key
	soulstone_spirit.copy_languages(victim, LANGUAGE_MIND)//Copies the old mobs languages into the new mob holder.
	if(user)
		soulstone_spirit.copy_languages(user, LANGUAGE_MASTER)
	soulstone_spirit.update_atom_languages()
	soulstone_spirit.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue
	if(user)
		soulstone_spirit.faction |= "[REF(user)]" //Add the master as a faction, allowing inter-mob cooperation
	if(user && IS_CULTIST(user))
		soulstone_spirit.mind.add_antag_datum(/datum/antagonist/cult)
	soulstone_spirit.cancel_camera()
	name = "soulstone: Shade of [victim.real_name]"
	switch(theme)
		if(THEME_HOLY)
			icon_state = "purified_soulstone2"
		if(THEME_WIZARD)
			icon_state = "mystic_soulstone2"
		if(THEME_CULT)
			icon_state = "soulstone2"
	if(user)
		if(IS_CULTIST(user))
			to_chat(soulstone_spirit, "Your soul has been captured! You are now bound to the cult's will. Help them succeed in their goals at all costs.")
		else if(role_check(user))
			to_chat(soulstone_spirit, "Your soul has been captured! You are now bound to [user.real_name]'s will. Help [user.p_them()] succeed in [user.p_their()] goals at all costs.")
		if(message_user)
			to_chat(user, "[span_info("<b>Capture successful!</b>:")] [victim.real_name]'s soul has been ripped from [victim.p_their()] body and stored within [src].")
	victim.dust()


/obj/item/soulstone/proc/getCultGhost(mob/living/carbon/victim, mob/user)
	var/mob/dead/observer/chosen_ghost

	chosen_ghost = victim.get_ghost(TRUE,TRUE) //Try to grab original owner's ghost first

	if(!chosen_ghost || !chosen_ghost.client) //Failing that, we grab a ghosts
		var/list/consenting_candidates = poll_ghost_candidates("Would you like to play as a Shade?", "Cultist", ROLE_CULTIST, 50, POLL_IGNORE_SHADE)
		if(consenting_candidates.len)
			chosen_ghost = pick(consenting_candidates)
	if(!victim || user.incapacitated() || !user.is_holding(src) || !user.CanReach(victim, src))
		return FALSE
	if(!chosen_ghost || !chosen_ghost.client)
		to_chat(user, span_danger("There were no spirits willing to become a shade."))
		return FALSE
	if(contents.len) //If they used the soulstone on someone else in the meantime
		return FALSE
	victim.unequip_everything()
	init_shade(victim, user, shade_controller = chosen_ghost)
	return TRUE
