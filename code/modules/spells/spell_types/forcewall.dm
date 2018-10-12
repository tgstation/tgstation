/obj/effect/proc_holder/spell/targeted/forcewall
	name = "Forcewall"
	desc = "Create a magical barrier that only you can pass through."
	school = "transmutation"
	charge_max = 100
	clothes_req = FALSE
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "shout"
	sound = 'sound/magic/forcewall.ogg'
	action_icon_state = "shield"
	range = -1
	include_user = TRUE
	cooldown_min = 50 //12 deciseconds reduction per rank
	var/wall_type = /obj/effect/forcefield/wizard

/obj/effect/proc_holder/spell/targeted/forcewall/cast(list/targets,mob/user = usr)
	new wall_type(get_turf(user),user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new wall_type(get_step(user, EAST),user)
		new wall_type(get_step(user, WEST),user)
	else
		new wall_type(get_step(user, NORTH),user)
		new wall_type(get_step(user, SOUTH),user)


/obj/effect/forcefield/wizard
	var/mob/wizard

/obj/effect/forcefield/wizard/Initialize(mapload, mob/summoner)
	. = ..()
	wizard = summoner

/obj/effect/forcefield/wizard/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		if(M.anti_magic_check())
			return TRUE
	return FALSE

/obj/effect/proc_holder/spell/targeted/forcewall/sandbag
	name = "Deploy Sandbags"
	desc = "Deploys sandbags to help fortify your location. Ranged weapon fire is blocked by sandbags unless fired adjacent to them."
	school = "transmutation"
	charge_max = 1200
	invocation = "Deploying Sandbags!"
	invocation_type = "shout"
	sound = 'sound/magic/forcewall.ogg'
	action_icon = 'icons/mob/actions/actions_items.dmi'
	action_icon_state = "deploy_box"
	range = -1
	include_user = TRUE
	wall_type = /obj/structure/barricade/sandbags

/obj/effect/proc_holder/spell/targeted/forcewall/sandbag/cast(list/targets,mob/user = usr)
	new wall_type(get_turf(user))