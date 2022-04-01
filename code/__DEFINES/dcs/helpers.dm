/// Used to trigger signals and call procs registered for that signal
/// The datum hosting the signal is automaticaly added as the first argument
/// Returns a bitfield gathered from all registered procs
/// Arguments given here are packaged in a list and given to _send_signal
#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup?[sigtype] ? NONE : target._send_signal(sigtype, list(target, ##arguments)) )

#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( SEND_SIGNAL(SSdcs, sigtype, ##arguments) )

/// Signifies that this proc is used to handle signals.
/// Every proc you pass to register_signal must have this.
#define SIGNAL_HANDLER SHOULD_NOT_SLEEP(TRUE)

/// A wrapper for _add_element that allows us to pretend we're using normal named arguments
#define add_element(arguments...) _add_element(list(##arguments))
/// A wrapper for _remove_element that allows us to pretend we're using normal named arguments
#define remove_element(arguments...) _remove_element(list(##arguments))

/// A wrapper for _add_component that allows us to pretend we're using normal named arguments
#define add_component(arguments...) _add_component(list(##arguments))

/// A wrapper for _load_component that allows us to pretend we're using normal named arguments
#define load_component(arguments...) _load_component(list(##arguments))
