module NodeList = {
  type t<'u> = {"length": int}
  @val @scope("Array") external toArray: t<'u> => array<'u> = "from"
}

type rec rawDocument = {
  "nodeName": string,
  "data": option<string>,
  "childNodes": NodeList.t<rawDocument>,
}

module DomParser = {
  type t
  @new external make: unit => t = "DOMParser"
  @send external parseFromString: (t, string, string) => rawDocument = "parseFromString"
}

type rec t =
  | Leaf(string, option<string>)
  | Node(string, array<t>)

let parse = text => {
  let parser = DomParser.make()
  let rawParse = parser->DomParser.parseFromString(text, "text/xml")
  let rec convertToObject = curr => {
    if curr["childNodes"]["length"] === 0 {
      Leaf(curr["nodeName"], curr["data"])
    } else {
      Node(
        curr["nodeName"],
        curr["childNodes"]
        ->NodeList.toArray
        ->Js.Array2.filter(v => v["nodeName"] !== "#comment")
        ->Js.Array2.filter(v =>
          !(
            v["nodeName"] === "#text" &&
              switch v["data"] {
              | Some(text) => Js.String.trim(text) === ""
              | None => false
              }
          )
        )
        ->Js.Array2.map(convertToObject),
      )
    }
  }
  rawParse->convertToObject
}
