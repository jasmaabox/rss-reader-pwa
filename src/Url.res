module SearchParams = {
  type t

  @new external make: Js.Dict.t<string> => t = "URLSearchParams"
  @send external set: (t, string, string) => unit = "set"
  @send external get: (t, string) => Js.Nullable.t<string> = "get"
  @send external toString: t => string = "toString"
}

type t = {
  "searchParams": SearchParams.t,
}
@new external make: string => t = "URL"
@send external toString: t => string = "toString"