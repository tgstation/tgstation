///Objects or mobs with this componenet will drop items when taking damage.
/datum/component/pinata
	///How much damage does an attack need to do to have a chance to drop "candy"
	var/minimum_damage = 10
	///What is the likelyhood some "candy" should drop when attacked.
	var/drop_chance = 40
	///A list of "candy" items that can be dropped when taking damage
	var/candy = list(/obj/item/food/candy, /obj/item/food/lollipop/cyborg, /obj/item/food/gumball, /obj/item/food/bubblegum, /obj/item/food/chocolatebar)
	///Number of "candy" items dropped when the structure is destroyed/mob is killed, set to 0 if none. drop_chance and minimum damage are not applied.
	var/death_drop = 0

/datum/component/pinata/Initialize()
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_inflicted))
		RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(pinata_broken))
	else if(isstructure(parent))
		RegisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(damage_inflicted))
		RegisterSignal(parent, COMSIG_ATOM_DESTRUCTION, PROC_REF(pinata_broken))
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/pinata/proc/damage_inflicted(obj/target, damage)
	SIGNAL_HANDLER
	if(damage < minimum_damage)
		return
	if(!prob(drop_chance + damage))
		return
	var/list/turf_options = get_adjacent_open_turfs(parent)
	turf_options += get_turf(parent)
	if(length(turf_options))
		var/dropped_item = pick(candy)
		new dropped_item(pick(turf_options))

/datum/component/pinata/proc/pinata_broken()
	SIGNAL_HANDLER
	for(var/i in 1 to death_drop)
		var/dropped_item = pick(candy)
		new dropped_item(get_turf(parent))
	qdel(src)

/datum/component/pinata/Destroy(force, silent)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)
	UnregisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE)
	UnregisterSignal(parent, COMSIG_ATOM_DESTRUCTION)
	return ..()
