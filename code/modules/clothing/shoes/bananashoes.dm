//banana flavored chaos and horror ahead

/obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "mk-honk prototype shoes"
	desc = "Lost prototype of advanced clown tech. Powered by bananium, these shoes leave a trail of chaos in their wake."
	icon_state = "clown_prototype_off"
	actions_types = list(/datum/action/item_action/toggle)
	/// Whether the clown shoes are active (spawning bananas)
	var/on = FALSE
	/// If TRUE, we will always have the noslip trait no matter whether they're on or off
	var/always_noslip = FALSE
	/// How many materials we consume per banana created
	var/material_per_banana =SMALL_MATERIAL_AMOUNT
	/// Typepath of created banana
	var/banana_type = /obj/item/grown/bananapeel/specialpeel
	/// Material container for bananium
	var/datum/component/material_container/bananium

/obj/item/clothing/shoes/clown_shoes/banana_shoes/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	bananium = AddComponent(/datum/component/material_container, list(/datum/material/bananium), 100 * SHEET_MATERIAL_AMOUNT, MATCONTAINER_EXAMINE|MATCONTAINER_ANY_INTENT|MATCONTAINER_SILENT, allowed_items=/obj/item/stack)
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 75, falloff_exponent = 20)
	RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, PROC_REF(on_step))
	if(always_noslip)
		LAZYOR(clothing_traits, TRAIT_NO_SLIP_WATER)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/Destroy()
	bananium = null
	return ..()

/obj/item/clothing/shoes/clown_shoes/banana_shoes/proc/toggle_clowning_action()
	on = !on
	update_appearance()
	if(always_noslip)
		return

	if(on)
		attach_clothing_traits(TRAIT_NO_SLIP_WATER)
	else
		detach_clothing_traits(TRAIT_NO_SLIP_WATER)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/proc/on_step()
	SIGNAL_HANDLER

	var/mob/wearer = loc
	if(!on || !istype(wearer))
		return

	if(bananium.use_amount_mat(material_per_banana, /datum/material/bananium))
		new banana_type(get_step(src, turn(wearer.dir, 180))) //honk
		return

	toggle_clowning_action()
	to_chat(wearer, span_warning("You ran out of bananium!"))

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attack_self(mob/user)
	var/sheet_amount = bananium.retrieve_all()
	if(sheet_amount)
		to_chat(user, span_notice("You retrieve [sheet_amount] sheets of bananium from the prototype shoes."))
	else
		to_chat(user, span_warning("You cannot retrieve any bananium from the prototype shoes!"))

/obj/item/clothing/shoes/clown_shoes/banana_shoes/examine(mob/user)
	. = ..()
	. += span_notice("The shoes are [on ? "enabled" : "disabled"].")

/obj/item/clothing/shoes/clown_shoes/banana_shoes/ui_action_click(mob/user)
	if(bananium.get_material_amount(/datum/material/bananium) >= material_per_banana)
		toggle_clowning_action()
		to_chat(user, span_notice("You [on ? "activate" : "deactivate"] the prototype shoes."))
	else
		to_chat(user, span_warning("You need bananium to turn the prototype shoes on!"))

/obj/item/clothing/shoes/clown_shoes/banana_shoes/update_icon_state()
	icon_state = "clown_prototype_[on ? "on" : "off"]"
	return ..()
