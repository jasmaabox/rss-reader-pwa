open PostCard

module Home = {
  @react.component
  let make = () => {
    let (posts, setPosts) = React.useState(_ => [])
    let (contentProviders, setContentProviders) = React.useState(_ => Storage.getContentProviders())
    let (name, setName) = React.useState(_ => "")
    let (feedUrl, setFeedUrl) = React.useState(_ => "")

    let onChangeName = evt => {
      let value = ReactEvent.Form.currentTarget(evt)["value"]
      setName(_ => value)
    }
    let onChangeFeedUrl = evt => {
      let value = ReactEvent.Form.currentTarget(evt)["value"]
      setFeedUrl(_ => value)
    }

    let fetchPosts = url => {
      switch Env.corsProxyUrl {
      | Some(corsProxyUrl) =>
        let rssUrl = Url.make(corsProxyUrl)
        rssUrl["searchParams"]->Url.SearchParams.set("targetURL", url)
        Http.fetch1(rssUrl->Url.toString)
        ->Js.Promise.then_(
          res => {
            res->Http.Response.text
          },
          // Get response text
          _,
        )
        ->Js.Promise.then_(
          res => {
            let rss = Rss.parseFeed(res)
            Js.Promise.resolve(rss.posts)
          },
          // Set posts
          _,
        )
        ->Js.Promise.catch(
          err => {
            Js.log(err)
            Js.Promise.resolve([])
          },
          // TEMP: log errors for now
          _,
        )
      | None =>
        Js.log("No cors proxy found.")
        Js.Promise.resolve([])
      }
    }

    React.useEffect1(() => {
      let urls =
        contentProviders
        ->Belt.Set.toArray
        ->Js.Array2.map(contentProvider => contentProvider.feedUrl)
        ->Js.Array2.map(fetchPosts)
      let _ = Js.Promise.all(urls)->Js.Promise.then_(
        res => {
          let allPosts = res->Js.Array2.reduce((acc, posts) => Js.Array2.concat(acc, posts), [])
          setPosts(_prev => allPosts)
          Js.Promise.resolve()
        },
        // TODO: sort by date
        _,
      )
      None
    }, [contentProviders])

    let onAddContentProvider = evt => {
      ReactEvent.Form.preventDefault(evt)
      let provider: ContentProvider.t = {name: name, feedUrl: feedUrl}
      setName(_ => "")
      setFeedUrl(_ => "")

      let updatedContentProviders = contentProviders->Belt.Set.add(provider)
      setContentProviders(_ => updatedContentProviders)
      Storage.setContentProviders(updatedContentProviders)
    }

    <div>
      <h1> {"RSS Reader"->React.string} </h1>
      <form onSubmit={onAddContentProvider}>
        <input
          type_="text" name="name" placeholder="RSS Feed Name" value={name} onChange={onChangeName}
        />
        <input
          type_="text"
          name="feed-url"
          placeholder="RSS Feed URL"
          value={feedUrl}
          onChange={onChangeFeedUrl}
        />
        <input type_="submit" value="Add feed" />
      </form>
      {Array.map(post => {
        <PostCard key=post.guid post />
      }, posts)->React.array}
    </div>
  }
}
