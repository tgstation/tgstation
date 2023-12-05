import { createPopper } from '@popperjs/core';
import { ArgumentsOf } from 'common/types';
import { Component, findDOMfromVNode, InfernoNode, render } from 'inferno';

type PopperProps = {
  popperContent: InfernoNode;
  options?: ArgumentsOf<typeof createPopper>[2];
  additionalStyles?: CSSProperties;
};

export class Popper extends Component<PopperProps> {
  static id: number = 0;

  renderedContent: HTMLDivElement;
  popperInstance: ReturnType<typeof createPopper>;

  constructor() {
    super();

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
      // of consumers, so we do the inferno equivalent of `findDOMNode(this)`.
      // This is usually bad as refs are usually better, but refs did
      // not work in this case, as they weren't propagating correctly.
      // A previous attempt was made as a render prop that passed an ID,
      // but this made consuming use too unwieldly.
      // This code is copied from `findDOMNode` in inferno-extras.
      // Because this component is written in TypeScript, we will know
      // immediately if this internal variable is removed.
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
