GENERAL_PROTECT_DATUM(/mob/admin_verb_holder)
GENERAL_PROTECT_DATUM(/datum/admin_verb)

/// The only purpose of this fake mob is to hold the admin verb and utilize the group verb system.
/mob/admin_verb_holder
    var/datum/admin_verb/parent_admin_verb //! The parent admin verb datum which this holder is assigned to.

/mob/admin_verb_holder/Destroy(force)
    if(!QDELING(parent_admin_verb))
        qdel(parent_admin_verb, TRUE)
    parent_admin_verb = null
    return ..()

/**
 * This is the admin verb datum. It is used to store the verb's information and handle the verb's functionality.
 * All of this is setup for you, and you should not be defining this manually.
 * That means you reader.
 */
/datum/admin_verb
    var/name //! The name of the verb.
    var/description //! The description of the verb.
    var/category //! The category of the verb.
    var/permissions //! The permissions required to use the verb.
    var/mob/admin_verb_holder/verb_holder //! The holder for this verb.
    var/list/mob/mobs_assigned_by_ckey = list() //! A list of mobs assigned to this verb by ckey. Used for tracking and removing the holder from mob groups

/datum/admin_verb/New()
    verb_holder = new verb_holder
    verb_holder.parent_admin_verb = src
    return ..()

/datum/admin_verb/Destroy(force)
    if(!force)
        return QDEL_HINT_LETMELIVE
    // its very important we do it in this order!
    for(var/ckey in mobs_assigned_by_ckey)
        unassign_ckey(ckey)
    if(!QDELING(verb_holder))
        qdel(verb_holder, TRUE)
    verb_holder = null
    return ..()

/datum/admin_verb/proc/check_should_exist()
    return TRUE

/// Assigns a mob to this admin verb and stores a reference to it to prevent double assignment
/datum/admin_verb/proc/assign_to_mob(mob/target)
    if(isnull(target.ckey))
        CRASH("Attempted to assign admin verb [type] to a mob that doesnt have a ckey. Absolutely not.")
    if(target.ckey in mobs_assigned_by_ckey)
        unassign_ckey(target.ckey)
    target.group += list(verb_holder)
    mobs_assigned_by_ckey[target.ckey] = target

/// Unassigns the mob referenced to by the specified ckey. Usually for logout or mob switching.
/datum/admin_verb/proc/unassign_ckey(ckey)
    if(!(ckey in mobs_assigned_by_ckey))
        return // not even in the list, fool
    mobs_assigned_by_ckey[ckey].group -= list(verb_holder)
    mobs_assigned_by_ckey -= ckey
