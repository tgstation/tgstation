
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

/obj/item/aquarium_upgrade/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!HAS_TRAIT(interacting_with, TRAIT_IS_AQUARIUM))
		return NONE
	if(upgrade_from_type != interacting_with.type)
		interacting_with.balloon_alert(user, "wrong kind of aquarium!")
		return ITEM_INTERACT_BLOCKING
	interacting_with.balloon_alert(user, "upgrading...")
	if(!PERFORM_ALL_TESTS(aquarium_upgrade) && !do_after(user, 5 SECONDS, interacting_with))
		return ITEM_INTERACT_BLOCKING
	var/atom/movable/upgraded_aquarium = new upgrade_to_type(interacting_with.drop_location())
	//This should transfer all the fish, reagents and settings from the aquarium component
	interacting_with.TransferComponents(upgraded_aquarium)
	upgraded_aquarium.balloon_alert(user, "upgraded")
	qdel(src)
	qdel(interacting_with)
	return ITEM_INTERACT_SUCCESS

/obj/item/aquarium_upgrade/bioelec_gen
	name = "aquarium bioelectricity kit"
	desc = "All the required components to allow an aquarium to harness energy bioelectric fish."
	icon_state = "bioelec_kit"
	upgrade_to_type = /obj/structure/aquarium/bioelec_gen

/obj/structure/aquarium/bioelec_gen
	name = "bioelectricity generator"
	desc = "An unconventional type of generator that boosts and harvests the energy produced by bioelectric fish."

	icon_state = "bioelec_map"
	base_icon_state = "bioelec"

	default_beauty = 0

/obj/structure/aquarium/bioelec_gen/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_BIOELECTRIC_GENERATOR, INNATE_TRAIT)

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

/obj/item/aquarium_upgrade/bluespace_tank
	name = "bluespace fish tank kit"
	desc = "The required components to upgrade your portable fish tank into bottomless, handheld aquarium."
	icon_state = "bluespace_kit"
	upgrade_from_type = /obj/item/fish_tank
	upgrade_to_type = /obj/item/fish_tank/bluespace

/obj/item/fish_tank/bluespace
	name = "bluespace fish tank"
	desc = "All the capacity of a bulky room aquarium, squeezed in a bag-sized rectangular cuboid."
	icon_state = "fish_tank_bluespace_map"
	base_icon_state = "fish_tank_bluespace"
	w_class = WEIGHT_CLASS_NORMAL
	maximum_relative_size = INFINITY
	max_total_size = 2000
	slowdown_coeff = 0.15
	min_fluid_temp = MIN_AQUARIUM_TEMP
	max_fluid_temp = MAX_AQUARIUM_TEMP
	reagent_size = 6
