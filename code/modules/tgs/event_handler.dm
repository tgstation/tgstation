/datum/tgs_event_handler/tg/HandleEvent(event_code, ...)
    switch(event_code)
        if(TGS_EVENT_COMPILE_COMPLETE)
            GLOB.bypass_tgs_reboot = FALSE
