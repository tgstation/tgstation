/// Makes you gain a trait
/datum/status_effect/food/trait
	var/trait = TRAIT_DUMB // You need to override this

/datum/status_effect/food/trait/on_apply()
	if(!HAS_TRAIT_FROM(owner, trait, TRAIT_STATUS_EFFECT(id))) // Check if trait was already applied
		ADD_TRAIT(owner, trait, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/food/trait/be_replaced()
	REMOVE_TRAIT(owner, trait, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/food/trait/on_remove()
	REMOVE_TRAIT(owner, trait, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/food/trait/shockimmune
	alert_type = /atom/movable/screen/alert/status_effect/shockimmune
	trait = TRAIT_SHOCKIMMUNE

/atom/movable/screen/alert/status_effect/shockimmune
	name = "Grounded"
	desc = "Эта еда заставляет меня чувствовать себя как сверхпроводник..."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "shock_immune"

/datum/status_effect/food/trait/mute
	alert_type = /atom/movable/screen/alert/status_effect/mute
	trait = TRAIT_MUTE

/atom/movable/screen/alert/status_effect/mute
	name = "..."
	desc = "..."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "mute"

/datum/status_effect/food/trait/ashstorm_immune
	alert_type = /atom/movable/screen/alert/status_effect/ashstorm_immune
	trait = TRAIT_ASHSTORM_IMMUNE

/atom/movable/screen/alert/status_effect/ashstorm_immune
	name = "Ashstorm-proof"
	desc = "После этой еды кажется, что я родился на Лаваленде."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "ashstorm_immune"

/datum/status_effect/food/trait/waddle
	alert_type = /atom/movable/screen/alert/status_effect/waddle
	trait = TRAIT_WADDLING

/datum/status_effect/food/trait/waddle/on_apply()
	owner.AddElementTrait(trait, type, /datum/element/waddling)
	return ..()

/atom/movable/screen/alert/status_effect/waddle
	name = "Waddling"
	desc = "Это блюдо вызывает у меня желание пошутить."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_icon = /obj/item/clothing/mask/gas/clown_hat::icon
	overlay_state = /obj/item/clothing/mask/gas/clown_hat::icon_state
