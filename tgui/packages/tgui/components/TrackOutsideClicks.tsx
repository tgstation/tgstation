import { Component, createRef } from "inferno";

export class TrackOutsideClicks extends Component<{
  onOutsideClick: () => void,
}> {
  ref = createRef<HTMLDivElement>();

  constructor() {
    super();

    this.handleOutsideClick = this.handleOutsideClick.bind(this);

    document.addEventListener("click", this.handleOutsideClick);
  }

  componentWillUnmount() {
    document.removeEventListener("click", this.handleOutsideClick);
  }

  handleOutsideClick(event: MouseEvent) {
    if (!(event.target instanceof Node)) {
      return;
    }

    if (this.ref.current && !this.ref.current.contains(event.target)) {
      this.props.onOutsideClick();
    }
  }

  render() {
    return (
      <div ref={this.ref}>
        {this.props.children}
      </div>
    );
  }
}

