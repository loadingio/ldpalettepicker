# @loadingio/paginate

Fetching data with paging functionality supported:

 - keep pagination state ( `limit` & `offset` )
 - auto fetching on scrolling or event
 - stop fetching on end of data ( returned length < limit )


# Usage

install dependencies (`proxise` and `@loadingio/debounce.js`) and `@loadingio/paginate` via npm:

    npm install @loadingio/paginate proxise @loadingio/debounce.js

and include them in HTML:

    <script src="path-to/debounce.js/index.min.js"></script>
    <script src="path-to/proxise/index.min.js"></script>
    <script src="path-to/paginate/index.min.js"></script>


create a paginate object:

    mypal = new paginate({
      fetch: -> ld$.fetch '...' , {}, {type: \json}
    })


you can process fetched data directly in the fetch function:

    mypal = new paginate do
      fetch: ->
        ld$.fetch '...' , {}, {type: \json}
          .then ->
            render(it)
            return it /* should return the fetched list */


see also `sample/index.ls`.


## Constructor Options

 - `limit`: default 20. maximal count return per fetch
 - `offset`: default 0. offset for fetch to start
 - `host`: container that scrolls. default `document.scrollingElement`.
 - `pivot`: element for determining if we should scroll. omitted if not provided.
   - when provided, `intersectionObserver` is used
 - `scrollDelay`: default 100. debounce time (ms) before fetching after scrolled.
 - `fetchDelay`: default 200. debounce time (ms) before fetching when fetch is called.
 - `fetchOnScroll`: default false. when true, fetch when scrolling to the bottom of `host`.
   - only applicable if `host` is provided
 - `fetchOnInit`: default false. should a fetch be called after init. possible values:
   - `always`: fetch after both `init` and `reset`
   - `once`:  fetch only after `init`
   - `lazy`: fetch when visibility of `host` is changed to visible, and `offset` = 0
   - false: never fetch on init
 - `boundary`: threshold of the distance to `host` bottom to trigger fetch.
   - default 5. rounding may lead to extra px uncounted so a small default value 5 is used here.
   - omitted if `fetchOnScroll` is false.
   - larger `boundary` makes fetch triggered earlier.
 - `fetch`: required custom function to fetch data according to `@loadingio/paginate`'s status.
   - when called, - use `this.limit` and `this.offset` for current position of fetch progress.
   - should return an Array. `@loadingio/paginate` use it to update `this.offset` and count progress.
 - `enabled`: default true. when false, fetch won't start until re-enabled by `toggle(v)`.


## Method

 - `reset()`: reset page.
 - `fetch()`: fetch data again.
 - `isEnd()`: is there anything to fetch.
 - `host(node)`: set scrolling host. use document.scrollingElement for the webpage itself.
 - `host(pivot)`: set pivot element ( for detecting refreshing )
 - `toggle(v)`: flip enabled/disabled statue. force set to v if v(true or false) is provided.


## Events

 - `empty`: fired when `@loadingio/paginate` confirms that the list is empty.
 - `finish`: fired when `@loadingio/paginate` confirms that all items are fetched.
 - `fetch`: fired when `@loadingio/paginate` fetch a new list of data
 - `scroll.fetch`: fired when `@loadingio/paginate` fetch a new list of data triggered by scrolling.
   - can happen along with `fetch` event.
 - `fetching`: fired before fetch is called.


## Auto Fetching Policy

You can decide when to fetch data by yourself but `@loadingio/pagination` still provides some handy mechanism to watch for scrolling or intersection events for you with following 2 options:

 - `fetchOnScroll`: when set to true, this triggers fetch when
   - `pivot` becomes visible ( if pivot is provided )
   - user scrolls to the bottom of `host` element ( if pivot is not provided )
     - this relies on `scroll` event and related attribues such as `scrollTop` thus is less efficient.
 - `fetchOnInit`: this defines how fetch should be done initially.
   - `always`: fetch called after paginate object constructed and reset everytime.
   - `once`: fetch called only after paginate object constructed.
   - `lazy`: fetch called only if offset = 0 and `host` becomes visible.
   - false: no fetch for initialization.

These are handy however may introduce inconsistency and confusion. Set both of them to `false` if you'd like to control how fetching is done manually.


# License

MIT
