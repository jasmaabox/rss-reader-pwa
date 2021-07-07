// Generated by ReScript, PLEASE EDIT WITH CARE

import * as $$Array from "rescript/lib/es6/array.js";
import * as Curry from "rescript/lib/es6/curry.js";
import * as React from "react";
import * as Parser from "../Parser.bs.js";
import * as $$Storage from "../Storage.bs.js";
import * as Belt_Set from "rescript/lib/es6/belt_Set.js";
import * as PostCard from "../components/PostCard.bs.js";

function Home$Home(Props) {
  var match = React.useState(function () {
        return [];
      });
  var setPosts = match[1];
  var match$1 = React.useState(function () {
        return $$Storage.getFeedUrls(undefined);
      });
  var setFeedUrls = match$1[1];
  var feedUrls = match$1[0];
  var fetchPosts = function (url) {
    var corsProxyUrl = process.env.REACT_APP_CORS_PROXY_URL;
    if (corsProxyUrl !== undefined) {
      var rssUrl = new URL(corsProxyUrl);
      rssUrl.searchParams.set("targetURL", url);
      var __x = fetch(rssUrl.toString());
      var __x$1 = __x.then(function (res) {
            return res.text();
          });
      var __x$2 = __x$1.then(function (res) {
            var rss = Parser.Rss.parseFeed(res);
            return Promise.resolve(rss.posts);
          });
      return __x$2.catch(function (err) {
                  console.log(err);
                  return Promise.resolve([]);
                });
    }
    console.log("No cors proxy found.");
    return Promise.resolve([]);
  };
  React.useEffect((function () {
          var urls = Belt_Set.toArray(feedUrls).map(fetchPosts);
          var __x = Promise.all(urls);
          __x.then(function (res) {
                var allPosts = res.reduce((function (acc, posts) {
                        return acc.concat(posts);
                      }), []);
                Curry._1(setPosts, (function (_prev) {
                        return allPosts;
                      }));
                return Promise.resolve(undefined);
              });
          
        }), [feedUrls]);
  var onSubmit = function (evt) {
    evt.preventDefault();
    var url = evt.target["rss-url"].value;
    var updatedFeedUrls = Belt_Set.add(feedUrls, url);
    Curry._1(setFeedUrls, (function (param) {
            return updatedFeedUrls;
          }));
    return $$Storage.setFeedUrls(updatedFeedUrls);
  };
  return React.createElement("div", undefined, React.createElement("h1", undefined, "RSS Reader"), React.createElement("form", {
                  onSubmit: onSubmit
                }, React.createElement("input", {
                      name: "rss-url",
                      placeholder: "RSS Feed URL",
                      type: "text"
                    }), React.createElement("input", {
                      type: "submit",
                      value: "Add feed"
                    })), $$Array.map((function (post) {
                    return React.createElement(PostCard.PostCard.make, {
                                post: post,
                                key: post.guid
                              });
                  }), match[0]));
}

var Home = {
  make: Home$Home
};

export {
  Home ,
  
}
/* react Not a pure module */
