%%raw(`import './App.css';`)
@module("./logo.svg") external logo:string = "default"

module App = {
  @react.component
  let make = () => {
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          {"Edit "->React.string}<code>{"src/App.js"->React.string}</code>{" and save to reload."->React.string}
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          {"Learn React"->React.string}
        </a>
      </header>
    </div>
  }
}