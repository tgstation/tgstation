/**
 * An armblade that instantly snuffs out lights
 */
/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_MINING
	hitsound = 'sound/weapons/bladeslice.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20
	///If this is true, our next hit will be critcal, temporarily stunning our target
	var/has_crit = FALSE
	///The timer which controls our next crit
	var/crit_timer

/obj/item/light_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS, \
	effectiveness = 70, \
	)
	AddComponent(/datum/component/light_eater)
	RegisterSignal(antag, COMSIG_MOB_ENTER_JAUNT, PROC_REF(remove_crit))
	crit_timer = addtimer(CALLBACK(src, PROC_REF(add_crit)), TIMER_DELETE_ME | TIMER_STOPPABLE)

/obj/item/light_eater/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if(!has_crit)
		return
	user.visible_message(span_boldwarning("[user] gores [target] with their [src], bringing them to a halt!"), span_userdanger("You gore [target] with your [src], bringing them to a halt!"))
	target.Paralyze(1 SECONDS)
	remove_crit()

/obj/item/light_eater/proc/add_crit()
	has_crit = TRUE
	add_filter("crit_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	balloon_alert(owner, "critical strike ready")

/obj/item/light_eater/proc/remove_crit()
	has_crit = FALSE
	remove_filter("crit_glow")
	deltimer(crit_timer)
