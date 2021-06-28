%%raw(`import './App.css';`)
@module("./logo.svg") external logo: string = "default"
open Home

module App = {
  @react.component
  let make = () => {
    <Home />
  }
}
