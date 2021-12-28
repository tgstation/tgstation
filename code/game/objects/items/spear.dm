//spears
/obj/item/spear
	icon_state = "spearglass0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	atom_size = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 4
	embedding = list("impact_pain_mult" = 2, "remove_pain_mult" = 4, "jostle_chance" = 2.5)
	armour_penetration = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	sharpness = SHARP_EDGED // i know the whole point of spears is that they're pointy, but edged is more devastating at the moment so
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	var/war_cry = "AAAAARGH!!!"
	var/icon_prefix = "spearglass"
	wound_bonus = -15
	bare_wound_bonus = 15

/obj/item/spear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 70) //decent in a pinch, but pretty bad.
	AddComponent(/datum/component/jousting)
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, icon_wielded="[icon_prefix]1")
	update_appearance()

/obj/item/spear/update_icon_state()
	icon_state = "[icon_prefix]0"
	return ..()

/obj/item/spear/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if(tip)
		if (istype(tip, /obj/item/shard/plasma))
			throwforce = 21
			icon_prefix = "spearplasma"
			AddComponent(/datum/component/two_handed, force_unwielded=11, force_wielded=19, icon_wielded="[icon_prefix]1")
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
	var/wielded = FALSE // track wielded status on item

/obj/item/spear/explosive/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	set_explosive(new /obj/item/grenade/iedcasing/spawned()) //For admin-spawned explosive lances

/obj/item/spear/explosive/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, icon_wielded="[icon_prefix]1")

/// triggered on wield of two handed item
/obj/item/spear/explosive/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/spear/explosive/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = FALSE

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
		var/datum/component/two_handed/comp_twohand = lancePart.GetComponent(/datum/component/two_handed)
		if(comp_twohand)
			var/lance_wielded = comp_twohand.force_wielded
			var/lance_unwielded = comp_twohand.force_unwielded
			AddComponent(/datum/component/two_handed, force_unwielded=lance_unwielded, force_wielded=lance_wielded)
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
	user.gib()
	qdel(src)
	return BRUTELOSS

/obj/item/spear/explosive/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to set your war cry.")

/obj/item/spear/explosive/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		..()
		if(istype(user) && loc == user)
			var/input = tgui_input_text(user, "What do you want your war cry to be? You will shout it when you hit someone in melee.", "War Cry", max_length = 50)
			if(input)
				src.war_cry = input

/obj/item/spear/explosive/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity || !wielded || !istype(AM))
		return
	if(AM.resistance_flags & INDESTRUCTIBLE) //due to the lich incident of 2021, embedding grenades inside of indestructible structures is forbidden
		return
	if(ismob(AM))
		var/mob/mob_target = AM
		if(mob_target.status_flags & GODMODE) //no embedding grenade phylacteries inside of ghost poly either
			return
	if(iseffect(AM)) //and no accidentally wasting your moment of glory on graffiti
		return
	user.say("[war_cry]", forced="spear warcry")
	explosive.forceMove(AM)
	explosive.detonate(lanced_by=user)
	qdel(src)

//GREY TIDE
/obj/item/spear/grey_tide
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	attack_verb_continuous = list("gores")
	attack_verb_simple = list("gore")
	force=15

/obj/item/spear/grey_tide/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=15, force_wielded=25, icon_wielded="[icon_prefix]1")

/obj/item/spear/grey_tide/afterattack(atom/movable/AM, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	user.faction |= "greytide([REF(user)])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)

/*
 * Bone Spear
 */
/obj/item/spear/bonespear //Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon_state = "bone_spear0"
	base_icon_state = "bone_spear0"
	icon_prefix = "bone_spear"
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	force = 12
	throwforce = 22
	armour_penetration = 15 //Enhanced armor piercing

/obj/item/spear/bonespear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=12, force_wielded=20, icon_wielded="[icon_prefix]1")
