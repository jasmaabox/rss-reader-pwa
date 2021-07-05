open PostCard

module Home = {

  @react.component
  let make = () => {

    let (posts, setPosts) = React.useState(_ => [])

    let onSubmit = evt => {
      ReactEvent.Form.preventDefault(evt)

      switch Env.corsProxyUrl {
      | Some(corsProxyUrl) =>
        let rssUrl = Url.make(corsProxyUrl)
        rssUrl["searchParams"]->Url.SearchParams.set(
          "targetURL",
          ReactEvent.Form.target(evt)["rss-url"]["value"],
        )

        let _ = Http.fetch1(rssUrl->Url.toString)->Js.Promise.then_(res => {
          // Get response text
          res->Http.Response.text
        }, _)->Js.Promise.then_(res => {
          // Set posts
          let rss = Parser.Rss.parseFeed(res)
          setPosts(_prev => rss.posts)
          Js.Promise.resolve(())
        }, _)->Js.Promise.catch(err => {
          // TEMP: log errors for now
          Js.log(err)
          Js.Promise.resolve(())
        }, _)
      | None =>
        Js.log("No cors proxy found.")
      }
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
