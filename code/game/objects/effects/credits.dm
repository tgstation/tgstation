#define CREDIT_ROLL_SPEED 150
#define CREDIT_SPAWN_SPEED 30
#define CREDIT_ANIMATE_HEIGHT 16
#define CREDIT_EASE_DURATION 15
#define CREDITS_LOC locate(10, 166, ZLEVEL_CENTCOM)

/proc/RollCredits()
    var/icon/credits_file = new('icons/credits.dmi')
    var/list/contributors = icon_states(credits_file) - "___EMPTY_ICON_STATE___"
    qdel(credits_file)

    . = list()
    for(var/I in 1 to contributors.len)
        var/obj/effect/abstract/credit/C = new(CREDITS_LOC, contributors[I])
        addtimer(CALLBACK(C, /obj/effect/abstract/credit/proc/Animate), CREDIT_SPAWN_SPEED * (I - 1), TIMER_CLIENT_TIME)
        . += C

/proc/TestCredit(name)
    var/obj/effect/abstract/credit/C = new(get_turf(usr), name)
    C.alpha = 255

/obj/effect/abstract/credit
    icon = 'icons/credits.dmi'
    mouse_opacity = MOUSE_OPACITY_OPAQUE
    alpha = 0
    layer = FLY_LAYER
    maptext_x = TURF_PIXEL_DIAMETER + 2
    maptext_y = (TURF_PIXEL_DIAMETER / 2) - 4
    maptext_width = TURF_PIXEL_DIAMETER * 3

/obj/effect/abstract/credit/Initialize(mapload, credited)
    . = ..()
    name = "\improper [credited]"
    icon_state = credited
    maptext = credited

/obj/effect/abstract/credit/proc/Animate()
    animate(src, pixel_y = CREDIT_ANIMATE_HEIGHT * TURF_PIXEL_DIAMETER, time = CREDIT_ROLL_SPEED)
    animate(src, alpha = 255, time = CREDIT_EASE_DURATION)
    addtimer(CALLBACK(src, .proc/FadeOut), CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION, TIMER_CLIENT_TIME)
    QDEL_IN_CLIENT_TIME(src, CREDIT_ROLL_SPEED)

/obj/effect/abstract/credit/proc/FadeOut()
    animate(src, alpha = 0, time = CREDIT_EASE_DURATION)