/obj/structure/alien_tank
	name = "alien tank"
	icon = 'monkestation/code/modules/ghost_players/arena/arena_assets/icons/alien_autopsy.dmi'
	icon_state = "tank_empty"
	desc = "An empty tank full of unknown liquid."
	density = TRUE
	anchored = TRUE

/obj/structure/alien_tank/broken
	name = "broken alien tank"
	icon_state = "tank_broken"
	desc = "This is what happens when you let humans unto an alien ship filled with fragile equipment."

/obj/structure/alien_tank/filled
	icon_state = "tank_alien"
	desc = "Occupied."

/obj/structure/alien_tank/filled/hugger
	icon_state = "tank_hugger"

/obj/structure/alien_tank/filled/larva
	icon_state = "tank_larva"

/obj/structure/alien_sleeper
	name = "alien hypersleep chamber"
	icon = 'monkestation/code/modules/ghost_players/arena/arena_assets/icons/alien_sleeper.dmi'
	icon_state = "sleeper"
	desc = "Appears to be occupied. Best not disturb their sleep."
	density = TRUE
	anchored = TRUE
