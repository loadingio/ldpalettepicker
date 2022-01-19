# ldPage

Pagination library.


# Usage

```
    mypal = new ldPage do
      fetch: ->
        ld$.fetch '...' , {}, {type: \json}
          .then -> return it
```

you can process fetched data directly in the fetch function:

```
    mypal = new ldPage do
      fetch: ->
        ld$.fetch '...' , {}, {type: \json}
          .then ->
            render(it)
            return it
```

see src/sample.ls.


## Configuration

 * host - scrolling host. for entire document, use `window`.
 * fetch-on-scroll - should ldPage fetch data when scrolling to the bottom of the host. default false.
 * fetch - custom function to fetch data according to ldPage's status.
   - use this.limit and this.offset to control the current position of fetch progress.
   - should return the list fetched for ldPage to count progress.
 * fetch-delay - delay before fetching when fetch is called.
 * enabled - default true. set to false to disable fetching by default until explicitly enabled with toggle(v),
 * boundary - default 0. if fetch-on-scroll, fetch is triggered only if remaining space for scrolling is smaller than `boundary`. larger `boundary` makes fetch triggered earlier.


## Method

 * reset(opt) - reset page. opt:
   - data - data for use in this bunch of fetch.
 * init(opt) - reset page. deprecated. ( use reset instead )
 * fetch - fetch data again.
 * isEnd - is there anything to fetch.
 * setHost(node) - set scrolling host. for entire document, use `window`.
 * toggle(v) - flip enabled/disabled statue. force set to v if v(true or false) is provided.


## Events

 * empty - fired when ldPage confirms that the list is empty.
 * finish - fired when ldPage confirms that all items are fetched.
 * fetch - fired when ldPage fetch a new list of data
 * scroll.fetch - fired when ldPage fetch a new list of data triggered by scrolling. can happen along with `fetch` event.
 * fetching - fired before fetch is called.

# License

MIT.
