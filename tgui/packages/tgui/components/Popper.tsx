import { createPopper } from '@popperjs/core';
import { ArgumentsOf } from 'common/types';
import { Component, createRef, JSXElementConstructor, PropsWithChildren, ReactElement, RefObject } from 'react';
import { render } from 'react-dom';

type PopperProps = {
  popperContent: ReactElement<any, string | JSXElementConstructor<any>>;
  options?: ArgumentsOf<typeof createPopper>[2];
  additionalStyles?: CSSProperties;
} & PropsWithChildren;

export class Popper extends Component<PopperProps> {
  static id: number = 0;
  popperRef: RefObject<HTMLDivElement>;

  renderedContent: HTMLDivElement;
  popperInstance: ReturnType<typeof createPopper>;

  constructor(props) {
    super(props);

    Popper.id += 1;
  }

  componentDidMount() {
    const { additionalStyles, options } = this.props;

    this.popperRef = createRef();

    this.renderedContent = document.createElement('div');

    if (additionalStyles) {
      for (const [attribute, value] of Object.entries(additionalStyles)) {
        this.renderedContent.style[attribute] = value;
      }
    }

    this.renderPopperContent(() => {
      document.body.appendChild(this.renderedContent);

      const domNode = this.popperRef.current;
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
    render(<> </>, this.renderedContent, () => {
      this.renderedContent.remove();
    });
  }

  renderPopperContent(callback: () => void) {
    // `render` errors when given false, so we convert it to `null`,
    // which is supported.
    render(this.props.popperContent, this.renderedContent, callback);
  }

  render() {
    return this.props.children;
  }
}
