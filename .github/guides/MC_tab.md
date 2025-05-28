The MC tab hold information on how the game is performing. Here's a crash course on what the most important of those numbers mean.

If you already know what these numbers mean and you want to see them update faster than the default refresh rate of once every 2 seconds, you can enable the admin pref to make the MC tab refresh every 4 deciseconds. Please don't do this unless you actually need that information at a faster refresh rate since updating every subsystems information is expensive.

# Main Entries:

- CPU: What percentage of a tick the game is using before starting the next tick. If this is above 100 it means we are over budget.

- TickCount: How many ticks should have elapsed since the start of the game if no ticks were ever delayed from starting.

- TickDrift: How many ticks since the game started that have been delayed. Essentially this is how many ticks the game is running behind. If this is increasing then the game is currently not able to keep up with demand.

- Internal Tick Usage: You might have heard of this referred to as "maptick". It's how much of the tick that an internal byond function called SendMaps() has taken recently. The higher this is the less time our code has to run. SendMaps() deals with sending players updates of their view of the game world so it has to run every tick but it's expensive so ideally this is optimized as much as possible. You can see a more detailed breakdown of the cost of SendMaps by looking at the profiler in the debug tab -> "Send Maps Profile".

# Master Controller Entry:

- TickRate: How many Byond ticks go between each master controller iteration. By default this is 1 meaning the MC runs once every byond tick. But certain configurations can increase this slightly.

- Iteration: How many times the MC has ran since starting.

- TickLimit: This SHOULD be what percentage of the tick the MC can use when it starts a run, however currently it just represents how much of the tick the MC can use by the time that SSstatpanels fires. Someone should fix that.

# Subsystem Entries:

Subsystems will typically have a base stat entry of the form:
[ ] Name 12ms|28%(2%)|3

The brackets hold a letter if the subsystem is in a state other than idle.

The first numbered entry is the cost of the subsystem, which is a running average of how many milliseconds the subsystem takes to complete a full run. This is increased every time the subsystem resumes an uncompleted run or starts a new run and decays when runs take less time. If this balloons to huge values then it means that the amount of work the subsystem needs to complete in a run is far greater than the amount of time it actually has to execute in whenever it is its turn to fire.

The second numbered entry is like cost, but in percentage of an ideal tick this subsystem takes to complete a run. They both represent the same data.

The third entry (2%) is how much time this subsystem spent executing beyond the time it was allocated by the MC. This is bad, it means that this subsystem doesn't yield when it's taking too much time and makes the job of the MC harder. The MC will attempt to account for this but it is better for all subsystems to be able to correctly yield when their turn is done.

The fourth entry represents how many times this subsystem fires before it completes a run.
