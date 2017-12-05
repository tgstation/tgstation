(function(window, navigator) {
 
    var escaper = encodeURIComponent || escape;
 
    var triggerError = function(msg, url, line, col, error) {
        window.onerror(msg, url, line, col, error);
    };
 
    /**
     * Directs JS errors to a byond proc for logging
     *
     * @param string file Name of the logfile to dump errors in, do not prepend with data/
     * @param boolean overrideDefault True to prevent default JS errors (an big honking error prompt thing)
     * @return boolean
     */
    var attach = function(file, overrideDefault) {
        overrideDefault = typeof overrideDefault === 'undefined' ? false : overrideDefault;
        file = escaper(file);
 
        window.onerror = function(msg, url, line, col, error) {
            var extra = !col ? '' : ' | column: ' + col;
            extra += !error ? '' : ' | error: ' + error;
            extra += !navigator.userAgent ? '' : ' | user agent: ' + navigator.userAgent;
            var debugLine = 'Error: ' + msg + ' | url: ' + url + ' | line: ' + line + extra;
            window.location = '?action=debugFileOutput&file=' + file + '&message=' + escaper(debugLine);
            return overrideDefault;
        };
 
        return triggerError;
    };
 
    window.attachErrorHandler = attach;
 
}(window, window.navigator));