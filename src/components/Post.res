module Post = {
  @react.component
  let make = (~post: Parser.rssPost) => {
    <div>
      <h2>{post.title->React.string}</h2>
      <div dangerouslySetInnerHTML={"__html": post.description} />
    </div>
  }
}