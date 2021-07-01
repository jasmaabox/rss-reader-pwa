// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Caml_array from "rescript/lib/es6/caml_array.js";
import * as ParserHelper from "./parserHelper";
import * as Caml_exceptions from "rescript/lib/es6/caml_exceptions.js";

var BadFormat = /* @__PURE__ */Caml_exceptions.create("Parser.BadFormat");

function parseRawXML(prim) {
  return ParserHelper.parseRawXML(prim);
}

function parseContent(targetTag, nodes) {
  var res = nodes.find(function (node) {
        return node.VAL[0] === targetTag;
      });
  if (res !== undefined) {
    if (typeof res === "object") {
      if (res.NAME === "node") {
        var data = res.VAL[1];
        if (data.length !== 0) {
          var match = Caml_array.get(data, 0);
          if (typeof match === "object") {
            if (match.NAME === "leaf") {
              var match$1 = match.VAL;
              switch (match$1[0]) {
                case "#cdata-section" :
                case "#text" :
                    return match$1[1];
                default:
                  throw {
                        RE_EXN_ID: BadFormat,
                        _1: "content incorrectly structured",
                        Error: new Error()
                      };
              }
            } else {
              throw {
                    RE_EXN_ID: BadFormat,
                    _1: "content incorrectly structured",
                    Error: new Error()
                  };
            }
          } else {
            throw {
                  RE_EXN_ID: BadFormat,
                  _1: "content incorrectly structured",
                  Error: new Error()
                };
          }
        } else {
          throw {
                RE_EXN_ID: BadFormat,
                _1: "missing content child",
                Error: new Error()
              };
        }
      } else {
        throw {
              RE_EXN_ID: BadFormat,
              _1: "node has incorrect type",
              Error: new Error()
            };
      }
    } else {
      throw {
            RE_EXN_ID: BadFormat,
            _1: "node has incorrect type",
            Error: new Error()
          };
    }
  } else {
    throw {
          RE_EXN_ID: BadFormat,
          _1: "tag not found",
          Error: new Error()
        };
  }
}

function parsePosts(nodes) {
  var itemNodes = nodes.filter(function (node) {
        return node.VAL[0] === "item";
      });
  return itemNodes.map(function (node) {
              if (typeof node === "object") {
                if (node.NAME === "node") {
                  var match = node.VAL;
                  if (match[0] === "item") {
                    var data = match[1];
                    return {
                            title: parseContent("title", data),
                            description: parseContent("description", data),
                            pubDate: parseContent("pubDate", data),
                            link: parseContent("link", data),
                            guid: parseContent("guid", data)
                          };
                  }
                  throw {
                        RE_EXN_ID: BadFormat,
                        _1: "item has incorrect node type",
                        Error: new Error()
                      };
                }
                throw {
                      RE_EXN_ID: BadFormat,
                      _1: "item has incorrect node type",
                      Error: new Error()
                    };
              }
              throw {
                    RE_EXN_ID: BadFormat,
                    _1: "item has incorrect node type",
                    Error: new Error()
                  };
            });
}

function parseFeed(text) {
  var match = ParserHelper.parseRawXML(text);
  if (typeof match === "object") {
    if (match.NAME === "node") {
      var match$1 = match.VAL;
      if (match$1[0] === "#document") {
        var data = match$1[1];
        if (data.length !== 0) {
          var match$2 = Caml_array.get(data, 0);
          if (typeof match$2 === "object") {
            if (match$2.NAME === "node") {
              var match$3 = match$2.VAL;
              if (match$3[0] === "rss") {
                var data$1 = match$3[1];
                if (data$1.length !== 0) {
                  var match$4 = Caml_array.get(data$1, 0);
                  if (typeof match$4 === "object") {
                    if (match$4.NAME === "node") {
                      var match$5 = match$4.VAL;
                      if (match$5[0] === "channel") {
                        var data$2 = match$5[1];
                        return {
                                title: parseContent("title", data$2),
                                link: parseContent("link", data$2),
                                description: parseContent("description", data$2),
                                posts: parsePosts(data$2)
                              };
                      }
                      throw {
                            RE_EXN_ID: BadFormat,
                            _1: "missing channel tag",
                            Error: new Error()
                          };
                    }
                    throw {
                          RE_EXN_ID: BadFormat,
                          _1: "missing channel tag",
                          Error: new Error()
                        };
                  }
                  throw {
                        RE_EXN_ID: BadFormat,
                        _1: "missing channel tag",
                        Error: new Error()
                      };
                }
                throw {
                      RE_EXN_ID: BadFormat,
                      _1: "missing children in rss",
                      Error: new Error()
                    };
              }
              throw {
                    RE_EXN_ID: BadFormat,
                    _1: "missing rss tag",
                    Error: new Error()
                  };
            }
            throw {
                  RE_EXN_ID: BadFormat,
                  _1: "missing rss tag",
                  Error: new Error()
                };
          }
          throw {
                RE_EXN_ID: BadFormat,
                _1: "missing rss tag",
                Error: new Error()
              };
        }
        throw {
              RE_EXN_ID: BadFormat,
              _1: "missing children in #document",
              Error: new Error()
            };
      }
      throw {
            RE_EXN_ID: BadFormat,
            _1: "missing #document tag",
            Error: new Error()
          };
    }
    throw {
          RE_EXN_ID: BadFormat,
          _1: "missing #document tag",
          Error: new Error()
        };
  }
  throw {
        RE_EXN_ID: BadFormat,
        _1: "missing #document tag",
        Error: new Error()
      };
}

export {
  BadFormat ,
  parseRawXML ,
  parseContent ,
  parsePosts ,
  parseFeed ,
  
}
/* ./parserHelper Not a pure module */
