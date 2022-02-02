# Progression Traitor Balance Guide

This guide will explain how the values for progression traitor works, how to balance progression traitors and what you should NOT do when balancing.
This guide will only explain progression values.

## Definitions

- Progression points OR Progression - A currency that controls what uplink items a player can purchase and what objectives they have accessible to them. Gained passively or by completing objectives and has diminishing returns as it strays from the expected progression
- Expected Progression - A global value that increments by a value of 1 minute every minute, representing the 'time' that a player should be at if they had not completed any objectives.
- Objectives - An activity or job that a player can take for rewards such as TC and progression points.
- Player - The user(s) that are playing as the antagonist in this new system.
- Expected deviance - The amount of deviance that can be expected from the minimum and maximum progressions. Usually calculated by `progression_scaling_deviance` + `progression_scaling_deviance` * `global_progression_deviance_required` (explained further down)

## How it works

This section will explain how the entire balance system works. This is an overview of the entire system.

### Progression

Progression points is passively given to a player, and are represented as minutes (or time values) in code. The round has its own 'expected progression', which is the progression value that you'd normally have if you hadn't completed any objectives whatsoever. This is the baseline progression that all players will be at unless they're a latejoiner, and it acts as the basis for determining how much progression points a player should get over time and the cost of objectives for a specific player, if they deviate too much from this value. The idea is that they will slowly drift back towards the expected progression if they do nothing and it becomes harder for them to progress as they deviate further from the expected progression. The amount that is passively given can also vary depending on how many players there are, so that at lower populations, expected progression rises more slowly.

### Objectives

Objectives are worth a certain amount of progression points, determined by the code. However, this can be scaled to be less if the player taking them is ahead of the expected progression. This scales exponentially, so that as a player deviates further from the expected progression, the reward diminishes exponentially, up to a reduced value of 90%. The similar thing happens in the opposite direction, with people who are lower than the expected progression getting more progression than usual for completing objectives.

## How to balance

### The traitor subsystem
- `newjoin_progression_coeff` - The coefficient multiplied by the expected progression for new joining traitors to calculate their starting progression, so that they don't start from scratch
- `progression_scaling_deviance` - The value that the entire system revolves around. This determines how much you deviate by compared to your value against the expected progression. Having a deviance of 20 minutes means that you won't get any progression at all, and if objectives were configured to suit this, you'd have the highest reduction you can possibly get. From no deviance to this value, it scales linearly
- `current_progression_scaling` - Defined at compile time, this determines how fast expected progression scales. So if you have it set to 0.5 MINUTES, it'll take twice as long to unlock uplink items and new objectives.
- `CONFIG:TRAITOR_IDEAL_PLAYER_COUNT` - The ideal player count before expected progression stops increasing. If the living player list gets below this value, the current progression scaling will be multiplied by player_count/traitor_ideal_player_count. In essence, this makes it so that progression scales more slowly when there isn't a lot of people alive.

If you want to balance how fast the system progresses, you should look at modifying `current_progression_scaling`. If you want to balance how far someone should be allowed to deviate, you should look at modifying `progression-scaling-deviance`

### Objectives
- `progression_minimum` - The minimum number of progression points required before this objective can show up as a potential objective
- `progression_maximum` - The maximum number of progression points before this objective stops showing up as a potential objective, used to prevent roundstart objectives from showing up during the late game.
- `progression_reward` - The progression reward you get from completing an objective. This is the base value, and can also be a two element list of numbers if you want it to be random. This value is then scaled depending on whether a player is ahead or behind the expected progression
- `global_progression_influence_intensity` - Determines how influential expected progression will affect the progression reward of this objective. Set to 0 to disable.
- `global_progression_deviance_required` - Determines how much deviance is required before the scaling kicks in, to give objectives more leeway so that at the `progression_scaling_deviance`, it doesn't scale to 90% immediately.
- `progression_cost_coeff_deviance` - This determines the randomness of the progression reward, to prevent all of the scaling from looking the same. Becomes a lot less significant as the scaling variable gets closer to 1.

If you want to balance the expected timeframe an objective should be available, you should look at changing the `progression_minimum` or `progression_maximum`. If you want to balance how much objectives reward, you may want to look at modifying `progression_reward`. If you want to look at balancing the cost of an objective depending on the expected progression, you may want to look at `global_progression_influence_intensity`. If you want to look at decreasing or increasing the deviance allowed before objectives become worthless progression-wise, you may want to look at modifying `global_progression_deviance_required`

### Uplink Items
- `progression_minimum` - The minimum number of progression points required to purchase this uplink item.

## What NOT to do when balancing

### Overcompensate

You do not want to overcompensate variables such as `progression_minimum` and `progression_maximum`. Such values need to be an accurate representation of roughly around the time a player should unlock the objective or uplink item. progression_scaling_deviance is supposed to represents the limit that a casual player can be at before it becomes significantly harder for them to progress throughout. You should expect people to be within `progression_scaling_deviance` + `progression_scaling_deviance` * `global_progression_deviance_required`. (Assuming `progression_scaling_deviance` is 20 minutes and `progression_scaling_deviance_required` is 0.5, 20 + 0.5 * 20 = 30; this gives us a value of 30 minutes). This is the expected deviance.

### Reward large amounts of progression points

Progression points are passively gained, so rewarding large amounts of progression points will let people bypass the scaling as they'll immediately jump to an absurd value. A good rule of thumb is to always keep the reward within or below the expected deviance.

