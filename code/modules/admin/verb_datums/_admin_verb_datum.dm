
ADMIN_VERB( \
    name_of_verb, \
    R_ADMIN, \
    "Verb Name", \
    "Verb Desc", \
    "Verb Category", \
    /mob/target in view(1),
)
    to_chat(user, span_userdanger("Hello!"))

/// The only purpose of this fake mob is to hold the admin verb and utilize the group verb system.
/mob/admin_verb_holder
    var/datum/admin_verb/parent_admin_verb //! The parent admin verb datum which this holder is assigned to.

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
    var/list/mobs_assigned_by_ckey = list() //! A list of mobs assigned to this verb by ckey. Used for tracking and removing the holder from mob groups

/datum/admin_verb/proc/assign_to_client(client/admin)
    SHOULD_NOT_OVERRIDE(TRUE)
    if(admin.ckey in mobs_assigned_by_ckey)
        remove_from_client(admin)
    admin.mob.group += list(verb_holder)
    mobs_assigned_by_ckey[admin.ckey] = verb_holder

/datum/admin_verb/proc/remove_from_client(client/admin)
    SHOULD_NOT_OVERRIDE(TRUE)
    if(!(admin.ckey in mobs_assigned_by_ckey))
        return
    mobs_assigned_by_ckey[admin.ckey].group -= list(verb_holder)
    mobs_assigned_by_ckey -= admin.ckey

/datum/admin_verb/proc/handle_client_login(client/admin)
    SHOULD_NOT_OVERRIDE(TRUE)
    assign_to_client(admin)

/datum/admin_verb/proc/handle_client_logout(client/admin)
    SHOULD_NOT_OVERRIDE(TRUE)
    remove_from_client(admin)
