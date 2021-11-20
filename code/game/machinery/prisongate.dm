/obj/machinery/prisongate
    name = "prison gate scanner"
    desc = "A hardlight gate with an ID scanner attached to the side. Good at deterring even the most persistent temporalily embarrassed employee."
    icon = 'icons/obj/machines/implantchair.dmi'
    icon_state = "hypnochair"
    base_icon_state = "hypnochair"
    use_power = IDLE_POWER_USE
    power_channel = AREA_USAGE_EQUIP
    idle_power_usage = 5
    active_power_usage = 30
    anchored = TRUE
    var/gate_active = TRUE

/obj/machinery/prisongate/power_change()
    . = ..()
    if(!powered())
        turn_off()
    if(powered())
        turn_on()

/obj/machinery/prisongate/proc/turn_off()
    gate_active = FALSE

/obj/machinery/prisongate/proc/turn_on()
    gate_active = TRUE

/obj/machinery/prisongate/CanAllowThrough(atom/movable/gate_toucher, border_dir)
    . = ..()
    if(iscarbon(gate_toucher))
        var/mob/living/carbon/the_toucher = gate_toucher
        if(gate_active == FALSE)
            return TRUE
        for(var/obj/item/card/id/regular_id in the_toucher.get_all_contents())
            var/list/id_access = regular_id.GetAccess()
            if(ACCESS_BRIG in id_access)
                say("Brig clearance detected. Access granted.")
                return TRUE
        for(var/obj/item/card/id/advanced/prisoner/prison_id in the_toucher.get_all_contents())
            if(prison_id.timed)
                if(prison_id.time_to_assign)
                    say("Prison ID with active sentence detected. Please enjoy your stay in our corporate rehabilitation center, [prison_id.registered_name]!")
                    prison_id.time_left = prison_id.time_to_assign
                    prison_id.time_to_assign = initial(prison_id.time_to_assign)
                    prison_id.start_timer()
                    return TRUE
                if(prison_id.time_left <= 0)
                    say("Prison ID with served sentence detected. Access granted.")
                    prison_id.timed = FALSE //effectively turns it back into a generic prison ID so you can't throw it back in for easy mass escapes
                    return TRUE
                else
                    say("Prison ID with ongoing sentence detected. Access denied.")
                    return FALSE

        to_chat(the_toucher, span_warning("You try to push through the hardlight barrier with little effect."))
        return FALSE
    return FALSE
            

        