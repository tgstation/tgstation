/// Ratwood's shisha pipe (structures/hookah.dm): packed with a powder or a leaf, it is smoked through its hose. A hand takes the
/// mouthpiece, and clicking oneself or another with it (not in combat) takes a gurgling puff of the mix: the less is left, the
/// more a puff draws. The hose reaches hookah_hose_range tiles; further, or dropped, the mouthpiece flies back to the pipe.
/obj/structure/shisha
	/// The mouthpiece on its hose, always this pipe's own.
	var/obj/item/rockhill/hookah_mouthpiece/mouthpiece

/obj/structure/shisha/hookah
	anchored = FALSE

/obj/structure/shisha/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	create_reagents(rogue_value("hookah_volume"))
	make_mouthpiece()

/obj/structure/shisha/Destroy()
	if(mouthpiece)
		UnregisterSignal(mouthpiece, COMSIG_QDELETING)
		QDEL_NULL(mouthpiece)
	return ..()

/obj/structure/shisha/proc/make_mouthpiece()
	mouthpiece = new(src)
	mouthpiece.parent_hookah = WEAKREF(src)
	RegisterSignal(mouthpiece, COMSIG_QDELETING, PROC_REF(on_mouthpiece_deleted))

/// Ratwood on_mouhtpiece_delete(): a lost mouthpiece grows back on the pipe.
/obj/structure/shisha/proc/on_mouthpiece_deleted(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(mouthpiece, COMSIG_QDELETING)
	mouthpiece = null
	if(!QDELETED(src))
		make_mouthpiece()

/// Ratwood reattach_mouthpiece(): the hose pulls the mouthpiece back to the pipe.
/obj/structure/shisha/proc/reattach_mouthpiece()
	if(!mouthpiece || mouthpiece.loc == src)
		return
	var/mob/living/smoker = mouthpiece.loc
	if(istype(smoker))
		smoker.dropItemToGround(mouthpiece, force = TRUE, silent = TRUE)
	mouthpiece.forceMove(src)

/obj/structure/shisha/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(mouthpiece?.loc == src)
		user.put_in_active_hand(mouthpiece)
		to_chat(user, span_notice("You grab \the [src]'s [mouthpiece]."))
	else
		to_chat(user, span_notice("\The [src] is already in use!"))
	return TRUE

/obj/structure/shisha/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == mouthpiece)
		reattach_mouthpiece()
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/reagent_containers/powder) || istype(tool, /obj/item/reagent_containers/food/snacks/grown))
		pack(user, tool)
		return ITEM_INTERACT_SUCCESS
	return NONE

/// Ratwood attackby(): a powder or a leaf goes in whole, if the pipe has room for all of it. Ratwood smokes a leaf's
/// pipe_reagents; the port's leaves carry no such list, so a leaf gives its own reagents, as a pipe does (clothing/smoking.dm).
/obj/structure/shisha/proc/pack(mob/living/user, obj/item/smokable)
	var/amount = smokable.reagents?.total_volume
	if(!amount)
		to_chat(user, span_notice("[smokable] is useless for shisha."))
		return
	if(reagents.total_volume + amount > reagents.maximum_volume)
		to_chat(user, span_notice("[src] is already tightly packed."))
		return
	to_chat(user, span_notice("I pack [src] with [smokable]."))
	smokable.reagents.trans_to(src, amount, transferred_by = user)
	qdel(smokable)

/// The puff: a gurgle, a moment, and the share of the mix the pipe gives (Ratwood: its volume over what is left).
/obj/structure/shisha/proc/puff(mob/living/smoker, mob/living/user)
	if(!reagents.total_volume)
		to_chat(user, span_notice("\The [src] has nothing in it to smoke."))
		return
	playsound(src, 'modular_redtard/rockhill/sound/foley/shisha_gurgle.ogg', rand(70, 100), FALSE, -1)
	if(!do_after(user, rogue_value("hookah_puff_time"), target = smoker) || QDELETED(src) || QDELETED(smoker) || !reagents.total_volume)
		return
	var/amount = reagents.maximum_volume / reagents.total_volume
	if(smoker != user)
		user.visible_message(span_danger("[user] attempts to force [smoker] to take a puff from \the [mouthpiece]."), span_danger("I attempt to force [smoker] to puff \the [mouthpiece]."))
	else
		to_chat(smoker, span_notice("You take a pleasant puff from \the [mouthpiece]."))
	if(!reagents.trans_to(smoker, amount, transferred_by = user, methods = INHALE))
		reagents.remove_all(amount)

/// The hookah's mouthpiece on its hose (Ratwood /obj/item/hookah_mouthpiece, made by the pipe, never on a map).
/obj/item/rockhill/hookah_mouthpiece
	name = "hookah mouthpiece"
	desc = "Pestra knows how many tongues this thing has seen so far."
	icon = 'modular_redtard/rockhill/icons/roguetown/items/misc.dmi'
	icon_state = "mouthpiece"
	inhand_icon_state = null
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	/// The pipe it belongs to.
	var/datum/weakref/parent_hookah
	/// Who holds it, watched so the hose can pull it back.
	var/mob/living/smoker_user

/obj/item/rockhill/hookah_mouthpiece/Destroy()
	if(smoker_user)
		UnregisterSignal(smoker_user, COMSIG_MOVABLE_MOVED)
		smoker_user = null
	parent_hookah = null
	return ..()

/obj/item/rockhill/hookah_mouthpiece/equipped(mob/user, slot, initial)
	. = ..()
	if(smoker_user == user)
		return
	if(smoker_user)
		UnregisterSignal(smoker_user, COMSIG_MOVABLE_MOVED)
	smoker_user = user
	RegisterSignal(smoker_user, COMSIG_MOVABLE_MOVED, PROC_REF(on_smoker_moved))

/obj/item/rockhill/hookah_mouthpiece/dropped(mob/user, silent)
	. = ..()
	if(smoker_user)
		UnregisterSignal(smoker_user, COMSIG_MOVABLE_MOVED)
		smoker_user = null
	if(!parent_hookah?.resolve())
		qdel(src)
		return
	addtimer(CALLBACK(src, PROC_REF(return_to_pipe)), 0)

/// Let go of, the mouthpiece goes back on its hose; passed to the other hand, it stays.
/obj/item/rockhill/hookah_mouthpiece/proc/return_to_pipe()
	if(QDELETED(src) || ismob(loc))
		return
	var/obj/structure/shisha/pipe = parent_hookah?.resolve()
	if(!pipe)
		qdel(src)
		return
	pipe.reattach_mouthpiece()

/obj/item/rockhill/hookah_mouthpiece/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with) || user.combat_mode)
		return NONE
	var/obj/structure/shisha/pipe = parent_hookah?.resolve()
	if(!pipe)
		return NONE
	INVOKE_ASYNC(pipe, TYPE_PROC_REF(/obj/structure/shisha, puff), interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/// Ratwood on_smoker_moved(): walked too far, the mouthpiece flies out of the hand.
/obj/item/rockhill/hookah_mouthpiece/proc/on_smoker_moved(mob/living/moved, atom/old_loc, dir)
	SIGNAL_HANDLER
	var/obj/structure/shisha/pipe = parent_hookah?.resolve()
	if(pipe && get_dist(moved, pipe) <= rogue_value("hookah_hose_range"))
		return
	to_chat(moved, span_notice("[src] flies out of my hands! I walked too far away from [pipe || "the pipe"]."))
	moved.dropItemToGround(src, force = TRUE, silent = TRUE)
