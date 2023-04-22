// Interfaces for the SpacemanDMM linter, define'd to nothing when the linter
// is not in use.

// The SPACEMAN_DMM define is set by the linter and other tooling when it runs.
#ifdef SPACEMAN_DMM
	/**
	 * Sets a return type expression for a proc. The return type can take the forms:

	 * `/typepath` - a raw typepath. The return type of the proc is the type named.

	 * `param` - a typepath given as a parameter, for procs which return an instance of the passed-in type.

	 * `param.type` - the static type of a passed-in parameter, for procs which
	 * return their input or otherwise another value of the same type.

	 * `param[_].type` - the static type of a passed-in parameter, with one level
	 * of `/list` stripped, for procs which select one item from a list. The `[_]`
	 * may be repeated to strip more levels of `/list`.
	 */
	#define RETURN_TYPE(X) set SpacemanDMM_return_type = X
	/**
	 * If set, will enable a diagnostic on children of the proc it is set on which do
	 * not contain any `..()` parent calls. This can help with finding situations
	 * where a signal or other important handling in the parent proc is being skipped.
	 * Child procs may set this setting to `0` instead to override the check.
	 */
	#define SHOULD_CALL_PARENT(X) set SpacemanDMM_should_call_parent = X
	/**
	 * If set, raise a warning for any child procs that override this one,
	 * regardless of if it calls parent or not.
	 * This functions in a similar way to the `final` keyword in some languages.
	 * This cannot be disabled by child overrides.
	 */
	#define SHOULD_NOT_OVERRIDE(X) set SpacemanDMM_should_not_override = X
	/**
	 * If set, raise a warning if the proc or one of the sub-procs it calls
	 * uses a blocking call, such as `sleep()` or `input()` without using `set waitfor = 0`
	 * This cannot be disabled by child overrides.
	 */
	#define SHOULD_NOT_SLEEP(X) set SpacemanDMM_should_not_sleep = X
	/**
	 * If set, ensure a proc is 'pure', such that it does not make any changes
	 * outside itself or output. This also checks to make sure anything using
	 * this proc doesn't invoke it without making use of the return value.
	 * This cannot be disabled by child overrides.
	 */
	#define SHOULD_BE_PURE(X) set SpacemanDMM_should_be_pure = X
	///Private procs can only be called by things of exactly the same type.
	#define PRIVATE_PROC(X) set SpacemanDMM_private_proc = X
	///Protected procs can only be call by things of the same type *or subtypes*.
	#define PROTECTED_PROC(X) set SpacemanDMM_protected_proc = X
	///If set, will not lint.
	#define UNLINT(X) SpacemanDMM_unlint(X)

	///If set, overriding their value isn't permitted by types that inherit it.
	#define VAR_FINAL var/SpacemanDMM_final
	///Private vars can only be called by things of exactly the same type.
	#define VAR_PRIVATE var/SpacemanDMM_private
	///Protected vars can only be called by things of the same type *or subtypes*.
	#define VAR_PROTECTED var/SpacemanDMM_protected
#else
	#define RETURN_TYPE(X)
	#define SHOULD_CALL_PARENT(X)
	#define SHOULD_NOT_OVERRIDE(X)
	#define SHOULD_NOT_SLEEP(X)
	#define SHOULD_BE_PURE(X)
	#define PRIVATE_PROC(X)
	#define PROTECTED_PROC(X)
	#define UNLINT(X) X

	#define VAR_FINAL var
	#define VAR_PRIVATE var
	#define VAR_PROTECTED var
#endif
