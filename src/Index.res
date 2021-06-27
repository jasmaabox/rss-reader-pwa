%%raw(`import './index.css';`)
open App
@module("./reportWebVitals") external reportWebVitals: unit => unit = "default"

switch ReactDOM.querySelector("#root") {
| None => ()
| Some(root) => ReactDOM.render(
    <React.StrictMode>
        <App />
    </React.StrictMode>,
    root,
)}

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
