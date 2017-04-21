# Obj Construction
by Cyberboss

##### Interface 

- `/datum/construction_state` - The datum that holds all properties of an object's unfinished states. See the datum definition below

# TODO : Document the datum here

- `/obj/var/datum/construction_state/current_construction_state` - A reference to an obj's current `datum/construction_state`, null means no construction steps defined

- `CONSTRUCTION_BLUEPRINT(<full object path>, <root_only TRUE/FALSE>, <build_root_only TRUE/FALSE>)` - Called to list out the construction steps of the object path given. The `root_only` parameter is a bool as to whether or not this consturction blueprint applies to subtypes of the object. `build_root_only` means that only the type that defined the blueprint can be constructed. This is a proc definition for an internal datum. Should return a list of `datum/construction_state`. See ai_core.dm or barsigns.dm in the structures tree for good examples of its use

- `/obj/proc/OnConstruction(state_id, mob/user, obj/item/used)` - Called when a construction step is completed on an object with the new state id. If `state_id` is zero, the object has been fully constructed and can't be deconstructed.	`used` is the material object if any used for construction and it will be deleted/deducted/stashed at the end of this proc. `user` is always holding `used`.

- `/obj/proc/OnConstructionTransform(mob/user, obj/created)` - Called when the last construction state is reached and has a transformation_type set. `user` is the mob that constructed it.
`created` is the object that was created. `Construct` will be called on `created` when it returns. If `CONSTRUCTION_TRANSFORMATION_TYPE_AT_RUNTIME` was set as a transformation_type this proc must return a new /obj.

- `/obj/proc/OnDeconstruction(state_id, mob/user, obj/item/created, forced)` - Called when a deconstruction step is completed on an object with the new state_id. If `state_id` is zero, the object has been fully deconstructed. `created` is the item that will be dropped, if any. `forced` is if the object was aggressively put into this state. If it's TRUE, `user` and `created` MAY be null. Returning TRUE from this function will cause `created` to be qdel'd before it is dropped.

- `/obj/proc/OnRepair(mob/user, obj/item/used, old_integrity)` - Called after an object is repaired. `used` is the material object if any used for repairing and it will be deleted/deducted from on return. It is not a tool

- `/obj/proc/Construct(mob/user, ndir)` - Call this after creating an obj to have it appear in it's first `datum/construction_state`. Must not be called more than once. `ndir` is the direction of the new object. Set in the base proc
	
- `/datum/construction_state/proc/DamageDeconstruct(obj/parent)` - Call this on `current_construction_state` if you want to forcefully deconstruct an object. Will be called automatically from `obj_break`. Will only work if the previous state has `damage_reachable` set to TRUE

- `/obj/proc/ConstructionChecks(state_started_id, action_type, obj/item, mob/user, first_check)` - Called repeatedly during a construction step. Must check the base. Returning FALSE will cancel the step. The proc should not continue if the parent call returns FALSE. `action_type` is the type of construction going on, either `CONSTRUCTING`, `DECONSTRUCTING`, or `REPAIRING`. `first_check` is TRUE if this is the first time the check is called in the construction action. Should generally be ignored in the logic (i.e. The base proc uses it to change the wording for welding tool and material checks).

- `/obj/proc/ConstructionDoAfter(mob/user, obj/item/I, delay)` - Call this when you want to do a custom action not supported by the construction system (i.e. Some optional step with a delay). This will call ConstructionChecks with the appropriate parameters and `CUSTOM_CONSTRUCTION` as `action_type`. This will also play `I`'s usesound at the appropriate volume if it has one. `user` is the mob performing the task. `I` is the tool being used to perform the task (can be null). `delay` is exactly how long the task should take.

- `/obj/var/bp_name` - The name of an item as it appears in stack construction recipes, if this is null, the regular name will be used

- `/obj/var/construction_blueprint` - Set by the CONSTRUCTION_BLUEPRINT macro, setting this back to null on subtypes will prevent those types from being able to be stack constructed even if they have `root_only` set to FALSE

- `/obj/var/stored_construction_items` - A list of items stored during construction for states with `stash_construction_item` set to TRUE. This list must be populated on obj Initialization before calling the base. Items in the list will be located in the obj's contents. `datum/construction_state`s with `stash_construction_item` set to TRUE will store the used items in here. This list is keyed by the stringized id of the construction state (e.g. `"[construction_state.id]" => item reference`). Items in this list will be deleted under certain circumstances. An entry is guaranteed to exist if the current_construction_state's id is higher than the id that stored them. Items will be placed back into the world or deleted when the obj is deconstructed
- 
	The following helpers are for easier manipulation of stored_construction_items

	`/obj/proc/GetItemStoredInConstructionState(id)`
    
    `/obj/proc/GetItemUsedToReachConstructionState(id)`
    
	`/obj/proc/SetItemToLeaveConstructionState(id, obj/item/I)`
    
	`/obj/proc/SetItemToReachConstructionState(id, obj/item/I)`