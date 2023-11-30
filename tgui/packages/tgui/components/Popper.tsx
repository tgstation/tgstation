import { createPopper } from '@popperjs/core';
import { ArgumentsOf } from 'common/types';
import { Component, PropsWithChildren, ReactNode } from 'react';

type PopperProps = {
  popperContent: ReactNode;
  options?: ArgumentsOf<typeof createPopper>[2];
  additionalStyles?: CSSProperties;
} & PropsWithChildren;

export class Popper extends Component<PopperProps> {
  static id: number = 0;

  renderedContent: HTMLDivElement;
  popperInstance: ReturnType<typeof createPopper>;

  constructor(props) {
    super(props);

    Popper.id += 1;
  }

  componentDidMount() {
    const { additionalStyles, options } = this.props;

    this.renderedContent = document.createElement('div');

    if (additionalStyles) {
      for (const [attribute, value] of Object.entries(additionalStyles)) {
        this.renderedContent.style[attribute] = value;
      }
    }

    this.renderPopperContent(() => {
      document.body.appendChild(this.renderedContent);

      const domNode = findDOMfromVNode(this.$LI, true);
      if (!domNode) {
        return;
      }

      this.popperInstance = createPopper(
        domNode,
        this.renderedContent,
        options
      );
    });
  }

  componentDidUpdate() {
    this.renderPopperContent(() => this.popperInstance?.update());
  }

  componentWillUnmount() {
    this.popperInstance?.destroy();
    render(null, this.renderedContent, () => {
      this.renderedContent.remove();
    });
  }

  renderPopperContent(callback: () => void) {
    // `render` errors when given false, so we convert it to `null`,
    // which is supported.
    render(this.props.popperContent || null, this.renderedContent, callback);
  }

  render() {
    return this.props.children;
  }
}
