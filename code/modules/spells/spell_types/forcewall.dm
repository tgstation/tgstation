/obj/effect/proc_holder/spell/targeted/forcewall
	name = "Forcewall"
	desc = "Create a magical barrier that only you can pass through. Does not require wizard garb."
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "shout"
	sound =  "sound/magic/ForceWall.ogg"
	action_icon_state = "shield"
	range = -1
	include_user = 1
	cooldown_min = 50 //12 deciseconds reduction per rank

/obj/effect/proc_holder/spell/targeted/forcewall/cast(list/targets,mob/user = usr)
	new /obj/effect/forcefield/wizard(get_turf(user),user)
	if(user.dir == SOUTH || user.dir == NORTH)

/obj/effect/forcefield/wizard/CanPass(atom/movable/mover, turf/target, height=0)
	if(mover == wizard)
		return 1
	return 0
