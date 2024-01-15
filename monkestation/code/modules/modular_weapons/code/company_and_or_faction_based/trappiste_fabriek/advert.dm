/obj/structure/sign/poster/official/trappiste_suppressor
	name = "Keep It Quiet - Ear Protection Unneeded"
	desc = "This poster depicts, alongside the prominent logo of Trappiste Fabriek, a \
		diagram of the average suppressor, and how on most* Trappiste weapons \
		the sound of firing will be low enough to eradicate the need for ear protection. \
		How safety minded, they even have a non-liability statement too."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/trappiste_fabriek/propaganda.dmi'
	icon_state = "keep_it_quiet"

/obj/structure/sign/poster/official/trappiste_suppressor/examine_more(mob/user)
	. = ..()

	. += "It was hard to notice before, but now that you really look at it... \
		This thing is completely covered in micro scale text telling you in just about \
		every human language and then some that Trappiste isn't liable for ear damage \
		caused by their weapons, suppressed or not."

	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/trappiste_suppressor, 32)

/obj/structure/sign/poster/official/trappiste_ammunition
	name = "Know Your Ammuniton Colors"
	desc = "This poster depicts, alongside the prominent logo of Trappiste Fabriek, \
		a variety of colors that one may find on .585 Trappiste rounds. \
		A plain white case usually means lethal, while a blue stripe is less-lethal \
		and a purple stripe is more lethal. How informative."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/trappiste_fabriek/propaganda.dmi'
	icon_state = "know_the_difference"

/obj/structure/sign/poster/official/trappiste_ammunition/examine_more(mob/user)
	. = ..()

	. += "Small text details that this information may also be transferrable \
		to other types of SolFed ammunition, but that you should check the box \
		the bullets come in just to be sure. Trappiste is, of course,\
		not liable for excess harm caused by misreading color identification systems."

	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/trappiste_ammunition, 32)
