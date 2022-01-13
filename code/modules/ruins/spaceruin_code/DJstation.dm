/////////// djstation items

/obj/item/paper/fluff/ruins/djstation
	name = "paper - 'DJ Listening Outpost'"
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio frequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multitool</li><li>Use the multitool on the relay.</li><li>Turn it on. It has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms. They are located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.9 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Service Channel</li><li>134.7 - Supply Channel</li>"


/////////// djstation module templates

///// radio room

/datum/map_template/map_module/djstation/radio/variant1
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/radioroom_1.dmm"

/datum/map_template/map_module/djstation/radio/variant2
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/radioroom_2.dmm"

/datum/map_template/map_module/djstation/radio/variant3
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/radioroom_3.dmm"

///// starboard solars

/datum/map_template/map_module/djstation/solar/variant1
	name = "Ruskie DJ Station Solar Array"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/solar_1.dmm"

/datum/map_template/map_module/djstation/solar/variant2
	name = "Ruskie DJ Station Solar Array"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/solar_2.dmm"

///// sleeping quarters

/datum/map_template/map_module/djstation/quarters/variant1
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/quarters_1.dmm"

/datum/map_template/map_module/djstation/quarters/variant2
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/quarters_2.dmm"

/datum/map_template/map_module/djstation/quarters/variant3
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/quarters_3.dmm"

/datum/map_template/map_module/djstation/quarters/variant4
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/quarters_4.dmm"

///// kitchen

/datum/map_template/map_module/djstation/kitchen/variant1
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/kitchen_1.dmm"

/datum/map_template/map_module/djstation/kitchen/variant2
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/kitchen_2.dmm"

/datum/map_template/map_module/djstation/kitchen/variant3
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/kitchen_3.dmm"

/datum/map_template/map_module/djstation/kitchen/variant4
	name = "Ruskie DJ Station Radio Room"
	mappath = "_maps/RandomRuins/SpaceRuins/DJstation/kitchen_4.dmm"

/////////// djstation module roots

/obj/modular_map_root/djstation/radio
	modules = list(/datum/map_template/map_module/djstation/radio/variant1, /datum/map_template/map_module/djstation/radio/variant2, /datum/map_template/map_module/djstation/radio/variant3)

/obj/modular_map_root/djstation/solar
	modules = list(/datum/map_template/map_module/djstation/solar/variant1, /datum/map_template/map_module/djstation/solar/variant2)

/obj/modular_map_root/djstation/quarters
	modules = list(/datum/map_template/map_module/djstation/quarters/variant1, /datum/map_template/map_module/djstation/quarters/variant2, /datum/map_template/map_module/djstation/quarters/variant3, /datum/map_template/map_module/djstation/quarters/variant4)

/obj/modular_map_root/djstation/kitchen
	modules = list(/datum/map_template/map_module/djstation/kitchen/variant1, /datum/map_template/map_module/djstation/kitchen/variant2, /datum/map_template/map_module/djstation/kitchen/variant3, /datum/map_template/map_module/djstation/kitchen/variant4)
