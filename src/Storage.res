@val @scope("JSON") external parseToUrls: string => array<string> = "parse"
@val @scope("JSON") external stringifyFromUrls: array<string> => string = "stringify"

let key = "feedURLs"

module StringCmp = Belt.Id.MakeComparable({
  type t = string
  let cmp = Pervasives.compare
})


let setFeedUrls = (urls) => {
  let rawUrls = urls->Belt.Set.toArray->stringifyFromUrls
  Dom.Storage2.setItem(Dom.Storage.localStorage, key, rawUrls)
}

let getFeedUrls = () => {
  let rawUrls = Dom.Storage.localStorage->Dom.Storage2.getItem(key)
  switch rawUrls {
  | Some(rawUrls) => rawUrls->parseToUrls->Belt.Set.fromArray(~id=module(StringCmp))
  | None =>
    let urls = Belt.Set.make(~id=module(StringCmp))
    setFeedUrls(urls)
    urls
  }
}