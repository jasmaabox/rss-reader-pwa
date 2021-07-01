module PostCard = {
  @react.component
  let make = (~post: Parser.rssPost) => {
      <div className="card">
        <small>{post.pubDate->React.string}</small>
        <a href=post.link target="_blank"><h2>{post.title->React.string}</h2></a>
      </div>
  }
}