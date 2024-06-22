#define SPELLBOOK_CATEGORY_PERKS "Perks"

/datum/spellbook_entry/perks
	desc = "Main nod of perks"
	category = SPELLBOOK_CATEGORY_PERKS
	refundable = FALSE // no refund
	requires_wizard_garb = FALSE

/datum/spellbook_entry/perks/can_buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(book.uses < cost)
		return FALSE
	var/datum/antagonist/wizard/wizard_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(!wizard_datum)
		stack_trace("Someone as not a wizard trying to get perks.")
		return TRUE
	for(var/spell in user.actions)
		if(is_type_in_typecache(spell, no_coexistance_typecache))
			return FALSE
	if(is_type_in_list(src, wizard_datum.perks))
		to_chat(user, span_warning("This perk already learned!"))
		return FALSE
	return TRUE

/datum/spellbook_entry/perks/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	var/datum/antagonist/wizard/wizard_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(wizard_datum)
		wizard_datum.perks += src
	to_chat(user, span_notice("You got a new perk: [src.name]."))
	return TRUE

/datum/spellbook_entry/perks/can_refund(mob/living/carbon/human/user, obj/item/spellbook/book)
	return TRUE

/datum/spellbook_entry/perks/refund_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/area/centcom/wizard_station/wizard_home = GLOB.areas_by_type[/area/centcom/wizard_station]
	if(get_area(user) != wizard_home)
		to_chat(user, span_warning("You can only refund spells at the wizard lair!"))
		return -1
	var/datum/antagonist/wizard/wizard_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(wizard_datum)
		var/datum/spellbook_entry/perks/perk_to_remove = locate(src) in wizard_datum.perks
		if(perk_to_remove)
			wizard_datum.perks -= perk_to_remove
			return perk_to_remove.cost
	return -1

/datum/spellbook_entry/perks/fourhands
	name = "Four Hands"
	desc = "Gives you even more hands to perform magic"

/datum/spellbook_entry/perks/fourhands/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	user.change_number_of_hands(4)

/datum/spellbook_entry/perks/wormborn
	name = "Worm Born"
	desc = "A worm parasite grows in your body. When the host dies, he will turn into a large worm. \
	When worm die then you will not be able to be reborn (probably). Can't buy bind souls on this purchases."
	no_coexistance_typecache = list(/datum/action/cooldown/spell/lichdom)

/datum/spellbook_entry/perks/wormborn/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	user.AddComponent(/datum/component/wormborn)

/datum/spellbook_entry/perks/dejavu
	name = "Dejavu"
	desc = "Every 60 seconds returns you to the place where you were 60 seconds ago with the same amount of health as you had 60 seconds ago"

/datum/spellbook_entry/perks/dejavu/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	check_safe_location(user)

/datum/spellbook_entry/perks/dejavu/proc/check_safe_location(mob/living/carbon/human/user)
	if(get_area(user) == GLOB.areas_by_type[/area/centcom/wizard_station])
		addtimer(CALLBACK(src, PROC_REF(check_safe_location), user), 10 SECONDS)
		return
	user.AddComponent(/datum/component/dejavu/timeline, -1, 60 SECONDS)

/datum/spellbook_entry/perks/ecologist
	name = "Ecologist"
	desc = "your body becomes a vessel for rapidly growing vines. \
	as soon as the vessel receives damage, the vines will be released from and surround the vessel and then begin to grow rapidly"

/datum/spellbook_entry/perks/ecologist/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	user.AddComponent(/datum/component/ecologist)

/datum/spellbook_entry/perks/angel_doll
	name = "Angel Doll"
	desc = "You grow angel wings. The corpses near you become infected with the zombie infection and will soon be reborn to take over the entire station. \
	You become immune to virus... but zombies will still attack you."

/datum/spellbook_entry/perks/angel_doll/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	var/obj/item/organ/external/wings/functional/zombie_wings/angel_wing = new(get_turf(user))
	angel_wing.Insert(user)

/datum/spellbook_entry/perks/sale_off
	name = "Sale Off"
	desc = "Spell sale gives you the chance to get something from the book absolutely free, but you can no longer refund any purchases."

/datum/spellbook_entry/perks/sale_off/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	ADD_TRAIT(user, TRAIT_SPELL_FOR_SALE, REF(src))

/datum/spellbook_entry/perks/gamble
	name = "Gamble"
	desc = "You get 2 random perks."

/datum/spellbook_entry/perks/gamble/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	var/datum/antagonist/wizard/check_perks = user.mind.has_antag_datum(/datum/antagonist/wizard)
	var/only_two
	for(var/datum/spellbook_entry/perks/generate_perk as anything in book.entries)
		if(!istype(generate_perk))
			continue
		if(istype(generate_perk, src))
			continue
		if(check_perks && is_type_in_list(generate_perk, check_perks.perks))
			continue
		if(!generate_perk.buy_spell(user, book, log_buy))
			continue
		only_two++
		if(only_two >= 2)
			break
	if(only_two < 2)
		to_chat(user, span_warning("Gamble cannot give 2 perks, so points are returned"))
		return FALSE

/datum/spellbook_entry/perks/heart_eater
	name = "Heart Eater"
	desc = "Gives you ability to obtain a person's life force by eating their heart. \
	By eating someone's heart you can increase your maximum health or decrease it but get a random mutation."

/datum/spellbook_entry/perks/heart_eater/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	user.AddComponent(/datum/component/heart_eater)

/datum/spellbook_entry/perks/slime_friends
	name = "Slime Friends"
	desc = "Slimes are your friends. \
	Every 15 seconds you lose some nutriments and summon a random evil slime to fight on your side."

/datum/spellbook_entry/perks/slime_friends/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	user.AddComponent(/datum/component/slime_friends)

/datum/spellbook_entry/perks/transparence
	name = "Transparence"
	desc = "You become a little closer to the world of the dead. \
	Projectiles pass through you, but you lose 25% of your health and you are hunted by an evil stalker who wants to take you to the world of the dead"

/datum/spellbook_entry/perks/transparence/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	if(user.alpha > 125)
		user.alpha = 125
	user.maxHealth *= 0.75
	try_to_make_stalker(user)
	ADD_TRAIT(user, TRAIT_UNHITTABLE_BY_PROJECTILES, REF(src))

/datum/spellbook_entry/perks/transparence/proc/try_to_make_stalker(mob/living/carbon/human/user)
	if(get_area(user) == GLOB.areas_by_type[/area/centcom/wizard_station])
		addtimer(CALLBACK(src, PROC_REF(try_to_make_stalker), user), 10 SECONDS)
		return
	user.gain_trauma(/datum/brain_trauma/magic/stalker)

/datum/spellbook_entry/perks/magnetism
	name = "Magnetism"
	desc = "You get a small gravity anomaly that orbit around you. \
	Every second attracts unscrewed objects and unscrewed people nearby closer to you."

/datum/spellbook_entry/perks/magnetism/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	var/atom/movable/magnitizm = new /obj/effect/magnitizm(get_turf(user))
	magnitizm.orbit(user, 20)

/obj/effect/magnitizm
	name = "magnitizm anomaly"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	var/mob/living/owner
	var/timer

/obj/effect/magnitizm/New(loc, ...)
	. = ..()
	transform *= 0.4

/obj/effect/magnitizm/orbit(atom/A, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	. = ..()
	if(!isliving(A))
		return
	owner = A
	timer = addtimer(CALLBACK(src, PROC_REF(magnetik)), 1 SECONDS)
	RegisterSignal(CALLBACK(owner, COMSIG_LIVING_LIFE, PROC_REF(magnetik_check)))

/obj/effect/magnitizm/proc/perform_throw(obj/throw_it, atom/throw_there)
	throw_it.throw_at(throw_there, 5, 2)

/obj/effect/magnitizm/stop_orbit()
	if(!isnull(owner))
		UnregisterSignal(owner, COMSIG_LIVING_LIFE)
	owner = null
	timer = null
	Destroy()

/obj/effect/magnitizm/proc/magnetik_check()
	SIGNAL_HANDLER

	if(isnull(timer))
		timer = addtimer(CALLBACK(src, PROC_REF(magnetik)), 1 SECONDS)

/obj/effect/magnitizm/proc/magnetik()
	if(!timer)
		return
	if(!owner)
		return
	if(!owner.stat == DEAD)
		timer = null
		return
	if(get_area(owner) == GLOB.areas_by_type[/area/centcom/wizard_station])
		timer = addtimer(CALLBACK(src, PROC_REF(magnetik)), 1 SECONDS)
		return
	for(var/obj/take_object in orange(5, owner))
		if(take_object in orange(1, owner))
			continue
		if(!take_object.anchored)
			step_towards(take_object,owner)
	for(var/mob/living/living_mov in orange(5, owner))
		if(living_mov in orange(1, owner))
			continue
		if(owner)
			if(living_mov == owner)
				continue
		if(!living_mov.mob_negates_gravity())
			step_towards(living_mov, owner)

	timer = addtimer(CALLBACK(src, PROC_REF(magnetik)), 1 SECONDS)

#undef SPELLBOOK_CATEGORY_PERKS
