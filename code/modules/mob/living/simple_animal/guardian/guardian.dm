
GLOBAL_LIST_EMPTY(parasites) //all currently existing/living guardians

#define GUARDIAN_HANDS_LAYER 1
#define GUARDIAN_TOTAL_LAYERS 1

/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "guardian"
	desc = "A mysterious being that guardians by its charge, ever vigilant."
	speak_emote = list("hisses")
	gender = NEUTER
	bubble_icon = "guardian"
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	movement_type = FLYING // Immunity to chasms and landmines, etc.
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "punches"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	healable = FALSE //don't brusepack the guardian
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) //1 by default but abilities chip down on the total 1.
	environment_smash = 1
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0 // all 0 by default until abilities come into play
	butcher_results = list(/obj/item/weapon/ectoplasm = 1)
	AIStatus = AI_OFF
	dextrous_hud_type = /datum/hud/dextrous/guardian //if we're set to dextrous, account for it.
	ranged_cooldown_time = 0 //changed in the abilities datum
	var/list/guardian_overlays[GUARDIAN_TOTAL_LAYERS]
	var/reset = 0 //if the summoner has reset the guardian already
	var/cooldown = 0
	var/mob/living/summoner

	var/obj/item/internal_storage //what we're storing within ourself

	var/list/abilities
	var/list/current_abilities

	var/range = 0 //how far from the user the spirit can be
	var/has_mode = FALSE
	var/toggle_button_type = /obj/screen/guardian/ToggleMode/Inactive //what sort of toggle button the hud uses
	var/datum/guardianname/namedatum = new/datum/guardianname()
	var/playstyle_string = "<span class='holoparasite'>You are a guardianard guardian. You shouldn't exist!</span>"
	var/magic_fluff_string = "<span class='holoparasite'>You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!</span>"
	var/tech_fluff_string = "<span class='holoparasite'>BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!</span>"
	var/carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP SOME SORT OF HORRIFIC BUG BLAME THE CODERS CARP CARP CARP</span>"

/mob/living/simple_animal/hostile/guardian/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "guardian"
	set desc = "Choose what you shout as you attack people."
	var/input = stripped_input(src,"What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	if(input)
		for(var/datum/guardian_abilities/I in current_abilities)
			I.battlecry = input

/mob/living/simple_animal/hostile/guardian/Initialize(loc, theme)
	LAZYINITLIST(abilities)
	LAZYINITLIST(current_abilities)
	setthemename(theme)
	give_ability()
	GLOB.parasites |= src
	..()

/mob/living/simple_animal/hostile/guardian/proc/give_ability()
	for(var/type in abilities)
		var/datum/guardian_abilities/G = new type
		G.user = summoner
		G.guardian = src
		G.handle_stats()
		current_abilities += G

/mob/living/simple_animal/hostile/guardian/Shoot()
	. = ..()
	for(var/I in current_abilities)
		var/datum/guardian_abilities/A = I
		A.ranged_attack()

/mob/living/simple_animal/hostile/guardian/AttackingTarget()
	if(loc == summoner)
		to_chat(src,"<span class='danger'><B>You must be manifested to attack!</span></B>")
		return FALSE
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.ability_act()
		return ..()

/mob/living/simple_animal/hostile/guardian/AltClickOn(atom/movable/A)
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.alt_ability_act(A)

/mob/living/simple_animal/hostile/guardian/Crossed(atom/movable/A)
	..()
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.bump_reaction(A)

/mob/living/simple_animal/hostile/guardian/Bumped(atom/movable/A)
	..()
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.bump_reaction(A)

/mob/living/simple_animal/hostile/guardian/Bump(atom/movable/A)
	..()
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.bump_reaction(A)


/mob/living/simple_animal/hostile/guardian/med_hud_set_health()
	if(summoner)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner)]"

/mob/living/simple_animal/hostile/guardian/med_hud_set_status()
	if(summoner)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if(summoner.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/guardian/Destroy()
	GLOB.parasites -= src
	for(var/I in current_abilities)
		qdel(I)
	current_abilities.Cut()
	abilities.Cut()
	return ..()

/mob/living/simple_animal/hostile/guardian/proc/setthemename(pickedtheme) //set the guardian's theme to something cool!
	if(!pickedtheme)
		pickedtheme = pick("magic", "tech", "carp")
	var/list/possible_names = list()
	switch(pickedtheme)
		if("magic")
			for(var/type in (subtypesof(/datum/guardianname/magic) - namedatum.type))
				possible_names += new type
		if("tech")
			for(var/type in (subtypesof(/datum/guardianname/tech) - namedatum.type))
				possible_names += new type
		if("carp")
			for(var/type in (subtypesof(/datum/guardianname/carp) - namedatum.type))
				possible_names += new type
	namedatum = pick(possible_names)
	updatetheme(pickedtheme)

/mob/living/simple_animal/hostile/guardian/proc/updatetheme(theme) //update the guardian's theme to whatever its datum is; proc for adminfuckery
	name = "[namedatum.prefixname] [namedatum.suffixcolour]"
	real_name = "[name]"
	icon_living = "[namedatum.parasiteicon]"
	icon_state = "[namedatum.parasiteicon]"
	icon_dead = "[namedatum.parasiteicon]"
	bubble_icon = "[namedatum.bubbleicon]"

	if (namedatum.stainself)
		add_atom_colour(namedatum.colour, FIXED_COLOUR_PRIORITY)

	//Special case holocarp, because #snowflake code
	if(theme == "carp")
		speak_emote = list("gnashes")
		desc = "A mysterious fish that guardians by its charge, ever vigilant."

		attacktext = "bites"
		attack_sound = 'sound/weapons/bite.ogg'


/mob/living/simple_animal/hostile/guardian/Login() //if we have a mind, set its name to ours when it logs in
	..()
	if(mind)
		mind.name = "[real_name]"
	if(!summoner)
		to_chat(src, "<span class='holoparasitebold'>For some reason, somehow, you have no summoner. Please report this bug immediately.</span>")
		return
	to_chat(src, "<span class='holoparasite'>You are <font color=\"[namedatum.colour]\"><b>[real_name]</b></font>, bound to serve [summoner.real_name].</span>")
	to_chat(src, "<span class='holoparasite'>You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with them privately there.</span>")
	to_chat(src, "<span class='holoparasite'>While personally invincible, you will die if [summoner.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself.</span>")
	to_chat(src, playstyle_string)

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	. = ..()
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.life_act()

	update_health_hud() //we need to update all of our health displays to match our summoner and we can't practically give the summoner a hook to do it
	med_hud_set_health()
	med_hud_set_status()
	if(summoner)
		if(summoner.stat == DEAD)
			forceMove(summoner.loc)
			to_chat(src, "<span class='danger'>Your summoner has died!</span>")
			visible_message("<span class='danger'><B>\The [src] dies along with its user!</B></span>")
			summoner.visible_message("<span class='danger'><B>[summoner]'s body is completely consumed by the strain of sustaining [src]!</B></span>")
			for(var/obj/item/W in summoner)
				if(!summoner.dropItemToGround(W))
					qdel(W)
			summoner.dust()
			death(TRUE)
			qdel(src)
	else
		to_chat(src,"<span class='danger'>Your summoner has died!</span>")
		visible_message("<span class='danger'><B>The [src] dies along with its user!</B></span>")
		death(TRUE)
		qdel(src)
	snapback()

/mob/living/simple_animal/hostile/guardian/Stat()
	..()
	if(statpanel("Status"))
		if(summoner)
			var/resulthealth
			if(iscarbon(summoner))
				resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) * 100)
			else
				resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
			stat(null, "Summoner Health: [resulthealth]%")
		if(cooldown >= world.time)
			stat(null, "Manifest/Recall Cooldown Remaining: [max(round((cooldown - world.time)*0.1, 0.1), 0)] seconds")



/mob/living/simple_animal/hostile/guardian/Moved() //Returns to summoner if they move out of range
	. = ..()
	snapback()
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.move_act()

/mob/living/simple_animal/hostile/guardian/OpenFire(atom/A)
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.openfire_act(A)

/mob/living/simple_animal/hostile/guardian/throw_impact(atom/A)
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.impact_act(A)

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		if(!(S.snapback_act()))
			return

	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			to_chat(src,"<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!</span>")
			visible_message("<span class='danger'>\The [src] jumps back to its user.</span>")
			if(istype(summoner.loc, /obj/effect))
				Recall(TRUE)
			else
				new /obj/effect/overlay/temp/guardian/phase/out(loc)
				forceMove(summoner.loc)
				new /obj/effect/overlay/temp/guardian/phase(loc)


/mob/living/simple_animal/hostile/guardian/canSuicide()
	return 0

/mob/living/simple_animal/hostile/guardian/examine(mob/user)
	..()
	if(dextrous)
		var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <b>[src]</b>!\n"
		msg += "[desc]\n"

		for(var/obj/item/I in held_items)
			if(!(I.flags & ABSTRACT))
				if(I.blood_DNA)
					msg += "<span class='warning'>It has \icon[I] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in its [get_held_index_name(get_held_index_of_item(I))]!</span>\n"
				else
					msg += "It has \icon[I] \a [I] in its [get_held_index_name(get_held_index_of_item(I))].\n"

		if(internal_storage && !(internal_storage.flags&ABSTRACT))
			if(internal_storage.blood_DNA)
				msg += "<span class='warning'>It is holding \icon[internal_storage] [internal_storage.gender==PLURAL?"some":"a"] blood-stained [internal_storage.name] in its internal storage!</span>\n"
			else
				msg += "It is holding \icon[internal_storage] \a [internal_storage] in its internal storage.\n"
		msg += "*---------*</span>"
		to_chat(user,msg)



/mob/living/simple_animal/hostile/guardian/death()
	if(internal_storage && dextrous)
		dropItemToGround(internal_storage)
	drop_all_held_items()
	..()
	if(summoner)
		to_chat(summoner,"<span class='danger'><B>Your [name] died somehow!</span></B>")
		summoner.death()


/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if(summoner && hud_used && hud_used.healths)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount, updating_health = TRUE, forced = FALSE) //The spirit is invincible, but passes on damage to the summoner
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.adjusthealth_act(amount, updating_health = TRUE, forced = FALSE)
	. = amount
	if(summoner)
		if(loc == summoner)
			return FALSE
		summoner.adjustBruteLoss(amount)
		if(amount > 0)
			to_chat(summoner,"<span class='danger'><B>Your [name] is under attack! You take damage!</span></B>")
			summoner.visible_message("<span class='danger'><B>Blood sprays from [summoner] as [src] takes damage!</B></span>")
			if(summoner.stat == UNCONSCIOUS)
				to_chat(summoner,"<span class='danger'><B>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span></B>")
				summoner.adjustCloneLoss(amount * 0.5) //dying hosts take 50% bonus damage as cloneloss
		update_health_hud()


/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.boom_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		to_chat(summoner,"<span class='danger'><B>Your [src] was blown up!</span></B>")
		summoner.gib()
	ghostize()
	qdel(src)

//HAND HANDLING

/mob/living/simple_animal/hostile/guardian/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return FALSE
	if(!istype(I))
		return FALSE

	. = TRUE
	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null
		update_inv_hands()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null // will get moved if inventory is visible
	I.loc = src
	I.equipped(src, slot)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE

/mob/living/simple_animal/hostile/guardian/proc/apply_overlay(cache_index)
	if((. = guardian_overlays[cache_index]))
		add_overlay(.)

/mob/living/simple_animal/hostile/guardian/proc/remove_overlay(cache_index)
	var/I = guardian_overlays[cache_index]
	if(I)
		cut_overlay(I)
		guardian_overlays[cache_index] = null

/mob/living/simple_animal/hostile/guardian/update_inv_hands()
	remove_overlay(GUARDIAN_HANDS_LAYER)
	var/list/hands_overlays = list()
	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)

	if(r_hand)
		var/r_state = r_hand.item_state
		if(!r_state)
			r_state = r_hand.icon_state

		hands_overlays += r_hand.build_worn_icon(state = r_state, default_layer = GUARDIAN_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.plane = ABOVE_HUD_PLANE
			r_hand.screen_loc = ui_hand_position(get_held_index_of_item(r_hand))
			client.screen |= r_hand

	if(l_hand)
		var/l_state = l_hand.item_state
		if(!l_state)
			l_state = l_hand.icon_state

		hands_overlays +=  l_hand.build_worn_icon(state = l_state, default_layer = GUARDIAN_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.plane = ABOVE_HUD_PLANE
			l_hand.screen_loc = ui_hand_position(get_held_index_of_item(l_hand))
			client.screen |= l_hand

	if(hands_overlays.len)
		guardian_overlays[GUARDIAN_HANDS_LAYER] = hands_overlays
	apply_overlay(GUARDIAN_HANDS_LAYER)

/mob/living/simple_animal/hostile/guardian/regenerate_icons()
	if(dextrous)
		update_inv_hands()
		update_inv_internal_storage()

/mob/living/simple_animal/hostile/guardian/can_equip(obj/item/I, slot)
	if(dextrous)
		switch(slot)
			if(slot_generic_dextrous_storage)
				if(internal_storage)
					return FALSE
				return TRUE

/mob/living/simple_animal/hostile/guardian/doUnEquip(obj/item/I, force)
	if(dextrous)
		if(..())
			update_inv_hands()
			if(I == internal_storage)
				internal_storage = null
				update_inv_internal_storage()
			return 1
		return 0

/mob/living/simple_animal/hostile/guardian/getBackSlot()
	return slot_generic_dextrous_storage

/mob/living/simple_animal/hostile/guardian/getBeltSlot()
	return slot_generic_dextrous_storage

/mob/living/simple_animal/hostile/guardian/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used && hud_used.hud_shown	&& dextrous)
		internal_storage.screen_loc = ui_id
		client.screen += internal_storage



/mob/living/simple_animal/hostile/guardian/equip_to_slot(obj/item/I, slot)
	if(dextrous)
		if(!slot)
			return FALSE
		if(!istype(I))
			return FALSE

		. = TRUE
		var/index = get_held_index_of_item(I)
		if(index)
			held_items[index] = null
			update_inv_hands()

		if(I.pulledby)
			I.pulledby.stop_pulling()

		I.screen_loc = null // will get moved if inventory is visible
		I.loc = src
		I.equipped(src, slot)
		I.layer = ABOVE_HUD_LAYER
		I.plane = ABOVE_HUD_PLANE

//MANIFEST, RECALL, TOGGLE MODE/LIGHT, SHOW TYPE

/mob/living/simple_animal/hostile/guardian/proc/Manifest(forced)
	if(istype(summoner.loc, /obj/effect) || (cooldown > world.time && !forced))
		return FALSE
	if(loc == summoner)
		forceMove(summoner.loc)
		new /obj/effect/overlay/temp/guardian/phase(loc)
		cooldown = world.time + 10
		for(var/I in current_abilities)
			var/datum/guardian_abilities/S = I
			S.manifest_act()
		return TRUE
	return FALSE


/mob/living/simple_animal/hostile/guardian/proc/Recall(forced)
	if(!summoner || loc == summoner || (cooldown > world.time && !forced))
		return FALSE
	new /obj/effect/overlay/temp/guardian/phase/out(loc)

	forceMove(summoner)
	cooldown = world.time + 10
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.recall_act(forced)
	return TRUE

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	if(has_mode)
		for(var/I in current_abilities)
			var/datum/guardian_abilities/S
			S.handle_mode()
	else
		to_chat(src,"<span class='danger'><B>You don't have another mode!</span></B>")

/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(light_range<3)
		to_chat(src, "<span class='notice'>You activate your light.</span>")
		set_light(3)
	else
		to_chat(src,"<span class='notice'>You deactivate your light.</span>")
		set_light(0)
	for(var/I in current_abilities)
		var/datum/guardian_abilities/S = I
		S.light_switch()

/mob/living/simple_animal/hostile/guardian/verb/ShowType()
	set name = "Check guardian Type"
	set category = "guardian"
	set desc = "Check what type you are."
	to_chat(src, playstyle_string)

//COMMUNICATION

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	if(summoner)
		var/input = stripped_input(src, "Please enter a message to tell your summoner.", "guardian", "")
		if(!input)
			return

		var/preliminary_message = "<span class='holoparasitebold'>[input]</span>" //apply basic color/bolding
		var/my_message = "<font color=\"[namedatum.colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the guardian's color

		to_chat(summoner, my_message)
		var/list/guardians = summoner.hasparasites()
		for(var/para in guardians)
			to_chat(para, my_message)
		for(var/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [my_message]")

		log_say("[src.real_name]/[src.key] : [input]")

/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input)
		return

	var/preliminary_message = "<span class='holoparasitebold'>[input]</span>" //apply basic color/bolding
	var/my_message = "<span class='holoparasitebold'><i>[src]:</i> [preliminary_message]</span>" //add source, color source with default grey...

	to_chat(src, my_message)
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		to_chat(G, "<font color=\"[G.namedatum.colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" )
	for(var/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		to_chat(M, "[link] [my_message]")

	log_say("[src.real_name]/[src.key] : [text]")

//FORCE RECALL/RESET

/mob/living/proc/guardian_recall()
	set name = "Recall guardian"
	set category = "guardian"
	set desc = "Forcibly recall your guardian."
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset guardian Player (One Use)"
	set category = "guardian"
	set desc = "Re-rolls which ghost will control your guardian. One use per guardian."

	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/P = para
		if(P.reset)
			guardians -= P //clear out guardians that are already reset
	if(guardians.len)
		var/mob/living/simple_animal/hostile/guardian/G = input(src, "Pick the guardian you wish to reset", "guardian Reset") as null|anything in guardians
		if(G)
			to_chat(src, "<span class='holoparasite'>You attempt to reset <font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font>'s personality...</span>")
			var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [src.real_name]'s [G.real_name]?", "pAI", null, FALSE, 100)
			var/mob/dead/observer/new_guardian = null
			if(candidates.len)
				new_guardian = pick(candidates)
				to_chat(G, "<span class='holoparasite'>Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.</span>")
				to_chat(src, "<span class='holoparasitebold'>Your <font color=\"[G.namedatum.colour]\">[G.real_name]</font> has been successfully reset.</span>")
				message_admins("[key_name_admin(new_guardian)] has taken control of ([key_name_admin(G)])")
				G.ghostize(0)
				G.setthemename(G.namedatum.theme) //give it a new color, to show it's a new person
				G.key = new_guardian.key
				G.reset = 1
				switch(G.namedatum.theme)
					if("tech")
						to_chat(src, "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> is now online!</span>")
					if("magic")
						to_chat(src, "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been summoned!</span>")
				guardians -= G
				if(!guardians.len)
					verbs -= /mob/living/proc/guardian_reset
			else
				to_chat(src, "<span class='holoparasite'>There were no ghosts willing to take control of <font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font>. Looks like you're stuck with it for now.</span>")
		else
			to_chat(src, "<span class='holoparasite'>You decide not to reset [guardians.len > 1 ? "any of your guardians":"your guardian"].</span>")
	else
		verbs -= /mob/living/proc/guardian_reset

////////parasite tracking/finding procs

/mob/living/proc/hasparasites() //returns a list of guardians the mob is a summoner for
	. = list()
	for(var/P in GLOB.parasites)
		var/mob/living/simple_animal/hostile/guardian/G = P
		if(G.summoner == src)
			. |= G

/mob/living/simple_animal/hostile/guardian/proc/hasmatchingsummoner(mob/living/simple_animal/hostile/guardian/G) //returns 1 if the summoner matches the target's summoner
	return (istype(G) && G.summoner == summoner)



////////Creation

/obj/item/weapon/guardiancreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "guardian"
	var/use_message = "<span class='holoparasite'>You shuffle the deck...</span>"
	var/used_message = "<span class='holoparasite'>All the cards seem to be blank now.</span>"
	var/failure_message = "<span class='holoparasitebold'>..And draw a card! It's...blank? Maybe you should try again later.</span>"
	var/ling_failure = "<span class='holoparasitebold'>The deck refuses to respond to a souless creature such as you.</span>"

	var/list/chosen_abilities = null
	var/totalvalue = 0
	var/allowedvalue = 10
	var/chosen_ability = null

	var/list/datablocks = null
	var/list/chosen_blocks = null //these blocks are for the system used to find the chosen abilities in a datablock of [name|id]
	var/block_value = 0

	var/possible_candidates
	var/random = TRUE
	var/allowmultiple = FALSE
	var/allowling = TRUE
	var/allowguardian = FALSE

/obj/item/weapon/guardiancreator/attack_self(mob/living/user)
	if(isguardian(user) && !allowguardian)
		to_chat(user, "<span class='holoparasite'>[mob_name] chains are not allowed.</span>")
		return
	var/list/guardians = user.hasparasites()
	if(guardians.len && !allowmultiple)
		to_chat(user, "<span class='holoparasite'>You already have a [mob_name]!</span>")
		return
	if(user.mind && user.mind.changeling && !allowling)
		to_chat(user, "[ling_failure]")
		return
	if(used == TRUE)
		to_chat(user, "[used_message]")
		return
	used = TRUE
	to_chat(user, "[use_message]")
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_PAI, null, FALSE, 100)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		spawn_guardian(user, theghost.key)
	else
		to_chat(user, "[failure_message]")
		used = FALSE


/obj/item/weapon/guardiancreator/proc/pick_guardian(var/mob/living/user)
	if(random)
		var/datum/guardian_abilities/S = pick(possible_candidates)
		S = chosen_ability
		S.value += totalvalue
		possible_candidates -= S
		LAZYINITLIST(chosen_abilities)
		chosen_abilities |= S
	else
		while(totalvalue <= allowedvalue)//rollercoaster of pain//rollercoaster of pain//rollercoaster of pain
			for(var/ora in possible_candidates)
				var/datum/guardian_abilities/A = ora
				for(var/muda in chosen_abilities)
					var/datum/guardian_abilities/M = muda
					if((A in M.blacklisted_abilities) && (A in chosen_abilities))
						possible_candidates -= A
						return

					var/datablock = "[A.id]|[A.name]|[A.value]" //NO NEED TO MAINTAIN MASSIVE LISTS OF ABILITIES BABY.
					LAZYINITLIST(datablocks)
					datablocks |= datablock //from type to text + name + number (block)

					var/chosen_block = input(user, "Pick the abilities of [mob_name]", "[mob_name] Creation") as null|anything in datablocks
					LAZYINITLIST(chosen_blocks) //blocks put into a list and player given multiple choices
					chosen_blocks |= chosen_block

					for(var/i in datablocks)
						block_value = text2num(i) //from block to number
						if(i in chosen_blocks || !((block_value += totalvalue) > allowedvalue))

							LAZYINITLIST(chosen_abilities)
							if((findtext(A.id, chosen_blocks)))
								var/result = text2path("/datum/guardian_abilities/[A.id]")
								chosen_ability = result
								totalvalue += A.value
								chosen_abilities |= chosen_ability


/obj/item/weapon/guardiancreator/proc/spawn_guardian(var/mob/living/user, var/key)
	if(!(totalvalue = allowedvalue))
		for(var/ora in subtypesof(/datum/guardian_abilities))
			var/datum/guardian_abilities/A = ora
			LAZYINITLIST(possible_candidates)
			A += possible_candidates
		while(totalvalue <= allowedvalue)
			pick_guardian(user)

	else
		var/list/guardians = user.hasparasites()
		if(guardians.len && !allowmultiple)
			to_chat(user,"<span class='holoparasite'>You already have a [mob_name]!</span>") //nice try, bucko
			used = FALSE
			return
		var/mob/living/simple_animal/hostile/guardian/G = new
		G.abilities |= chosen_abilities
		G.give_ability()
		G.key = key
		G.mind.enslave_mind_to_creator(user)
		switch(theme)
			if("tech")
				to_chat(user,"[G.tech_fluff_string]")
				to_chat(user,"<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> is now online!</span>")
			if("magic")
				to_chat(user,"[G.magic_fluff_string]")
				to_chat(user,"<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been summoned!</span>")
			if("carp")
				to_chat(user,"[G.carp_fluff_string]")
				to_chat(user,"<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been caught!</span>")
		user.verbs += /mob/living/proc/guardian_comm
		user.verbs += /mob/living/proc/guardian_recall
		user.verbs += /mob/living/proc/guardian_reset

/obj/item/weapon/guardiancreator/choose
	random = FALSE


/obj/item/weapon/guardiancreator/choose/wizard
	allowmultiple = TRUE

/obj/item/weapon/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains an alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = "<span class='holoparasite'>You start to power on the injector...</span>"
	used_message = "<span class='holoparasite'>The injector has already been used.</span>"
	failure_message = "<span class='holoparasitebold'>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</span>"
	ling_failure = "<span class='holoparasitebold'>The holoparasites recoil in horror. They want nothing to do with a creature like you.</span>"


/obj/item/weapon/guardiancreator/tech/choose
	random = FALSE


/obj/item/weapon/paper/guardian
	name = "Holoparasite Guide"
	icon_state = "paper_words"
	info = {"<b>A list of Holoparasite Types</b><br>

 <br>
 <b>Assassin</b>: Does medium damage and takes full damage, but can enter stealth, causing its next attack to do massive damage and ignore armor. However, it becomes briefly unable to recall after attacking from stealth.<br>
 <br>
 <b>Chaos</b>: Ignites enemies on touch and causes them to hallucinate all nearby people as the parasite. Automatically extinguishes the user if they catch on fire.<br>
 <br>
 <b>Charger</b>: Moves extremely fast, does medium damage on attack, and can charge at targets, damaging the first target hit and forcing them to drop any items they are holding.<br>
 <br>
 <b>Explosive</b>: High damage resist and medium power attack that may explosively teleport targets. Can turn any object, including objects too large to pick up, into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered or after a delay.<br>
 <br>
 <b>Lightning</b>: Attacks apply lightning chains to targets. Has a lightning chain to the user. Lightning chains shock everything near them, doing constant damage.<br>
 <br>
 <b>Protector</b>: Causes you to teleport to it when out of range, unlike other parasites. Has two modes; Combat, where it does and takes medium damage, and Protection, where it does and takes almost no damage but moves slightly slower.<br>
 <br>
 <b>Ranged</b>: Has two modes. Ranged; which fires a constant stream of weak, armor-ignoring projectiles. Scout; Cannot attack, but can move through walls and is quite hard to see. Can lay surveillance snares, which alert it when crossed, in either mode.<br>
 <br>
 <b>guardianard</b>: Devastating close combat attacks and high damage resist. Can smash through weak walls.<br>
 <br>
"}

/obj/item/weapon/paper/guardian/update_icon()
	return

/obj/item/weapon/paper/guardian/wizard
	name = "guardian Guide"
	info = {"<b>A list of guardian Types</b><br>

 <br>
 <b>Assassin</b>: Does medium damage and takes full damage, but can enter stealth, causing its next attack to do massive damage and ignore armor. However, it becomes briefly unable to recall after attacking from stealth.<br>
 <br>
 <b>Chaos</b>: Ignites enemies on touch and causes them to hallucinate all nearby people as the guardian. Automatically extinguishes the user if they catch on fire.<br>
 <br>
 <b>Charger</b>: Moves extremely fast, does medium damage on attack, and can charge at targets, damaging the first target hit and forcing them to drop any items they are holding.<br>
 <br>
 <b>Dexterous</b>: Does low damage on attack, but is capable of holding items and storing a single item within it. It will drop items held in its hands when it recalls, but it will retain the stored item.<br>
 <br>
 <b>Explosive</b>: High damage resist and medium power attack that may explosively teleport targets. Can turn any object, including objects too large to pick up, into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered or after a delay.<br>
 <br>
 <b>Lightning</b>: Attacks apply lightning chains to targets. Has a lightning chain to the user. Lightning chains shock everything near them, doing constant damage.<br>
 <br>
 <b>Protector</b>: Causes you to teleport to it when out of range, unlike other parasites. Has two modes; Combat, where it does and takes medium damage, and Protection, where it does and takes almost no damage but moves slightly slower.<br>
 <br>
 <b>Ranged</b>: Has two modes. Ranged; which fires a constant stream of weak, armor-ignoring projectiles. Scout; Cannot attack, but can move through walls and is quite hard to see. Can lay surveillance snares, which alert it when crossed, in either mode.<br>
 <br>
 <b>Standard</b>: Devastating close combat attacks and high damage resist. Can smash through weak walls.<br>
 <br>
"}


/obj/item/weapon/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/weapon/storage/box/syndie_kit/guardian/New()
	..()
	new /obj/item/weapon/guardiancreator/tech/choose(src)
	new /obj/item/weapon/paper/guardian(src)
	return

/obj/item/weapon/guardiancreator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "fishfingers"
	theme = "carp"
	mob_name = "Holocarp"
	use_message = "<span class='holoparasite'>You put the fishsticks in your mouth...</span>"
	used_message = "<span class='holoparasite'>Someone's already taken a bite out of these fishsticks! Ew.</span>"
	failure_message = "<span class='holoparasitebold'>You couldn't catch any carp spirits from the seas of Lake Carp. Maybe there are none, maybe you fucked up.</span>"
	ling_failure = "<span class='holoparasitebold'>Carp'sie is fine with changelings, so you shouldn't be seeing this message.</span>"
	allowmultiple = TRUE
	allowling = TRUE
	random = TRUE

/obj/item/weapon/guardiancreator/carp/choose
	random = FALSE
