import { shallowDiffers } from 'common/react';
import { Component, createRef } from 'inferno';
import { chatRenderer } from './renderer';

export class ChatPanel extends Component {
  constructor() {
    super();
    this.ref = createRef();
  }

  componentDidMount() {
    chatRenderer.mount(this.ref.current);
    this.componentDidUpdate();
  }

  shouldComponentUpdate(nextProps) {
    return shallowDiffers(this.props, nextProps);
  }

  componentDidUpdate() {
    chatRenderer.assignStyle({
      width: '100%',
      whiteSpace: 'pre-wrap',
      fontSize: this.props.fontSize,
      lineHeight: this.props.lineHeight,
    });
  }

  render() {
    return (
      <div ref={this.ref} />
    );
  }
}
