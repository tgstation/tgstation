The byond tick proceeds as follows:

1. procs sleeping via walk() are resumed (i dont know why these are first)

2. normal sleeping procs are resumed, in the order they went to sleep in the first place, this is where the MC wakes up and processes subsystems. a consequence of this is that the MC almost never resumes before other sleeping procs, because it only goes to sleep for 1 tick 99% of the time, and 99% of procs either go to sleep for less time than the MC (which guarantees that they entered the sleep queue earlier when its time to wake up) and/or were called synchronously from the MC's execution, almost all of the time the MC is the last sleeping proc to resume in any given tick. This is good because it means the MC can account for the cost of previous resuming procs in the tick, and minimizes overtime.

3. Tick() is called

4. control is passed to byond after all of our code's procs stop execution for this tick

5. a few small things happen in byond internals

6. SendMaps is called for this tick, which processes the game state for all clients connected to the game and handles sending them changes
   in appearances within their view range. This is expensive and takes up a significant portion of our tick, about 0.3% per connected player
   as of 12/14/2025. meaning that with 50 players, 15% of our tick is being used up by just SendMaps, after all of our code has stopped executing. Thats only the average across all rounds, highpop sees lower averages numbers then lowpop (as a rule of thumb) since mapsending is threaded.

7. After SendMaps ends, client verbs sent to the server are executed, and its the last major step before the next tick begins.
   During the course of the tick, a client can send a command to the server saying that they have executed any verb. The actual code defined
   for that /verb/name() proc isnt executed until this point. Due to our main subsystem's unending hunger for cpu time, we risk verbs eating into the next tick's worth of time if they are not delayed, which we attempt to do automatically by guessing at how long they will take.

The master controller can derive how much of the tick was used in: procs executing before it woke up (because of world.tick_usage), and SendMaps (because of world.map_cpu, since this is a running average you cant derive the tick spent on maptick on any particular tick). It cannot derive how much of the tick was used for sleeping procs resuming after the MC will run, or for verbs executing after SendMaps. We can look back at these numbers using clever math but we cannot know in the moment.

It is for these reasons why you should heavily limit processing done in verbs, while procs resuming after the MC are rare, verbs are not, and are much more likely to cause overtime since theyre literally at the end of the tick. It's good practice to follow similar rules for sleeping procs, but only because they risk chewing all the cpu before the mc gets to it, the chances of them causing unrelated overtime are quite low.
