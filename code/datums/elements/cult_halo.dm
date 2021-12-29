/datum/element/cult_halo

/datum/element/cult_halo/Attach(datum/target, override = FALSE)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_CHANGELING_TRANSFORM, .proc/set_halo)
	RegisterSignal(target, COMSIG_MONKEY_HUMANIZE, .proc/set_halo)
	RegisterSignal(target, COMSIG_HUMAN_MONKEYIZE, .proc/set_halo)

	if (override)
		set_halo(target)
	else
		addtimer(CALLBACK(src, .proc/set_halo, target), 20 SECONDS)

/datum/element/cult_halo/proc/set_halo(datum/target)
	SIGNAL_HANDLER

	var/mob/living/parent_mob = target
	ADD_TRAIT(parent_mob, TRAIT_CULT_HALO, CULT_TRAIT)
	var/icon_state = pick("halo1", "halo2", "halo3", "halo4", "halo5", "halo6")
	var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', icon_state, -HALO_LAYER)
	if (ishuman(parent_mob))
		var/mob/living/carbon/human/human_parent = parent_mob
		new /obj/effect/temp_visual/cult/sparks(get_turf(human_parent), human_parent.dir)
		human_parent.overlays_standing[HALO_LAYER] = new_halo_overlay
		human_parent.apply_overlay(HALO_LAYER)
	else
		parent_mob.add_overlay(new_halo_overlay)

/datum/element/cult_halo/Detach(datum/target, ...)
	. = ..()
	var/mob/living/parent_mob = target
	REMOVE_TRAIT(parent_mob, TRAIT_CULT_HALO, CULT_TRAIT)
	if (ishuman(parent_mob))
		var/mob/living/carbon/human/human_parent = parent_mob
		human_parent.remove_overlay(HALO_LAYER)
		human_parent.update_body()
	else
		parent_mob.cut_overlay(HALO_LAYER)

	UnregisterSignal(target, COMSIG_CHANGELING_TRANSFORM)
	UnregisterSignal(target, COMSIG_HUMAN_MONKEYIZE)
	UnregisterSignal(target, COMSIG_MONKEY_HUMANIZE)
