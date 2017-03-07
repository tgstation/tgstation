
var/global/list/parasites = list() //all currently existing/living sutandos

#define sutando_HANDS_LAYER 1
#define sutando_TOTAL_LAYERS 1

/mob/living/simple_animal/hostile/sutando
	name = "sutando Spirit"
	real_name = "Sutando"
	desc = "A mysterious being that stands by its charge, ever vigilant."
	speak_emote = list("hisses")
	gender = NEUTER
	bubble_icon = "sutando"
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/sutando.dmi'
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
	healable = FALSE //don't brusepack the sutando
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) //1 by default but abilities chip down on the total 1.
	environment_smash = 1
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0 // all 0 by default until abilities come into play
	butcher_results = list(/obj/item/weapon/ectoplasm = 1)
	AIStatus = AI_OFF
	dextrous_hud_type = /datum/hud/dextrous/sutando //if we're set to dextrous, account for it.
	ranged_cooldown_time = 0 //changed in the abilities datum
	var/list/sutando_overlays[sutando_TOTAL_LAYERS]
	var/reset = 0 //if the summoner has reset the sutando already
	var/cooldown = 0
	var/mob/living/summoner

	var/obj/item/internal_storage //what we're storing within ourself

	var/list/abilities
	var/list/current_abilities

	var/range = 0 //how far from the user the spirit can be
	var/has_mode = FALSE
	var/toggle_button_type = /obj/screen/sutando/ToggleMode/Inactive //what sort of toggle button the hud uses
	var/datum/sutandoname/namedatum = new/datum/sutandoname()
	var/playstyle_string = "<span class='holoparasite'>You are a standard sutando. You shouldn't exist!</span>"
	var/magic_fluff_string = "<span class='holoparasite'>You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!</span>"
	var/tech_fluff_string = "<span class='holoparasite'>BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!</span>"
	var/carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP SOME SORT OF HORRIFIC BUG BLAME THE CODERS CARP CARP CARP</span>"

/mob/living/simple_animal/hostile/sutando/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "sutando"
	set desc = "Choose what you shout as you attack people."
	var/input = stripped_input(src,"What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	if(input)
		for(var/datum/sutando_abilities/I in current_abilities)
			I.battlecry = input

/mob/living/simple_animal/hostile/sutando/Initialize(loc, theme)
	LAZYINITLIST(abilities)
	LAZYINITLIST(current_abilities)
	setthemename(theme)
	for(var/type in abilities)
		var/datum/sutando_abilities/G = new type
		G.user = summoner
		G.stand = src
		G.handle_stats()
		current_abilities += G
	parasites |= src
	..()

/mob/living/simple_animal/hostile/sutando/Shoot()
	. = ..()
	for(var/datum/sutando_abilities/I in current_abilities)
		I.ranged_attack()

/mob/living/simple_animal/hostile/sutando/AttackingTarget()
	if(loc == summoner)
		src << "<span class='danger'><B>You must be manifested to attack!</span></B>"
		return FALSE
	else
		for(var/datum/sutando_abilities/I in current_abilities)
			I.ability_act()
		return ..()

/mob/living/simple_animal/hostile/sutando/AltClickOn(atom/movable/A)
	for(var/datum/sutando_abilities/I in current_abilities)
		I.alt_ability_act(A)

/mob/living/simple_animal/hostile/sutando/Crossed(atom/movable/A)
	..()
	for(var/datum/sutando_abilities/I in current_abilities)
		I.bump_reaction(A)

/mob/living/simple_animal/hostile/sutando/Bumped(atom/movable/A)
	..()
	for(var/datum/sutando_abilities/I in current_abilities)
		I.bump_reaction(A)

/mob/living/simple_animal/hostile/sutando/Bump(atom/movable/A)
	..()
	for(var/datum/sutando_abilities/I in current_abilities)
		I.bump_reaction(A)



/mob/living/simple_animal/hostile/sutando/med_hud_set_health()
	if(summoner)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner)]"

/mob/living/simple_animal/hostile/sutando/med_hud_set_status()
	if(summoner)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if(summoner.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/sutando/Destroy()
	parasites -= src
	for(var/datum/guardian_abilities/I in current_abilities)
		qdel(I)
	current_abilities.Cut()
	abilities.Cut()
	return ..()

/mob/living/simple_animal/hostile/sutando/proc/setthemename(pickedtheme) //set the sutando's theme to something cool!
	if(!pickedtheme)
		pickedtheme = pick("magic", "tech", "carp")
	var/list/possible_names = list()
	switch(pickedtheme)
		if("magic")
			for(var/type in (subtypesof(/datum/sutandoname/magic) - namedatum.type))
				possible_names += new type
		if("tech")
			for(var/type in (subtypesof(/datum/sutandoname/tech) - namedatum.type))
				possible_names += new type
		if("carp")
			for(var/type in (subtypesof(/datum/sutandoname/carp) - namedatum.type))
				possible_names += new type
	namedatum = pick(possible_names)
	updatetheme(pickedtheme)

/mob/living/simple_animal/hostile/sutando/proc/updatetheme(theme) //update the sutando's theme to whatever its datum is; proc for adminfuckery
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
		desc = "A mysterious fish that stands by its charge, ever vigilant."

		attacktext = "bites"
		attack_sound = 'sound/weapons/bite.ogg'


/mob/living/simple_animal/hostile/sutando/Login() //if we have a mind, set its name to ours when it logs in
	..()
	if(mind)
		mind.name = "[real_name]"
	if(!summoner)
		src << "<span class='holoparasitebold'>For some reason, somehow, you have no summoner. Please report this bug immediately.</span>"
		return
	src << "<span class='holoparasite'>You are <font color=\"[namedatum.colour]\"><b>[real_name]</b></font>, bound to serve [summoner.real_name].</span>"
	src << "<span class='holoparasite'>You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with them privately there.</span>"
	src << "<span class='holoparasite'>While personally invincible, you will die if [summoner.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself.</span>"
	src << playstyle_string

/mob/living/simple_animal/hostile/sutando/Life() //Dies if the summoner dies
	. = ..()
	for(var/datum/sutando_abilities/I in current_abilities)
		I.life_act()

	update_health_hud() //we need to update all of our health displays to match our summoner and we can't practically give the summoner a hook to do it
	med_hud_set_health()
	med_hud_set_status()
	if(summoner)
		if(summoner.stat == DEAD)
			forceMove(summoner.loc)
			src << "<span class='danger'>Your summoner has died!</span>"
			visible_message("<span class='danger'><B>\The [src] dies along with its user!</B></span>")
			summoner.visible_message("<span class='danger'><B>[summoner]'s body is completely consumed by the strain of sustaining [src]!</B></span>")
			for(var/obj/item/W in summoner)
				if(!summoner.dropItemToGround(W))
					qdel(W)
			summoner.dust()
			death(TRUE)
			qdel(src)
	else
		src << "<span class='danger'>Your summoner has died!</span>"
		visible_message("<span class='danger'><B>The [src] dies along with its user!</B></span>")
		death(TRUE)
		qdel(src)
	snapback()

/mob/living/simple_animal/hostile/sutando/Stat()
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



/mob/living/simple_animal/hostile/sutando/Moved() //Returns to summoner if they move out of range
	. = ..()
	snapback()
	for(var/datum/sutando_abilities/I in current_abilities)
		I.move_act()

/mob/living/simple_animal/hostile/sutando/OpenFire(atom/A)
	for(var/datum/sutando_abilities/I in current_abilities)
		I.openfire_act(A)

/mob/living/simple_animal/hostile/sutando/throw_impact(atom/A)
	for(var/datum/sutando_abilities/I in current_abilities)
		I.impact_act(A)

/mob/living/simple_animal/hostile/sutando/proc/snapback()
	for(var/datum/sutando_abilities/I in current_abilities)
		I.snapback_act()
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			src << "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!</span>"
			visible_message("<span class='danger'>\The [src] jumps back to its user.</span>")
			if(istype(summoner.loc, /obj/effect))
				Recall(TRUE)
			else
				new /obj/effect/overlay/temp/sutando/phase/out(loc)
				forceMove(summoner.loc)
				new /obj/effect/overlay/temp/sutando/phase(loc)


/mob/living/simple_animal/hostile/sutando/canSuicide()
	return 0

/mob/living/simple_animal/hostile/sutando/examine(mob/user)
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
		user << msg



/mob/living/simple_animal/hostile/sutando/death()
	if(internal_storage && dextrous)
		dropItemToGround(internal_storage)
	drop_all_held_items()
	..()
	if(summoner)
		summoner << "<span class='danger'><B>Your [name] died somehow!</span></B>"
		summoner.death()


/mob/living/simple_animal/hostile/sutando/update_health_hud()
	if(summoner && hud_used && hud_used.healths)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"

/mob/living/simple_animal/hostile/sutando/adjustHealth(amount, updating_health = TRUE, forced = FALSE) //The spirit is invincible, but passes on damage to the summoner
	for(var/datum/sutando_abilities/I in current_abilities)
		I.adjusthealth_act(amount, updating_health = TRUE, forced = FALSE)
	. = amount
	if(summoner)
		if(loc == summoner)
			return FALSE
		summoner.adjustBruteLoss(amount)
		if(amount > 0)
			summoner << "<span class='danger'><B>Your [name] is under attack! You take damage!</span></B>"
			summoner.visible_message("<span class='danger'><B>Blood sprays from [summoner] as [src] takes damage!</B></span>")
			if(summoner.stat == UNCONSCIOUS)
				summoner << "<span class='danger'><B>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span></B>"
				summoner.adjustCloneLoss(amount * 0.5) //dying hosts take 50% bonus damage as cloneloss
		update_health_hud()


/mob/living/simple_animal/hostile/sutando/ex_act(severity, target)
	for(var/datum/sutando_abilities/I in current_abilities)
		I.boom_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/sutando/gib()
	if(summoner)
		summoner << "<span class='danger'><B>Your [src] was blown up!</span></B>"
		summoner.gib()
	ghostize()
	qdel(src)

//HAND HANDLING

/mob/living/simple_animal/hostile/sutando/equip_to_slot(obj/item/I, slot)
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

/mob/living/simple_animal/hostile/sutando/proc/apply_overlay(cache_index)
	var/I = sutando_overlays[cache_index]
	if(I)
		add_overlay(I)

/mob/living/simple_animal/hostile/sutando/proc/remove_overlay(cache_index)
	var/I = sutando_overlays[cache_index]
	if(I)
		cut_overlay(I)
		sutando_overlays[cache_index] = null

/mob/living/simple_animal/hostile/sutando/update_inv_hands()
	remove_overlay(sutando_HANDS_LAYER)
	var/list/hands_overlays = list()
	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)

	if(r_hand)
		var/r_state = r_hand.item_state
		if(!r_state)
			r_state = r_hand.icon_state

		var/image/r_hand_image = r_hand.build_worn_icon(state = r_state, default_layer = sutando_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)

		hands_overlays += r_hand_image

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.plane = ABOVE_HUD_PLANE
			r_hand.screen_loc = ui_hand_position(get_held_index_of_item(r_hand))
			client.screen |= r_hand

	if(l_hand)
		var/l_state = l_hand.item_state
		if(!l_state)
			l_state = l_hand.icon_state

		var/image/l_hand_image = l_hand.build_worn_icon(state = l_state, default_layer = sutando_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)

		hands_overlays += l_hand_image

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.plane = ABOVE_HUD_PLANE
			l_hand.screen_loc = ui_hand_position(get_held_index_of_item(l_hand))
			client.screen |= l_hand

	if(hands_overlays.len)
		sutando_overlays[sutando_HANDS_LAYER] = hands_overlays
	apply_overlay(sutando_HANDS_LAYER)

/mob/living/simple_animal/hostile/sutando/regenerate_icons()
	if(dextrous)
		update_inv_hands()
		update_inv_internal_storage()

/mob/living/simple_animal/hostile/sutando/can_equip(obj/item/I, slot)
	if(dextrous)
		switch(slot)
			if(slot_generic_dextrous_storage)
				if(internal_storage)
					return FALSE
				return TRUE

/mob/living/simple_animal/hostile/sutando/doUnEquip(obj/item/I, force)
	if(dextrous)
		if(..())
			update_inv_hands()
			if(I == internal_storage)
				internal_storage = null
				update_inv_internal_storage()
			return 1
		return 0

/mob/living/simple_animal/hostile/sutando/getBackSlot()
	return slot_generic_dextrous_storage

/mob/living/simple_animal/hostile/sutando/getBeltSlot()
	return slot_generic_dextrous_storage

/mob/living/simple_animal/hostile/sutando/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used && hud_used.hud_shown	&& dextrous)
		internal_storage.screen_loc = ui_id
		client.screen += internal_storage



/mob/living/simple_animal/hostile/sutando/equip_to_slot(obj/item/I, slot)
	if(dextrous)
		if(!..())
			return

		switch(slot)
			if(slot_generic_dextrous_storage)
				internal_storage = I
				update_inv_internal_storage()
			else
				src << "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"


//MANIFEST, RECALL, TOGGLE MODE/LIGHT, SHOW TYPE

/mob/living/simple_animal/hostile/sutando/proc/Manifest(forced)
	if(istype(summoner.loc, /obj/effect) || (cooldown > world.time && !forced))
		return FALSE
	if(loc == summoner)
		forceMove(summoner.loc)
		new /obj/effect/overlay/temp/sutando/phase(loc)
		cooldown = world.time + 10
		for(var/datum/sutando_abilities/I in current_abilities)
			I.manifest_act()
		return TRUE
	return FALSE


/mob/living/simple_animal/hostile/sutando/proc/Recall(forced)
	if(!summoner || loc == summoner || (cooldown > world.time && !forced))
		return FALSE
	new /obj/effect/overlay/temp/sutando/phase/out(loc)

	forceMove(summoner)
	cooldown = world.time + 10
	for(var/datum/sutando_abilities/I in current_abilities)
		I.recall_act()
	return TRUE

/mob/living/simple_animal/hostile/sutando/proc/ToggleMode()
	if(has_mode)
		for(var/datum/sutando_abilities/I in current_abilities)
			I.handle_mode()
	else
		src << "<span class='danger'><B>You don't have another mode!</span></B>"

/mob/living/simple_animal/hostile/sutando/proc/ToggleLight()
	if(!luminosity)
		src << "<span class='notice'>You activate your light.</span>"
		set_light(3)
	else
		src << "<span class='notice'>You deactivate your light.</span>"
		set_light(0)
	for(var/datum/sutando_abilities/I in current_abilities)
		I.light_switch()

/mob/living/simple_animal/hostile/sutando/verb/ShowType()
	set name = "Check sutando Type"
	set category = "sutando"
	set desc = "Check what type you are."
	src << playstyle_string

//COMMUNICATION

/mob/living/simple_animal/hostile/sutando/proc/Communicate()
	if(summoner)
		var/input = stripped_input(src, "Please enter a message to tell your summoner.", "sutando", "")
		if(!input)
			return

		var/preliminary_message = "<span class='holoparasitebold'>[input]</span>" //apply basic color/bolding
		var/my_message = "<font color=\"[namedatum.colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the sutando's color

		summoner << my_message
		var/list/sutandos = summoner.hasparasites()
		for(var/para in sutandos)
			para << my_message
		for(var/M in dead_mob_list)
			var/link = FOLLOW_LINK(M, src)
			M << "[link] [my_message]"

		log_say("[src.real_name]/[src.key] : [input]")

/mob/living/proc/sutando_comm()
	set name = "Communicate"
	set category = "sutando"
	set desc = "Communicate telepathically with your sutando."
	var/input = stripped_input(src, "Please enter a message to tell your sutando.", "Message", "")
	if(!input)
		return

	var/preliminary_message = "<span class='holoparasitebold'>[input]</span>" //apply basic color/bolding
	var/my_message = "<span class='holoparasitebold'><i>[src]:</i> [preliminary_message]</span>" //add source, color source with default grey...

	src << my_message
	var/list/sutandos = hasparasites()
	for(var/para in sutandos)
		var/mob/living/simple_animal/hostile/sutando/G = para
		G << "<font color=\"[G.namedatum.colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" //but for sutandos, use their color for the source instead
	for(var/M in dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		M << "[link] [my_message]"

	log_say("[src.real_name]/[src.key] : [text]")

//FORCE RECALL/RESET

/mob/living/proc/sutando_recall()
	set name = "Recall sutando"
	set category = "sutando"
	set desc = "Forcibly recall your sutando."
	var/list/sutandos = hasparasites()
	for(var/para in sutandos)
		var/mob/living/simple_animal/hostile/sutando/G = para
		G.Recall()

/mob/living/proc/sutando_reset()
	set name = "Reset sutando Player (One Use)"
	set category = "sutando"
	set desc = "Re-rolls which ghost will control your sutando. One use per sutando."

	var/list/sutandos = hasparasites()
	for(var/para in sutandos)
		var/mob/living/simple_animal/hostile/sutando/P = para
		if(P.reset)
			sutandos -= P //clear out sutandos that are already reset
	if(sutandos.len)
		var/mob/living/simple_animal/hostile/sutando/G = input(src, "Pick the sutando you wish to reset", "sutando Reset") as null|anything in sutandos
		if(G)
			src << "<span class='holoparasite'>You attempt to reset <font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font>'s personality...</span>"
			var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [src.real_name]'s [G.real_name]?", "pAI", null, FALSE, 100)
			var/mob/dead/observer/new_stand = null
			if(candidates.len)
				new_stand = pick(candidates)
				G << "<span class='holoparasite'>Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.</span>"
				src << "<span class='holoparasitebold'>Your <font color=\"[G.namedatum.colour]\">[G.real_name]</font> has been successfully reset.</span>"
				message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(G)])")
				G.ghostize(0)
				G.setthemename(G.namedatum.theme) //give it a new color, to show it's a new person
				G.key = new_stand.key
				G.reset = 1
				switch(G.namedatum.theme)
					if("tech")
						src << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> is now online!</span>"
					if("magic")
						src << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been summoned!</span>"
				sutandos -= G
				if(!sutandos.len)
					verbs -= /mob/living/proc/sutando_reset
			else
				src << "<span class='holoparasite'>There were no ghosts willing to take control of <font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font>. Looks like you're stuck with it for now.</span>"
		else
			src << "<span class='holoparasite'>You decide not to reset [sutandos.len > 1 ? "any of your sutandos":"your sutando"].</span>"
	else
		verbs -= /mob/living/proc/sutando_reset

////////parasite tracking/finding procs

/mob/living/proc/hasparasites() //returns a list of sutandos the mob is a summoner for
	. = list()
	for(var/P in parasites)
		var/mob/living/simple_animal/hostile/sutando/G = P
		if(G.summoner == src)
			. |= G

/mob/living/simple_animal/hostile/sutando/proc/hasmatchingsummoner(mob/living/simple_animal/hostile/sutando/G) //returns 1 if the summoner matches the target's summoner
	return (istype(G) && G.summoner == summoner)


////////Creation

/obj/item/weapon/sutandocreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "sutando Spirit"
	var/use_message = "<span class='holoparasite'>You shuffle the deck...</span>"
	var/used_message = "<span class='holoparasite'>All the cards seem to be blank now.</span>"
	var/failure_message = "<span class='holoparasitebold'>..And draw a card! It's...blank? Maybe you should try again later.</span>"
	var/ling_failure = "<span class='holoparasitebold'>The deck refuses to respond to a souless creature such as you.</span>"
	var/list/possible_sutandos = list("Assassin", "Chaos", "Charger", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Support")
	var/random = TRUE
	var/allowmultiple = FALSE
	var/allowling = TRUE
	var/allowsutando = FALSE

/obj/item/weapon/sutandocreator/attack_self(mob/living/user)
	if(issutando(user) && !allowsutando)
		user << "<span class='holoparasite'>[mob_name] chains are not allowed.</span>"
		return
	var/list/sutandos = user.hasparasites()
	if(sutandos.len && !allowmultiple)
		user << "<span class='holoparasite'>You already have a [mob_name]!</span>"
		return
	if(user.mind && user.mind.changeling && !allowling)
		user << "[ling_failure]"
		return
	if(used == TRUE)
		user << "[used_message]"
		return
	used = TRUE
	user << "[use_message]"
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_PAI, null, FALSE, 100)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		spawn_sutando(user, theghost.key)
	else
		user << "[failure_message]"
		used = FALSE


/obj/item/weapon/sutandocreator/proc/spawn_sutando(var/mob/living/user, var/key)
	var/sutandotype = "Standard"
	if(random)
		sutandotype = pick(possible_sutandos)
	else
		sutandotype = input(user, "Pick the type of [mob_name]", "[mob_name] Creation") as null|anything in possible_sutandos
		if(!sutandotype)
			user << "[failure_message]" //they canceled? sure okay don't force them into it
			used = FALSE
			return
	var/pickedtype = /mob/living/simple_animal/hostile/sutando/punch
	switch(sutandotype)

		if("Chaos")
			pickedtype = /mob/living/simple_animal/hostile/sutando/fire

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/sutando/punch

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/sutando/ranged

		if("Support")
			pickedtype = /mob/living/simple_animal/hostile/sutando/healer

		if("Explosive")
			pickedtype = /mob/living/simple_animal/hostile/sutando/bomb

		if("Lightning")
			pickedtype = /mob/living/simple_animal/hostile/sutando/beam

		if("Protector")
			pickedtype = /mob/living/simple_animal/hostile/sutando/protector

		if("Charger")
			pickedtype = /mob/living/simple_animal/hostile/sutando/charger

		if("Assassin")
			pickedtype = /mob/living/simple_animal/hostile/sutando/assassin

		if("Dextrous")
			pickedtype = /mob/living/simple_animal/hostile/sutando/dextrous

	var/list/sutandos = user.hasparasites()
	if(sutandos.len && !allowmultiple)
		user << "<span class='holoparasite'>You already have a [mob_name]!</span>" //nice try, bucko
		used = FALSE
		return
	var/mob/living/simple_animal/hostile/sutando/G = new pickedtype(user, theme)
	G.summoner = user
	G.key = key
	G.mind.enslave_mind_to_creator(user)
	switch(theme)
		if("tech")
			user << "[G.tech_fluff_string]"
			user << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> is now online!</span>"
		if("magic")
			user << "[G.magic_fluff_string]"
			user << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been summoned!</span>"
		if("carp")
			user << "[G.carp_fluff_string]"
			user << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been caught!</span>"
	user.verbs += /mob/living/proc/sutando_comm
	user.verbs += /mob/living/proc/sutando_recall
	user.verbs += /mob/living/proc/sutando_reset

/obj/item/weapon/sutandocreator/choose
	random = FALSE

/obj/item/weapon/sutandocreator/choose/dextrous
	possible_sutandos = list("Assassin", "Chaos", "Charger", "Dextrous", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Support")

/obj/item/weapon/sutandocreator/choose/wizard
	possible_sutandos = list("Assassin", "Chaos", "Charger", "Dextrous", "Explosive", "Lightning", "Protector", "Ranged", "Standard")
	allowmultiple = TRUE

/obj/item/weapon/sutandocreator/tech
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

/obj/item/weapon/sutandocreator/tech/choose/traitor
	possible_sutandos = list("Assassin", "Chaos", "Charger", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Support")

/obj/item/weapon/sutandocreator/tech/choose
	random = FALSE

/obj/item/weapon/sutandocreator/tech/choose/dextrous
	possible_sutandos = list("Assassin", "Chaos", "Charger", "Dextrous", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Support")

/obj/item/weapon/paper/sutando
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
 <b>Standard</b>: Devastating close combat attacks and high damage resist. Can smash through weak walls.<br>
 <br>
"}

/obj/item/weapon/paper/sutando/update_icon()
	return

/obj/item/weapon/paper/sutando/wizard
	name = "sutando Guide"
	info = {"<b>A list of sutando Types</b><br>

 <br>
 <b>Assassin</b>: Does medium damage and takes full damage, but can enter stealth, causing its next attack to do massive damage and ignore armor. However, it becomes briefly unable to recall after attacking from stealth.<br>
 <br>
 <b>Chaos</b>: Ignites enemies on touch and causes them to hallucinate all nearby people as the sutando. Automatically extinguishes the user if they catch on fire.<br>
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


/obj/item/weapon/storage/box/syndie_kit/sutando
	name = "holoparasite injector kit"

/obj/item/weapon/storage/box/syndie_kit/sutando/New()
	..()
	new /obj/item/weapon/sutandocreator/tech/choose/traitor(src)
	new /obj/item/weapon/paper/sutando(src)
	return

/obj/item/weapon/sutandocreator/carp
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

/obj/item/weapon/sutandocreator/carp/choose
	random = FALSE
