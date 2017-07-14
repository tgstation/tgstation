//These components require a powered machine as a parent to run
/datum/component/powered

/datum/component/powered/ReceiveSignal(sigtype, list/sig_args, async)
    var/obj/machinery/M = parent
    return M.is_operational() && ..()
