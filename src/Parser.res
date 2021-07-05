module NodeList = {
  type t<'u> = {
    "length": int
  }
  @val @scope("Array") external toArray: t<'u> => array<'u> = "from"
}

type rec xmlDocument = {
  "nodeName": string,
  "data": option<string>,
  "childNodes": NodeList.t<xmlDocument>,
}

module DomParser = {
  type t
  @new external make: unit => t = "DOMParser"
  @send external parseFromString: (t, string, string) => xmlDocument = "parseFromString"
}

type rec xmlTree = [
  | #leaf((string, option<string>))
  | #node((string, array<xmlTree>))
]

type content =
  | Text(string)
  | CData(string)

type rssPost = {
  title: string,
  description: string,
  pubDate: string,
  link: string,
  guid: string,
}

type rssFeed = {
  title: string,
  link: string,
  description: string,
  posts: array<rssPost>,
}

exception BadFormat(string)

let parseRawXML = (text) => {
  let parser = DomParser.make()
  let rawParse = parser->DomParser.parseFromString(text, "text/xml")
  let rec convertToObject = (curr) => {
    if curr["childNodes"]["length"] === 0 {
      #leaf((curr["nodeName"], curr["data"]))
    } else {
      #node((
        curr["nodeName"],
        curr["childNodes"]
        ->NodeList.toArray
        ->Js.Array2.filter(v => v["nodeName"] !== "#comment")
        ->Js.Array2.filter(v => !(v["nodeName"] === "#text" && switch v["data"] {
        | Some(text) => Js.String.trim(text) === ""
        | None => false
        }))
        ->Js.Array2.map(convertToObject)
      ))
    }
  }
  rawParse->convertToObject
}

let parseContent = (targetTag: string, nodes: array<xmlTree>) => {
  // Find node from list
  let res = Js.Array.find(node => {
    switch node {
    | #leaf((tag, _)) => tag == targetTag
    | #node((tag, _)) => tag == targetTag
    }
  }, nodes)
  switch res {
  | Some(childNode) =>
    // Get content
    switch childNode {
    | #node((_, data)) =>
      if Array.length(data) > 0 {
        switch data[0] {
        | #leaf(("#text", Some(data)))
        | #leaf(("#cdata-section", Some(data))) => data
        | _ => raise(BadFormat("content incorrectly structured"))
        }
      } else {
        raise(BadFormat("missing content child"))
      }
    | _ => raise(BadFormat("node has incorrect type"))
    }
  | None => raise(BadFormat("tag not found"))
  }
}

let parsePosts = (nodes: array<xmlTree>) => {
  let itemNodes = Js.Array.filter(node => {
    switch node {
    | #leaf((tag, _)) => tag == "item"
    | #node((tag, _)) => tag == "item"
    }
  }, nodes)
  Js.Array2.map(itemNodes, node => {
    switch node {
    | #node(("item", data)) => {
        title: parseContent("title", data),
        description: parseContent("description", data),
        pubDate: parseContent("pubDate", data),
        link: parseContent("link", data),
        guid: parseContent("guid", data),
      }
    | _ => raise(BadFormat("item has incorrect node type"))
    }
  })
}

let parseFeed = (text: string) => {
  switch text->parseRawXML {
  | #node(("#document", data)) =>
    if Array.length(data) > 0 {
      switch data[0] {
      | #node(("rss", data)) =>
        if Array.length(data) > 0 {
          switch data[0] {
          | #node(("channel", data)) => {
              title: parseContent("title", data),
              link: parseContent("link", data),
              description: parseContent("description", data),
              posts: parsePosts(data),
            }
          | _ => raise(BadFormat("missing channel tag"))
          }
        } else {
          raise(BadFormat("missing children in rss"))
        }
      | _ => raise(BadFormat("missing rss tag"))
      }
    } else {
      raise(BadFormat("missing children in #document"))
    }
  | _ => raise(BadFormat("missing #document tag"))
  }
}
