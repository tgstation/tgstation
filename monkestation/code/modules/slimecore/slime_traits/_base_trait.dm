/datum/slime_trait
	var/name = "Base Trait"
	var/desc = "You shouldn't see this, this means someone forgot to set a trait desc or your seeing the base trait."

	//flags this trait has like TRAIT_PROCESS, TRAIT_ON_DEATH, TRAIT_ON_LIFE, etc
	var/trait_flags = NONE

	///what buttons do we show in the trait menu ie FOOD_CHANGE, ENVIRONMENT_CHANGE
	var/list/menu_buttons = list()

	///this is type paths of traits don't work together
	var/list/incompatible_traits = list()

	///our host slime
	var/mob/living/basic/slime/host

/datum/slime_trait/proc/on_add(mob/living/basic/slime/parent)
	if(!parent)
		return
	host = parent
	if(trait_flags & TRAIT_ON_DEATH)
		RegisterSignal(host, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	if(trait_flags & TRAIT_VISUAL)
		RegisterSignal(host, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_overlays))
		host.update_overlays()

/datum/slime_trait/proc/on_remove(mob/living/basic/slime/parent)
	return

/datum/slime_trait/proc/on_death()
	return

/datum/slime_trait/proc/apply_overlays(obj/item/source, list/overlays)
	return


/datum/slime_trait/visual

	trait_flags = (TRAIT_VISUAL)
	//the visual icon_state of the trait
	var/trait_icon_state
	///the icon path of the trait
	var/trait_icon


/datum/slime_trait/visual/apply_overlays(obj/item/source, list/overlays)
	if(!trait_icon || !trait_icon_state)
		return

	var/mutable_appearance/slime_visual = mutable_appearance(trait_icon, trait_icon_state, host.layer, host, host.plane)

	if(!host.overwrite_color)
		slime_visual.color = host.current_color.slime_color
	else
		slime_visual.color = host.overwrite_color

	overlays += slime_visual
