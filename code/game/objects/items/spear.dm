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
	bare_wound_bonus = 15
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

/obj/item/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
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
			bare_wound_bonus = 20
			force_unwielded = 13
			force_wielded = 20
			icon_prefix = "spearplastitanium"
			AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[icon_prefix]1")

	update_appearance()
	parts_list -= tip
	qdel(tip)
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

/obj/item/spear/explosive/CheckParts(list/parts_list)
	var/obj/item/grenade/G = locate() in parts_list
	if(G)
		var/obj/item/spear/lancePart = locate() in parts_list
		throwforce = lancePart.throwforce
		icon_prefix = lancePart.icon_prefix
		parts_list -= G
		parts_list -= lancePart
		set_explosive(G)
		qdel(lancePart)
	..()

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


/obj/item/spear/explosive/afterattack(atom/movable/target, mob/user, click_parameters)
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

/obj/item/spear/grey_tide/afterattack(atom/movable/target, mob/living/user, click_parameters)
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
	bare_wound_bonus = 25
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
 * Other than that ability, deals less damage than the average spear.
 */
/obj/item/spear/skybulge
	name = "\improper Sky Bulge"
	desc = "A legendary stick with a very pointy tip. Takes you to the skies!"
	icon_state = "sky_bulge0"
	icon_prefix = "sky_bulge"
	attack_verb_continuous = list("attacks", "pokes", "jabbes", "tears", "gores", "lances")
	attack_verb_simple = list("attacked", "poked", "jabbed", "torn", "gored", "lanced")
	force_unwielded = 10
	force_wielded = 18
	throwforce = 24
	throw_speed = 4
	slot_flags = parent_type::slot_flags | ITEM_SLOT_HANDS //this is needed for action types to give actions in-hand
	embed_type = null //no embedding
	actions_types = list(/datum/action/item_action/skybulge)

///The action button the spear gives, usable once a minute.
/datum/action/item_action/skybulge
	name = "Dragoon Jump"
	desc = "Jump up into the skies and fall down upon your opponents to deal double damage."
	///Cooldown time between jumps.
	var/skyfall_cooldown_time = 1 MINUTES

/datum/action/item_action/skybulge/do_effect(trigger_flags)
	if(HAS_TRAIT_FROM(owner, TRAIT_MOVE_PHASING, ACTION_TRAIT))
		to_chat(owner, span_warning("You're already airborne!"))
		return
	if(!HAS_TRAIT(target, TRAIT_WIELDED))
		to_chat(owner, span_warning("You must wield [target] in both hands!"))
		return
	var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(owner, COOLDOWN_SKYBULGE_JUMP)
	if(timeleft)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before attempting to jump."))
		return

	owner.balloon_alert(owner, "charging up...")
	ADD_TRAIT(target, TRAIT_NEEDS_TWO_HANDS, ACTION_TRAIT)
	INVOKE_ASYNC(src, PROC_REF(jump_up))

///Sends the owner up in the air and calls them back down, calling land() for aftereffects.
/datum/action/item_action/skybulge/proc/jump_up()
	if(!do_after(owner, 2 SECONDS, target = owner))
		REMOVE_TRAIT(target, TRAIT_NEEDS_TWO_HANDS, ACTION_TRAIT)
		return
	playsound(owner, 'sound/effects/footstep/heavy1.ogg', 50, 1)
	S_TIMER_COOLDOWN_START(owner, COOLDOWN_SKYBULGE_JUMP, skyfall_cooldown_time)
	new /obj/effect/temp_visual/telegraphing/exclamation/following(get_turf(owner), 2.5 SECONDS, owner)

	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_attack_during_jump))
	ADD_TRAIT(target, TRAIT_NODROP, ACTION_TRAIT)
	ADD_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, ACTION_TRAIT)
	owner.resistance_flags |= INDESTRUCTIBLE //not while jumping at least
	owner.set_density(FALSE)
	owner.layer = ABOVE_ALL_MOB_LAYER

	animate(owner, pixel_y = owner.pixel_y + 80, time = (2 SECONDS), easing = CIRCULAR_EASING|EASE_OUT)
	animate(pixel_y = initial(owner.pixel_y), time = (1 SECONDS), easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(land)), 3 SECONDS)

///Called by jump_up, this is the post-jump effects, damaging objects and mobs it lands on.
/datum/action/item_action/skybulge/proc/land()
	var/turf/landed_on = get_turf(owner)
	playsound(owner, 'sound/effects/explosion/explosion1.ogg', 50, 1)

	UnregisterSignal(target, COMSIG_ITEM_ATTACK)
	target.remove_traits(list(TRAIT_NEEDS_TWO_HANDS, TRAIT_NODROP), ACTION_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, ACTION_TRAIT)
	owner.resistance_flags &= ~INDESTRUCTIBLE
	owner.set_density(TRUE)
	owner.layer = initial(owner.layer)
	SET_PLANE(owner, initial(owner.plane), landed_on)

	for(var/atom/thing as anything in landed_on)
		if(thing == owner)
			continue
		if(isobj(thing))
			thing.take_damage(150)
			continue
		if(isliving(thing))
			var/obj/item/skybulge_item = target
			skybulge_item.force *= 2 //we hit for double damage.
			skybulge_item.attack(thing, owner)
			skybulge_item.force /= 2

///Called when the person holding us is trying to attack something mid-jump.
///You're technically in mid-air, so block any attempts at getting extra hits in.
/datum/action/item_action/skybulge/proc/on_attack_during_jump(atom/source, mob/living/target_mob, mob/living/user, params)
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_ATTACK_CHAIN
