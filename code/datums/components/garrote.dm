
#define STANDARD_MULT 1
#define NO_DAMAGE 0

/datum/component/garrote

    var/obj/item/weapon
    var/mob/living/target
    var/grab_speed_mult = STANDARD_MULT
    var/damage = NO_DAMAGE

/datum/component/garrote/Initialize(mob/living/targ, obj/item/wpn, _grab_speed_mult, _damage)

    if(!isliving(parent) || !iscarbon(targ))
        return COMPONENT_INCOMPATIBLE
    
    var/mob/living/attacker = parent
    if(_grab_speed_mult)
        grab_speed_mult = _grab_speed_mult
    if(_damage)
        damage = _damage
    target = targ
    weapon = wpn

    if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
        to_chat(attacker, "<span class='warning'>You couldn't bring yourself to strangle someone...</span>")
        return

    if(!targ.density && !iscarbon(targ))
        return
    if((targ.dir == attacker.dir) && (attacker.grab_state < GRAB_AGGRESSIVE))

        targ.losebreath += (2 + damage * 0.5)
        targ.apply_damage(damage, BRUTE, BODY_ZONE_HEAD)
        targ.drop_all_held_items()
        targ.stop_pulling()

        attacker.start_pulling(targ, supress_message = TRUE)
        attacker.setGrabState(GRAB_AGGRESSIVE)

        log_combat(attacker, targ, "grabbed", addition="aggressively")

        attacker.visible_message("<span class= 'danger'> [attacker] wraps the [wpn] around [targ]'s neck restraining them!", \
        "<span class= 'danger'>You wrap the [wpn] around [targ]'s neck from behind them! </span>", ignored_mobs = targ)

        to_chat(targ, "<span class='userdanger'>[attacker] restrains you by wraping the [wpn] around your neck from behind!</span>")

        targ.dir = attacker.dir //keep them facing away from us
        return

    if(targ.pulledby == attacker) //tighten out grip if we are already grabing them
        targ.grabbedby(attacker, FALSE, grab_speed_mult)
        return
        
#undef STANDARD_MULT
#undef NO_DAMAGE