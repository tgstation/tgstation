/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { shallowDiffers } from 'common/react';
import { Component, createRef } from 'react';
import { Button } from 'tgui/components';
import { chatRenderer } from './renderer';

export class ChatPanel extends Component {
  constructor(props) {
    super(props);
    this.ref = createRef();
    this.state = {
      scrollTracking: true,
    };
    this.handleScrollTrackingChange = (value) =>
      this.setState({
        scrollTracking: value,
      });
  }

  componentDidMount() {
    chatRenderer.mount(this.ref.current);
    chatRenderer.events.on(
      'scrollTrackingChanged',
      this.handleScrollTrackingChange,
    );
    this.componentDidUpdate();
  }

  componentWillUnmount() {
    chatRenderer.events.off(
      'scrollTrackingChanged',
      this.handleScrollTrackingChange,
    );
  }

  componentDidUpdate(prevProps) {
    requestAnimationFrame(() => {
      chatRenderer.ensureScrollTracking();
    });
    const shouldUpdateStyle =
      !prevProps || shallowDiffers(this.props, prevProps);
    if (shouldUpdateStyle) {
      chatRenderer.assignStyle({
        width: '100%',
        'white-space': 'pre-wrap',
        'font-size': this.props.fontSize,
        'line-height': this.props.lineHeight,
      });
    }
  }

  render() {
    const { scrollTracking } = this.state;
    return (
      <>
        <div className="Chat" ref={this.ref} />
        {!scrollTracking && (
          <Button
            className="Chat__scrollButton"
            icon="arrow-down"
            onClick={() => chatRenderer.scrollToBottom()}
          >
            Scroll to bottom
          </Button>
        )}
      </>
    );
  }
}
