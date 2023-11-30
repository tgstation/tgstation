import { Component, createRef, PropsWithChildren } from 'react';

export class Autofocus extends Component<PropsWithChildren> {
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
