open PostCard

module Home = {
  @react.component
  let make = () => {

    let (text, setText) = React.useState(_ => "")
    let (posts, setPosts) = React.useState(_ => [])

    let onChange = evt => {
      let value = ReactEvent.Form.target(evt)["value"]
      setText(_prev => value)
    }

    let onSubmit = evt => {
      ReactEvent.Form.preventDefault(evt)
      switch Parser.parseFeed(text) {
      | feed => 
        Js.log(feed)
        setPosts(_prev => feed.posts)
      | exception Parser.BadFormat(msg) => Js.log(msg)
      }
    }

    <div>
      <h1> {"RSS Reader"->React.string} </h1>
      <form onSubmit>
        <textarea rows=20 cols=100 onChange></textarea><br />
        <input type_="submit" value="Render" />
      </form>

      {
        Array.map((post) => {
          <PostCard key=post.guid post=post />
        }, posts)->React.array
      }

    </div>
  }
}