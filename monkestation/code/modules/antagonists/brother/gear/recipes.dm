/datum/bb_gear/granter/summon(mob/living/summoner, datum/team/brother_team/team)
	var/obj/item/book/granter/granter = new spawn_path
	granter.uses = length(team.members)
	podspawn(list(
		"target" = get_turf(summoner),
		"style" = STYLE_SYNDICATE,
		"spawn" = granter
	))

/datum/bb_gear/granter/trash_cannon
	name = "Recipe: Trash Cannon"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build a trash cannon."
	spawn_path = /obj/item/book/granter/crafting_recipe/trash_cannon
	preview_path = /obj/structure/cannon/trash

/datum/bb_gear/granter/pipegun
	name = "Recipe: Regal Pipegun"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build a regal pipegun."
	spawn_path = /obj/item/book/granter/crafting_recipe/maint_gun/pipegun_prime
	preview_path = /obj/item/gun/ballistic/rifle/boltaction/pipegun/prime

/datum/bb_gear/granter/laser
	name = "Recipe: Heroic Laser Musket"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build a heroic laser musket."
	spawn_path = /obj/item/book/granter/crafting_recipe/maint_gun/laser_musket_prime
	preview_path = /obj/item/gun/energy/laser/musket/prime

/datum/bb_gear/granter/disabler
	name = "Recipe: Elite Smoothbore Disabler"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build an elite smoothbore disabler."
	spawn_path = /obj/item/book/granter/crafting_recipe/maint_gun/smoothbore_disabler_prime
	preview_path = /obj/item/gun/energy/disabler/smoothbore/prime

/datum/bb_gear/granter/elance
	name = "Recipe: Explosive Lance (Grenade)"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build an explosive lance (grenade)."
	spawn_path = /obj/item/spear/explosive
	preview_path = /obj/item/book/granter/crafting_recipe/maint_gun/explosive_lance
