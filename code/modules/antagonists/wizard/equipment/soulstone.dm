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
	var/old_shard = FALSE
	var/spent = FALSE
	/// This controls the color of the soulstone as well as restrictions for who can use it. THEME_CULT is red and is the default of cultist THEME_WIZARD is purple and is the default of wizard and THEME_HOLY is for purified soul stone
	var/theme = THEME_CULT
	/// Role check, if any needed
	var/required_role = /datum/antagonist/cult

/obj/item/soulstone/proc/role_check(mob/who)
	return required_role ? (who.mind && who.mind.has_antag_datum(required_role, TRUE)) : TRUE

/obj/item/soulstone/proc/was_used()
	if(old_shard)
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
	old_shard = TRUE

/obj/item/soulstone/anybody/purified
	icon_state = "purified_soulstone"
	theme = THEME_HOLY

/obj/item/soulstone/anybody/chaplain
	name = "mysterious old shard"
	old_shard = TRUE

/obj/item/soulstone/pickup(mob/living/user)
	..()
	if(!role_check(user))
		to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you pick up [src]. It would be wise to be rid of this quickly.</span>")

/obj/item/soulstone/examine(mob/user)
	. = ..()
	if(role_check(user) || isobserver(user))
		if (old_shard)
			. += "<span class='cult'>A soulstone, used to capture a soul, either from dead humans or from freed shades.</span>"
		else
			. += "<span class='cult'>A soulstone, used to capture souls, either from unconscious or sleeping humans or from freed shades.</span>"
		. += "<span class='cult'>The captured soul can be placed into a construct shell to produce a construct, or released from the stone as a shade.</span>"
		if(spent)
			. += "<span class='cult'>This shard is spent; it is now just a creepy rock.</span>"

/obj/item/soulstone/Destroy() //Stops the shade from being qdel'd immediately and their ghost being sent back to the arrival shuttle.
	for(var/mob/living/simple_animal/shade/A in src)
		A.death()
	return ..()

/obj/item/soulstone/proc/hot_potato(mob/living/user)
	to_chat(user, "<span class='userdanger'>Holy magics residing in \the [src] burn your hand!</span>")
	var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
	affecting.receive_damage( 0, 10 ) // 10 burn damage
	user.emote("scream")
	user.update_damage_overlays()
	user.dropItemToGround(src)

//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/soulstone/attack(mob/living/carbon/human/M, mob/living/user)
	if(!role_check(user))
		user.Unconscious(100)
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		return
	if(spent)
		to_chat(user, "<span class='warning'>There is no power left in [src].</span>")
		return
	if(!ishuman(M))//If target is not a human.
		return ..()
	if(iscultist(M) && iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"Come now, do not capture your bretheren's soul.\"</span>")
		return
	if(theme == THEME_HOLY && iscultist(user))
		hot_potato(user)
		return
	log_combat(user, M, "captured [M.name]'s soul", src)
	transfer_soul("VICTIM", M, user)

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/soulstone/attack_self(mob/living/user)
	if(!in_range(src, user))
		return
	if(!role_check(user))
		user.Unconscious(100)
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		return
	if(theme == THEME_HOLY && iscultist(user))
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
			if(iscultist(user))
				to_chat(A, "<b>You have been released from your prison, but you are still bound to the cult's will. Help them succeed in their goals at all costs.</b>")
			else if(role_check(user))
				to_chat(A, "<b>You have been released from your prison, but you are still bound to [user.real_name]'s will. Help [user.p_them()] succeed in [user.p_their()] goals at all costs.</b>")
		was_used()

/obj/item/soulstone/pre_attack(atom/A, mob/living/user, params)
	var/mob/living/simple_animal/shade/occupant = (locate() in src)
	var/obj/item/storage/toolbox/mechanical/target_toolbox = A
	if(!occupant || !istype(target_toolbox) || target_toolbox.has_soul)
		return ..()

	if(theme == THEME_HOLY && iscultist(user))
		hot_potato(user)
		return
	if(!role_check(user))
		user.Unconscious(10 SECONDS)
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		return

	user.visible_message("<span class='notice'>[user] holds [src] above [user.p_their()] head and forces it into [target_toolbox] with a flash of light!", \
		"<span class='notice'>You hold [src] above your head briefly, then force it into [target_toolbox], transferring the [occupant]'s soul!</span>", ignored_mobs = occupant)
	to_chat(occupant, "<span class='userdanger'>[user] holds you up briefly, then forces you into [target_toolbox]!</span>")
	to_chat(occupant, "<span class='deadsay'><b>Your eternal soul has been sacrificed to restore the soul of a toolbox. Them's the breaks!</b></span>")

	occupant.client?.give_award(/datum/award/achievement/misc/toolbox_soul, occupant)
	occupant.deathmessage = "shrieks out in unholy pain as [occupant.p_their()] soul is absorbed into [target_toolbox]!"
	release_shades(user, TRUE)
	occupant.death()

	target_toolbox.name = "soulful toolbox"
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
	if(iscultist(user) || iswizard(user) || user.stat == DEAD)
		. += {"<span class='cult'>A construct shell, used to house bound souls from a soulstone.\n
		Placing a soulstone with a soul into this shell allows you to produce your choice of the following:\n
		An <b>Artificer</b>, which can produce <b>more shells and soulstones</b>, as well as fortifications.\n
		A <b>Wraith</b>, which does high damage and can jaunt through walls, though it is quite fragile.\n
		A <b>Juggernaut</b>, which is very hard to kill and can produce temporary walls, but is slow.</span>"}

/obj/structure/constructshell/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		if(!iscultist(user) && !iswizard(user) && !SS.theme == THEME_HOLY)
			to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you attempt to place [SS] into the shell. It would be wise to be rid of this quickly.</span>")
			user.Dizzy(30)
			return
		if(SS.theme == THEME_HOLY && iscultist(user))
			SS.hot_potato(user)
			return
		SS.transfer_soul("CONSTRUCT",src,user)
		SS.was_used()
	else
		return ..()

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


/obj/item/soulstone/proc/transfer_soul(choice as text, target, mob/user)
	switch(choice)
		if("FORCE")
			if(!iscarbon(target)) //TODO: Add sacrifice stoning for non-organics, just because you have no body doesnt mean you dont have a soul
				return FALSE
			if(contents.len)
				return FALSE
			var/mob/living/carbon/T = target
			if(T.client != null)
				for(var/obj/item/W in T)
					T.dropItemToGround(W)
				init_shade(T, user)
				return TRUE
			else
				to_chat(user, "<span class='userdanger'>Capture failed!</span>: The soul has already fled its mortal frame. You attempt to bring it back...")
				return getCultGhost(T,user)

		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/datum/antagonist/cult/C = user.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
			if(C?.cult_team.is_sacrifice_target(T.mind))
				if(iscultist(user))
					to_chat(user, "<span class='cult'><b>\"This soul is mine.</b></span> <span class='cultlarge'>SACRIFICE THEM!\"</span>")
				else
					to_chat(user, "<span class='danger'>[src] seems to reject this soul.</span>")
				return FALSE
			if(contents.len)
				to_chat(user, "<span class='userdanger'>Capture failed!</span>: [src] is full! Free an existing soul to make room.")
			else
				if((!old_shard && T.stat != CONSCIOUS) || (old_shard && T.stat == DEAD))
					if(T.client == null)
						to_chat(user, "<span class='userdanger'>Capture failed!</span>: The soul has already fled its mortal frame. You attempt to bring it back...")
						getCultGhost(T,user)
					else
						for(var/obj/item/W in T)
							T.dropItemToGround(W)
						init_shade(T, user, message_user = 1)
						qdel(T)
				else
					to_chat(user, "<span class='userdanger'>Capture failed!</span>: Kill or maim the victim first!")

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			if(contents.len)
				to_chat(user, "<span class='userdanger'>Capture failed!</span>: [src] is full! Free an existing soul to make room.")
			else
				T.AddComponent(/datum/component/soulstoned, src)
				if(theme == THEME_HOLY)
					icon_state = "purified_soulstone2"
					if(iscultist(T))
						SSticker.mode.remove_cultist(T.mind, FALSE, FALSE)
				if(theme == THEME_WIZARD)
					icon_state = "mystic_soulstone2"
				if(theme == THEME_CULT)
					icon_state = "soulstone2"
				name = "soulstone: Shade of [T.real_name]"
				to_chat(T, "<span class='notice'>Your soul has been captured by [src]. Its arcane energies are reknitting your ethereal form.</span>")
				if(user != T)
					to_chat(user, "<span class='info'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been captured and stored within [src].")

		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/mob/living/simple_animal/shade/A = locate() in src
			if(A)
				var/static/list/constructs = list(
					"Juggernaut" = image(icon = 'icons/mob/cult.dmi', icon_state = "juggernaut"),
					"Wraith" = image(icon = 'icons/mob/cult.dmi', icon_state = "wraith"),
					"Artificer" = image(icon = 'icons/mob/cult.dmi', icon_state = "artificer")
					)
				var/construct_class = show_radial_menu(user, src, constructs, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
				if(!T || !T.loc)
					return
				switch(construct_class)
					if("Juggernaut")
						if(iscultist(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut, A, user, FALSE, T.loc)
						else
							switch(theme)
								if(THEME_WIZARD)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/mystic, A, user, FALSE, T.loc)
								if(THEME_HOLY)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/angelic, A, user, FALSE, T.loc)
								if(THEME_CULT)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/noncult, A, user, FALSE, T.loc)
					if("Wraith")
						if(iscultist(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith, A, user, FALSE, T.loc)
						else
							switch(theme)
								if(THEME_WIZARD)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/mystic, A, user, FALSE, T.loc)
								if(THEME_HOLY)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/angelic, A, user, FALSE, T.loc)
								if(THEME_CULT)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/noncult, A, user, FALSE, T.loc)
					if("Artificer")
						if(iscultist(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer, A, user, FALSE, T.loc)
						else
							switch(theme)
								if(THEME_WIZARD)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/mystic, A, user, FALSE, T.loc)
								if(THEME_HOLY)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/angelic, A, user, FALSE, T.loc)
								if(THEME_CULT)
									makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/noncult, A, user, FALSE, T.loc)
					else
						return
				for(var/datum/mind/B in SSticker.mode.cult)
					if(B == A.mind)
						SSticker.mode.remove_cultist(A.mind)
				qdel(T)
				qdel(src)
			else
				to_chat(user, "<span class='userdanger'>Creation failed!</span>: [src] is empty! Go kill someone!")

/obj/item/soulstone/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

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
	if(newstruct.mind && ((stoner && iscultist(stoner)) || cultoverride) && SSticker?.mode)
		SSticker.mode.add_cultist(newstruct.mind, 0)
	if(iscultist(stoner) || cultoverride)
		to_chat(newstruct, "<b>You are still bound to serve the cult[stoner ? " and [stoner]":""], follow [stoner ? stoner.p_their() : "their"] orders and help [stoner ? stoner.p_them() : "them"] complete [stoner ? stoner.p_their() : "their"] goals at all costs.</b>")
	else if(stoner)
		to_chat(newstruct, "<b>You are still bound to serve your creator, [stoner], follow [stoner.p_their()] orders and help [stoner.p_them()] complete [stoner.p_their()] goals at all costs.</b>")
	newstruct.clear_alert("bloodsense")
	BS = newstruct.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	if(BS)
		BS.Cviewer = newstruct
	newstruct.cancel_camera()


/obj/item/soulstone/proc/init_shade(mob/living/carbon/human/T, mob/user, message_user = FALSE, mob/shade_controller)
	if(!shade_controller)
		shade_controller = T
	new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
	T.stop_sound_channel(CHANNEL_HEARTBEAT)
	T.invisibility = INVISIBILITY_ABSTRACT
	T.dust_animation()
	var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade(src)
	S.AddComponent(/datum/component/soulstoned, src)
	S.name = "Shade of [T.real_name]"
	S.real_name = "Shade of [T.real_name]"
	S.key = shade_controller.key
	S.copy_languages(T, LANGUAGE_MIND)//Copies the old mobs languages into the new mob holder.
	if(user)
		S.copy_languages(user, LANGUAGE_MASTER)
	S.update_atom_languages()
	grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue
	if(user)
		S.faction |= "[REF(user)]" //Add the master as a faction, allowing inter-mob cooperation
	if(user && iscultist(user))
		SSticker.mode.add_cultist(S.mind, 0)
	S.cancel_camera()
	name = "soulstone: Shade of [T.real_name]"
	switch(theme)
		if(THEME_HOLY)
			icon_state = "purified_soulstone2"
		if(THEME_WIZARD)
			icon_state = "mystic_soulstone2"
		if(THEME_CULT)
			icon_state = "soulstone2"
	if(user)
		if(iscultist(user))
			to_chat(S, "Your soul has been captured! You are now bound to the cult's will. Help them succeed in their goals at all costs.")
		else if(role_check(user))
			to_chat(S, "Your soul has been captured! You are now bound to [user.real_name]'s will. Help [user.p_them()] succeed in [user.p_their()] goals at all costs.")
		if(message_user)
			to_chat(user, "<span class='info'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been ripped from [T.p_their()] body and stored within [src].")


/obj/item/soulstone/proc/getCultGhost(mob/living/carbon/human/T, mob/user)
	var/mob/dead/observer/chosen_ghost

	chosen_ghost = T.get_ghost(TRUE,TRUE) //Try to grab original owner's ghost first

	if(!chosen_ghost || !chosen_ghost.client) //Failing that, we grab a ghosts
		var/list/consenting_candidates = pollGhostCandidates("Would you like to play as a Shade?", "Cultist", null, ROLE_CULTIST, 50, POLL_IGNORE_SHADE)
		if(consenting_candidates.len)
			chosen_ghost = pick(consenting_candidates)
	if(!T)
		return FALSE
	if(!chosen_ghost || !chosen_ghost.client)
		to_chat(user, "<span class='danger'>There were no spirits willing to become a shade.</span>")
		return FALSE
	if(contents.len) //If they used the soulstone on someone else in the meantime
		return FALSE
	for(var/obj/item/W in T)
		T.dropItemToGround(W)
	init_shade(T, user , shade_controller = chosen_ghost)
	qdel(T)
	return TRUE

