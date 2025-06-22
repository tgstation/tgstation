//spears
/obj/item/spear
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "spearglass0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	icon_angle = -45
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 4
	demolition_mod = 0.75
	embed_type = /datum/embedding/spear
	armour_penetration = 10
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass= HALF_SHEET_MATERIAL_AMOUNT * 2)
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	sharpness = SHARP_POINTY
	max_integrity = 200
	armor_type = /datum/armor/item_spear
	wound_bonus = -15
	exposed_wound_bonus = 15
	/// For explosive spears, what we cry out when we use this to bap someone
	var/war_cry = "AAAAARGH!!!"
	/// The icon prefix for this flavor of spear
	var/icon_prefix = "spearglass"
	/// How much damage to do unwielded
	var/force_unwielded = 10
	/// How much damage to do wielded
	var/force_wielded = 18

/datum/embedding/spear
	impact_pain_mult = 2
	remove_pain_mult = 4
	jostle_chance = 2.5

/datum/armor/item_spear
	fire = 50
	acid = 30

/obj/item/spear/Initialize(mapload)
	. = ..()
	force = force_unwielded
	//decent in a pinch, but pretty bad.
	AddComponent(/datum/component/jousting, \
		max_tile_charge = 9, \
		min_tile_charge = 6, \
		)

	AddComponent(/datum/component/butchering, \
		speed = 10 SECONDS, \
		effectiveness = 70, \
	)
	AddComponent(/datum/component/two_handed, \
		force_unwielded = force_unwielded, \
		force_wielded = force_wielded, \
		icon_wielded = "[icon_prefix]1", \
	)
	add_headpike_component()
	update_appearance()

// I dunno man
/obj/item/spear/proc/add_headpike_component()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/headpike)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/spear/update_icon_state()
	icon_state = "[icon_prefix]0"
	return ..()

/obj/item/spear/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/spear/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	var/obj/item/shard/tip = locate() in components
	if(!tip)
		return ..()

	switch(tip.type)
		if(/obj/item/shard/plasma)
			force = 11
			throwforce = 21
			custom_materials = list(/datum/material/iron= HALF_SHEET_MATERIAL_AMOUNT, /datum/material/alloy/plasmaglass= HALF_SHEET_MATERIAL_AMOUNT * 2)
			icon_prefix = "spearplasma"
			force_unwielded = 11
			force_wielded = 19
			AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[icon_prefix]1")
		if(/obj/item/shard/titanium)
			force = 13
			throwforce = 21
			throw_range = 8
			throw_speed = 5
			custom_materials = list(/datum/material/iron= HALF_SHEET_MATERIAL_AMOUNT, /datum/material/alloy/titaniumglass= HALF_SHEET_MATERIAL_AMOUNT * 2)
			wound_bonus = -10
			force_unwielded = 13
			force_wielded = 18
			icon_prefix = "speartitanium"
			AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[icon_prefix]1")
		if(/obj/item/shard/plastitanium)
			force = 13
			throwforce = 22
			throw_range = 9
			throw_speed = 5
			custom_materials = list(/datum/material/iron= HALF_SHEET_MATERIAL_AMOUNT, /datum/material/alloy/plastitaniumglass= HALF_SHEET_MATERIAL_AMOUNT * 2)
			wound_bonus = -10
			exposed_wound_bonus = 20
			force_unwielded = 13
			force_wielded = 20
			icon_prefix = "spearplastitanium"
			AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[icon_prefix]1")

	update_appearance()
	return ..()

/obj/item/spear/explosive
	name = "explosive lance"
	icon_state = "spearbomb0"
	base_icon_state = "spearbomb"
	icon_prefix = "spearbomb"
	var/obj/item/grenade/explosive = null

/obj/item/spear/explosive/Initialize(mapload)
	. = ..()
	set_explosive(new /obj/item/grenade/iedcasing/spawned()) //For admin-spawned explosive lances

/obj/item/spear/explosive/proc/set_explosive(obj/item/grenade/G)
	if(explosive)
		QDEL_NULL(explosive)
	G.forceMove(src)
	explosive = G
	desc = "A makeshift spear with [G] attached to it"

/obj/item/spear/explosive/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	var/obj/item/grenade/nade = locate() in components
	if(nade)
		var/obj/item/spear/lancePart = locate() in components
		throwforce = lancePart.throwforce
		icon_prefix = lancePart.icon_prefix
		set_explosive(nade)
	return ..()

/obj/item/spear/explosive/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("[war_cry]", forced="spear warcry")
	explosive.forceMove(user)
	explosive.detonate()
	user.gib(DROP_ALL_REMAINS)
	qdel(src)
	return BRUTELOSS

/obj/item/spear/explosive/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to set your war cry.")

/obj/item/spear/explosive/click_alt(mob/user)
	var/input = tgui_input_text(user, "What do you want your war cry to be? You will shout it when you hit someone in melee.", "War Cry", max_length = 50)
	if(input)
		war_cry = input
	return CLICK_ACTION_SUCCESS


/obj/item/spear/explosive/afterattack(atom/movable/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || !istype(target))
		return
	if(target.resistance_flags & INDESTRUCTIBLE) //due to the lich incident of 2021, embedding grenades inside of indestructible structures is forbidden
		return
	if(HAS_TRAIT(target, TRAIT_GODMODE))
		return
	if(iseffect(target)) //and no accidentally wasting your moment of glory on graffiti
		return
	user.say("[war_cry]", forced="spear warcry")
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.set_resting(new_resting = TRUE, silent = TRUE, instant = TRUE)
		living_user.Move(get_turf(target))
		explosive.forceMove(get_turf(living_user))
		explosive.detonate(lanced_by=user)
		if(!QDELETED(living_user))
			living_user.set_resting(new_resting = FALSE, silent = TRUE, instant = TRUE)
	qdel(src)

//GREY TIDE
/obj/item/spear/grey_tide
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualties among Nanotrasen military forces."
	attack_verb_continuous = list("gores")
	attack_verb_simple = list("gore")
	force_unwielded = 15
	force_wielded = 25

/obj/item/spear/grey_tide/afterattack(atom/movable/target, mob/living/user, list/modifiers, list/attack_modifiers)
	user.faction |= "greytide([REF(user)])"
	if(!isliving(target))
		return
	var/mob/living/stabbed = target
	if(istype(stabbed, /mob/living/simple_animal/hostile/illusion))
		return
	if(stabbed.stat == CONSCIOUS && prob(50))
		var/mob/living/simple_animal/hostile/illusion/fake_clone = new(user.loc)
		fake_clone.faction = user.faction.Copy()
		fake_clone.Copy_Parent(user, 100, user.health/2.5, 12, 30)
		fake_clone.GiveTarget(stabbed)

//MILITARY
/obj/item/spear/military
	icon_state = "military_spear0"
	base_icon_state = "military_spear0"
	icon_prefix = "military_spear"
	name = "military javelin"
	desc = "A stick with a seemingly blunt spearhead on its end. Looks like it might break bones easily."
	attack_verb_continuous = list("attacks", "pokes", "jabs")
	attack_verb_simple = list("attack", "poke", "jab")
	throwforce = 30
	demolition_mod = 1
	wound_bonus = 5
	exposed_wound_bonus = 25
	throw_range = 9
	throw_speed = 5
	sharpness = NONE // we break bones instead of cutting flesh

/obj/item/spear/military/add_headpike_component()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/headpikemilitary)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/*
 * Bone Spear
 */
/obj/item/spear/bonespear //Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon_state = "bone_spear0"
	base_icon_state = "bone_spear0"
	icon_prefix = "bone_spear"
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."

	throwforce = 22
	armour_penetration = 15 //Enhanced armor piercing
	custom_materials = list(/datum/material/bone = HALF_SHEET_MATERIAL_AMOUNT * 7)
	force_unwielded = 12
	force_wielded = 20

/obj/item/spear/bonespear/add_headpike_component()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/headpikebone)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/*
 * Bamboo Spear
 */
/obj/item/spear/bamboospear //Blatant imitation of spear, but all natural. Also not valid for explosive modification.
	icon_state = "bamboo_spear0"
	base_icon_state = "bamboo_spear0"
	icon_prefix = "bamboo_spear"
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."

	throwforce = 22	//Better to throw
	custom_materials = list(/datum/material/bamboo = SHEET_MATERIAL_AMOUNT * 20)
	force_unwielded = 10
	force_wielded = 18


/obj/item/spear/bamboospear/add_headpike_component()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/headpikebamboo)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/**
 * Skybulge
 *
 * Gives a special ability that allows you to enter the skies an drop down upon a target.
 * Other than that ability, is a default spear with extra throw force, but no embedding.
 */
/obj/item/spear/skybulge
	name = "\improper Sky Bulge"
	desc = "A legendary stick with a very pointy tip. Takes you to the skies!"
	icon_state = "dragoonpole0"
	icon_prefix = "dragoonpole"
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "gores", "lances")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "gore", "lance")
	throwforce = 24
	embed_type = null //no embedding

	custom_materials = list(
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/alloy/plastitaniumglass = SHEET_MATERIAL_AMOUNT,
	)
	action_slots = ITEM_SLOT_HANDS
	actions_types = list(/datum/action/item_action/skybulge)

///The action button the spear gives, usable once a minute.
/datum/action/item_action/skybulge
	name = "Dragoon Strike"
	desc = "Jump up into the skies and fall down upon your opponents to deal double damage."
	check_flags = parent_type::check_flags | AB_CHECK_IMMOBILE | AB_CHECK_PHASED
	///Ref to the addtimer we have between jumping up and falling down, used to cancel early if you're incapacitated mid-jump.
	var/jump_timer
	///Cooldown time between jumps.
	var/jump_cooldown_time = 1 MINUTES
	/**
	 * boolean we set every time we jump, to know if we should take away the passflags we give,
	 * so we don't give/take when they have it from other sources (since we don't have traits, we have
	 * no way to tell which pass flags they get from what source.)
	 */
	var/gave_pass_flags = FALSE

/datum/action/item_action/skybulge/do_effect(trigger_flags)
	if(!HAS_TRAIT(target, TRAIT_WIELDED))
		owner.balloon_alert(owner, "not dual-wielded!")
		return
	var/time_left = S_TIMER_COOLDOWN_TIMELEFT(target, COOLDOWN_SKYBULGE_JUMP)
	if(time_left)
		owner.balloon_alert(owner, "[FLOOR(time_left * 0.1, 0.1)]s cooldown!")
		return
	//do after shows the progress bar as feedback, so nothing here.
	if(LAZYACCESS(owner.do_afters, target))
		return

	owner.balloon_alert(owner, "charging up...")
	ADD_TRAIT(target, TRAIT_NEEDS_TWO_HANDS, ACTION_TRAIT)
	INVOKE_ASYNC(src, PROC_REF(jump_up))

///Sends the owner up in the air and calls them back down, calling land() for aftereffects.
/datum/action/item_action/skybulge/proc/jump_up()
	if(!do_after(owner, 2 SECONDS, target = owner, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		REMOVE_TRAIT(target, TRAIT_NEEDS_TWO_HANDS, ACTION_TRAIT)
		return
	playsound(owner, 'sound/effects/footstep/heavy1.ogg', 50, 1)
	S_TIMER_COOLDOWN_START(target, COOLDOWN_SKYBULGE_JUMP, jump_cooldown_time)
	new /obj/effect/temp_visual/telegraphing/exclamation/following(get_turf(owner), 2.5 SECONDS, owner)

	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_attack_during_jump))
	ADD_TRAIT(target, TRAIT_NODROP, ACTION_TRAIT)
	owner.add_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_MOVE_FLYING), ACTION_TRAIT)

	if(owner.pass_flags & PASSTABLE)
		gave_pass_flags = FALSE
	else
		gave_pass_flags = TRUE
		owner.pass_flags |= PASSTABLE

	owner.set_density(FALSE)
	owner.layer = ABOVE_ALL_MOB_LAYER

	animate(owner, pixel_y = owner.pixel_y + 60, time = (2 SECONDS), easing = CIRCULAR_EASING|EASE_OUT)
	animate(pixel_y = initial(owner.pixel_y), time = (1 SECONDS), easing = CIRCULAR_EASING|EASE_IN)

	jump_timer = addtimer(CALLBACK(src, PROC_REF(land), /*do_effects = */TRUE, /*mob_override = */owner), 3 SECONDS, TIMER_STOPPABLE)

/datum/action/item_action/skybulge/update_status_on_signal(datum/source, new_stat, old_stat)
	if(!isnull(jump_timer) && !IsAvailable())
		INVOKE_ASYNC(src, PROC_REF(land), /*do_effects = */FALSE, /*mob_override = */source)
		deltimer(jump_timer)
	return ..()

/**
 * ## land()
 *
 * Called by jump_up, this is the post-jump effects, damaging objects and mobs it lands on.
 * Args:
 * do_effects - Whether we'll do the attacking effects of the land (damaging mobs & sound),
 * we set this to false if we were forced out of the jump, they lost their ability to do the hit.
 * mob_doing_effects - This is who we use for aftereffects, passing the mob using the ability, with owner as fallback.
 * ourselves.
 */
/datum/action/item_action/skybulge/proc/land(do_effects = TRUE, mob/living/mob_doing_effects)
	if(!mob_doing_effects)
		mob_doing_effects = owner
	var/turf/landed_on = get_turf(mob_doing_effects)

	UnregisterSignal(target, COMSIG_ITEM_ATTACK)
	target.remove_traits(list(TRAIT_NEEDS_TWO_HANDS, TRAIT_NODROP), ACTION_TRAIT)
	mob_doing_effects.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_MOVE_FLYING), ACTION_TRAIT)
	if(gave_pass_flags)
		mob_doing_effects.pass_flags &= ~PASSTABLE
	mob_doing_effects.set_density(TRUE)
	mob_doing_effects.layer = initial(mob_doing_effects.layer)
	SET_PLANE(mob_doing_effects, initial(mob_doing_effects.plane), landed_on)

	if(!do_effects)
		return

	playsound(mob_doing_effects, 'sound/effects/explosion/explosion1.ogg', 40, 1)
	var/obj/item/skybulge_item = target

	for(var/atom/thing as anything in landed_on)
		if(thing == mob_doing_effects)
			continue

		if(isobj(thing))
			thing.take_damage(150)
			continue

		if(isliving(thing))
			skybulge_item.melee_attack_chain(owner, thing, list("[FORCE_MULTIPLIER]" = 2))
			skybulge_item.attack(thing, owner)
			var/mob/living/living_target = thing
			living_target.SetKnockdown(1 SECONDS)

///Called when the person holding us is trying to attack something mid-jump.
///You're technically in mid-air, so block any attempts at getting extra hits in.
/datum/action/item_action/skybulge/proc/on_attack_during_jump(atom/source, mob/living/target_mob, mob/living/user, params)
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_ATTACK_CHAIN
