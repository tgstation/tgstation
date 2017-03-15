# Obj Construction
by Cyberboss

##### Interface 

- `/datum/construction_state` - The datum that holds all properties of an object's unfinished states. See the datum definition below

# TODO : Document the datum here

- `/obj/var/datum/construction_state/current_construction_state` - A reference to an obj's current `datum/construction_state`, null means no construction steps defined

- `CONSTRUCTION_BLUEPRINT(<full object path>, <root_only TRUE/FALSE>)` - Called to list out the construction steps of the object path given.the `root_only` parameter is a bool as to whether or not this consturction blueprint applies to subtypes of the object. This is a proc definition for an internal datum. Should return a list of `datum/construction_state`. See ai_core.dm or barsigns.dm in the structures tree for good examples of its use

- `/obj/proc/OnConstruction(state_id, mob/user, obj/item/used)` - Called when a construction step is completed on an object with the new state id. If `state_id` is zero, the object has been fully constructed and can't be deconstructed.	`used` is the material object if any used for construction and it will be deleted/deducted/stashed at the end of this proc. `user` is always holding `used`.

- `/obj/proc/OnDeconstruction(state_id, mob/user, obj/item/created, forced)` - Called when a deconstruction step is completed on an object with the new state_id. If `state_id` is zero, the object has been fully deconstructed. `created` is the item that will be dropped, if any. `forced` is if the object was aggressively put into this state. If it's TRUE, `user` and `created` MAY be null. Returning TRUE from this function will cause `created` to be qdel'd before it is dropped.

- `/obj/proc/OnRepair(mob/user, obj/item/used, old_integrity)` - Called after an object is repaired. `used` is the material object if any used for repairing and it will be deleted/deducted from on return. It is not a tool

- `/obj/proc/Construct(mob/user, ndir)` - Call this after creating an obj to have it appear in it's first `datum/construction_state`. Calling this more than once has no effect. `ndir` is the direction of the new object. Set in the base proc
	
- `/datum/construction_state/proc/DamageDeconstruct(obj/parent)` - Call this on `current_construction_state` if you want to forcefully deconstruct an object. Will be called automatically from `obj_break`. Will only work if the previous state has `damage_reachable` set to TRUE

- `/obj/proc/ConstructionChecks(state_started_id, constructing, obj/item, mob/user, skip)` - Called repeatedly during a construction step. Must check the base. Returning FALSE will cancel the step. Setting skip to TRUE for parent calls requests that no further checks other than the base be made. e.g. Every instance of if must start like this:
```
/obj/.../ConstructionChecks(state_started_id, constructing, obj/item, mob/user, skip)
	. = ..()
    if(!. || skip)
    	return
```
# TODO: Reevaluate the skip arg, is it needed?


- `/obj/var/stored_construction_items` - A list of items stored during construction for states with `stash_construction_item` set to TRUE. This list must be populated on obj Initialization before calling the base. Items in the list will be located in the obj's contents. `datum/construction_state`s with `stash_construction_item` set to TRUE will store the used items in here. This list is keyed by the stringized id of the construction state (e.g. `"[construction_state.id]" => item reference`). Items in this list will be deleted under certain circumstances. An entry is guaranteed to exist if the current_construction_state's id is higher than the id that stored them. Items will be placed back into the world or deleted when the obj is deconstructed
- 
	The following helpers are for easier manipulation of stored_construction_items

	`/obj/proc/GetItemStoredInConstructionState(id)`
    
    `/obj/proc/GetItemUsedToReachConstructionState(id)`
    
	`/obj/proc/SetItemToLeaveConstructionState(id, obj/item/I)`
    
	`/obj/proc/SetItemToReachConstructionState(id, obj/item/I)`