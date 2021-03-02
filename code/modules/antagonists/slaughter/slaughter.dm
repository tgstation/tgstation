//////////////////Imp

/mob/living/simple_animal/hostile/imp
	name = "imp"
	real_name = "imp"
	unique_name = TRUE
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	icon = 'icons/mob/mob.dmi'
	icon_state = "imp"
	icon_living = "imp"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speed = 1
	combat_mode = TRUE
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("hell")
	attack_verb_continuous = "wildly tears into"
	attack_verb_simple = "wildly tear into"
	maxHealth = 200
	health = 200
	healable = 0
	obj_damage = 40
	melee_damage_lower = 10
	melee_damage_upper = 15
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	del_on_death = TRUE
	deathmessage = "screams in agony as it sublimates into a sulfurous smoke."
	deathsound = 'sound/magic/demon_dies.ogg'
	var/playstyle_string = "<span class='big bold'>You are an imp,</span><B> a mischievous creature from hell. You are the lowest rank on the hellish totem pole \
							Though you are not obligated to help, perhaps by aiding a higher ranking devil, you might just get a promotion. However, you are incapable \
							of intentionally harming a fellow devil.</B>"

/datum/antagonist/imp
	name = "Imp"
	antagpanel_category = "Other"
	show_in_roundend = FALSE

/datum/antagonist/imp/on_gain()
	. = ..()
	give_objectives()

/datum/antagonist/imp/proc/give_objectives()
	var/datum/objective/newobjective = new
	newobjective.explanation_text = "Try to get a promotion to a higher devilish rank."
	newobjective.owner = owner
	objectives += newobjective

//////////////////The Man Behind The Slaughter

/mob/living/simple_animal/hostile/imp/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	unique_name = FALSE
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	icon_state = "daemon"
	icon_living = "daemon"
	minbodytemp = 0
	obj_damage = 50
	melee_damage_lower = 15 // reduced from 30 to 15 with wounds since they get big buffs to slicing wounds
	melee_damage_upper = 15
	wound_bonus = -10
	bare_wound_bonus = 0
	sharpness = SHARP_EDGED
	playstyle_string = "<span class='big bold'>You are a slaughter demon,</span><B> a terrible creature from another realm. You have a single desire: To kill. \
							You may use the \"Blood Crawl\" ability near blood pools to travel through them, appearing and disappearing from the station at will. \
							Pulling a dead or unconscious mob while you enter a pool will pull them in with you, allowing you to feast and regain your health. \
							You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. \
							You gain strength the more attacks you land on live humanoids, though this resets when you return to the blood zone. You can also \
							launch a devastating slam attack with ctrl+shift+click, capable of smashing bones in one strike.</B>"

	loot = list(/obj/effect/decal/cleanable/blood, \
				/obj/effect/decal/cleanable/blood/innards, \
				/obj/item/organ/heart/demon)
	del_on_death = 1
	///Sound played when consuming a body
	var/feast_sound = 'sound/magic/demon_consume.ogg'
	/// How long it takes for the alt-click slam attack to come off cooldown
	var/slam_cooldown_time = 45 SECONDS
	/// The actual instance var for the cooldown
	var/slam_cooldown = 0
	/// How many times we have hit humanoid targets since we last bloodcrawled, scaling wounding power
	var/current_hitstreak = 0
	/// How much both our wound_bonus and bare_wound_bonus go up per hitstreak hit
	var/wound_bonus_per_hit = 5
	/// How much our wound_bonus hitstreak bonus caps at (peak demonry)
	var/wound_bonus_hitstreak_max = 12

/mob/living/simple_animal/hostile/imp/slaughter/Initialize(mapload, obj/effect/dummy/phased_mob/bloodpool)//Bloodpool is the blood pool we spawn in
	..()
	ADD_TRAIT(src, TRAIT_BLOODCRAWL_EAT, "innate")
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/phased_mob))
		bloodspell.phased = TRUE
	if(bloodpool)
		bloodpool.RegisterSignal(src, list(COMSIG_LIVING_AFTERPHASEIN,COMSIG_PARENT_QDELETING), /obj/effect/dummy/phased_mob/.proc/deleteself)

/mob/living/simple_animal/hostile/imp/slaughter/CtrlShiftClickOn(atom/A)
	if(!isliving(A))
		return ..()

	if(!Adjacent(A))
		to_chat(src, "<span class='warning'>You are too far away to use your slam attack on [A]!</span>")
		return

	if(slam_cooldown + slam_cooldown_time > world.time)
		to_chat(src, "<span class='warning'>Your slam ability is still on cooldown!</span>")
		return

	face_atom(A)
	var/mob/living/victim = A
	victim.take_bodypart_damage(brute=20, wound_bonus=wound_bonus) // don't worry, there's more punishment when they hit something
	visible_message("<span class='danger'>[src] slams into [victim] with monstrous strength!</span>", "<span class='danger'>You slam into [victim] with monstrous strength!</span>", ignored_mobs=victim)
	to_chat(victim, "<span class='userdanger'>[src] slams into you with monstrous strength, sending you flying like a ragdoll!</span>")
	var/turf/yeet_target = get_edge_target_turf(victim, dir)
	victim.throw_at(yeet_target, 10, 5, src)
	slam_cooldown = world.time
	log_combat(src, victim, "slaughter slammed")

/mob/living/simple_animal/hostile/imp/slaughter/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(iscarbon(A))
		var/mob/living/carbon/target = A
		if(target.stat != DEAD && target.mind && current_hitstreak < wound_bonus_hitstreak_max)
			current_hitstreak++
			wound_bonus += wound_bonus_per_hit
			bare_wound_bonus += wound_bonus_per_hit

	return ..()

/obj/effect/decal/cleanable/blood/innards
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."
	gender = NEUTER
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"
	random_icon_states = null

/mob/living/simple_animal/hostile/imp/slaughter/phasein()
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/slaughter)
	addtimer(CALLBACK(src, .proc/remove_movespeed_modifier, /datum/movespeed_modifier/slaughter), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	decay_factor = 0

/obj/item/organ/heart/demon/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

/obj/item/organ/heart/demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!</span>", \
		"<span class='danger'>An unnatural hunger consumes you. You raise [src] your mouth and devour it!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == /obj/effect/proc_holder/spell/bloodcrawl)
			to_chat(user, "<span class='warning'>...and you don't feel any different.</span>")
			qdel(src)
			return
	user.visible_message("<span class='warning'>[user]'s eyes flare a deep crimson!</span>", \
		"<span class='userdanger'>You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!</span>")
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E

/obj/item/organ/heart/demon/Insert(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))

/obj/item/organ/heart/demon/Remove(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)

/obj/item/organ/heart/demon/Stop()
	return 0 // Always beating.

/mob/living/simple_animal/hostile/imp/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles","titters","chuckles")
	emote_hear = list("guffaws","laughs")
	response_help_continuous = "hugs"
	attack_verb_continuous = "wildly tickles"
	attack_verb_simple = "wildly tickle"

	attack_sound = 'sound/items/bikehorn.ogg'
	feast_sound = 'sound/spookoween/scary_horn2.ogg'
	deathsound = 'sound/misc/sadtrombone.ogg'

	icon_state = "bowmon"
	icon_living = "bowmon"
	deathmessage = "fades out, as all of its friends are released from its \
		prison of hugs."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})

	// Keep the people we hug!
	var/list/consumed_mobs = list()

	playstyle_string = "<span class='big bold'>You are a laughter \
	demon,</span><B> a wonderful creature from another realm. You have a single \
	desire: <span class='clown'>To hug and tickle.</span><BR>\
	You may use the \"Blood Crawl\" ability near blood pools to travel \
	through them, appearing and disappearing from the station at will. \
	Pulling a dead or unconscious mob while you enter a pool will pull \
	them in with you, allowing you to hug them and regain your health.<BR> \
	You move quickly upon leaving a pool of blood, but the material world \
	will soon sap your strength and leave you sluggish.<BR>\
	What makes you a little sad is that people seem to die when you tickle \
	them; but don't worry! When you die, everyone you hugged will be \
	released and fully healed, because in the end it's just a jape, \
	sibling!</B>"

/mob/living/simple_animal/hostile/imp/slaughter/laughter/Initialize()
	. = ..()
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		icon_state = "honkmon"

/mob/living/simple_animal/hostile/imp/slaughter/laughter/Destroy()
	release_friends()
	. = ..()

/mob/living/simple_animal/hostile/imp/slaughter/laughter/ex_act(severity)
	switch(severity)
		if(1)
			death()
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/imp/slaughter/laughter/proc/release_friends()
	if(!consumed_mobs)
		return

	var/turf/T = get_turf(src)

	for(var/mob/living/M in consumed_mobs)
		if(!M)
			continue

		// Unregister the signal first, otherwise it'll trigger the "ling revived inside us" code
		UnregisterSignal(M, COMSIG_MOB_STATCHANGE)

		M.forceMove(T)
		if(M.revive(full_heal = TRUE, admin_revive = TRUE))
			M.grab_ghost(force = TRUE)
			playsound(T, feast_sound, 50, TRUE, -1)
			to_chat(M, "<span class='clown'>You leave [src]'s warm embrace, and feel ready to take on the world.</span>")

/mob/living/simple_animal/hostile/imp/slaughter/laughter/bloodcrawl_swallow(mob/living/victim)
	// Keep their corpse so rescue is possible
	consumed_mobs += victim
	RegisterSignal(victim, COMSIG_MOB_STATCHANGE, .proc/on_victim_statchange)

/* Handle signal from a consumed mob changing stat.
 *
 * A signal handler for if one of the laughter demon's consumed mobs has
 * changed stat. If they're no longer dead (because they were dead when
 * swallowed), eject them so they can't rip their way out from the inside.
 */
/mob/living/simple_animal/hostile/imp/slaughter/laughter/proc/on_victim_statchange(mob/living/victim, new_stat)
	SIGNAL_HANDLER

	if(new_stat == DEAD)
		return
	// Someone we've eaten has spontaneously revived; maybe nanites, maybe a changeling
	victim.forceMove(get_turf(src))
	victim.exit_blood_effect()
	victim.visible_message("<span class='warning'>[victim] falls out of the air, covered in blood, with a confused look on their face.</span>")
	consumed_mobs -= victim
	UnregisterSignal(victim, COMSIG_MOB_STATCHANGE)

/mob/living/simple_animal/hostile/imp/slaughter/engine_demon
	name = "engine demon"
	faction = list("hell", "neutral")
