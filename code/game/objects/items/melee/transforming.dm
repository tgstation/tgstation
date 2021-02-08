/obj/item/melee/transforming
	sharpness = SHARP_EDGED
	bare_wound_bonus = 20
	stealthy_audio = TRUE //Most of these are antag weps so we dont want them to be /too/ overt.
	var/active = FALSE
	var/force_on = 30 //force when active
	var/faction_bonus_force = 0 //Bonus force dealt against certain factions
	var/throwforce_on = 20
	var/icon_state_on = "axe1"
	var/hitsound_on = 'sound/weapons/blade1.ogg'
	var/list/attack_verb_on = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	var/list/attack_verb_off = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	w_class = WEIGHT_CLASS_SMALL
	var/bonus_active = FALSE //If the faction damage bonus is active
	var/list/nemesis_factions //Any mob with a faction that exists in this list will take bonus damage/effects
	var/w_class_on = WEIGHT_CLASS_BULKY
	var/clumsy_check = TRUE
	/// If we get sharpened with a whetstone, save the bonus here for later use if we un/redeploy
	var/sharpened_bonus
	/// sound to play when turned on
	var/sound_when_on = 'sound/weapons/saberon.ogg'
	/// sound to play when turned on
	var/sound_when_off = 'sound/weapons/saberoff.ogg'

/obj/item/melee/transforming/Initialize()
	. = ..()
	if(active)
		if(attack_verb_on.len)
			attack_verb_continuous = attack_verb_on
	else
		if(attack_verb_off.len)
			attack_verb_continuous = attack_verb_off
		if(embedding)
			updateEmbedding()
	if(sharpness)
		AddComponent(/datum/component/butchering, 50, 100, 0, hitsound)
	RegisterSignal(src, COMSIG_ITEM_SHARPEN_ACT, .proc/on_sharpen)

/obj/item/melee/transforming/attack_self(mob/living/carbon/user)
	if(transform_weapon(user))
		clumsy_transform_effect(user)

/obj/item/melee/transforming/attack(mob/living/target, mob/living/carbon/human/user)
	var/nemesis_faction = FALSE
	if(LAZYLEN(nemesis_factions))
		for(var/F in target.faction)
			if(F in nemesis_factions)
				nemesis_faction = TRUE
				force += faction_bonus_force
				nemesis_effects(user, target)
				break
	. = ..()
	if(nemesis_faction)
		force -= faction_bonus_force

/obj/item/melee/transforming/proc/transform_weapon(mob/living/user, supress_message_text)
	active = !active
	if(active)
		force = force_on + sharpened_bonus
		throwforce = throwforce_on + sharpened_bonus
		hitsound = hitsound_on
		throw_speed = 4
		if(attack_verb_on.len)
			attack_verb_continuous = attack_verb_on
		icon_state = icon_state_on
		w_class = w_class_on
		if(embedding)
			updateEmbedding()
	else
		force = initial(force) + (get_sharpness() ? sharpened_bonus : 0)
		throwforce = initial(throwforce) + (get_sharpness() ? sharpened_bonus : 0)
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(attack_verb_off.len)
			attack_verb_continuous = attack_verb_off
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		if(embedding)
			disableEmbedding()

	transform_messages(user, supress_message_text)
	add_fingerprint(user)
	return TRUE

/obj/item/melee/transforming/proc/nemesis_effects(mob/living/user, mob/living/target)
	return

/obj/item/melee/transforming/proc/transform_messages(mob/living/user, supress_message_text)
	playsound(user, active ? sound_when_on : sound_when_off, 35, TRUE)  //changed it from 50% volume to 35% because deafness
	if(!supress_message_text)
		to_chat(user, "<span class='notice'>[src] [active ? "is now active":"can now be concealed"].</span>")

/obj/item/melee/transforming/proc/clumsy_transform_effect(mob/living/user)
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
		user.take_bodypart_damage(5,5)

/obj/item/melee/transforming/proc/on_sharpen(datum/source, increment, max)
	SIGNAL_HANDLER

	if(sharpened_bonus)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	if(force_on + increment > max)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	sharpened_bonus = increment

/obj/item/melee/transforming/butter_fly
	name = "butterfly knife"
	icon_state = "butterfly"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "Float like a butterfly, sting like a knife."
	flags_1 = CONDUCT_1
	force = 3
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_speed = 3
	throw_range = 6
	bare_wound_bonus = 5
	stealthy_audio = FALSE
	force_on = 15
	icon_state_on = "butterfly_ext"
	hitsound_on = 'sound/weapons/bladeslice.ogg'
	attack_verb_on = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_off = list("pokes")
	w_class_on = WEIGHT_CLASS_SMALL
	sound_when_on = 'sound/weapons/batonextend.ogg'
	sound_when_off = 'sound/weapons/batonextend.ogg'
	///damage dealt on backstab
	var/backstab_damage = 40
	COOLDOWN_DECLARE(stab_cooldown)
	///cooldown on stabbing
	var/stab_cooldown_time = 3 SECONDS

/obj/item/melee/transforming/butter_fly/attack_alt(mob/living/victim, mob/living/user, params)
	if(!COOLDOWN_FINISHED(src, stab_cooldown))
		to_chat(user, "<span class='warning'>You aren't ready to backstab!</span>")
		return ALT_ATTACK_CONTINUE_CHAIN
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You are a pacifist.</span>")
		return ALT_ATTACK_CONTINUE_CHAIN
	/// fast dir checking to check for backstab
	if(active && (victim.dir == user.dir) && victim.density)
		///clumsy clown might backstab himself
		if((victim == user)  && (!HAS_TRAIT(user, TRAIT_CLUMSY)))
			return ALT_ATTACK_CONTINUE_CHAIN
		victim.emote("scream")
		user.visible_message("<span class='danger'>[user] backstabs [victim] with [src]!</span>")
		user.do_attack_animation(src)
		victim.apply_damage(backstab_damage, def_zone = BODY_ZONE_CHEST, wound_bonus = -5, bare_wound_bonus = 15, sharpness = SHARP_EDGED)
	else
	/// face strab
		attack(victim, user)
	COOLDOWN_START(src, stab_cooldown, stab_cooldown_time)

	return ALT_ATTACK_CONTINUE_CHAIN


///admin grief version
/obj/item/melee/transforming/butter_fly/admingrief
	backstab_damage = 600
	stab_cooldown_time = 1 SECONDS