/// Basically the squeak component but stripped down for only shoes
/// In other words it replaces the mob's default footstep sounds with the ones provided on all surfaces
/datum/component/shoe_footstep
	/// Tracks how many steps have been taken since the last sound was played
	VAR_PRIVATE/steps = 0

	/// The sounds that can be played
	var/list/sounds
	/// Whether the shoes can be taped, self-deleting the component / making the shoes silent
	var/can_tape
	/// The volume of the sound
	var/volume
	/// The chance that a sound will be played
	var/chance_per_play
	/// The number of steps that must be taken before a sound can be played
	var/steps_per_play
	/// Extrarange modifier on the played footstep sound
	var/extrarange
	/// Falloff exponent for the played footstep sound
	var/falloff_exponent
	/// Falloff distance for the played footstep sound
	var/falloff_distance

/datum/component/shoe_footstep/Initialize(
	list/sounds,
	volume = 50,
	chance_per_play = 100,
	steps_per_play = 1,
	extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE,
	falloff_exponent = SOUND_FALLOFF_EXPONENT,
	falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE,
)
	if(!istype(parent, /obj/item/clothing/shoes))
		return COMPONENT_INCOMPATIBLE
	if(!length(sounds) || volume <= 0 || chance_per_play <= 0 || steps_per_play < 0)
		return COMPONENT_INCOMPATIBLE
	src.sounds = sounds
	src.can_tape = can_tape
	src.volume = volume
	src.chance_per_play = chance_per_play
	src.steps_per_play = steps_per_play
	src.extrarange = extrarange
	src.falloff_exponent = falloff_exponent
	src.falloff_distance = falloff_distance

/datum/component/shoe_footstep/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, PROC_REF(stepped))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))

	var/obj/item/parent_object = parent
	var/mob/living/wearer = parent_object.loc
	if(istype(wearer) && (wearer.get_slot_by_item(parent_object) & parent_object.slot_flags))
		ADD_TRAIT(wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))

/datum/component/shoe_footstep/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_SHOES_STEP_ACTION,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
	))
	var/obj/item/parent_object = parent
	if(ismob(parent_object.loc))
		REMOVE_TRAIT(parent_object.loc, TRAIT_SILENT_FOOTSTEPS, REF(src))

/datum/component/shoe_footstep/proc/stepped(obj/item/clothing/shoes/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/owner = source.loc
	if(SHOULD_ATOM_DISABLE_FOOTSTEPS(owner) || SHOULD_MOB_DISABLE_FOOTSTEPS(owner))
		return
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_SILENT_FOOTSTEPS, REF(src)) )
		return // a second source of silent footsteps silences us! the plot thickens

	if(steps < steps_per_play)
		steps++
		return

	steps = 0
	if(prob(chance_per_play))
		playsound(
			source = source,
			soundin = pick(sounds),
			vol = volume,
			vary = TRUE,
			extrarange = extrarange,
			falloff_exponent = falloff_exponent,
			falloff_distance = falloff_distance,
		)

/datum/component/shoe_footstep/proc/equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(slot & source.slot_flags)
		ADD_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))

/datum/component/shoe_footstep/proc/dropped(obj/item/source, mob/user, silent)
	SIGNAL_HANDLER
	REMOVE_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))
