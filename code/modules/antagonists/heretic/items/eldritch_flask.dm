// An unholy water flask, but for heretics.
// Heals heretics, harms non-heretics. Pretty much identical.
/obj/item/reagent_containers/cup/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Токсичный для недалеких умов, но освежающий для тех, кто имеет знания о потустороннем."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "eldritch_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)
	can_lid = FALSE

// Unique bottle that lets you instantly draw blood from a victim
/obj/item/reagent_containers/cup/phylactery
	name = "phylactery of damnation"
	desc = "Служит для похищения крови у тех, кому ещё предстоит стать жертвами."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "phylactery"
	base_icon_state = "phylactery"
	has_variable_transfer_amount = FALSE
	initial_reagent_flags = OPENCONTAINER | DUNKABLE | TRANSPARENT
	volume = 10
	/// Cooldown before you can steal blood again
	COOLDOWN_DECLARE(drain_cooldown)

/obj/item/reagent_containers/cup/phylactery/interact_with_atom_secondary(atom/target, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, drain_cooldown))
		user.balloon_alert(user, "нельзя похитить так быстро!")
		return NONE
	if(!isliving(target))
		return NONE
	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/living_target = target
	if(living_target == user)
		return ITEM_INTERACT_BLOCKING
	if(reagents.total_volume >= reagents.maximum_volume)
		to_chat(user, span_notice("[capitalize(src.declent_ru(NOMINATIVE))] полон."))
		return ITEM_INTERACT_BLOCKING
	if(living_target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		to_chat(user, span_warning("Вы не можете похитить кровь у [living_target.declent_ru(GENITIVE)]!"))
		COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
		to_chat(living_target, span_warning("Вы чувствуете, как некая сила пыталась украсть вашу кровь, но получила отпор!"))
		return ITEM_INTERACT_BLOCKING
	var/drawn_amount = min(reagents.maximum_volume - reagents.total_volume, 5)
	if(living_target.transfer_blood_to(src, drawn_amount))
		to_chat(user, span_notice("Вы забираете немного крови у [living_target.declent_ru(GENITIVE)]."))
		to_chat(living_target, span_warning("Вы чувствуете крошечный укол!"))
		COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
		playsound(src, 'sound/effects/chemistry/catalyst.ogg', 20, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)
	else
		to_chat(user, span_warning("Вы не можете похитить кровь у [living_target.declent_ru(GENITIVE)]!"))
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/cup/phylactery/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(get_dist(user, interacting_with) <= 30)
		return interact_with_atom_secondary(interacting_with, user, modifiers)
	return ..()

/obj/item/reagent_containers/cup/phylactery/update_icon_state()
	. = ..()
	switch(reagents.total_volume)
		if(0)
			icon_state = base_icon_state
		if(0.1 to 5)
			icon_state = base_icon_state + "_1"
		if(5.1 to 10)
			icon_state = base_icon_state + "_2"

// Funny potion that is basically an aheal. The downside is that it puts you to sleep for a minute.
/obj/item/ether
	name = "ether of the newborn"
	desc = "Фляжка с густой зелёной жидкостью, вызывающей тошноту. Она полностью восстанавливает ваш организм, а затем погружает вас в крепкий сон на одну минуту."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "poison_flask"

/obj/item/ether/attack_self(mob/living/user, modifiers)
	. = ..()
	user.revive(HEAL_ALL)
	for(var/obj/item/implant/to_remove in user.implants)
		to_remove.removed(user)

	user.apply_status_effect(/datum/status_effect/eldritch_sleep)
	user.SetSleeping(60 SECONDS)
	qdel(src)

/datum/status_effect/eldritch_sleep
	id = "eldritch_sleep"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_sleep
	show_duration = TRUE
	remove_on_fullheal = TRUE
	/// List of traits our drinker gets while they are asleep
	var/list/sleeping_traits = list(TRAIT_NOBREATH, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT)

/datum/status_effect/eldritch_sleep/on_apply()
	. = ..()
	owner.add_traits(sleeping_traits, TRAIT_STATUS_EFFECT(id))
	owner.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_ELDRITCH_ETHER)

/datum/status_effect/eldritch_sleep/on_remove()
	owner.SetSleeping(0) // Wake up bookworm, we have some heathens to burn
	owner.remove_traits(sleeping_traits, TRAIT_STATUS_EFFECT(id))
	owner.reagents?.remove_all(100) // If someone gives you over 100 units of poison while you sleep then you deserve this L
	owner.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_ELDRITCH_ETHER)

/atom/movable/screen/alert/status_effect/eldritch_sleep
	name = "Жуткая спячка"
	desc = "Вы чувствуете неописуемое тепло, которое оберегает вас..."
	icon_state = "eldritch_slumber"
