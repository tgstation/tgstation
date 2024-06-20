# Hard Deletes

> Garbage collection is pretty gothic when you think about it.
>
>An object in code is like a ghost, clinging to its former life, and especially to the people it knew. It can only pass on and truly die when it has dealt with its unfinished business. And only when its been forgotten by everyone who ever knew it. If even one other object remembers it, it has a connection to the living world that lets it keep hanging on
>
>There is a kind of sombre tone to fixing GC errors too, its almost shamanistic, making sure all these little objects clear up their final affairs in life before they die, to ensure they don't become ghosts
>
> -- <cite>Nanako</cite>

### Table of contents

1. [What is hard deletion](#What-is-hard-deletion)
2. [Causes of hard deletes](#causes-of-hard-deletes)
3. [Detecting hard deletes](#detecting-hard-deletes)
4. [Techniques for fixing hard deletes](#techniques-for-fixing-hard-deletes)
5. [Help my code is erroring how fix](#help-my-code-is-erroring-how-fix)


## What is Hard Deletion

Hard deletion is a very expensive operation that basically clears all references to some "thing" from memory. Objects that undergo this process are referred to as hard deletes, or simply harddels

What follows is a discussion of the theory behind this, why we would ever do it, and the what we do to avoid doing it as often as possible

I'm gonna be using words like references and garbage collection, but don't worry, it's not complex, just a bit hard to pierce

### Why do we need to Hard Delete?

Ok so let's say you're some guy called Jerry, and you're writing a programming language

You want your coders to be able to pass around objects without doing a full copy. So you'll store the pack of data somewhere in memory

```dm
/someobject
    var/id = 42
    var/name = "some shit"
```

Then you want them to be able to pass that object into say a proc, without doing a full copy. So you let them pass in the object's location in memory instead
This is called passing something by reference

```dm
someshit(someobject) //This isn't making a copy of someobject, it's passing in a reference to it
```

This of course means they can store that location in memory in another object's vars, or in a list, or whatever

```dm
/datum
    var/reference

/proc/someshit(mem_location)
    var/datum/some_obj = new()
    some_obj.reference = mem_location
```

But what happens when you get rid of the object we're passing around references to? If we just cleared it out from memory, everything that holds a reference to it would suddenly be pointing to nowhere, or worse, something totally different!

So then, you've gotta do something to clean up these references when you want to delete an object

We could hold a list of references to everything that references us, but god, that'd get really expensive wouldn't it

Why not keep count of how many times we're referenced then? If an object's ref count is ever 0, nothing whatsoever cares about it, so we can freely get rid of it

But if something's holding onto a reference to us, we're not gonna have any idea where or what it is

So I guess you should scan all of memory for that reference?

```dm
del(someobject) //We now need to scan memory until we find the thing holding a ref to us, and clear it
```

This pattern is about how BYOND handles this problem of hanging references, or Garbage Collection

It's not a broken system, but as you can imagine scanning all of memory gets expensive fast

What can we do to help that?

### How we can avoid hard deletes

If hard deletion is so slow, we're gonna need to clean up all our references ourselves

In our codebase we do this with `/datum/proc/Destroy()`, a proc called by `qdel()`, whose purpose I will explain later

This procs only job is cleaning up references to the object it's called on. Nothing more, nothing else. Don't let me catch you giving it side effects

There's a long long list of things this does, since we use it a TON. So I can't really give you a short description. It will always move the object to nullspace though

## Causes Of Hard Deletes

Now that you know the theory, let's go over what can actually cause hard deletes. Some of this is obvious, some of it's much less so.

The BYOND reference has a list [Here](https://secure.byond.com/docs/ref/#/DM/garbage), but it's not a complete one

* Stored in a var
* An item in a list, or associated with a list item
* Has a tag
* Is on the map (always true for turfs)
* Inside another atom's contents
* Inside an atom's vis_contents
* A temporary value in a still-running proc
* Is a mob with a key
* Is an image object attached to an atom

Let's briefly go over the more painful ones yeah?

### Sleeping procs

Any proc that calls `sleep()`, `spawn()`, or anything that creates a separate "thread" (not technically a thread, but it's the same in these terms. Not gonna cause any race conditions tho) will hang references to any var inside it. This includes the usr it started from, the src it was called on, and any vars created as a part of processing

### Static vars

`/static` and `/global` vars count for this too, they'll hang references just as well as anything. Be wary of this, these suckers can be a pain to solve

### Range() and View() like procs

Some internal BYOND procs will hold references to objects passed into them for a time after the proc is finished doing work, because they cache the returned info to make some code faster. You should never run into this issue, since we wait for what should be long enough to avoid this issue as a part of garbage collection

This is what `qdel()` does by the by, it literally just means queue deletion. A reference to the object gets put into a queue, and if it still exists after 5 minutes or so, we hard delete it

### Walk() procs

Calling `walk()` on something will put it in an internal queue, which it'll remain in until `walk(thing, 0)` is called on it, which removes it from the queue

This sort is very cheap to harddel, since BYOND prioritizes checking this queue first when it's clearing refs, but it should be avoided since it causes false positives

You can read more about how BYOND prioritizes these things [Here](https://www.patreon.com/posts/diving-for-35855766)

## Detecting Hard Deletes

For very simple hard deletes, simple inspection should be enough to find them. Look at what the object does during `Initialize()`, and see if it's doing anything it doesn't undo later.
If that fails, search the object's typepath, and look and see if anything is holding a reference to it without regard for the object deleting

BYOND currently doesn't have the capability to give us information about where a hard delete is. Fortunately we can search for most all of then ourselves.
The procs to perform this search are hidden behind compile time defines, since they'd be way too risky to expose to admin button pressing

If you're having issues solving a harddel and want to perform this check yourself, go to `_compile_options.dm` and uncomment `REFERENCE_TRACKING_STANDARD`.

You can read more about what each of these do in that file, but the long and short of it is if something would hard delete our code will search for the reference (This will look like your game crashing, just hold out) and print information about anything it finds to [log_dir]/harddels.log, which you can find inside the round folder inside `/data/logs/year/month/day`

It'll tell you what object is holding the ref if it's in an object, or what pattern of list transversal was required to find the ref if it's hiding in a list of some sort, alongside the references remaining.

## Techniques For Fixing Hard Deletes

Once you've found the issue, it becomes a matter of making sure the ref is cleared as a part of Destroy(). I'm gonna walk you through a few patterns and discuss how you might go about fixing them

### Our Tools

First and simplest we have `Destroy()`. Use this to clean up after yourself for simple cases

```dm
/someobject/Initialize(mapload)
    . = ..()
    GLOB.somethings += src //We add ourselves to some global list

/someobject/Destroy()
    GLOB.somethings -= src //So when we Destroy() clean yourself from the list
    return ..()
```

Next, and slightly more complex, pairs of objects that reference each other

This is helpful when for cases where both objects "own" each other

```dm
/someobject
    var/someotherobject/buddy

/someotherobject
    var/someobject/friend

/someobject/Initialize(mapload)
    if(!buddy)
        buddy = new()
        buddy.friend = src

/someotherobject/Initialize(mapload)
    if(!friend)
        friend = new()
        friend.buddy = src

/someobject/Destroy()
    if(buddy)
        buddy.friend = null //Make sure to clear their ref to you
        buddy = null //We clear our ref to them to make sure nothing goes wrong

/someotherobject/Destroy()
    if(friend)
        friend.buddy = null //Make sure to clear their ref to you
        friend = null //We clear our ref to them to make sure nothing goes wrong
```

Something similar can be accomplished with `QDELETED()`, a define that checks to see if something has started being `Destroy()`'d yet, and `QDEL_NULL()`, a define that `qdel()`'s a var and then sets it to null

Now let's discuss something a bit more complex, weakrefs

You'll need a bit of context, so let's do that now

BYOND has an internal bit of behavior that looks like this

`var/string = "\ref[someobject]"`

This essentially gets that object's position in memory directly. Unlike normal references, this doesn't count for hard deletes. You can retrieve the object in question by using `locate()`

`var/someobject/someobj = locate(string)`

This has some flaws however, since the bit of memory we're pointing to might change, which would cause issues. Fortunately we've developed a datum to handle worrying about this for you, `/datum/weakref`

You can create one using the `WEAKREF()` proc, and use weakref.resolve() to retrieve the actual object

This should be used for things that your object doesn't "own", but still cares about

For instance, a paper bin would own the paper inside it, but the paper inside it would just hold a weakref to the bin

There's no need to clean these up, just make sure you account for it being null, since it'll return that if the object doesn't exist or has been queued for deletion

```dm
/someobject
    var/datum/weakref/our_coin

/someobject/proc/set_coin(/obj/item/coin/new_coin)
    our_coin = WEAKREF(new_coin)

/someobject/proc/get_value()
    if(!our_coin)
        return 0

    var/obj/item/coin/potential_coin = our_coin.resolve()
    if(!potential_coin)
        our_coin = null //Remember to clear the weakref if we get nothing
        return 0
    return potential_coin.value
```

Now, for the worst case scenario

Let's say you've got a var that's used too often to be weakref'd without making the code too expensive

You can't hold a paired reference to it because it's not like it would ever care about you outside of just clearing the ref

So then, we want to temporarily remember to clear a reference when it's deleted

This is where I might lose you, but we're gonna use signals

`qdel()`, the proc that sets off this whole deletion business, sends a signal called `COMSIG_QDELETING`

We can listen for that signal, and if we hear it clear whatever reference we may have

Here's an example

```dm
/somemob
    var/mob/target

/somemob/proc/set_target(new_target)
    if(target)
        UnregisterSignal(target, COMSIG_QDELETING) //We need to make sure any old signals are cleared
    target = new_target
    if(target)
        RegisterSignal(target, COMSIG_QDELETING, PROC_REF(clear_target)) //Call clear_target if target is ever qdel()'d

/somemob/proc/clear_target(datum/source)
    SIGNAL_HANDLER
    set_target(null)
```

This really should be your last resort, since signals have some limitations. If some subtype of somemob also registered for parent_qdeleting on the same target you'd get a runtime, since signals don't support it

But if you can't do anything else for reasons of conversion ease, or hot code, this will work

## Help My Code Is Erroring How Fix

First, do a quick check.

Are you doing anything to the object in `Initialize()` that you don't undo in `Destroy()`? I don't mean like, setting its name, but are you adding it to any lists, stuff like that

If this fails, you're just gonna have to read over this doc. You can skip the theory if you'd like, but it's all pretty important for having an understanding of this problem

## Misc facts

> i like rust and all, buuut it removes garbage collecctor, and i pretend garbage collector is a cute girl checking my code
>
> -- <cite>Armhulenn</cite>

- The reference tracker, while powerful, is incredibly easy to break<br>
If it weren't for those unit tests we'd still be missing list["a"] = list(ref)
- Everyone but me sucks, because everyone but me keeps adding new hard deletes
- Garbage collection is a spook, best practice is to use a random reference in place of null, it scares the compiler demons
