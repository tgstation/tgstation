
GLOBAL_LIST_EMPTY(mentors) //all clients whom are admins
GLOBAL_PROTECT(mentors)

/client/New()
    . = ..()
    mentor_datum_set()

/client/proc/is_mentor() // admins are mentors too.
    if(mentor_datum || check_rights_for(src, R_ADMIN))
        return TRUE

/client/proc/hippie_client_procs(href_list)
    if(href_list["mentor_msg"])
        if(CONFIG_GET(flag/mentors_mobname_only))
            var/mob/M = locate(href_list["mentor_msg"])
            cmd_mentor_pm(M,null)
        else
            cmd_mentor_pm(href_list["mentor_msg"],null)
        return TRUE


/client/proc/mentor_datum_set(admin)
    mentor_datum = GLOB.mentor_datums[ckey]
    if(!mentor_datum && check_rights_for(src, R_ADMIN)) // admin with no mentor datum?let's fix that
        new /datum/mentors(ckey)
    if(mentor_datum)
        if(!check_rights_for(src, R_ADMIN) && !admin)
            GLOB.mentors |= src // don't add admins to this list too.
        mentor_datum.owner = src
        add_mentor_verbs()

/proc/log_mentor(text)
    GLOB.mentorlog.Add(text)
    WRITE_LOG(GLOB.world_game_log, "MENTOR: [text]")
