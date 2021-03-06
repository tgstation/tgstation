# Atmospherics
## 1. Preamble

This file will be written in the first person in the interest of having a laid back style, as some of the concepts here would be ass to read as technical writing. Understand that this isn't the work of one person, but the combined efforts of several contributors. It is a living document, and one you should strive to keep up to date.

I have ~~stolen~~ adapted this document from the work of duncathan, an off and on maintainer who is responsible for the majority of the quality of the current atmos system. He pushed through several code cleanliness and sanity refactors to the system, and wrote the rundown of gas mixtures you'll find in this document. See the [original](https://gist.github.com/duncathan/77d918748d153b4f31a8f76f6085b91a) for his draft.

Now, the purpose of this bit of documentation.

Over the history of /tg/ there have been several periods where one or no active coders understood how atmospherics works, or even how it was intended to work. We've lost several major pieces of functionality, not because none knew how they worked, but because none knew that they should work, or even that they existed.

Atmospherics tends to be a somewhat cloudy corner of our codebase, unless you know exactly what to look for noticing that something is broken can be a feat in and of itself.

My goal here is to solve that problem once and for all. Not everything will be documented in this file, I won't go line by line. I will however describe how things ought to work, and how some of the more complex stuff is meant to run.

Atmospherics is a very complicated and intimidating system of SS13, and as such very few contributors have ever made changes to it. Even fewer is the number of contributors who have made changes to the more fundamental aspects of atmos, such as Environmental Atmos or gas mixtures. There are several other factors for this, of course. In the case of Environmental, its arcane nature coupled with its extremely important gameplay effects leave it a very undesirable target for even the least sane coder. As for gas mixtures, they were virtually untouchable without extensive reworks of the code. This [paste-bin](https://pastebin.com/bwy4KpBE) is a good example; it lists all the files one would need to make changes in order to add a new type of gas in the old system. As you can imagine, the sheer bulk of work one would need to do to accomplish this essentially invalidated any such attempts. However, my primary goal is to bring atmos to a state where any coder will be able to understand how and why it works, as well as cleanly and relatively easily make changes or additions to the system. While much progress to this end has been achieved, still very few have taken advantage of the new frameworks to try to implement meaningful features or changes. The purpose of this document is to lay out the inner workings of the entire atmos system, such that someone who does not have an intimate understand of the system like myself will be able to contribute to the system nonetheless.

Recognizing this desire, I hope and believe that you who are reading this are willing to learn and contribute.

Thank you.

## 2. Introduction to Atmos

Hello! So glad you could join us.

Atmospherics is the system we use to simulate gases. Might as well get that out of the way. It is made up of several major parts, and a few more minor ones. We'll be covering the air subsystem, gas mixtures, reactions, environmental flow, and pipenets in the document.

If you'd like to understand more about how environmental atmos works after reading the relevant subsection, go to Appendix B. It discusses how to properly visualize the system, and what different behavior looks like.

Now then, into the breach.

## 3. The Air Controller

![Cyclical graph of one atmos tick](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/Cycle.png)

*Figure 3.1: The structure of one air controller tick. Not totally accurate, but it will do*

 The air controller is, at its core, quite simple, yet it is absolutely fundamental to the atmospheric system. The air controller is the clock which triggers all continuous actions within the atmos system, such as vents distributing air or gas moving between tiles. The actions taken by the air controller are quite simple, and will be enumerated here. Much of the substance of the air ticker is due to the game's master controller, whose intricacies I will not delve into for this document. I will however go into more detail about how SSAir in particular works in Chapter 6. In any case, this is a simplified list of the air controller's actions in a single tick:
1. Rebuild Pipenets
    - Runs each time SSAir processes, sometimes out of order. It ensures that no pipenets sit unresolved or unbuilt
    - Calls `build_network()` on each `/obj/machinery/atmospherics` in the `pipenets_needing_rebuilt` list
2. Pipenets
    - Updates the internal gasmixes of attached pipe machinery, and reacts the gases in a pipeline
	- Calls `process()` on each `/datum/pipenet` in the `networks` list
3. Machinery
	- Handles machines that effect atmospherics, think vents, the supermatter, pumps, all that
    - Calls `process_atmos()` on each `/obj/machinery` (typically `/obj/machinery/atmospherics`) in the `atmos_machinery` list
    - May remove the machinery from said list if `process_atmos()` returns `PROCESS_KILL`
4. Active turfs
    - This is the heart and soul of environmental atmos, see more details below
    - All you need to know right now is it manages moving gas from tile to tile
    - Calls `process_cell()` on each `/turf/open` in the `active_turfs` list
5. Excited groups
    - Manages excited groups, which are core to working flow simulation
    - More details to come, they handle differences between gasmixtures when active turfs can't do the job
    - Increases the `breakdown_cooldown` and `dismantle_cooldown` for each `/datum/excited_group` in the `excited_groups` list
    - If either cooldown for a given excited group has passed its threshold
    - Calls `self_breakdown()` or `dismantle()` appropriately on the excited group.
6. High pressure deltas
    - Takes the gas movement from Active Turfs and uses it to move objects on said turfs
    - Calls `high_pressure_movements()` on each `/turf/open` in the `high_pressure_delta` list.
    - Sets each turf's `pressure_difference` to 0
7. Hotspots
    - These are what you might know as fire, at least the effect of it.
    - They deal with burning things, and color calculations, lots of color calculations
    - Calls `process()` on each `/obj/effect/hotspot` in the `hotspots` list
8. Superconductivity
    - Moves heat through turfs that don't allow gas to pass
    - Deals with heating up the floor below windows, and some other more painful heat stuff
    - Calls `super_conduct()` on each `/turf` in the `active_super_conductivity` list
9. Atoms
    - Processes things in the world that should know about gas changes, used to account for turfs sleeping, I'll get more into that in a bit
    - Calls `process_exposure()` on each `/atom` in the `atom_process` list

## 4. Gas Mixtures
If the air controller is the heart of atmos, then gas mixtures make up its blood. The bulk of all atmos calculations are performed within a given gas mixture datum (an instance of `/datum/gas_mixture`), be it within a turf or within an emergency oxygen tank or within a pipe. In particular, `/datum/gas_mixture/proc/share()` is the cornerstone of atmos simulation, as it and its stack perform all the calculations for equalizing two gas mixtures.

Gas mixtures contain some of the oldest code still in our codebase, and it is remarkable that overall, the logic behind the majority of gas mixture procs has gone unchanged since the days of Exadv1. Despite being in some sense "oldcode", the logic itself is quite robust and based in real world physics. Thankfully, gas mixtures already are quite well documented in terms of their behavior. Their file is well commented and kept up to date. I will, however, elaborate on some of the less obvious operations here. Additionally, I will document the structure of gas lists, and how one should interface with a gas mixture should you choose to use one in other code.

Now don't be scared by the code mind, it's SPOOKY PHYSICS but it's not the devil, we can break it down into component parts to understand it.

```DM
//transfer of thermal energy (via changed heat capacity) between self and sharer
		if(new_self_heat_capacity > MINIMUM_HEAT_CAPACITY)
			temperature = (old_self_heat_capacity*temperature - heat_capacity_self_to_sharer*temperature_archived + heat_capacity_sharer_to_self*sharer.temperature_archived)/new_self_heat_capacity
```
*Snippet 4.1: excerpt from `/datum/gas_mixture/proc/share()`*

The snippet above is an example of one particularly strange looking calculation. This part of share() is updating the temperature of a gas mixture to account for lost or gained thermal energy as gas moves to/from the mixture, since gases themselves carry heat. To understand this snippet, it is important to understand the difference between heat and temperature. For the most part, the average coder need only concern himself with temperature, as it is a familiar experience for anybody. However, internally in atmos, heat (thermal energy) is the truly important quantity. Heat is defined as temperature multiplied by heat capacity, and is measured in joules. Typically within atmos, we are more concerned with manipulating heat than temperature; however, temperature is tracked rather than heat largely to make interfacing with the system simpler for the average coder. Thus, this snippet modifies heat in terms of temperature - it adds/subtracts three terms, each of which measure heat, to determine the new heat in the gas mixture. This heat is then divided by the mixture's heat capacity in order to determine temperature.

One trick to understanding passages like this is to do some simple dimensional analysis. Look only at the units, and ensure that whenever a variable is assigned that it is being assigned the appropriate unit. The snippet previously discussed can be represented with the following units: `temperature = ((J/K)*K - (J/K)*K + (J/K)*K)/(J/K)`. Simplified, you get `(J-J+J)*K/J` and then simply `J*K/J` and `K`, verifying that temperature is being set to a value in kelvins. This trick has proven invaluable to me when debugging the inner workings of gas mixtures.

### Gases

The true beauty of the gas mixture datum is how it represents the gases it contains. A bit of history: gas mixtures used to represent gas in two ways - there were the four primary gases (oxygen, nitrogen, carbon dioxide, and plasma) which were hardcoded. Each gas mixture had two vars (moles and archived moles, a concept to be explained later) to represent each of these gases. Calculations such as thermal energy made use of predefined constants for these hardcoded gases. The benefit of this was that they were extremely quick - only a single datum var access was needed for each one. In contrast, there were trace gases, for which there were a list of gas datums. The only trace gas available in normal gameplay was nitrous oxide (N2O or sleeping agent), though through adminnery it was possible to create oxygen agent B and volatile fuel, curious gases which will be described later for historical reasons. Trace gases, in contrast to hardcoded gases, were quite modular. To add a new trace gas one needed only to define a new subtype of /datum/gas and add appropriate behavior wherever desired, such as breath code. Unfortunately, of course, trace gases were slooooow. Calculations on trace gases were significantly more costly than hardcoded gases. The problem was obvious - it seemed impossible to have a gas definition which shared the modularity of trace gases without sacrificing too much of the performance of the hardcoded gases.

What then to do? There was no option to port an improvement from another codebase. As far as I am aware, there have been no significant downstream improvements to gas mixtures. The other major upstream codebase, Baystation12, uses a very different atmos system; in particular, their XGM gas mixtures have their own solution to this problem. To summarize XGM, there is a singleton which has associative lists of gas metadata (information such as specific heat, or which overlay to display when the gas is present) which gets accessed whenever such information is needed. To count moles, each gas mixture has an associative list of gas ids mapped to mole counts. There were a couple of problems with this approach: 1. There was no measure of archived moles. While it would be easy to simply add a second associative list, this has non-trivial memory implications as well as a potential increase to total datum var accesses within internal atmos calculations. 2. The singleton used for storing metadata helps with the memory impact that using full datums would have, but does not properly address the cost of datum var accesses, as to access metadata you must still access a datum var on the singleton.

For some time, without a clear solution, we simply stuck to the status quo and left gases non-modular. Eventually, however, there was an idea.

Enter Listmos.

### The Gas List
The solution we came to was beautifully simple, but founded on some unintuitive principles. While datum var accesses are quite slow, proc var accesses are acceptable. If we use a reference for a given var, this can be exploited by "caching" the reference inside of a proc var. How can we take advantage of this without using a datum, thus nullifying the benefit?

The answer was to use a list. The critical realization was that a gas datum functioned more so as a struct than as a class. There were no procs attached to gas datums; only vars. While DM lacks a true struct with quick lookup times, a list works very well to perform the same function. Thus, the current structure of gas was created, under the name Listmos.

Each gas mixture has an associative list, gases, which maps according to a key to a particular gas. This gas is itself a list (not an associative list, mind) with three elements; these elements correspond to the moles, archived moles, and to another list. This final list is a singleton - only one instance of it exists per gas, and all gas instances of a particular type point to this same list as their third element. The final list contains the metadata for the gas, such as specific heat or the name of the gas. The structure of the metadata list varies according to how many attributes are defined overall for all gases, but it is also non-associative since the structure can never change post-compile, so we save a little bit of performance by avoiding associative lookups.

Each type of gas is defined by defining a new subtype of /datum/gas. These datums do not get instantiated; they merely serve as a convenient and familiar means for a coder unfamiliar with the inner workings of listmos to define a new gas. Additionally, the type paths serve a second use as the keys used to access a particular gas within the gases list. It is easiest to demonstrate the manipulation of gas, including these list accesses, with an example.

### Interfacing with a Gas Mixture

```DM
var/datum/gas_mixture/air = new
air.assert_gas(/datum/gas/oxygen)
air.gases[/datum/gas/oxygen][MOLES] = 100
world << air.gases[/datum/gas/oxygen][GAS_META][META_GAS_NAME] //outputs "Oxygen"
world << air.gases.heat_capacity() //outputs 2000 (100 mol * 20 J/K/mol)
air.gases[/datum/gas/oxygen][MOLES] -= 110
air.garbage_collect() //oxygen is now removed from the gases list, since it was empty
```
*Snippet 4.2: gas mixture usage examples*

Of particular note in this snippet are the two procs assert_gas() and garbage_collect(). These procs are very important while interfacing with gas mixtures. If you are uncertain about whether a given mixture has a particular gas, you must use assert_gas() before any reads or writes from the gas. If you fail to use assert_gas() then there will be runtime errors when you try to access the inner lists. When you remove any number of moles from a given gas, be sure to call garbage_collect(). This proc removes all gases which have mole counts less than or equal to 0. This is a memory and performance enhancement for list accesses achieved by reducing the size of the list, and also saves us from having to do sanity checks for negative moles whenever gas is removed. As a quick reference, here is a list of common procs/vars/list indices which the average coder may wish to use when interfacing with a gas mixture.

##### Gas Mixture Datum
* *`/datum/gas_mixture/proc/assert_gas()`* - Used before accessing a particular type of gas.
* *`/datum/gas_mixture/proc/assert_gases()`* - Shorthand for calling assert_gas() multiple times.
* *`/datum/gas_mixture/proc/garbage_collect()`* - Used after removing any number of moles from a mixture.
* *`/datum/gas_mixture/proc/return_pressure()`* - Pressure is what should be displayed to players to quantify gas; measured in kilopascals.
* *`/datum/gas_mixture/var/temperature`* - Measured in kelvins. Useful constants are T0C and T20C for 0 and 20 degrees Celsius respectively, and TCMB,the temperature of space and the lower bound for temperature in atmos.
* *`/datum/gas_mixture/var/volume`* - Measured in liters.

While we're on the subject, `/datum/gas_mixture` has two subtypes.
The first is `/datum/gas_mixture/turf`, which exists for literally one purpose. When a turf is empty, we want it to have the same heat capacity as space. This lets us achieve that by overriding `heat_capacity()`

The second is `/datum/gas_mixture/immutable`, which itself has two subtypes.
The type is built to allow for gasmixtures that serve as infinite sources of "something", which can't be changed or mutated.
It's used by `/datum/gas_mixture/immutable/space`, which implements some particular things for `heat_capacity()` and some optimizations for gas operations.
It's also implemented by `/datum/gas_mixture/immutable/planetary`, which is used for planetary turfs, and has some code that makes actually having a gasmix possible.


##### Gas List
* *`gases[path][MOLES]`* - Quantity of a particular gas within a mixture.
* *`gases[path][GAS_META][META_GAS_NAME]`* - The long name of a gas, ex. "Oxygen" or "Hyper-noblium"
* *`gases[path][GAS_META][META_GAS_ID]`* - The internal ID of a given gas, ex. "o2" or "nob"

### Reactions
While defining a new gas on its own is very simple, there is no gas-specific behavior defined within /datum/gas. This behavior gets defined in a few places, notably breath code (to be discussed later) and in reactions. The most important and well known reaction in SS13 is fire - the combustion of plasma. Reactions are used for several things - in particular, it is conventional (though by no means enforced) that to form a gas, a reaction must occur. Creating a new reaction is fairly simple, this is the area of atmos that has received the most attention over the last few years, and the best place to start. Don't be scared of the size of reactions.dm, it's not that complex.

There are two procs needed when defining a new reaction, /datum/gas_reaction/proc/init_reqs() and /datum/gas_reaction/proc/react(). init_reqs() initializes the requirements for the reaction to occur. There is a list, min_requirements, which maps gas paths to required amount of moles. It also maps three specific strings ("TEMP", "MAX_TEMP" and "ENER") to temperature in kelvins and thermal energy in joules. More behavior could easily be added here, but it hasn't yet for performance reasons because no reactions have need of it.

As for react(), it is where all the behavior of the reaction is defined. The proc must return one of NO_REACTION, REACTING, or STOP_REACTIONS. The proc takes one or optionally two arguments. The first, mandatory, argument is a gas mixture on which to perform calculations; this mixture is what is reacting. The second, optional, argument is a turf or pipenet, specifically the thing which contains the gas mixture. You may choose for the reaction to affect the object in some way. Note that it is conventional for constants within reactions to be #define'd at the top of the file and #undef'd at the end.

## 5. Environmental Atmos

This is a rather large subject, we will need to cover gas flow, turf sleeping, superconduction, and much more. Strap in and enjoy the ride!

### Active Turfs
![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/FlowVisuals.png)

*Figure 5.1: A visual of the algorithm `process_cell()` implements, ignoring our optimizations*

Active turfs are the backbone of how gas moves from tile to tile. While most of `process_cell()` should be easy enough to understand, I am going to go into some detail about archiving, since I think it's a common source of hiccups.

* *`archived_cycle`* this var stores the last cycle of the atmos loop that the turf processed on. The key point to notice here is that when processing a turf, we don't share with all its neighbors, we only talk to those who haven't processed yet. This is because the remainder of `process_cell()` and especially `share()` ought to be similar in form to addition. We can add in any order we like, and we only need to add once. This is what archived gases are for by the way, they store the state of the relevant tile before any processing occurs. This additive behavior isn't strictly the case unfortunately, but it's minor enough that we can ignore the effects.

Alright then, with that out of the way, what is an active turf.

This is actually the main success of LINDA, the math for gas movement is r4407 goon code or older, but that implementation (FEA) had a glaring issue. All turfs processed, or rather, all `/simulated` turfs processed. There was a separate type for `/unsimulated` turfs, but that was mostly used for things like centcom or space. Aside from that all the turfs that could in theory have gas on them needed to process each tick. `process_cell()` didn't quite look how it does now mind, but this was still a horrible state of affairs.

The major difference between then and now is our turfs will stop processing. They sit idle most of the round, wake up when something changes around them, process until no major changes are happening, and then go to sleep.

Active turfs also poke all the listening objects sitting on them, and start to process them so they can react to heat or gas changes. We do this so objects don't need to process when nothing has changed, but they also can operate through a turf sleeping. In essence this is like waking up things that ought to be listening to us.

If we just used active turfs sleeping would be easy as pie, we could do it turf by turf. But we don't.

### Excited Groups

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/Unsettled.png)
![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/Settled.png)

*Figure 5.2.1-5.2.2: Settled VS Unsettled gases, this is what excited groups do*

I didn't mention this above, but active turf processing, or really `share()`, has a fatal flaw. The amount of gas moved per tick goes down exponentially the further away a turf is from the source of changes, or diffs.

With only active turfs breaches would never settle, and as soon as a tile becomes active it would never rest again. (This is one of the reasons I wrote this document by the way, excited groups nearly totally broke around about 2016, and none at the time noticed because the code was so twisted none knew how it ought to work, so it persisted for 4 years past that)

So active turfs are bad at evening out diffs. What can we do to solve this?

Enter the excited group. We hold a list of all the turfs that have talked to each other, then we keep track of how active those turfs are. When they start to wind down, we spread all the gas out evenly between them, and the group starts to spread again. They tend to fill the space given to them, so be careful with open plan stations.

This is `self_breakdown()`, our equalization step. It cuts down on churn, and keeps things flowing smoothly.

I've been talking kinda abstractly about turfs sleeping. That's because turfs on their own don't stop waiting to process once they have an excited group. Groups have secondary roles as the grim reaper of active turfs. When a group is totally inactive, and nothing whatsoever is going on, it will `dismantle()`, putting all of the turfs inside it to sleep, and killing itself.

### A brief romp to talk about excited groups and LAST_SHARE_CHECK

Excited groups can tell the amount of diff being shared by hooking into a value `share()` sets on gasmixes, the absolute amount of gas shared by each tile. The issue is this isn't pressure, it's molar count. So heat being shared in a sealed room causes excited groups to break down, then reform from sources. This isn't a major issue due to how breakdown evens things out, but it's worth knowing.

### Back to the main thread

Now this would all be fine, but as I'm sure you've noticed, there's a crouching pile of lag hiding here. What happens if the excited group has turfs with a fire on them over in cargo, but the flow of gas started in medical? There's no point processing the majority of the tiles, but we still want to keep the group alive for equalization.

### Turfs can have a little nap

Originally LINDA only had the above 2 constructions, but we ran into a problem when making planetary turfs. The old implementation was mutable, but shared with a copy of its initial mix each tick. This lead to problems. In essence, the groups never stopped spreading so long as a source of diffs existed. This is because the job of excited groups is to move the diffs from the source, to the edges of the group. But we put these mixes on huge open planets. Doesn't really work out so well.

To combat this, a timer was added to each turf. It reset when a significant share was made, but otherwise if enough time passed the turf was forcibly removed from the active_turfs list. Unfortunately for us, this had unintended side effects.

When a turf is removed from active, the excited group is broken down, as it's assumed that the proc will only be called when the landscape of the map itself has changed. You begin to see the issue. With large enough space, excited groups broke, totally. Constant rebuilds into dismantles, cycling forever.

Now this issue here is we'd like to keep this napping, but we don't want to `garbage_collect()` the excited group constantly.

So, a new proc was added, `sleep_active_turf()`. It removes the active turf from processing, but doesn't `garbage_collect()` the group.

You'd think this would cause issues with maintaining the shape of an excited group, however this isn't actually a priority, since `garbage_collect()` and the subsequent rebuild in `process_cell()` causes turfs that are actually active to reform, just as it always has. This has benefits, as it lessens the tendency of one group to cover a huge space, equalize all at once, and fuck with things.

There's another issue here however, how do we deal with things that react to heat? A firelock shouldn't just open because the turf that the alarm is on went to sleep. Thus, atom_process, as I mentioned before, a list of atoms with requirements and things to do. It processes them until their requirements are not met, then it removes them from its list them.

There's one more major aspect of environmental atmos to cover, and while it's not the most misunderstood, it is the code with the worst set dressing.

### Superconduction, or why var names really matter

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/Superconduction.png)

*Figure 5.3: The death of a pug, and a visual description of what superconduction does*

Superconduction, an odd name really, it doesn't really describe much of anything aside from something to do with heat. It gets worse, trust me.

Superconduction is the system that makes heat move through solid objects, so in theory walls, windows, airlocks, so on. This is another one that just broke one day, and none noticed cause none knew what it was meant to do.

There's another issue with it, the var names don't mean what you think, and it is very old code, so it's hard to grasp. You can do it, you've made it this far.

So then, what does superconduction do, and what do all these damn vars mean.

### What does superconduction do?

As I mentioned above, superconduction shares heat where heat can't normally travel. It does this by heating up the turf the heat is in, not the gasmix, the turf itself. This temperature is then shared with adjacent turfs, based on `thermal_conductivity`, a value between 0 and 1 that slows the heat share. Turfs also have a `heat_capacity`, which is how hard it is to heat, along with providing a threshold for the lowest temperature that can melt the turf.

There's one more, and it's a doozy. `atmos_superconductivity` is a set of directions that we cannot share with. I know. It's set in CanAtmosPass(), a rather heady set of procs that build `atmos_adjacent_turfs`, and also modify `atmos_superconductivity`.

So then, a review.

* *`thermal_conductivity`* Ranges from 0 to 1, effects how easy it is for a turf to receive heat
* *`heat_capacity`* Large numbers mean it's harder to heat, but holds more heat. You get it. Also used for turf melting
* *`atmos_supeconductivity`* Bitfield of directions we **can't** share in, this is often set by firelocks and such

One more thing, turfs will superconduct until they either run out of energy, or temperature. This is a stable system because turfs "conduct" with space, which is why floods of heat will equalize to about 690k over time.

## 6. Processing time, Dynamic scaling, and what slows us down the most

This will require/impart a light understanding of the master controller, I will go over what makes the atmos subsystem slow, what can be done, and what it effects.

First, some new vocab.

* *`wait`* Subsystem var, it is the amount of time to "wait" between each fire, or process. Measured in deciseconds.
* *`MC_TICK_CHECK`* A define that checks to see if the subsystem has taken more then it's allotted time. In the case of SSAir we use it to allow for dynamic scaling

The MC entry for SSAir is very helpful for debugging, and it is good to understand before I talk about cost.

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/SSAirAtRest.png)

*Figure 6.1: SSAir sitting doing little to nothing turf wise, only processing pipenets and atmos machines*

As you can see here, SSAir is a bit of a jumble, don't worry, it'll make sense in a second. The first line is in this order: cost, tick_usage, tick_overrun, ticks.
All of these are averages by the way.

* *`cost`* Cost is the raw time spent running the subsystem in milliseconds
* *`tick_usage`* The percent of each byond tick the last fire() took. Tends to be twice cost, good for comparing with overrun.
* *`tick_overrun`* A percentage of how far past our allotted time we ran. This is what causes Time Dilation, it's bad.
* *`ticks`* The amount of subsystem fires it takes to run through all the subprocesses once.

The second line is the cost each subprocess contributed per full cycle, this is a rolling average. It'll give you a good feel for what is misbehaving.

The third line is the amount of "whatever" in each subprocess. Handy for noticing dupe bugs and crying at active turf cost. Speaking of, the last entry is the active turfs per overall cost. Not a great metric, but larger is better.

Now then, what the hell is going on in that image.

### Dynamic scaling

SSAir has a wait of 5 deciseconds, or 500ms. This means it wants to fire roughly twice a second. You'll see in a moment why this hardly ever happens.

See that image from before? Notice how the cost of SSAir at rest is about 40ms? yeahhhhh.

The atmos subsystem was used as a testing ground for the robustness of the master-controller. It used to have a wait of 2 seconds, but that was lowered to 0.5 as it was thought that the system could handle it. It can! But this can have annoying side effects. As you know, we edge right up against 1/10th of the wait when sitting at rest, and if we start to make diffs...

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/GasTypes.png)

*Figure 6.2: SSAir when a high amount of active turfs are operating, with a large selection of gastypes for each tile*

As you can see, active turfs can be really slow. Oh but it gets so much worse.

Active turf cost is mostly held up in `react()`, `share()` and `compare()`. `react()` and `share()` scale directly with the amount of gas in the air. `compare()` does better, but none of them do that great.

For this reason, and because excited groups spread gas out so much, we want to keep the variation of gastypes in the air relatively low.

react() is called for every active turf, and every pipenet. On each react call for reasons I don't want to go into right now, we need to iterate over every reaction and do a preliminary test. Therefor, the more datum reactions we have, the slower those two processes go.

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/LargeExcitedGroup.png)

*Figure 6.3: The effects of a large excited group on overtime*

It's hard to tell here because I took the picture right as it happen, but when large excited groups go through `self_breakdown()` they can overtime by a significant deal. This is because `self_breakdown()` can't be delayed, or done in two parts. We can't let an older gasmix that's already been collected have say 1000 mols of plasma added, then go into breakdown and delete it all. Thus, the overtime cost. This was with a excited group 900 tiles large though, so it isn't nearly ever this bad. It also scales with the amount of gases in the same way that `share()` does.

On the whole excited groups are the only major source of overrun, consider this a treatise on why that 900ms cost number next to atmos isn't making the server die. It's really that excited group mass equalizing constantly.

## 7. What we want atmos code to be

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/DiffsSettling.png)

*Figure 7.1: Diffs settling out as they should, around their sources*

Our goal is not to simulate real life atmospherics. It is instead to put on a show of doing so. To sleep wherever we can, and fake it as hard as possible.

This is matters the most with environmental stuff, but it's everywhere you look.

The goal of active turfs, excited groups, and sleeping is to isolate the processing that needs to happen, and move diffs from their source to a consumer as much as we can. We don't simulate every tile, and most of the changes to LINDA have been directed at simulating as little as we can get away with.

Hell, space being cold is a hack we use to make gameplay interesting. There's a lot more stuff like this, because this isn't a simulator, it's a theater production.

Performance and gameplay are much more important then realism. In all your work on the subsystem, keep this in mind, and you'll build fast and quality code.

## 8. Pipelines and pipeline machinery

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/PipelineVisuals.png)

*Figure 8.1: The structure of pipelines shown in color, components are a mix*

`/datum/pipeline` handles the simulation of piping and such. It has 2 main actions, one of which you should know very well. The other is slightly more of a hurdle.

To understand pipelines you'll first need to understand how we process things like pumps or vents, atmos components that is.
To start with, a set of pipes is treated as one gas mixture, however several different components draw from this mix. Think pumps, heaters, mixers, vents, etc.

Since these components change the mix itself, we can't just let them all act on the mix at once, because that would cause concerns around the order in which things process, and so on.
We don't want canisters that blow up half the time, and the other half of the time don't. Better then to give each component its own gas mix that it alone can act on, that will be shared with the pipeline as a whole. Pipelines do something similar to active turfs by the way, they won't re-equalize their mix if nothing about the state of things has changed.

We do this sharing based on the proportion of volume between all the components. So if you want a component to consume more gas, give it a higher volume.

On that note, I'd like to be clear about something. In lines of connected pipes, each pipe doesn't have its own gasmix, they instead share mixes, as the pipes themselves won't have any effect on the state of the mix.

Oh, and pipelines react the gas mixture inside them, thought I should mention that.

All the other behavior of pipes and pipe components are handled by atmos machinery. I'll give a brief rundown of how they're classified, but the details of each machine are left as an exercise to the reader.

#### Pipes

The raw pipes. They have some amount of nuance, mostly around layers, but it's not too tricky to deal with.

##### Heat Exchange

The HE pipes, used to transfer heat from the pipe to the turf it's sitting on. These work directly with the pipeline's mix, which is ehhhh? Might need some touching up, perhaps making them subnets that do one heat transfer. Not too big a deal in any case, since they're the only thing that acts directly on a pipeline mix. They have some other behavior, like glowing when hot, but it's minor.

#### Components

These are the components I described above, they have some sort of internal gas mix that they act on in some manner.

The following classifications are very simple, but I'll run them over anyhow

##### Unary

Unary devices can only interact with one pipeline, aside from some exceptions, like the heat exchanger. The type path comes from the amount of pipelines a device expects gas-mixtures from. I'm sure you can see where this is going.

##### Binary

Binary devices connect to 2 pipelines.

##### Trinary

Trinary devices connect to 3 p- Listen you get it already.

##### Fusion

Finally something more interesting. Unfortunately I'm not familiar with the inner workings of this machine, but this folder deals with hypertorus code.

#### Other

This is for the oddballs, the one offs, the half useless things. Things that are tied to the module, but that we don't have a better spot for. Think meters, stuff like that.

#### Portable

These are the atmos machines you can move around. They interface with connectors to talk to pipelines, and can contain tanks. Not a whole lot more to discuss here.

## Appendix A - Glossary

* *LINDA* - Our environmental gas system, created by Aranclanos, Beautiful in Spanish
* *Naps* - A healthy pastime
* *Gas mixtures* - The datums that store gas information, key to listmos and our underlying method of handling well gas
* *Diffs* - The differences between gasmixes. We want to get rid of these over time, and clump them up with their sources so we don't need to process too many turfs
* *FEA* - Finite Element Analysis, the underlying system our atmos is built on top of. Ugly in Spanish
* *Pipelines* - The datum that represents and handles the gasmixtures of a set of pipes and their components
* *Components* - Atmos machines that act on pipelines, modifying their mix
* *Active Turfs* - An optimization of FEA implemented in LINDA that causes processing to only occur when differences are equalizing
* *Excited Groups* - Evens out groups of active turfs to compensate for the way `share()` works
* *Carbon dioxide* - What the fuck is this?]
* *MC* - The master controller, makes sure all subsystems get the time they need to process, prevents lockups from one subsystem having a lot of work

## Appendix B - How to test environmental atmos
If you really want to get a feeling for how flow works you'll need to load up the game and make some diffs. What follows is a short description of how to set up testing.

To start with, you should enable the `TESTING` define in compile_options.dm, this toggles `VISUALIZE_ACTIVE_TURFS` and `TRACK_MAX_SHARE`. These two debug methods are very helpful for understanding flow, but they aren't cheap, so we make them a compile time option. Active turfs will show up as green, don't worry about the second define, it's coming right up.

Past that you'll want to turn on excited group highlighting, to do this open the atmos control panel in the debug tab and toggle both personal view and display all. Display all makes turfs display their group and personal view shows/hides the groups from you, it's faster to toggle this, and this way you don't piss off the other debuggers on live.

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/AtmosControlPanel.png)

*Figure B.1: The atmospherics control panel*

To go into more detail about the control panel, it is split into two parts. At the top there's a readout of some relevant stats, the amount of active turfs, how many times the subsystem has fired, etc. You can get the same information from the SSAir MC entry, but it's a bit harder to read. I detail this in the section on performance in environmental atmos. There's a button that turns the subsystem on/off in the top left, it's handy for debugging and seeing how things work step by step. Use it if you need to slow things down.

The rest of the panel is where things get more interesting, it's a readout of excited groups, sorted by area name. Most of it ought to be obvious, this is where `TRACK_MAX_SHARE` comes into effect. If it's defined, excited groups will have an extra entry which displays the largest molar diff in the group. This is useful for diagnosing group breakdown issues, and getting a feel for when a group will next breakdown. You can also toggle the visibility of each individual group here, and teleport to the group by clicking on the area name.

### What to look for

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/StartingOut.png)

An excited group can contain 2 things, sources of diffs, and dead tiles.

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/MovingForward.png)

Of course, if left unchecked active turfs will spread further and further out, slowly lowering the amount of dead tiles.

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/SleepWorking.png)

Excited group breakdown causes them to recede and wrap around the things causing them

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/CleanupTroubles.png)

Cleanup causes a major recession due to turfs becoming suddenly no longer having an excited group

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/StrangeGrowth.png)
![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/OddGrowth%2BMonkey.png)

Due to how process_cell() works, active turfs will spread strangely when low on diffs

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/atmos/Flickering.png)

They will also occasionally nap, then immediately wake back up. This is either because of a discrepancy between `compare()` and `LAST_SHARE_CHECK`, or just the result of sleeping being a thing.
