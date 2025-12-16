## Guide to Smooth Visuals

I'd like to begin this document with two disclaimers:
- This is my view of the game/engine at this precise moment in time. Whenever you write something down it will always rot.
- This is far more information about how to make BYOND behave then you likely need. I'm writing it down because it's important that it's documented, because otherwise our solutions would be absolutely incomprehensible.

### What does smooth mean?

The game server fires at a set tickrate, which is 20 ticks per second (TPS) or 0.5 deciseconds (DS) tick_lag (between ticks) on mainline /tg/. Clients are sent visual packets full of things like map data and animation once each tick but have their own independent tick rate (default being 100 TPS, but any divisible value shall work). Each client tick animations will continue on along some gradient between the start and end values.

Because the client and server are not the same thing, they have their own opinions about how far along in an animation the client is in any given frame. Our goal here is to minimize this difference in opinion, to keep the two as synced together as possible.

We're doing this because if we can keep them in time, animations/effects will transition smoothly, and we avoid "jitter" in the client's smooth interpolation.

Achieving smoothness has other benefits, this idea of client and server desyncs applies to stuff like icon state animations and sound lengths just the same.

### What causes this difference in opinion?

> In order to talk about this properly you need to have a basic understanding of the game tick. See this [writeup on tick order](TICK_ORDER.md) for a baseline.

As discussed before the client and server fire at different tick rates. What this means mechanically is the server will try to send out a packet of information to the client every tick_lag ds, and the client will anticipate a packet of information from the server every tick_lag ds. If the client recieves its packet on regular intervals, and is able to render at its specified framerate, then any animations or effects will happen smoothly, assuming we don't literally fuck up the timing on the server.

There's a bunch of different things that can happen which can fuck up this cycle.

#### 1. Network Lag

A series of tubes separates the client from the server, and if the packet of information containing appearance updates gets slowed down in transit then we'll see that as jitter on the client.

There isn't a ton we can actually do about this, because sometimes the internet fucks up. We just have to assume the network connection will be stable.

#### 2. Clientside Overrun

When set to make a new frame X times a second, the client is expected to make a new frame X times a second. This number is built into the gradients used for any animations happening clientside. If it's not able to meet quota, the user will see delays in action and other sorts of jitter.

This usually happens because the user's computer just doesn't have a powerful enough GPU (or CPU in some cases) to render a frame in the time required. This is something we can work on, but it's quite complicated since we lack effective profiling tools for clientside issues. You can get a decent feeling for your own machine by looking at the task manager.

This delay can also lead to a desync between client and server frames, which would cause the same sort of failure as server overrun.

> As a general rule: more stuff on screen/more filters being applied to that stuff -> more clientside lag. There's some flaws here on byond's end which lummox is working on but there's only so much you can do.

#### 3. Server Overrun

The server is expected to finish a tick every tick_lag ds. If it CAN'T, like if the Master Controller, Sleeping Procs, or Verbs (more on these later) takes more than that amount of time to execute, then that'll show up as a delayed appearance update on the client. This will result in a jitter in any animations that are extended by the server (movement falls into this).

If the overrun is consistent enough we can build this delay into our animations. This is most relevant for smooth movement (fancy byond stuff that functionally just animates a glide between two tiles). If we know the average overrun we can use it as a multiplier for how long animations like movement should take and sync them back up with the server's functional tickrate. If the overrun isn't consistent then we just kind of have to bite it. This is one of the more persistent problems we have, since in theory any part of the codebase could overconsume the tick.

#### 4. Server Underrun

I've been lying to you a little bit so far. We don't actually need the server and client tick rate to sync up perfectly. What we actually need is the time between map sends to sync up with the client's framerate (IE, the time between mapsends needs to be consistent). This is because appearance info is sent by the server as soon as map sending finishes, the time after when verbs run is something closer to "dead" time (verbs don't even show up on byond's cpu tracking tools, although that's for different reasons).

This means that if say, it takes 70% of the tick to get to sending maps on tick 1, 20% on tick 2, and 90% on tick 3, then clients will see that as jitter "forward" (50% of a tick separates 1 and 2) and then a long delay (170% of a tick separates 2 and 3).

There are ways for byond to fix this jumping "forward" (it could just hold the frame for a little while, though this would be weird with aforementioned network problems), but fixing the delay is harder and would in theory require some form of client-side prediction.

This behavior means we need to try to "pin" the time map sends to roughly the same % of the tick. In some cases we literally do nothing burning cpu time that could otherwise be spent on verbs because we NEED the mapsends to line up.

### Asides

#### Verbs are Stupid

Verbs are not actually measured in world.cpu, because verbs don't really like, have a start and stop time for execution. Verbs can fire anytime after map sending, and before the next tick starts. You might get no verbs until the very last moment, and then get 10 that want to run all at once.

This is because verbs are executed when they arrive at the server. They're literally just requests from the clients to "do something". They're not allowed to run in map sending or while sleeping procs are going, but afterwards it's basically free game for them.

This means in order to keep them from causing server overrun, we need to keep track of when they're trying to run and queue them up if it's too late to finish on time.

> Verbs can also somtimes run AFTER a tick is over, even if no verbs were holding up the tick before. I frankly have no idea why this happens.

#### Types of "failure"

There's two types of ways to fuck up a transition (sound, animate() call, glide, etc). You can start too early, or start too late.

It's quite rare for "undershooting" to be a problem. It only really shows up if the client gets packets too quickly, which would either happen due to server underrun, or because of network hell leading to the client getting a bunch of packets at once.

Overshooting on the other hand is quite common. We have a very hard time avoiding server overrun because code can functionally do whatever it wants. The MC does its best to avoid this but if a subsystem/sleeping proc/verb just decides it's not going to cooperate then we're going to have to eat the cost.

Building undershooting into your work is kind of impossible, but working around overshooting isn't always assuming you don't need things to line up perfectly. As an example, if you're making an icon state animation that's meant to be set, and then changed away from a few ticks later, you can prevent it from looping on the client during overrun by adding a long delay to the last frame. The same idea applies to say, a fade out animation. If you have something that needs to happen LATER than some time, building in grace will help a lot in avoiding weird ass UX.
