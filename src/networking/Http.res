module Response = {
  type t
  @send external text: t => Js.Promise.t<string> = "text"
}

type body

type abortController

type fetchOptions = {
  "method": option<string>,
  "headers": option<Js.Dict.t<string>>,
  "body": option<body>,
  "referrer": option<string>,
  "referrerPolicy": option<string>,
  "mode": option<string>,
  "credentials": option<string>,
  "cache": option<string>,
  "redirect": option<string>,
  "integrity": option<string>,
  "keepalive": option<bool>,
  "signal": option<abortController>,
}
let makeFetchOptions = (
  ~method=?,
  ~headers=?,
  ~body=?,
  ~referrer=?,
  ~referrerPolicy=?,
  ~mode=?,
  ~credentials=?,
  ~cache=?,
  ~redirect=?,
  ~integrity=?,
  ~keepalive=?,
  ~signal=?,
  ()
) =>
  {
    "method": method,
    "headers": headers,
    "body": body,
    "referrer": referrer,
    "referrerPolicy": referrerPolicy,
    "mode": mode,
    "credentials": credentials,
    "cache": cache,
    "redirect": redirect,
    "integrity": integrity,
    "keepalive": keepalive,
    "signal": signal,
  }

@val external fetch1: string => Js.Promise.t<Response.t> = "fetch"
@val external fetch2: (string, fetchOptions) => Js.Promise.t<Response.t> = "fetch"
