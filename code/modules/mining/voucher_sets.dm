/datum/voucher_set
    /// Name of the set
    var/name
    /// Description of the set
    var/description
	/// Icon of the set
    var/icon
	/// Icon state of the set
    var/icon_state
    /// List of items contained in the set
    var/list/set_items = list()

/datum/voucher_set/crusher_kit
    name = "Crusher Kit"
    description = "Contains a kinetic crusher and pocket fire extinguisher."
    icon = 'icons/obj/mining.dmi'
    icon_state = "crusher"
    set_items = list(
        /obj/item/extinguisher/mini,
        /obj/item/kinetic_crusher,
        )

/datum/voucher_set/extraction_kit
    name = "Extraction and Rescue Kit"
    description = "Contains a fulton extraction pack and a beacon, which allows you to send back home minerals, items and dead miners without having to use the mining shuttle. As a bonus, you get 30 marker beacons too."
    icon = 'icons/obj/fulton.dmi'
    icon_state = "extraction_pack"
    set_items = list(
        /obj/item/extraction_pack,
        /obj/item/fulton_core,
        /obj/item/stack/marker_beacon/thirty,
        )

/datum/voucher_set/resonator_kit
    name = "Resonator Kit"
    description = "Contains a resonator and a pocket fire extinguisher."
    icon = 'icons/obj/mining.dmi'
    icon_state = "resonator"
    set_items = list(
        /obj/item/extinguisher/mini,
        /obj/item/resonator,
        )

/datum/voucher_set/survival_capsule
    name = "Survival Capsule and Explorer's Webbing"
    description = "Contains a webbing (you put on your belt slot), which allows you to carry even more mining equipment - having a second shelter capsule is nice too."
    icon = 'icons/obj/clothing/belts.dmi'
    icon_state = "explorer1"
    set_items = list(
        /obj/item/storage/belt/mining/vendor,
        )

/datum/voucher_set/minebot_kit
    name = "Minebot Kit"
    description = "Contains a little companion that helps you in storing ore and hunting wildlife. Comes with an upgraded industrial welding tool (80u), a welding mask and a KA modkit that allows shots to pass through the drone."
    icon = 'icons/mob/aibots.dmi'
    icon_state = "mining_drone"
    set_items = list(
        /mob/living/simple_animal/hostile/mining_drone,
        /obj/item/weldingtool/hugetank,
        /obj/item/clothing/head/welding,
        /obj/item/borg/upgrade/modkit/minebot_passthrough,
        )

/datum/voucher_set/conscription_kit
    name = "Mining Conscription Kit"
    description = "This set contains a whole new mining starter kit for one crewmember, consisting of proto-kinetic accelerator, survival knife, seclite, explorer's suit, mesons, mining scanner, satchel, gas mask, a supply radio key and a special ID card with basic mining access."
    icon = 'icons/obj/storage.dmi'
    icon_state = "duffel"
    set_items = list(
        /obj/item/storage/backpack/duffelbag/mining_conscript,
        )
