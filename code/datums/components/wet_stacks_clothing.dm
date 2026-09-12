/// a component for clothing or objects which will apply wet stacks to whoever wears or holds it
/datum/component/wet_stacks_clothing
	/// how many wet stacks will be added per tick, as well as the threshold (if less than will not add)
	var/stacks_to_add = 3
	/// will fire stacks be removed?
	var/dousing = FALSE
	/// must the parent item be worn? if false component will process in-hand
	var/must_be_worn = TRUE
	/// who is in posession of parent and should gain the stacks?
	var/mob/living/carbon/wearer
	/// the callback which will try to drain a cell if provided
	var/datum/callback/use_cell
	/// how often it ticks to check for adding stacks
	COOLDOWN_DECLARE(tick_cooldown)

/datum/component/wet_stacks_clothing/Initialize(datum/callback/use_cell, must_be_worn)
	. = ..()
	if(!isobj(parent))
		stack_trace("[src] component was applied to something other than an object, [parent] ([parent.type].)")
	src.use_cell = use_cell
	src.must_be_worn = must_be_worn

/datum/component/wet_stacks_clothing/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(start_processing))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(stop_processing))

/datum/component/wet_stacks_clothing/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED,	COMSIG_ITEM_DROPPED))

/// proc when picked up or worn by someone
/datum/component/wet_stacks_clothing/proc/start_processing(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	if(must_be_worn && (slot & ITEM_SLOT_HANDS))
		return
	START_PROCESSING(SSobj, src)
	wearer = user

/// proc when dropped
/datum/component/wet_stacks_clothing/proc/stop_processing(obj/item/source, mob/living/user)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)
	wearer = null

/datum/component/wet_stacks_clothing/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, tick_cooldown))
		return
	COOLDOWN_START(src, tick_cooldown, rand(10 SECONDS, 30 SECONDS))
	// don't set stacks if a higher amount has already been applied to wearer
	var/datum/status_effect/fire_handler/wet_stacks/wet_stacks = wearer.has_status_effect(/datum/status_effect/fire_handler/wet_stacks)
	if(wet_stacks?.stacks > stacks_to_add)
		return
	// try to drain a cell if provided
	if(!use_cell?.Invoke())
		return
	playsound(wearer, 'sound/effects/droplet.ogg', rand(15, 35), TRUE, falloff_exponent = 5)
	wearer.set_wet_stacks(stacks = stacks_to_add, remove_fire_stacks = dousing)
