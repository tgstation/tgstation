#define SPELLBOOK_CATEGORY_PERKS "Perks"

/datum/spellbook_entry/perks
	desc = "Main node of perks"
	category = SPELLBOOK_CATEGORY_PERKS
	refundable = FALSE // no refund
	requires_wizard_garb = FALSE

/datum/spellbook_entry/perks/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	var/datum/antagonist/wizard/wizard_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(wizard_datum)
		wizard_datum.perks += src
	to_chat(user, span_notice("You got a new perk: [src.name]."))
	return TRUE

/datum/spellbook_entry/perks/fourhands
	name = "Four Hands"
	desc = "Gives you even more hands to perform magic"

/datum/spellbook_entry/perks/fourhands/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	user.change_number_of_hands(4)

/datum/spellbook_entry/perks/wormborn
	name = "Worm Born"
	desc = "Your soul is infested with mana worms. When you die, you will be reborn as a large worm. \
		When the worm dies, it has no such luck. Parasitic infection prevents you from binding your soul to objects."
	no_coexistance_typecache = list(/datum/action/cooldown/spell/lichdom)

/datum/spellbook_entry/perks/wormborn/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	user.AddComponent(/datum/component/wormborn)

/datum/spellbook_entry/perks/dejavu
	name = "Déjà vu"
	desc = "Every 60 seconds returns you to the place where you were 60 seconds ago with the same amount of health as you had 60 seconds ago."

/datum/spellbook_entry/perks/dejavu/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	RegisterSignal(user, COMSIG_ENTER_AREA, PROC_REF(give_dejavu))

/datum/spellbook_entry/perks/dejavu/proc/give_dejavu(mob/living/carbon/human/wizard, area/new_area)
	SIGNAL_HANDLER

	if(istype(new_area, /area/centcom))
		return
	wizard.AddComponent(/datum/component/dejavu/wizard, 1, 60 SECONDS, TRUE)
	UnregisterSignal(wizard, COMSIG_ENTER_AREA)

/datum/spellbook_entry/perks/spell_lottery
	name = "Spells Lottery"
	desc = "Spells Lottery gives you the chance to get something from the book absolutely free, but you can no longer refund any purchases."

/datum/spellbook_entry/perks/spell_lottery/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	ADD_TRAIT(user, TRAIT_SPELLS_LOTTERY, REF(src))

/datum/spellbook_entry/perks/gamble
	name = "Gamble"
	desc = "You get 2 random perks."

/datum/spellbook_entry/perks/gamble/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	var/datum/antagonist/wizard/check_perks = user.mind.has_antag_datum(/datum/antagonist/wizard)
	var/perks_allocated = 0
	var/list/taking_perks = list()
	for(var/datum/spellbook_entry/perks/generate_perk in book.entries)
		if(istype(generate_perk, src))
			continue
		if(check_perks && is_type_in_list(generate_perk, check_perks.perks))
			continue
		taking_perks += generate_perk
		perks_allocated++
		if(perks_allocated >= 2)
			break
	if(taking_perks.len < 1)
		to_chat(user, span_warning("Gamble cannot give 2 perks, so points are returned"))
		return FALSE
	taking_perks = shuffle(taking_perks)
	for(var/datum/spellbook_entry/perks/perks_ready in taking_perks)
		perks_ready.buy_spell(user, book, log_buy)

/datum/spellbook_entry/perks/heart_eater
	name = "Heart Eater"
	desc = "Gives you ability to obtain a person's life force by eating their heart. \
		By eating someone's heart you can increase your damage resistance or gain random mutation. \
		Heart also give strong healing buff."

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
		Projectiles pass through you, but you lose 25% of your health and you are hunted by a terrible curse which wants to return you to the afterlife."

/datum/spellbook_entry/perks/transparence/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	user.maxHealth *= 0.75
	user.alpha = 125
	ADD_TRAIT(user, TRAIT_UNHITTABLE_BY_PROJECTILES, REF(src))
	RegisterSignal(user, COMSIG_ENTER_AREA, PROC_REF(make_stalker))

/datum/spellbook_entry/perks/transparence/proc/make_stalker(mob/living/carbon/human/wizard, area/new_area)
	SIGNAL_HANDLER

	if(new_area == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	wizard.gain_trauma(/datum/brain_trauma/magic/stalker)
	UnregisterSignal(wizard, COMSIG_ENTER_AREA)

/datum/spellbook_entry/perks/magnetism
	name = "Magnetism"
	desc = "You get a small gravity anomaly that orbit around you. \
		Nearby things will be attracted to you."

/datum/spellbook_entry/perks/magnetism/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	var/atom/movable/magnitizm = new /obj/effect/wizard_magnetism(get_turf(user))
	magnitizm.orbit(user, 20)

/obj/effect/wizard_magnetism
	name = "magnetic anomaly"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	/// We need to orbit around someone.
	var/datum/weakref/owner

/obj/effect/wizard_magnetism/New(loc, ...)
	. = ..()
	transform *= 0.4

/obj/effect/wizard_magnetism/orbit(atom/new_owner, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	. = ..()
	if(!isliving(new_owner))
		return
	owner = WEAKREF(new_owner)
	RegisterSignal(new_owner, COMSIG_ENTER_AREA, PROC_REF(check_area))
	RegisterSignal(new_owner, COMSIG_LIVING_DEATH, PROC_REF(on_owner_death))

/obj/effect/wizard_magnetism/proc/check_area(mob/living/wizard, area/new_area)
	SIGNAL_HANDLER

	if(new_area == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	START_PROCESSING(SSprocessing, src)
	UnregisterSignal(wizard, COMSIG_ENTER_AREA)

/obj/effect/wizard_magnetism/proc/on_owner_death()
	SIGNAL_HANDLER

	stop_orbit()

/obj/effect/wizard_magnetism/process(seconds_per_tick)
	if(isnull(owner))
		stop_orbit()
		return
	var/mob/living/wizard = owner.resolve()
	var/list/things_in_range = orange(5, wizard) - orange(1, wizard)
	for(var/obj/take_object in things_in_range)
		if(!take_object.anchored)
			step_towards(take_object, wizard)
	for(var/mob/living/living_mov in things_in_range)
		if(wizard)
			if(living_mov == wizard)
				continue
		if(!living_mov.mob_negates_gravity())
			step_towards(living_mov, wizard)

/obj/effect/wizard_magnetism/stop_orbit()
	STOP_PROCESSING(SSprocessing, src)
	qdel(src)

#undef SPELLBOOK_CATEGORY_PERKS
