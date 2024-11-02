/obj/item/organ/internal/cyberimp/arm/lighter
	name = "finger-bound lighter"
	desc = "Allows you to light cigarettes with the snap of a finger."
	items_to_create = list(/obj/item/lighter/implanted)

/obj/item/organ/internal/cyberimp/arm/lighter/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF))
		return
	var/obj/item/bodypart/real_hand = hand
	if(!istype(real_hand))
		return
	real_hand.receive_damage(burn = 10 / severity, wound_bonus = 10, damage_source = src)
	to_chat(owner, span_warning("You feel your [parse_zone(zone)] begin to burn up!"))


/obj/item/organ/internal/cyberimp/arm/lighter/Extend(obj/item/augment)
	. = ..()
	var/obj/item/lighter/implanted/lighter = augment
	if(!istype(augment) || augment.loc == src)
		return
	lighter.set_lit(TRUE)

/obj/item/organ/internal/cyberimp/arm/lighter/Retract()
	var/obj/item/lighter/implanted/lighter = active_item
	if(istype(lighter))
		lighter.set_lit(FALSE)
	return ..()

/obj/item/organ/internal/cyberimp/arm/lighter/proc/on_snap(mob/living/source)
	SIGNAL_HANDLER
	if(source.get_active_hand() != hand)
		return
	if(organ_flags & ORGAN_FAILING)
		return
	if(isnull(active_item))
		Extend(contents[1])
		source.visible_message(
			span_infoplain(span_rose("With a snap, [source]'s finger emits a low flame.")),
			span_infoplain(span_rose("With a snap, your finger begins to emit a low flame.")),
		)

	else
		Retract()
		source.visible_message(
			span_infoplain(span_rose("With a snap, [source]'s finger extinguishes.")),
			span_infoplain(span_rose("With a snap, your finger is extinguished.")),
		)

/obj/item/organ/internal/cyberimp/arm/lighter/left
	zone = BODY_ZONE_L_ARM

/obj/item/lighter/implanted
	name = "implanted lighter"
	desc = "A lighter implanted in your finger."
	item_flags = EXAMINE_SKIP

/obj/item/lighter/implanted/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		return span_infoplain(span_rose(
			"With a snap, [user]'s finger emits a low flame, which they use to light [A] ablaze. \
			Hot damn, [user.p_theyre()] badass."))

/obj/item/lighter/implanted/attack_self(mob/living/user)
	return

/obj/item/lighter/implanted/set_lit(new_lit)
	. = ..()
	if(lit)
		name = "\proper [loc]'s finger-light"
	else
		name = initial(name)
