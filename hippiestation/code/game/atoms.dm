/atom
    var/icon_hippie

/atom/proc/check_hippie_icon()
    if (!icon || !icon_state || !icon_hippie)
        return

    var/icon/I = new (icon_hippie)

    if (length(icon_hippie) <= 0)
        return

    if (!is_string_in_list(icon_state, icon_states(I)))
        return
    
    icon = icon_hippie

/atom/Initialize()
    check_hippie_icon()
    return ..()