/**
 * This is the only macro you should use to define admin verbs.
 * It will define the verb and the verb holder for you.
 * Using it is very simple:
 *  ADMIN_VERB(verb_path, R_PERM, "Name", "Description", "Admin.Category", args...)
 * This sets up all of the above and also acts as syntatic sugar as a verb delcaration for the verb itself.
 * Note that the verb args have an injected `client/user` argument that is the user that called the verb.
 * Do not use usr in your verb; technically you can but I'll kill you.
 */
#define ADMIN_VERB(verb_path_name, verb_permissions, verb_name, verb_desc, verb_category, verb_args...) \
/datum/admin_verb/##verb_path_name \
{ \
    name = ##verb_name; \
    description = ##verb_desc; \
    category = ##verb_category; \
    permissions = ##verb_permissions; \
    verb_holder = /mob/admin_verb_holder/##verb_path_name; \
}; \
/mob/admin_verb_holder/##verb_path_name/verb/do_verb(##verb_args) \
{ \
    set name = ##verb_name; \
    set desc = ##verb_desc; \
    set category = ##verb_category; \
    set src in group; \
    if(IsAdminAdvancedProcCall()) { \
        message_admins("[key_name_admin(usr)] attempted to elevate permissions and call [type] directly."); \
        return; \
    }; \
    if(!usr.client?.holder?.check_for_rights(##verb_permissions)) { \
        to_chat(usr, span_adminnotice("You do not have permission to use this verb.")); \
        return; \
    }; \
    parent_admin_verb:handle_do_verb(usr.client, args); \
}; \
/datum/admin_verb/##verb_path_name/proc/handle_do_verb(client/user, ##verb_args)
