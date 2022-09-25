/datum/component/bumpattack
    dupe_mode = COMPONENT_DUPE_UNIQUE

    var/valid_slots
    var/active = FALSE

    var/mob/living/wearer

    var/obj/item/proxy_weapon


/datum/component/bumpattack/Initialize(valid_slots, obj/item/proxy_weapon)
    if(!isitem(parent))
        return COMPONENT_INCOMPATIBLE

    src.valid_slots = valid_slots

    if(proxy_weapon)
        src.proxy_weapon = proxy_weapon


/datum/component/bumpattack/Destroy(force, silent)
    return ..()
 
/datum/component/bumpattack/RegisterWithParent()
    RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/check_equip)
    RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/check_drop)
 
/datum/component/bumpattack/UnregisterFromParent()
    UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
 
/datum/component/bumpattack/proc/check_equip(obj/item/source, mob/living/user, slot)
    SIGNAL_HANDLER
    if(!user) // iunno, thoroughness
        return

    if((slot & valid_slots))
        activate(user)
    else
        deactivate()

/datum/component/bumpattack/proc/check_drop(datum/source, mob/living/dropper)
    SIGNAL_HANDLER

    deactivate()

/datum/component/bumpattack/proc/activate(mob/living/user)
    if(!istype(user))
        return

    active = TRUE
    wearer = user
    RegisterSignal(user, COMSIG_LIVING_MOB_BUMP, .proc/check_bump)

///Cancel the holdup if the shooter moves out of sight or out of range of the target
/datum/component/bumpattack/proc/deactivate()
    active = FALSE
    if(wearer)
        UnregisterSignal(wearer, COMSIG_LIVING_MOB_BUMP)
    wearer = null


///Bang bang, we're firing a charged shot off
/datum/component/bumpattack/proc/check_bump(mob/living/bumper, mob/living/target)
    SIGNAL_HANDLER

    var/obj/item/our_weapon = proxy_weapon || parent

    if(!istype(our_weapon))
        qdel(src)
        return
    bumper.visible_message(span_danger("[bumper] charges into [target], attacking with [our_weapon]!"), span_danger("You charge into [target], attacking with [our_weapon]!"), vision_distance = COMBAT_MESSAGE_RANGE)
    INVOKE_ASYNC(target, /atom.proc/attackby , our_weapon, bumper)

