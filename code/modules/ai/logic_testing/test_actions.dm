// Getting to the Holy Land
/datum/goof_action/crusading/boat_to_holy
	cost = 2
	name = "Sail to the Holy Land"
	world_state_changes = list("at_holy_land" = 1)
	prereq_world_state = list("at_holy_land" = 0, "has_boat" = 1)

/datum/goof_action/crusading/horse_to_holy
	cost = 5
	name = "Ride to the Holy Land"
	world_state_changes = list("at_holy_land" = 1)
	prereq_world_state = list("at_holy_land" = 0, "has_horse" = 1)

/datum/goof_action/crusading/walk_to_holy
	cost = 8
	name = "Walk to the Holy Land"
	world_state_changes = list("at_holy_land" = 1)
	prereq_world_state = list("at_holy_land" = 0)

// prayer (very important for crusading)
/datum/goof_action/crusading/pray_at_church
	cost = 3
	name = "Pray at the Church before Departing"
	world_state_changes = list("has_prayed" = 1)
	prereq_world_state = list("at_holy_land" = 0, "has_prayed" = 0)

/datum/goof_action/crusading/pray_at_holy_land
	cost = 5
	name = "Pray at the Holy Land"
	world_state_changes = list("has_prayed" = 1)
	prereq_world_state = list("at_holy_land" = 1, "has_prayed" = 0)

// gear up for smashing the saracens
/datum/goof_action/crusading/buy_sword_and_shield
	cost = 3
	name = "Buy a Sword and Shield before Departing"
	world_state_changes = list("has_sword" = 1, "has_shield" = 1)
	prereq_world_state = list("has_sword" = 0, "has_shield" = 0, "at_holy_land" = 0)

/datum/goof_action/crusading/scavenge_sword
	cost = 3
	name = "Scavenge a Sword"
	world_state_changes = list("has_sword" = 1)
	prereq_world_state = list("has_sword" = 0, "at_holy_land" = 1)

/datum/goof_action/crusading/scavenge_shield
	cost = 3
	name = "Scavenge a Shield"
	world_state_changes = list("has_shield" = 1)
	prereq_world_state = list("has_shield" = 0, "at_holy_land" = 1)

/datum/goof_action/crusading/buy_horse
	cost = 2
	name = "Buy a Horse before Departing"
	world_state_changes = list("has_horse" = 1)
	prereq_world_state = list("at_holy_land" = 0, "has_horse" = 0)

/datum/goof_action/crusading/steal_horse
	cost = 5
	name = "Steal a Horse from the Saracens"
	world_state_changes = list("has_horse" = 1)
	prereq_world_state = list("at_holy_land" = 1, "has_horse" = 0)

// NON NOBIS DOMINE
/datum/goof_action/crusading/crusade
	cost = 1
	name = "DEUS VULT"
	world_state_changes = list("crusading" = 1)
	prereq_world_state = list("has_sword" = 1, "has_shield" = 1, "has_horse" = 1, "has_prayed" = 1, "at_holy_land" = 1)