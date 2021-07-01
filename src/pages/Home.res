open PostCard

module Home = {

  type httpResponse
  @val external fetch: string => Js.Promise.t<httpResponse> = "fetch"
  @send external text: httpResponse => Js.Promise.t<string> = "text"

  @react.component
  let make = () => {

    let (posts, setPosts) = React.useState(_ => [])

    let onSubmit = evt => {
      ReactEvent.Form.preventDefault(evt)

      let rssUrl = ReactEvent.Form.target(evt)["rss-url"]["value"]
      // TODO: attach cors proxy to fetch
      let _ = fetch(rssUrl)->Js.Promise.then_(res => {
        // Get response text
        text(res)
      }, _)->Js.Promise.then_(res => {
        // Set posts
        let rss = Parser.parseFeed(res)
        setPosts(_prev => rss.posts)
        Js.Promise.resolve(())
      }, _)->Js.Promise.catch(err => {
        // TEMP: log errors for now
        Js.log(err)
        Js.Promise.resolve(())
      }, _)
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
