import { Component, createRef } from "inferno";

export class Autofocus extends Component {
  ref = createRef<HTMLDivElement>();

  componentDidMount() {
    setTimeout(() => {
      this.ref.current?.focus();
    }, 1);
  }

  render() {
    return (
      <div ref={this.ref} tabIndex={-1}>
        {this.props.children}
      </div>
    );
  }
}
