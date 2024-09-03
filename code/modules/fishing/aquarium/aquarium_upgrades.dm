
/// Aquarium upgrades, can be applied to a basic aquarium to upgrade it into an advanced subtype.
/obj/item/aquarium_upgrade
	name = "Aquarium Upgrade"
	desc = "An upgrade."

	icon = 'icons/obj/aquarium/supplies.dmi'
	icon_state = "construction_kit"
	/// What kind of aquarium can accept this upgrade. Strict type check, no subtypes.
	var/upgrade_from_type = /obj/structure/aquarium
	/// typepath of the new aquarium subtype created.
	var/upgrade_to_type = /obj/structure/aquarium

/obj/item/aquarium_upgrade/bioelec_gen
	name = "Aquarium Bioelectricity Kit"
	desc = "All the required components to allow an aquarium to harness energy bioelectric fish."
	icon_state = "bioelec_kit"
	upgrade_to_type = /obj/structure/aquarium/bioelec_gen

/obj/structure/aquarium/bioelec_gen
	name = "bioelectricity generator"
	desc = "An unconventional type of generator that boosts and harvests the energy produced by bioelectric fish."

	icon_state = "bioelec_map"
	icon_prefix = "bioelec"

	current_beauty = 0

/obj/structure/aquarium/bioelec_gen/zap_act(power, zap_flags)
	var/explosive = zap_flags & ZAP_MACHINE_EXPLOSIVE
	if(!explosive)
		return //immune to all other shocks to make sure power can be generated without breaking the generator itself
	return ..()

/obj/structure/aquarium/bioelec_gen/examine(mob/user)
	. = ..()
	. += span_boldwarning("WARNING! WARNING! WARNING!")
	. += span_warning("The bioelectric potential of the fish inside is magnified to dangerous levels by the generator.")
	. += span_notice("Tesla coils are required to collect this magnified energy... and you'll want a grounding rod to protect yourself as well.")
