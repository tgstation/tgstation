/datum/component/bugged/proc/on_heard(datum/source, list/hearing_args)
	var/atom/movable/virtualspeaker/speaker = new(null, hearing_args[HEARING_SPEAKER], src)
	var/datum/signal/subspace/vocal/signal = new(hearing_args[HEARING_SPEAKER], FREQ_SYNDICATE, speaker, /datum/language/common, hearing_args[HEARING_RAW_MESSAGE], list(SPAN_ROBOT), list())
	signal.send_to_receivers()

/datum/component/bugged/Initialize()
	RegisterSignals(parent, list(COMSIG_MOVABLE_HEAR), PROC_REF(on_heard))

/obj/item/spy_bug
	name = "\improper spy bug"
	desc = "A small little dot commonly used by the Syndicate to track communications."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "bug"
	w_class = WEIGHT_CLASS_TINY

/obj/item/spy_bug/Bump(atom/A)
	A.AddComponent(/datum/component/bugged)
	qdel(src)
	. = ..()


/obj/item/spy_bug/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if (!proximity_flag)
		return
	target.AddComponent(/datum/component/bugged)
	user.show_message(span_notice("You attach \the [name] onto [target]!"))
	qdel(src)