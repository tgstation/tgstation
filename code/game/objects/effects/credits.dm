#define CREDIT_ROLL_SPEED 150
#define CREDIT_SPAWN_SPEED 30
#define CREDIT_ANIMATE_HEIGHT 16
#define CREDIT_EASE_DURATION 15
#define CREDITS_LOC locate(10, 166, ZLEVEL_CENTCOM)

/proc/RollCredits()
    set waitfor = FALSE
    var/icon/credits_file = new('icons/credits.dmi')
    var/list/contributors = icon_states(credits_file) - "___EMPTY_ICON_STATE___"
    qdel(credits_file)

    for(var/I in contributors)
        sleep(CREDIT_ROLL_SPEED)
        new /obj/effect/abstract/credit(CREDITS_LOC, I)

INITIALIZE_IMMEDIATE(/obj/effect/abstract/credit)

/obj/effect/abstract/credit
    icon = 'icons/credits.dmi'
    mouse_opacity = MOUSE_OPACITY_OPAQUE
    alpha = 0

/obj/effect/abstract/credit/Initialize(mapload, credited)
    . = ..()
    name = "\improper [credited]"
    icon_state = credited
    maptext = credited
    animate(src, pixel_y = CREDIT_ANIMATE_HEIGHT * TURF_PIXEL_DIAMETER, time = CREDIT_ROLL_SPEED)
    animate(src, alpha = 255, time = CREDIT_EASE_DURATION)
    addtimer(CALLBACK(src, .proc/FadeOut), CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION, TIMER_CLIENT_TIME)
    addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, src), CREDIT_ROLL_SPEED, TIMER_CLIENT_TIME)

/obj/effect/abstract/credit/proc/FadeOut()
    animate(src, alpha = 0, time = CREDIT_EASE_DURATION)