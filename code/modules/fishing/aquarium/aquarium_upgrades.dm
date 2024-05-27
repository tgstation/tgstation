
/// Aquarium upgrades, can be applied to a basic aquarium to upgrade it into an advanced subtype.
/obj/item/aquarium_upgrade
	name = "Aquarium Upgrade"
	desc = "An upgrade."
	/// typepath of the new aquarium subtype created.
	var/upgrade_type = /obj/structure/aquarium

/obj/item/aquarium_upgrade/bioelec_gen
	name = "Aquarium Bioelectricity Kit"
	desc = "All the required components to allow an aquarium to harness energy bioelectric fish."
	upgrade_type = /obj/structure/aquarium/bioelec_gen

/obj/structure/aquarium/bioelec_gen
	name = "bioelectricity generator"
	desc = "An unconventional type of generator that harvests the energy produced by bioelectric fish."

	icon_state = "bioelec_map"
	icon_prefix = "bioelec"

/obj/structure/aquarium/bioelec_gen/examine(mob/user)
	. = ..()
	. += span_boldwarning("WARNING! WARNING! WARNING!")
	. += span_warning("The bioelectric potential of the fish inside is magnified to dangerous levels by the generator.")
	. += span_notice("Tesla coils are required to collect this magnified energy... and to protect yourself.")
