# Datum Component System (DCS)

## Concept

Loosely adapted from /vg/. This is an entity component system for adding behaviours to datums when inheritance doesn't quite cut it. By using signals and events instead of direct inheritance, you can inject behaviours without hacky overloads. It requires a different method of thinking, but is not hard to use correctly. If a behaviour can have application across more than one thing. Make it generic, make it a component. Atom/mob/obj event? Give it a signal, and forward it's arguments with a `SendSignal()` call. Now every component that want's to can also know about this happening.

### In the code

#### Slippery things

At the time of this writing, every object that is slippery overrides atom/Crossed does some checks, then slips the mob. Instead of all those Crossed overrides they could add a slippery component to all these objects. And have the checks in one proc that is run by the Crossed event

#### Powercells

A lot of objects have powercells. The `get_cell()` proc was added to give generic access to the cell var if it had one. This is just a specific use case of `GetComponent()`

#### Radios

The radio object as it is should not exist, given that more things use the _concept_ of radios rather than the object itself. The actual function of the radio can exist in a component which all the things that use it (Request consoles, actual radios, the SM shard) can add to themselves.

#### Standos

Stands have a lot of procs which mimic mob procs. Rather than inserting hooks for all these procs in overrides, the same can be accomplished with signals

## API

### Defines

1. `COMPONENT_INCOMPATIBLE` Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it's applied to an incorrect type. `parent` must not be modified if this is to be returned. This will be noted in the runtime logs

### Vars

1. `/datum/var/list/datum_components` (private)
    * Lazy associated list of type -> component/list of components.
1. `/datum/component/var/enabled` (protected, boolean)
    * If the component is enabled. If not, it will not react to signals
    * `FALSE` by default, set to `TRUE` when a signal is registered
1. `/datum/component/var/dupe_mode` (protected, enum)
    * How duplicate component types are handled when added to the datum.
        * `COMPONENT_DUPE_HIGHLANDER` (default): Old component will be deleted, new component will first have `/datum/component/proc/InheritComponent(datum/component/old, FALSE)` on it
        * `COMPONENT_DUPE_ALLOWED`: The components will be treated as separate, `GetComponent()` will return the first added
        * `COMPONENT_DUPE_UNIQUE`: New component will be deleted, old component will first have `/datum/component/proc/InheritComponent(datum/component/new, TRUE)` on it
        * `COMPONENT_DUPE_UNIQUE_PASSARGS`: New component will never exist and instead its initialization arguments will be passed on to the old component.
1. `/datum/component/var/dupe_type` (protected, type)
    * Definition of a duplicate component type
        * `null` means exact match on `type` (default)
        * Any other type means that and all subtypes
1. `/datum/component/var/list/signal_procs` (private)
    * Associated lazy list of signals -> `/datum/callback`s that will be run when the parent datum recieves that signal
1. `/datum/component/var/datum/parent` (protected, read-only)
    * The datum this component belongs to
    * Never `null` in child procs
1.	`report_signal_origin` (protected, boolean)
	* If `TRUE`, will invoke the callback when signalled with the signal type as the first argument.
	* `FALSE` by default.

### Procs

1. `/datum/proc/GetComponent(component_type(type)) -> datum/component?` (public, final)
    * Returns a reference to a component of component_type if it exists in the datum, null otherwise
1. `/datum/proc/GetComponents(component_type(type)) -> list` (public, final)
    * Returns a list of references to all components of component_type that exist in the datum
1. `/datum/proc/GetExactComponent(component_type(type)) -> datum/component?` (public, final)
    * Returns a reference to a component whose type MATCHES component_type if that component exists in the datum, null otherwise
1. `GET_COMPONENT(varname, component_type)` OR `GET_COMPONENT_FROM(varname, component_type, src)`
    * Shorthand for `var/component_type/varname = src.GetComponent(component_type)`
1. `SEND_SIGNAL(target, sigtype, ...)` (public, final)
    * Use to send signals to target datum
    * Extra arguments are to be specified in the signal definition
    * Returns a bitflag with signal specific information assembled from all activated components
    * Arguments are packaged in a list and handed off to _SendSignal()
1. `/datum/proc/AddComponent(component_type(type), ...) -> datum/component`  (public, final)
    * Creates an instance of `component_type` in the datum and passes `...` to its `Initialize()` call
    * Sends the `COMSIG_COMPONENT_ADDED` signal to the datum
    * All components a datum owns are deleted with the datum
    * Returns the component that was created. Or the old component in a dupe situation where `COMPONENT_DUPE_UNIQUE` was set
    * If this tries to add an component to an incompatible type, the component will be deleted and the result will be `null`. This is very unperformant, try not to do it
    * Properly handles duplicate situations based on the `dupe_mode` var
1. `/datum/proc/LoadComponent(component_type(type), ...) -> datum/component` (public, final)
    * Equivalent to calling `GetComponent(component_type)` where, if the result would be `null`, returns `AddComponent(component_type, ...)` instead
1. `/datum/proc/ComponentActivated(datum/component/C)` (abstract, async)
    * Called on a component's `parent` after a signal recieved causes it to activate. `src` is the parameter
    * Will only be called if a component's callback returns `TRUE`
1. `/datum/proc/TakeComponent(datum/component/C)` (public, final)
    * Properly transfers ownership of a component from one datum to another
    * Signals `COMSIG_COMPONENT_REMOVING` on the parent
    * Called on the datum you want to own the component with another datum's component
1. `/datum/proc/_SendSignal(signal, list/arguments)` (private, final)
    * Handles most of the actual signaling procedure
    * Will runtime if used on datums with an empty component list
1. `/datum/component/New(datum/parent, ...)` (private, final)
    * Runs internal setup for the component
    * Extra arguments are passed to `Initialize()`
1. `/datum/component/Initialize(...)` (abstract, no-sleep)
    * Called by `New()` with the same argments excluding `parent`
    * Component does not exist in `parent`'s `datum_components` list yet, although `parent` is set and may be used
    * Signals will not be recieved while this function is running
    * Component may be deleted after this function completes without being attached
    * Do not call `qdel(src)` from this function
1. `/datum/component/Destroy(force(bool), silent(bool))` (virtual, no-sleep)
    * Sends the `COMSIG_COMPONENT_REMOVING` signal to the parent datum if the `parent` isn't being qdeleted
    * Properly removes the component from `parent` and cleans up references
    * Setting `force` makes it not check for and remove the component from the parent
    * Setting `silent` deletes the component without sending a `COMSIG_COMPONENT_REMOVING` signal
1. `/datum/component/proc/InheritComponent(datum/component/C, i_am_original(boolean))` (abstract, no-sleep)
    * Called on a component when a component of the same type was added to the same parent
    * See `/datum/component/var/dupe_mode`
    * `C`'s type will always be the same of the called component
1. `/datum/component/proc/AfterComponentActivated()` (abstract, async)
    * Called on a component that was activated after it's `parent`'s `ComponentActivated()` is called
1. `/datum/component/proc/OnTransfer(datum/new_parent)` (abstract, no-sleep)
    * Called before `new_parent` is assigned to `parent` in `TakeComponent()`
    * Allows the component to react to ownership transfers
1. `/datum/component/proc/_RemoveFromParent()` (private, final)
    * Clears `parent` and removes the component from it's component list
1. `/datum/component/proc/_JoinParent` (private, final)
    * Tries to add the component to it's `parent`s `datum_components` list
1. `/datum/component/proc/RegisterSignal(signal(string/list of strings), proc_ref(type), override(boolean))` (protected, final) (Consider removing for performance gainz)
    * If signal is a list it will be as if RegisterSignal was called for each of the entries with the same following arguments
    * Makes a component listen for the specified `signal` on it's `parent` datum.
    * When that signal is recieved `proc_ref` will be called on the component, along with associated arguments
    * Example proc ref: `.proc/OnEvent`
    * If a previous registration is overwritten by the call, a runtime occurs. Setting `override` to TRUE prevents this
    * These callbacks run asyncronously
    * Returning `TRUE` from these callbacks will trigger a `TRUE` return from the `SendSignal()` that initiated it

### See/Define signals and their arguments in __DEFINES\components.dm
