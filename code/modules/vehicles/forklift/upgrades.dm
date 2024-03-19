/obj/item/forklift_upgrade
    name = "Base Forklift Upgrade"
    desc = "If you see this, file an issue report."
    icon = 'icons/effects/buymode.dmi'
    icon_state = "upgrade_base"
    var/upgrade_type = "TEST"

/obj/item/forklift_upgrade/storage
    name = "forklift storage upgrade"
    desc = "Triples the storage capacity of the forklift it's applied to."
    icon_state = "storage_upgrade"
    upgrade_type = FORKLIFT_UPGRADE_STORAGE

/obj/item/forklift_upgrade/seating
    name = "forklift seating upgrade"
    desc = "Adds two extra seats to the forklift for additional labor."
    icon_state = "seating_upgrade"
    upgrade_type = FORKLIFT_UPGRADE_SEATING

/obj/item/forklift_upgrade/lighting
    name = "forklift lighting module upgrade"
    desc = "Adds a lighting module to the forklift, allowing it to place lights and adding bright floodlights to the forklift."
    icon_state = "light_upgrade"
    upgrade_type = FORKLIFT_LIGHT_UPGRADE

/*/obj/item/forklift_upgrade/jetpack
    name = "forklift jetpack upgrade"
    desc = "Installs a jetpack in the forklift, allowing it to fly in space and zero-grav."
    icon_state = "jetpack_upgrade"
    upgrade_type = FORKLIFT_UPGRADE_STORAGE*/

/obj/item/forklift_upgrade/multitasking
    name = "forklift multitasking upgrade"
    desc = "Adds two additional nanobeam streams to the forklift, allowing two additional simultaneous build and deconstruct tasks at once."
    icon_state = "build_upgrade"
    upgrade_type = FORKLIFT_UPGRADE_BUILD_2

/obj/item/forklift_upgrade/multitasking_mk3
    name = "forklift multitasking MK3 upgrade"
    desc = "Adds three additional nanobeam streams to the forklift, allowing three additional simultaneous build and deconstruct tasks at once. Stacks with the previous edition."
    icon_state = "build3_upgrade"
    upgrade_type = FORKLIFT_UPGRADE_BUILD_3
