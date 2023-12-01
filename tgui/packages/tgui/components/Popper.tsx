import { createPopper } from '@popperjs/core';
import { ArgumentsOf } from 'common/types';
import { Component, CSSProperties, JSXElementConstructor, PropsWithChildren, ReactElement, RefObject } from 'react';
import { findDOMNode, render } from 'react-dom';

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

    this.renderedContent = document.createElement('div');

    if (additionalStyles) {
      for (const [attribute, value] of Object.entries(additionalStyles)) {
        this.renderedContent.style[attribute] = value;
      }
    }

    this.renderPopperContent(() => {
      document.body.appendChild(this.renderedContent);

      // HACK: We don't want to create a wrapper, as it could break the layout
      // of consumers, so we use findDOMNode.
      // This is usually bad as refs are usually better, but refs did
      // not work in this case, as they weren't propagating correctly.
      // A previous attempt was made as a render prop that passed an ID,
      // but this made consuming use too unwieldly.
      // Because this component is written in TypeScript, we will know
      // immediately if this internal variable is removed.
      //
      // eslint-disable-next-line react/no-find-dom-node
      const domNode = findDOMNode(this) as Element;
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
    render(this.props.popperContent || null, this.renderedContent, callback);
  }

  render() {
    return this.props.children;
  }
}
