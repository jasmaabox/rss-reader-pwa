exception BadFormat(string)

module Xml = {
  
  module NodeList = {
    type t<'u> = {
      "length": int
    }
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
  
  let parse = (text) => {
    let parser = DomParser.make()
    let rawParse = parser->DomParser.parseFromString(text, "text/xml")
    let rec convertToObject = (curr) => {
      if curr["childNodes"]["length"] === 0 {
        Leaf(curr["nodeName"], curr["data"])
      } else {
        Node(
          curr["nodeName"],
          curr["childNodes"]->NodeList.toArray
          ->Js.Array2.filter(v => v["nodeName"] !== "#comment")
          ->Js.Array2.filter(v => !(v["nodeName"] === "#text" && switch v["data"] {
            | Some(text) => Js.String.trim(text) === ""
            | None => false
            })
          )
          ->Js.Array2.map(convertToObject),
        )
      }
    }
    rawParse->convertToObject
  }
}

module Rss = {

  type content =
  | Text(string)
  | CData(string)

  let parseContent = (targetTag: string, nodes: array<Xml.t>) => {
    // Find node from list
    let res = Js.Array.find(node => {
      switch node {
      | Xml.Leaf(tag, _) => tag == targetTag
      | Xml.Node(tag, _) => tag == targetTag
      }
    }, nodes)
    switch res {
    | Some(childNode) =>
      // Get content
      switch childNode {
      | Xml.Node(_, data) =>
        if Array.length(data) > 0 {
          switch data[0] {
          | Xml.Leaf("#text", Some(data))
          | Xml.Leaf("#cdata-section", Some(data)) => data
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

  type post = {
    title: string,
    description: string,
    pubDate: string,
    link: string,
    guid: string,
  }

  let parsePosts = (nodes: array<Xml.t>) => {
    let itemNodes = Js.Array.filter(node => {
      switch node {
      | Xml.Leaf(tag, _) => tag == "item"
      | Xml.Node(tag, _) => tag == "item"
      }
    }, nodes)
    Js.Array2.map(itemNodes, node => {
      switch node {
      | Xml.Node("item", data) => {
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

  type feed = {
    title: string,
    link: string,
    description: string,
    posts: array<post>,
  }

  let parseFeed = (text: string) => {
    switch text->Xml.parse {
    | Xml.Node("#document", data) =>
      if Array.length(data) > 0 {
        switch data[0] {
        | Xml.Node("rss", data) =>
          if Array.length(data) > 0 {
            switch data[0] {
            | Xml.Node("channel", data) => {
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
}
