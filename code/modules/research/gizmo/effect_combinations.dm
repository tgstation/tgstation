/// Handles a pool of effects, randomly picking one to execute upon activation
/datum/gizmo_effect_combination
    /// Our parent gizmo interface
    var/datum/gizmo_interface/interface
    /// Weighted list of effects this combination can roll
    var/list/possible_effects = list()
    /// Time between activations
    var/cooldown_time = 1 SECONDS
    COOLDOWN_DECLARE(cooldown_timer)

    /// Minimal amount of effects to trigger at the same time
    var/min_effects = 1
    /// Maximal amount of effects to trigger at the same time
    var/max_effects = 1

/// Triggers a random effect from the pool (or multiple, depending on min/max_effects)
/datum/gizmo_effect_combination/proc/activate(atom/movable/holder)
    if(!COOLDOWN_FINISHED(src, cooldown_timer))
        return

    var/cooldown_started = FALSE
    var/iterations = rand(min_effects, max_effects)

    for(var/i in 1 to iterations)
        var/chosen_effect_path = pick_weight(possible_effects)
        if(!chosen_effect_path)
            continue

        var/path_to_spawn = chosen_effect_path
        var/datum/gizmo_effect/effect = new path_to_spawn

        if(!cooldown_started && effect.affect_timer)
            COOLDOWN_START(src, cooldown_timer, cooldown_time)
            cooldown_started = TRUE

        effect.activate(holder, src, interface)

/// Spawn some items.
/datum/gizmo_effect_combination/dispense
    possible_effects = list(
        /datum/gizmo_effect/dispense = 1,
        /datum/gizmo_effect/dispense = 1,
        /datum/gizmo_effect/dispense = 1,
        /datum/gizmo_effect/dispense = 1,
        /datum/gizmo_effect/dispense = 1,
        /datum/gizmo_effect/dispense = 1,
    )
    min_effects = 4
    max_effects = 6

/// Shakes, dispences oil.
/datum/gizmo_effect_combination/sputter
    possible_effects = list(
        /datum/gizmo_effect/sputter = 1,
        /datum/gizmo_effect/throw_self = 1,
    )
    min_effects = 2
    cooldown_time = 5 SECONDS

/// A bunch of bad effects that can maim or kill you.
/datum/gizmo_effect_combination/dangerous
    cooldown_time = 5 SECONDS
    possible_effects = list(
        /datum/gizmo_effect/explode = 1,
        /datum/gizmo_effect/explode/fire = 1,
        /datum/gizmo_effect/dispense/robot_spider = 1,
        /datum/gizmo_effect/thrower = 1,
        /datum/gizmo_effect/thrower/grenade = 1,
        /datum/gizmo_effect/radiation_pulse = 1,
        /datum/gizmo_effect/bone_breaker = 1,
        /datum/gizmo_effect/ominous = 2,
    )
    min_effects = 1
    max_effects = 2

/// Scans and creates a copy of the nearest object. The copy serves no functionality.
/datum/gizmo_effect_combination/copier
    possible_effects = list(
        /datum/gizmo_effect/scan = 1,
        /datum/gizmo_effect/copy = 1,
        /datum/gizmo_effect/erase = 1,
    )
    /// Weakref of what is marked to copy
    var/datum/weakref/marked
    /// List of copies currently in circulation
    var/list/copies = list()
    /// The max amount of copies that can exist at a time
    var/max_copies = 50

/// Suck power and shoot it out again
/datum/gizmo_effect_combination/electric
    cooldown_time = 6 SECONDS
    possible_effects = list(
        /datum/gizmo_effect/electric/emp = 1,
        /datum/gizmo_effect/electric/discharge = 1,
        /datum/gizmo_effect/electric/charge = 1,
        /datum/gizmo_effect/electric/revive = 1,
        /datum/gizmo_effect/electric/draw = 1,
        /datum/gizmo_effect/electric/passive_charge = 1,
    )
    min_effects = 3
    max_effects = 4

    /// The internal power cell
    var/obj/item/stock_parts/power_store/battery/gizmo/power

/// Make the holder move by adding a movement element.
/datum/gizmo_effect_combination/mover
    possible_effects = list(
        /datum/gizmo_effect/start_moving = 1,
        /datum/gizmo_effect/stop_moving = 1,
    )

/// Start glowing
/datum/gizmo_effect_combination/lights
    possible_effects = list(
        /datum/gizmo_effect/lights_on = 1,
        /datum/gizmo_effect/lights_off = 1,
    )

/// Gives a voice hint or changes the voices language for use with a voice interface
/datum/gizmo_effect_combination/voice
    possible_effects = list(
        /datum/gizmo_effect/voice_hint = 1,
        /datum/gizmo_effect/language_change = 1,
    )

/// Send out mood pulses, good or bad
/datum/gizmo_effect_combination/mood_pulser
    possible_effects = list(
        /datum/gizmo_effect/mood_pulser/positive = 1,
        /datum/gizmo_effect/mood_pulser/negative = 1,
        /datum/gizmo_effect/radiation_pulse = 1,
    )
    min_effects = 0
    max_effects = 1

/// Gizmo mode that regenerates, cycles and expells reagents in different functions
/datum/gizmo_effect_combination/mopper
    possible_effects = list(
        /datum/gizmo_effect/wet_tiles/fluid_circle/small = 1,
        /datum/gizmo_effect/wet_tiles/fluid_circle/medium = 1,
        /datum/gizmo_effect/wet_tiles/fluid_circle/large = 1,
        /datum/gizmo_effect/fluid_smoke = 1,
        /datum/gizmo_effect/swap_reagent = 1,
    )
    min_effects = 3
    max_effects = 5

    /// Reagents that can be selected
    var/list/reagents = list(
        /datum/reagent/water,
        /datum/reagent/toxin/acid,
        /datum/reagent/consumable/salt,
        /datum/reagent/uranium/radium,
    )
    /// Reference to the reagent holder.
    var/datum/reagents/reagent_holder
    /// Reagent that is being generated right now
    var/active_reagent = /datum/reagent/water
    /// Max volume of the reagent holder we hand out
    var/max_volume = 50
    /// Amount of reagents we regenerate per second
    var/regeneration_speed = 2
    /// How many reagents we grab from get_random_reagent_id
    var/random_reagents_to_add = 1
    /// Flags to pass to the reagent holder
    var/reagent_flags = AMOUNT_VISIBLE

/// Teleports itself and/or others
/datum/gizmo_effect_combination/teleporter
    possible_effects = list(
        /datum/gizmo_effect/teleport/self = 1,
        /datum/gizmo_effect/teleport/other = 1,
        /datum/gizmo_effect/teleport/other/and_self = 1,
    )
    min_effects = 2
    max_effects = 3

/// Spawn fake goop food
/datum/gizmo_effect_combination/dispense/food
    possible_effects = list(
        /datum/gizmo_effect/dispense/food = 1,
    )
    min_effects = 1
    max_effects = 1
