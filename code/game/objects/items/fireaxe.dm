/*
 * Fireaxe
 */
/obj/item/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb = list("attacked", "chopped", "cleaved", "tore", "lacerated", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF
	wound_bonus = -15
	bare_wound_bonus = 20
	var/wielded = FALSE // track wielded status on item

/obj/item/fireaxe/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/fireaxe/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 80, 0 , hitsound) //axes are not known for being precision butchering tools
	AddComponent(/datum/component/two_handed, force_unwielded=5, force_wielded=24, icon_wielded="fireaxe1")

/// triggered on wield of two handed item
/obj/item/fireaxe/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/fireaxe/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE

/obj/item/fireaxe/update_icon_state()
	icon_state = "fireaxe0"

/obj/item/fireaxe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/fireaxe/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(wielded) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
			var/obj/structure/W = A
			W.obj_destruction("fireaxe")

/*
 * Bone Axe
 */
/obj/item/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon_state = "bone_axe0"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."

/obj/item/fireaxe/boneaxe/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=5, force_wielded=23, icon_wielded="bone_axe1")

/obj/item/fireaxe/boneaxe/update_icon_state()
	icon_state = "bone_axe0"


// Baseball Bat

/obj/item/fireaxe/baseball
	name = "Executioner's Bat"
	desc = "Die the Death."
	icon_state = "baseball_bat_exec0"
	throwforce = 8
	w_class = WEIGHT_CLASS_HUGE

/obj/item/fireaxe/baseball/ComponentInitialize()
	AddComponent(/datum/component/two_handed, force_unwielded=2, force_wielded=13, icon_wielded="baseball_bat_exec1", dismemberment_unwielded = 0, dismemberment_wielded = 100)


/obj/item/fireaxe/baseball/update_icon_state()
	icon_state = "baseball_bat_exec0"
	if(wielded)
		icon_state = "baseball_bat_exec1"
	else
		icon_state = "baseball_bat_exec0"

/obj/item/fireaxe/baseball/attack(mob/living/target, mob/living/user)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
			return
		var/list/parts = list()
		for(var/X in C.bodyparts)
			var/obj/item/bodypart/bodypart = X
			if(bodypart.body_part != HEAD && bodypart.body_part != CHEST && bodypart.body_part != LEG_LEFT && bodypart.body_part != LEG_RIGHT)
				if(bodypart.dismemberable)
					parts += bodypart
		if(length(parts) && prob(30))
			var/obj/item/bodypart/bodypart = pick(parts)
			bodypart.dismember()
	if(wielded)
		force = 13
	else
		force = 2
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	if(!target.anchored && wielded)
		var/whack_speed = (prob(60) ? 1 : 4)
		target.throw_at(throw_target, rand(1, 2), whack_speed, user)

/obj/item/fireaxe/baseball/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(wielded) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
			return