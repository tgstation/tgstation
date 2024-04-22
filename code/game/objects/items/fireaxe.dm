/*
 * Fireaxe
 */
/obj/item/fireaxe  // DEM AXES MAN, marker -Agouri
	icon = 'icons/obj/weapons/fireaxe.dmi'
	icon_state = "fireaxe0"
	base_icon_state = "fireaxe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	demolition_mod = 1.25
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("attacks", "chops", "cleaves", "tears", "lacerates", "cuts")
	attack_verb_simple = list("attack", "chop", "cleave", "tear", "lacerate", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	armor_type = /datum/armor/item_fireaxe
	resistance_flags = FIRE_PROOF
	wound_bonus = -15
	bare_wound_bonus = 20
	/// How much damage to do unwielded
	var/force_unwielded = 5
	/// How much damage to do wielded
	var/force_wielded = 24

/datum/armor/item_fireaxe
	fire = 100
	acid = 30

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 10 SECONDS, \
		effectiveness = 80, \
		bonus_modifier = 0 , \
		butcher_sound = hitsound, \
	)
	//axes are not known for being precision butchering tools
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[base_icon_state]1")

/obj/item/fireaxe/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/fireaxe/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/fireaxe/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED)) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
			if(!(A.resistance_flags & INDESTRUCTIBLE))
				var/obj/structure/W = A
				W.atom_destruction("fireaxe")

/*
 * Bone Axe
 */
/obj/item/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon_state = "bone_axe0"
	base_icon_state = "bone_axe"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_unwielded = 5
	force_wielded = 23

/*
 * Metal Hydrogen Axe
 */
/obj/item/fireaxe/metal_h2_axe
	icon_state = "metalh2_axe0"
	base_icon_state = "metalh2_axe"
	name = "metallic hydrogen axe"
	desc = "A lightweight crowbar with an extreme sharp fire axe head attached. It trades it's hefty as a weapon by making it easier to carry around when holstered to suits without having to sacrifice your backpack."
	force_unwielded = 5
	force_wielded = 15
	demolition_mod = 2
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	usesound = 'sound/items/crowbar.ogg'

/*
 * Syndicate Incendiary Axe
 */

/obj/item/fireaxe/firey
	icon = 'icons/obj/weapons/fireaxe.dmi'
	icon_state = "fireaxe0"
	base_icon_state = "fireaxe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	wound_bonus = -15
	bare_wound_bonus = 20
	/// Can the axe ignite it's target?
	var/ignite_target = TRUE

/obj/item/fireaxe/firey/attack(mob/living/carbon/victim, mob/living/carbon/user)
	if(ignite_target)
		victim.adjust_fire_stacks(1)
		victim.ignite_mob()

	if(!isliving(victim))
		return ..()

	return ..()

/*
 * Energy Fire Axe
 */

/obj/item/fireaxe/energy
	name = "energy fire axe"
	desc = "A massive, two handed, energy-based hardlight axe capable of cutting through solid metal. 'Glory to atmosia' is carved on the side of the handle."
	icon = 'icons/obj/weapons/fireaxe.dmi'
	icon_state = "energy-fireaxe0"
	base_icon_state = "energy-fireaxe"
	demolition_mod = 4 // DESTROY
	armour_penetration = 50 // Probably doesn't care much for armor given how it can destroy solid metal structures
	block_chance = 50 // Big handle and large flat energy blade, good for blocking things
	heat = 1800 // It's a FIRE axe
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = "swing_hit"
	light_system = OVERLAY_LIGHT
	light_range = 6 //This is NOT a stealthy weapon
	light_color = "#ff4800" //red-orange
	light_on = FALSE
	sharpness = NONE
	resistance_flags = FIRE_PROOF | ACID_PROOF

	force_wielded = 25

	var/w_class_on = WEIGHT_CLASS_BULKY

/obj/item/fireaxe/energy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
		wieldsound = 'sound/weapons/saberon.ogg', \
		unwieldsound = 'sound/weapons/saberoff.ogg', \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)

/obj/item/fireaxe/energy/proc/on_wield(obj/item/source, mob/living/carbon/user)
	w_class = w_class_on
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/blade1.ogg'
	START_PROCESSING(SSobj, src)
	set_light_on(TRUE)

/obj/item/fireaxe/energy/proc/on_unwield(obj/item/source, mob/living/carbon/user)
	w_class = initial(w_class)
	sharpness = initial(sharpness)
	hitsound = "swing_hit"
	STOP_PROCESSING(SSobj, src)
	set_light_on(FALSE)

/obj/item/fireaxe/energy/attack(mob/living/M, mob/living/user)
	..()
	M.ignite_mob() // Ignites you if you're flammable

/obj/item/fireaxe/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return 0 // large energy blade can only block stuff if it's actually on
	return ..()

/obj/item/fireaxe/energy/ignition_effect(atom/A, mob/user)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return "[user] tries to light [A] with [src] while it's off. Nothing happens."
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	return "[user] casually raises [src] up to [user.p_their()] face and lights [A]. Hot damn."

/obj/item/fireaxe/energy/process()
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		STOP_PROCESSING(SSobj, src)
		return PROCESS_KILL
	open_flame(heat)
