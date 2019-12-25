/datum/component/speed_curse
    var/mob/holder
    var/slowdown
    var/change_delay = 0
    var/lasttime = 0

/datum/component/speed_curse/Initialize(_change_delay)
    _change_delay = (3 SECONDS)
    change_delay = _change_delay

/datum/component/speed_curse/RegisterWithParent()
    RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
    RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)

//Called when we are equipped to a user
/datum/component/speed_curse/proc/on_equip(datum/source, mob/equipper, slot)
    holder = equipper
    //Start processing regularly
    START_PROCESSING(SSdcs, src)

/datum/component/speed_curse/process()
    if(world.time  < (lasttime + change_delay))
        return //no update to movespeed
    else if(holder.is_holding(parent))
        slowdown = rand(-2, 2)
        holder.add_movespeed_modifier(MOVESPEED_ID_TRIBALKNIFE, TRUE, 100, override=TRUE, multiplicative_slowdown = slowdown)
        lasttime = world.time
        //apply slowdown

/datum/component/speed_curse/proc/on_drop(datum/source, mob/user)
    holder = null
    //nothing to do anymore
    STOP_PROCESSING(SSdcs, src)

//cleanup when we are unregistered
/datum/component/speed_curse/UnregisterFromParent()
    UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
    UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
