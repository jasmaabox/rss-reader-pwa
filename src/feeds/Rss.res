exception BadFormat(string)

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
