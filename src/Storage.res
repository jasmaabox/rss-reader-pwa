exception StorageError(string)

let key = "contentProviders"

module ContentProviderCmp = Belt.Id.MakeComparable({
  type t = ContentProvider.t
  let cmp = (a: ContentProvider.t, b: ContentProvider.t) => Pervasives.compare(a.feedUrl, b.feedUrl)
})

let setContentProviders = contentProviders => {
  let rawContentProviders = contentProviders->Belt.Set.toArray->Js.Json.stringifyAny
  switch rawContentProviders {
  | Some(rawContentProviders) =>
    Dom.Storage2.setItem(Dom.Storage.localStorage, key, rawContentProviders)
  | None => failwith("could not serialize content providers")
  }
}

let getContentProviders = () => {
  let rawContentProviders = Dom.Storage.localStorage->Dom.Storage2.getItem(key)
  switch rawContentProviders {
  | Some(rawContentProviders) =>
    let json = rawContentProviders->Js.Json.parseExn
    switch Js.Json.classify(json) {
    | Js.Json.JSONArray(contentProviders) =>
      Belt.Array.map(contentProviders, json => {
        switch Js.Json.classify(json) {
        | Js.Json.JSONObject(json) =>
          switch Js.Dict.get(json, "name") {
          | Some(name) =>
            switch Js.Json.classify(name) {
            | Js.Json.JSONString(name) =>
              switch Js.Dict.get(json, "feedUrl") {
              | Some(feedUrl) => switch Js.Json.classify(feedUrl) {
                | Js.Json.JSONString(feedUrl) =>
                  let contentProvider: ContentProvider.t = {name: name, feedUrl: feedUrl}
                  contentProvider
                | _ => failwith("invalid format")
                }
              | None => failwith("invalid format")
              }
            | _ => failwith("invalid format")
            }
          | None => failwith("invalid format")
          }
        | _ => failwith("invalid format")
        }
      })->Belt.Set.fromArray(~id=module(ContentProviderCmp))
    | _ =>
      let contentProviders = Belt.Set.make(~id=module(ContentProviderCmp))
      setContentProviders(contentProviders)
      contentProviders
    }
  | None =>
    let contentProviders = Belt.Set.make(~id=module(ContentProviderCmp))
    setContentProviders(contentProviders)
    contentProviders
  }
}
