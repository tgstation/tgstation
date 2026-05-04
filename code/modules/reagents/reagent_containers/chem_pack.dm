/obj/item/reagent_containers/chem_pack
	name = "intravenous medicine bag"
	desc = "A plastic pressure bag, or 'chem pack', for IV administration of drugs. It is fitted with a thermosealing strip."
	icon = 'icons/obj/medical/bloodpack.dmi'
	icon_state = "chempack"
	volume = 100
	initial_reagent_flags = OPENCONTAINER
	obj_flags = UNIQUE_RENAME
	resistance_flags = ACID_PROOF
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	has_variable_transfer_amount = FALSE
	interaction_flags_click = NEED_DEXTERITY

/obj/item/reagent_containers/chem_pack/click_alt(mob/living/user)
	if(reagents.flags & SEALED_CONTAINER)
		balloon_alert(user, "already sealed!")
		return CLICK_ACTION_BLOCKING

	if(iscarbon(user) && (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50)))
		to_chat(user, span_warning("Uh... whoops! You accidentally spill the content of the bag onto yourself."))
		splash_reagents(user, user, allow_closed_splash = TRUE)
		return CLICK_ACTION_BLOCKING

	update_container_flags(SEALED_CONTAINER | DRAWABLE | INJECTABLE)
	balloon_alert(user, "sealed")
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/chem_pack/examine()
	. = ..()
	if(reagents.flags & SEALED_CONTAINER)
		. += span_notice("The bag is sealed shut.")
	else
		. += span_notice("Alt-click to seal it.")
