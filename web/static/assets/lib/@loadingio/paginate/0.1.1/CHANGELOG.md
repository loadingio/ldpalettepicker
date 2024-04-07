# Change Logs

## v0.1.1

 - audit fix to fix dependencies vulnerability
 - fix bug: `res` is not defined in `_fetch`


## v0.1.0

 - rename module to `@loadingio/paginate`. export `paginate` instead of `ldpage`
 - upgrade dependencies to fix vulnerabilities
 - refactoring with concise configs and simpler APIs.
   - `init` removed
   - internal vairables prefixed with `_`
   - rename `setHost` to `host`
 - support debounce based on `@loadingio/debounce.js`
 - blocking `reset` by `fetch` based on `proxise`
 - add `fetchOnInit` option
 - update documentation


## v0.0.4

 - rename `ldPage` to `ldpage`
 - rename `ldpage.js`, `ldpage.min.js` to `index.js` and `index.min.js`
 - upgrade modules
 - release with compact directory structure
 - add `main` and `browser` field in `package.json`.
 - further minimize generated js file with mangling and compression
 - remove assets files from git
 - patch test code to make it work with upgraded modules


## v0.0.3

 - fix bug: end should be set before finish event is fired.


## v0.0.2

 - rename `init` to `reset`, while keeping `init` for backward compatibility.
