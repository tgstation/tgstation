/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash
	name = "Ashen Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls, removing restraints in the process."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	exit_jaunt_sound = null
	jaunt_duration = 1.1 SECONDS
	jaunt_in_time = 1.3 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/spell_jaunt/red
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out
	/// If we are on fire while wearing ash robes, we can empower our next cast
	var/empowered_cast = FALSE

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_FIRE_STACKS_UPDATED, PROC_REF(update_status_on_signal))

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_FIRE_STACKS_UPDATED)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force)
	. = ..()
	// Put an active border whenever our spell is able to be casted empowered
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner.wear_suit, /obj/item/clothing/suit/hooded/cultrobes/eldritch/ash))
		return
	if(human_owner.fire_stacks <= 3)
		return

	current_button.cut_overlay(current_button.button_overlay)
	current_button.button_overlay = mutable_appearance(icon = overlay_icon, icon_state = "bg_spell_border_active_green")
	current_button.add_overlay(current_button.button_overlay)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/cast(mob/living/cast_on)
	if(!iscarbon(owner))
		return ..()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.uncuff()
	var/obj/item/clothing/shoes/shoes = carbon_owner.shoes
	if(istype(shoes) && shoes.tied == SHOES_KNOTTED)
		shoes.adjust_laces(SHOES_TIED, carbon_owner)

	// Wearing Ash heretic armor empowers your spells if you have over 3 fire stacks
	if(!ishuman(owner))
		return ..()
	var/mob/living/carbon/human/human_owner = owner
	if(human_owner.fire_stacks <= 3)
		return ..()
	if(!istype(human_owner.wear_suit, /obj/item/clothing/suit/hooded/cultrobes/eldritch/ash))
		return ..()

	empowered_cast = TRUE
	human_owner.setStaminaLoss(0)
	human_owner.SetAllImmobility(0)

	return ..()

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/do_jaunt(mob/living/cast_on)
	jaunt_duration = (empowered_cast ? 1.5 SECONDS : initial(jaunt_duration))
	return ..()

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/do_steam_effects()
	return

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/long
	name = "Ashen Walk"
	desc = "A long range spell that allows you pass unimpeded through multiple walls."
	jaunt_duration = 5 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "ash_shift2"
	duration = 1.3 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"
