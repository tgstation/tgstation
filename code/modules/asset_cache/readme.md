# Asset cache system

## Framework for managing browser assets (javascript,css,images,etc)

This manages getting the asset to the client without doing unneeded re-sends, as well as utilizing any configured cdns.

There are two frameworks for using this system:

### Asset datum:

Make a datum in asset_list_items.dm with your browser assets for your thing.

Checkout asset_list.dm for the helper subclasses

The `simple` subclass will most likely be of use for most cases.

Call get_asset_datum() with the type of the datum you created to get your asset cache datum

Call .send(client|usr) on that datum to send the asset to the client. Depending on the asset transport this may or may not block.

Call .get_url_mappings() to get an associated list with the urls your assets can be found at.

### Manual backend:

See the documentation for `/datum/asset_transport` for the backend api the asset datums utilize.

The global variable `SSassets.transport` contains the currently configured transport. 



### Notes:

Because byond browse() calls use non-blocking queues, if your code uses output() (which bypasses all of these queues) to invoke javascript functions you will need to first have the javascript announce to the server it has loaded before trying to invoke js functions.

To make your code work with any CDNs configured by the server, you must make sure assets are referenced from the url returned by `get_url_mappings()` or by asset_transport's `get_asset_url()`. (TGUI also has helpers for this.) If this can not be easily done, you can bypass the cdn using legacy assets, see the simple asset datum for details. 

CSS files that use url() can be made to use the CDN without needing to rewrite all url() calls in code by using the namespaced helper datum. See the documentation for `/datum/asset/simple/namespaced` for details.
