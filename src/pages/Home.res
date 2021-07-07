open PostCard

module Home = {

  @react.component
  let make = () => {

    let (posts, setPosts) = React.useState(_ => [])
    let (feedUrls, setFeedUrls) = React.useState(_ => Storage.getFeedUrls())

    let fetchPosts = (url) => {
      switch Env.corsProxyUrl {
      | Some(corsProxyUrl) =>
        let rssUrl = Url.make(corsProxyUrl)
        rssUrl["searchParams"]->Url.SearchParams.set("targetURL", url)

        Http.fetch1(rssUrl->Url.toString)->Js.Promise.then_(res => {
          // Get response text
          res->Http.Response.text
        }, _)->Js.Promise.then_(res => {
          // Set posts
          let rss = Parser.Rss.parseFeed(res)
          Js.Promise.resolve(rss.posts)
        }, _)->Js.Promise.catch(err => {
          // TEMP: log errors for now
          Js.log(err)
          Js.Promise.resolve([])
        }, _)
      | None =>
        Js.log("No cors proxy found.")
        Js.Promise.resolve([])
      }
    }

    React.useEffect1(() => {
      let urls = feedUrls->Belt.Set.toArray->Js.Array2.map(fetchPosts)
      let _ = Js.Promise.all(urls)->Js.Promise.then_(res => {
        let allPosts = res->Js.Array2.reduce((acc, posts) => Js.Array2.concat(acc, posts), [])
        // TODO: sort by date
        setPosts(_prev => allPosts)
        Js.Promise.resolve(())
      }, _)
      None
    }, [feedUrls])

    let onSubmit = evt => {
      ReactEvent.Form.preventDefault(evt)
      let url = ReactEvent.Form.target(evt)["rss-url"]["value"]

      let updatedFeedUrls = feedUrls->Belt.Set.add(url)
      setFeedUrls(_ => updatedFeedUrls)
      Storage.setFeedUrls(updatedFeedUrls)
    }

    <div>
      <h1> {"RSS Reader"->React.string} </h1>
      <form onSubmit>
        <input type_="text" name="rss-url" placeholder="RSS Feed URL" />
        <input type_="submit" value="Add feed" />
      </form>
      {
        Array.map((post) => {
          <PostCard key=post.guid post=post />
        }, posts)->React.array
      }
    </div>
  }
}
