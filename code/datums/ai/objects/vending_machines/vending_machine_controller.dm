///AI controller for vending machine gone rogue, Don't try using this on anything else, it wont work.
/datum/ai_controller/vending_machine
	movement_delay = 0.4 SECONDS
	behavior_tree_json = "code/datums/ai/objects/vending_machines/vending_machine.bt.json"
	blackboard = list(
		BB_VENDING_CURRENT_TARGET = null,
		BB_VENDING_TILT_COOLDOWN = 0,
		BB_VENDING_UNTILT_COOLDOWN = 0,
		BB_VENDING_BUSY_TILTING = FALSE,
		BB_VENDING_LAST_HIT_SUCCESSFUL = FALSE,
	)
	/// If TRUE stops mobs from buying things from active machines
	var/block_usage = FALSE

/datum/ai_controller/vending_machine/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /obj/machinery/vending))
		return AI_CONTROLLER_INCOMPATIBLE
	var/obj/machinery/vending/vendor_pawn = new_pawn
	vendor_pawn.tiltable = FALSE  //Not manually tiltable by hitting it anymore. We are now aggressively doing it ourselves.
	vendor_pawn.AddElementTrait(TRAIT_WADDLING, REF(src), /datum/element/waddling)
	vendor_pawn.AddElement(/datum/element/footstep, FOOTSTEP_OBJ_MACHINE, 1, -6, sound_vary = TRUE)
	vendor_pawn.squish_damage = 15
	RegisterSignal(vendor_pawn, COMSIG_VENDING_UI_INTERACT, PROC_REF(deny_vending_interact))
	return ..() //Run parent at end

/datum/ai_controller/vending_machine/UnpossessPawn(destroy)
	var/obj/machinery/vending/vendor_pawn = pawn
	vendor_pawn.tiltable = TRUE
	REMOVE_TRAIT(vendor_pawn, TRAIT_WADDLING, REF(src))
	vendor_pawn.squish_damage = initial(vendor_pawn.squish_damage)
	RemoveElement(/datum/element/footstep, FOOTSTEP_OBJ_MACHINE, 1, -6, sound_vary = TRUE)
	UnregisterSignal(vendor_pawn, COMSIG_VENDING_UI_INTERACT)
	return ..() //Run parent at end

/datum/ai_controller/vending_machine/proc/deny_vending_interact(obj/machinery/vending/vending_machine, mob/user, datum/tgui/ui)
	SIGNAL_HANDLER
	if(!block_usage)
		return NONE
	vending_machine.speak(pick(
		"Once in a life time offer, and you [pick("blew it", "missed it", "screwed it up")]!",
		"The deals are off!",
		"We don't accept card, only accept flesh and blood!",
		"You had your chance!",
	))
	return VENDING_DENIED

/datum/ai_controller/vending_machine/eventspawn
	block_usage = TRUE
