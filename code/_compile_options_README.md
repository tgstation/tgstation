You can create a file named "_dev_compile_options.dm" to make your own defines without worrying about commiting. Tick it before using. Be careful not to commit the file inclusion in .dme. It will fail compilation in your tests.

Example

#define TESTING
