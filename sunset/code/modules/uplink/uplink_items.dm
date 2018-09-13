// Infiltrator shit
/datum/uplink_item/infiltration
	category = "Infiltration Gear"
	include_modes = list(/datum/game_mode/infiltration)
	surplus = 0

/datum/uplink_item/infiltration/pinpointer_upgrade
	name = "Pinpointer Upgrade"
	desc = "An infiltration pinpointer upgrade that allows pinpointers to track objective targets."
	item = /obj/item/infiltrator_pinpointer_upgrade
	cost = 8

/datum/uplink_item/infiltration/extra_stealthsuit
	name = "Extra Chameleon Hardsuit"
	desc = "An infiltration hardsuit, capable of changing it's appearance instantly."
	item = /obj/item/clothing/suit/space/hardsuit/infiltration
	cost = 10

// Events
/datum/uplink_item/services
	category = "Services"
	include_modes = list(/datum/game_mode/infiltration, /datum/game_mode/nuclear)
	surplus = 0

/datum/uplink_item/services/manifest_spoof
	name = "Crew Manifest Spoof"
	desc = "A button capable of adding a single person to the crew manifest."
	item = /obj/item/service/manifest
	cost = 15 //Maybe this is too cheap??

/datum/uplink_item/services/fake_ion
	name = "Fake Ion Storm"
	desc = "Fakes an ion storm announcment. A good distraction, especially if the AI is weird anyway."
	item = /obj/item/service/ion
	cost = 7

/datum/uplink_item/services/fake_meteor
	name = "Fake Meteor Announcement"
	desc = "Fakes an meteor announcment. A good way to get any C4 on the station exterior, or really any small explosion, brushed off as a meteor hit."
	item = /obj/item/service/meteor
	cost = 7

/datum/uplink_item/services/fake_rod
	name = "Fake Immovable Rod"
	desc = "Fakes an immovable rod announcement. Good for a short-lasting distraction."
	item = /obj/item/service/rodgod
	cost = 6 //less likely to be believed

/datum/uplink_item/services/centcom_spoof
	name = "Custom CentCom announcement"
	desc = "Allows you to send a fake CentCom announcement. Abusing this may result in the gods smiting you!"
	item = /obj/item/service/a_really_bad_idea
	cost = 20
	include_modes = list(/datum/game_mode/infiltration) //no shit like this for nukies!


/datum/uplink_item/dangerous/sword
	exclude_modes = list(/datum/game_mode/nuclear/clown_ops, /datum/game_mode/infiltration)

/datum/uplink_item/dangerous/doublesword
	exclude_modes = list(/datum/game_mode/nuclear/clown_ops, /datum/game_mode/infiltration)

/datum/uplink_item/dangerous/syndicate_minibomb
	exclude_modes = list(/datum/game_mode/nuclear/clown_ops, /datum/game_mode/infiltration)

/datum/uplink_item/dangerous/guardian
	exclude_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops, /datum/game_mode/infiltration)

/datum/uplink_item/stealthy_weapons/martialarts
	exclude_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops, /datum/game_mode/infiltration)

/datum/uplink_item/stealthy_weapons/romerol_kit
	exclude_modes = list(/datum/game_mode/nuclear, /datum/game_mode/infiltration)

/datum/uplink_item/stealthy_weapons/detomatix
	exclude_modes = list(/datum/game_mode/infiltration) //stealthhhh!

/datum/uplink_item/device_tools/c4bag
	exclude_modes = list(/datum/game_mode/infiltration) //you don't need to be blowing that much shit up!

/datum/uplink_item/device_tools/x4bag
	exclude_modes = list(/datum/game_mode/infiltration) //you don't need to be blowing that much shit up!

/datum/uplink_item/device_tools/powersink
	exclude_modes = list(/datum/game_mode/infiltration) //if they have this objective, they get a special one

/datum/uplink_item/device_tools/singularity_beacon
	exclude_modes = list(/datum/game_mode/infiltration) //no.

/datum/uplink_item/device_tools/syndicate_bomb
	exclude_modes = list(/datum/game_mode/infiltration) //no blowing shit up

/datum/uplink_item/cyber_implants/thermals
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/infiltration)

/datum/uplink_item/badass/balloon
	exclude_modes = list(/datum/game_mode/infiltration) //no.

/datum/uplink_item/badass/bundle
	exclude_modes = list(/datum/game_mode/nuclear, /datum/game_mode/infiltration)

/datum/uplink_item/badass/surplus
	exclude_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops, /datum/game_mode/infiltration)
