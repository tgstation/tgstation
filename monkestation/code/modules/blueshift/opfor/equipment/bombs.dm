/datum/opposing_force_equipment/bomb_chemical
	category = OPFOR_EQUIPMENT_CATEGORY_BOMB_CHEM

/datum/opposing_force_equipment/bomb_chemical/c4
	item_type = /obj/item/grenade/c4
	description = "A brick of plastic explosives, for breaking open walls, doors, and optionally people."

/datum/opposing_force_equipment/bomb_chemical/x4
	item_type = /obj/item/grenade/c4/x4
	description = "Similar to C4, but with a stronger blast that is directional instead of circular."

/datum/opposing_force_equipment/bomb_chemical/minibomb
	name = "Syndicate Minibomb"
	item_type = /obj/item/grenade/syndieminibomb
	description = "The minibomb is a grenade with a five-second fuse. Upon detonation, it will create a small hull breach in addition to dealing high amounts of damage to nearby personnel."

/datum/opposing_force_equipment/bomb_chemical/minibomb_cluster
	name = "Syndicate Minibomb Cluster-Grenade"
	admin_note = "Devastating payload, equal explosion size to the average command bridge."
	item_type = /obj/item/grenade/clusterbuster/syndieminibomb

/datum/opposing_force_equipment/bomb_chemical/fragnade
	item_type = /obj/item/grenade/frag
	description = "A fragmentation grenade that looses pieces of shrapnel after detonating for maximum injury."

/datum/opposing_force_equipment/bomb_chemical/fire
	name = "Incendiary Grenade"
	admin_note = "Very mid despite having a scary name."
	item_type = /obj/item/grenade/chem_grenade/incendiary

/datum/opposing_force_equipment/bomb_chemical/fire_cluster
	name = "Incendiary Cluster-Grenade"
	admin_note = "Room-filling plasmafire that lasts for about 10 seconds."
	item_type = /obj/item/grenade/clusterbuster/inferno

/datum/opposing_force_equipment/bomb_chemical/clf3
	name = "Trifluoride Grenade"
	admin_note = "In most cases you want to refer the player to the 'incendiary grenade' instead. This grenade has a huge scale, and spaces non-floored tiles."
	item_type = /obj/item/grenade/chem_grenade/clf3
/*
/datum/opposing_force_equipment/bomb_chemical/clf3_cluster //this fucking thing deletes your station
	name = "Trifluoride Cluster-Grenade"
	admin_note = ""
	item_type = /obj/item/grenade/clusterbuster/clf3
*/
/datum/opposing_force_equipment/bomb_chemical/facid
	name = "Acid grenade"
	admin_note = "This thing will remove most player's clothing."
	item_type = /obj/item/grenade/chem_grenade/facid
/*
/datum/opposing_force_equipment/bomb_chemical/facid_cluster //massive collateral. only uncomment if you're OK with all of crew becoming nude
	name = "Acid Cluster-Grenade"
	item_type = /obj/item/grenade/clusterbuster/facid
*/
/datum/opposing_force_equipment/bomb_chemical/radnade
	item_type = /obj/item/grenade/gluon
	description = "A prototype grenade that freezes the target area and unleashes a wave of deadly radiation."

/datum/opposing_force_equipment/bomb_chemical/henade
	item_type = /obj/item/grenade/syndieminibomb/concussion
	description = "A grenade intended to concuss and incapacitate enemies. Still rather explosive."

/datum/opposing_force_equipment/bomb_chemical/anti_grav
	name = "Anti-Gravity Grenade"
	item_type = /obj/item/grenade/antigravity

/datum/opposing_force_equipment/bomb_chemical/emp
	name = "EMP Grenade"
	item_type = /obj/item/grenade/empgrenade

/datum/opposing_force_equipment/bomb_chemical/flashbang
	name = "Flashbang"
	item_type = /obj/item/grenade/flashbang
	description = "A flash-and-sonic stun grenade, useful for non-lethally incapacitating crowds."

/datum/opposing_force_equipment/bomb_chemical/smoke
	name = "Smoke Grenade"
	item_type = /obj/item/grenade/smokebomb

/datum/opposing_force_equipment/bomb_chemical/soap
	name = "Soap cluster-Grenade"
	item_type = /obj/item/grenade/clusterbuster/soap

/datum/opposing_force_equipment/bomb_chemical/moustache
	name = "Tearstache Grenade"
	item_type = /obj/item/grenade/chem_grenade/teargas/moustache
	admin_note = "Puts mustaches on their victims that last for ten minutes."

/datum/opposing_force_equipment/bomb_chemical/carp
	name = "Carp Grenade"
	item_type = /obj/item/grenade/spawnergrenade/spesscarp

/datum/opposing_force_equipment/bomb_chemical/carp_cluster
	name = "Carp Cluster-Grenade"
	item_type = /obj/item/grenade/clusterbuster/spawner_spesscarp

/datum/opposing_force_equipment/bomb_chemical/viscerator
	name = "Viscerator Delivery Grenade"
	item_type = /obj/item/grenade/spawnergrenade/manhacks
	description = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred any non-operatives in the area."

/datum/opposing_force_equipment/bomb_chemical/viscerator_cluster
	name = "Viscerator Delivery cluster-Grenade"
	item_type = /obj/item/grenade/clusterbuster/spawner_manhacks

/datum/opposing_force_equipment/bomb_chemical/buzzkill
	name = "Buzzkill Grenade"
	item_type = /obj/item/grenade/spawnergrenade/buzzkill
	description = "A grenade that release a swarm of angry bees upon activation. These bees indiscriminately attack friend or foe with random toxins. Courtesy of the BLF and Tiger Cooperative."
	admin_note = "WARNING: The bee's from this grenade can have almost anything chem-wise into them, and just a few can make a massive swarm of bees(10 bees per!!)"

/datum/opposing_force_equipment/bomb_chemical/pizza
	name = "Pizza Bomb"
	item_type = /obj/item/pizzabox/bomb
	description = "A pizza box with a bomb cunningly attached to the lid. The timer needs to be set by opening the box; afterwards,	opening the box again will trigger the detonation after the timer has elapsed. Comes with free pizza, for you or your target!"

/datum/opposing_force_equipment/bomb_payload
	category = OPFOR_EQUIPMENT_CATEGORY_BOMB_PAYLOAD

/datum/opposing_force_equipment/bomb_payload/syndicate
	name = "Syndicate Bomb"
	item_type = /obj/item/sbeacondrop/bomb
	description = "A large, powerful bomb that can be wrenched down and armed with a variable timer."
	admin_note = "WARNING: This is a pretty big bomb, it can take out entire rooms."

/datum/opposing_force_equipment/bomb_payload/syndicate_emp
	name = "Syndicate EMP Bomb"
	item_type = /obj/item/sbeacondrop/emp
	description = "A modified version of the Syndicate Bomb that releases a large EMP instead."

/datum/opposing_force_equipment/bomb_payload/syndicate_sink
	name = "Syndicate Power Sink"
	item_type = /obj/item/sbeacondrop/powersink

/datum/opposing_force_equipment/bomb_payload/syndicate_clown_bomb
	name = "Syndicate Clown Bomb"
	item_type = /obj/item/sbeacondrop/clownbomb
	admin_note = "Does not deal any damage, just spawns twenty passive simplemob clowns."
