// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Curry from "rescript/lib/es6/curry.js";
import * as React from "react";
import * as Parser from "./Parser.bs.js";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";

function Home$Home(Props) {
  var match = React.useState(function () {
        return "";
      });
  var setText = match[1];
  var text = match[0];
  var onChange = function (evt) {
    var value = evt.target.value;
    return Curry._1(setText, (function (_prev) {
                  return value;
                }));
  };
  var onSubmit = function (evt) {
    evt.preventDefault();
    var feed;
    try {
      feed = Parser.parseFeed(text);
    }
    catch (raw_msg){
      var msg = Caml_js_exceptions.internalToOCamlException(raw_msg);
      if (msg.RE_EXN_ID === Parser.BadFormat) {
        console.log(msg._1);
        return ;
      }
      throw msg;
    }
    console.log(feed);
    
  };
  return React.createElement("div", undefined, React.createElement("h1", undefined, "RSS Reader"), React.createElement("form", {
                  onSubmit: onSubmit
                }, React.createElement("textarea", {
                      cols: 100,
                      rows: 20,
                      onChange: onChange
                    }), React.createElement("br", undefined), React.createElement("input", {
                      type: "submit",
                      value: "Render"
                    })));
}

var Home = {
  make: Home$Home
};

export {
  Home ,
  
}
/* react Not a pure module */
