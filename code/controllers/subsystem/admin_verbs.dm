GENERAL_PROTECT_DATUM(/datum/controller/subsystem/admin_verbs)

SUBSYSTEM_DEF(admin_verbs)
    name = "Admin Verbs"
    flags = SS_NO_FIRE
    var/list/datum/admin_verb/admin_verbs_by_type
    var/list/datum/admin_verb/admin_verbs_by_permission

/datum/controller/subsystem/admin_verbs/Initialize()
    setup_verb_list()
    setup_permissions_map()
    return SS_INIT_SUCCESS

/datum/controller/subsystem/admin_verbs/Recover()
    admin_verbs_by_type = SSadmin_verbs.admin_verbs_by_type
    admin_verbs_by_permission = SSadmin_verbs.admin_verbs_by_permission

/datum/controller/subsystem/admin_verbs/stat_entry(msg)
    return "[..()] | V: [length(admin_verbs_by_type)]"

/datum/controller/subsystem/admin_verbs/proc/setup_verb_list()
    if(length(admin_verbs_by_type))
        CRASH("Attempting to setup admin verbs twice!")
    admin_verbs_by_type = list()
    for(var/datum/admin_verb/verb_type as anything in subtypesof(/datum/admin_verb))
        var/datum/admin_verb/verb_singleton = new verb_type
        if(!verb_singleton.check_should_exist())
            qdel(verb_singleton, force = TRUE)
            continue
        admin_verbs_by_type[verb_type] = verb_singleton

/datum/controller/subsystem/admin_verbs/proc/setup_permissions_map()
    if(length(admin_verbs_by_permission))
        CRASH("Attempting to setup verb permission map twice!")
    admin_verbs_by_permission = list()
    for(var/flag in GLOB.bitflags)
        admin_verbs_by_permission[flag] = list()

    for(var/datum/admin_verb/verb_singleton as anything in admin_verbs_by_type)
        verb_singleton = admin_verbs_by_type[verb_singleton]
        for(var/permission_flag in bitfield_to_list(verb_singleton.permissions))
            admin_verbs_by_permission[permission_flag] += list(verb_singleton)

/datum/controller/subsystem/admin_verbs/proc/get_valid_verbs_for_admin(client/admin)
    if(isnull(admin.holder))
        CRASH("Why are we checking a non-admin for their valid... ahem... admin verbs?")

    var/list/has_permission = list()
    for(var/permission_flag in GLOB.bitflags)
        if(admin.holder.check_for_rights(permission_flag))
            has_permission[permission_flag] = TRUE

    var/list/valid_verbs = list()
    for(var/datum/admin_verb/verb_type as anything in admin_verbs_by_type)
        var/datum/admin_verb/verb_singleton = admin_verbs_by_type[verb_type]
        for(var/permission_flag in bitfield_to_list(verb_singleton.permissions))
            if(!has_permission[permission_flag])
                continue
            valid_verbs |= list(verb_singleton)

    return valid_verbs

/datum/controller/subsystem/admin_verbs/proc/dynamic_invoke_verb(client/admin, datum/admin_verb/verb_type, ...)
    if(!ispath(verb_type, /datum/admin_verb) || verb_type == /datum/admin_verb)
        CRASH("Attempted to dynamically invoke admin verb with invalid typepath '[verb_type]'.")
    if(isnull(admin.holder))
        CRASH("Attempted to dynamically invoke admin verb '[verb_type]' with a non-admin.")

    var/list/verb_args = args.Copy(3)
    var/datum/admin_verb/verb_singleton = admin_verbs_by_type[verb_type]
    if(isnull(verb_singleton))
        CRASH("Attempted to dynamically invoke admin verb '[verb_type]' that doesn't exist.")
    
    var/old_usr = usr
    admin = CLIENT_FROM_VAR(admin)
    usr = admin.mob
    // THE MACRO ENSURES THIS EXISTS. IF IT EVER DOESNT EXIST SOMEONE DIDNT USE THE DAMN MACRO!
    verb_singleton:do_verb(arglist(verb_args))
    usr = old_usr
    SSblackbox.record_feedback("tally", "dynamic_admin_verb_invocation", 1, "[verb_type]")

/// Reacts to the client logging into another mob. Admin verb assigning will automatically unassign their old mob on new mob assignment.
/datum/controller/subsystem/admin_verbs/proc/on_client_mob_login(client/source)
    SIGNAL_HANDLER
    assosciate_admin(source)

/**
 * Assosciates an admin with their admin verbs. Also registers to the client logging into another a mob so that their admin verbs carry over properly.
 */
/datum/controller/subsystem/admin_verbs/proc/assosciate_admin(client/admin)
    if(IsAdminAdvancedProcCall())
        return

    RegisterSignal(admin, COMSIG_CLIENT_MOB_LOGIN, PROC_REF(on_client_mob_login))
    var/mob/admin_mob = admin.mob
    for(var/datum/admin_verb/verb_singleton as anything in get_valid_verbs_for_admin(admin))
        verb_singleton.assign_to_mob(admin_mob)

/**
 * Unassosciates an admin from their admin verbs.
 * Goes over all admin verbs because we don't know which ones are assigned to the admin's mob without a bunch of extra bookkeeping.
 * This might be a performance issue in the future if we have a lot of admin verbs.
 */
/datum/controller/subsystem/admin_verbs/proc/deassosciate_admin(client/admin)
    if(IsAdminAdvancedProcCall())
        return

    UnregisterSignal(admin, COMSIG_CLIENT_MOB_LOGIN)
    var/admin_ckey = admin.ckey
    for(var/datum/admin_verb/verb_type as anything in admin_verbs_by_type)
        var/datum/admin_verb/verb_singleton = admin_verbs_by_type[verb_type]
        verb_singleton.unassign_ckey(admin_ckey)
