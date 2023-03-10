///Objects or mobs with this element will drop items when taking damage.
/datum/element/pinata
	///How much damage does an attack need to do to have a chance to drop "candy"
	var/minimum_damage
	///What is the likelyhood some "candy" should drop when attacked.
	var/drop_chance
	///A list of "candy" items that can be dropped when taking damage
	var/candy
	///Number of "candy" items dropped when the structure is destroyed/mob is killed, set to 0 if none. drop_chance and minimum damage are not applied.
	var/death_drop

/datum/element/pinata/Attach(
		datum/target,
		minimum_damage = 10,
		drop_chance = 40,
		candy = list(/obj/item/food/candy, /obj/item/food/lollipop/cyborg, /obj/item/food/gumball, /obj/item/food/bubblegum, /obj/item/food/chocolatebar),
		death_drop = 5
	)
	. = ..()
	src.minimum_damage = minimum_damage
	src.drop_chance = drop_chance
	src.candy = candy
	src.death_drop = death_drop

	if(ismob(target))
		RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_inflicted))
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(pinata_broken))
	else if(isstructure(target) || ismachinery(target))
		RegisterSignal(target, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(damage_inflicted))
		RegisterSignal(target, COMSIG_ATOM_DESTRUCTION, PROC_REF(pinata_broken))
	else
		return ELEMENT_INCOMPATIBLE

/datum/element/pinata/proc/damage_inflicted(obj/target, damage, damage_type)
	SIGNAL_HANDLER
	if(damage < minimum_damage || damage_type == STAMINA || damage_type == OXY)
		return
	if(!prob(drop_chance + damage)) //Higher damage means less rolls but higher odds on the roll
		return
	var/list/turf_options = get_adjacent_open_turfs(target)
	turf_options += get_turf(target)
	if(length(turf_options))
		var/dropped_item = pick(candy)
		new dropped_item(pick(turf_options))

/datum/element/pinata/proc/pinata_broken(obj/target)
	SIGNAL_HANDLER
	for(var/i in 1 to death_drop)
		var/dropped_item = pick(candy)
		new dropped_item(get_turf(target))
	target.RemoveElement(/datum/element/pinata)

/datum/element/pinata/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(source, COMSIG_LIVING_DEATH)
	UnregisterSignal(source, COMSIG_ATOM_TAKE_DAMAGE)
	UnregisterSignal(source, COMSIG_ATOM_DESTRUCTION)

/datum/element/pinata/Destroy(force, silent)
	return ..()
