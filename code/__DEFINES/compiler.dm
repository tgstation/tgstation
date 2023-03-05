/// Marks the given variable as potentially unused, silencing lints from the compiler.
/// Compiles out completely.
// #define SUPPRESS_UNUSED(name) if (UNLINT(FALSE)) { pass(name) }
#define SUPPRESS_UNUSED(name)
