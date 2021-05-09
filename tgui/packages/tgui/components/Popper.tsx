import { createPopper, OptionsGeneric } from "@popperjs/core";
import { Component, createRef, Fragment, findDOMfromVNode, InfernoNode, RefObject, render } from "inferno";

type PopperProps = {
  popperContent?: InfernoNode;
  options?: Partial<OptionsGeneric<unknown>>;
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
    this.renderedContent = document.createElement("div");

    render(this.props.popperContent, this.renderedContent, () => {
      document.body.appendChild(this.renderedContent);

      this.popperInstance = createPopper(
        // HACK: We don't want to create a wrapper, as it could break the layout
        // of consumers, so we do the inferno equivalent of `findDOMNode(this)`.
        // This is usually bad as refs are usually better, but refs did
        // not work in this case, as they weren't propagating correctly.
        // A previous attempt was made as a render prop that passed an ID,
        // but this made consuming use too unwieldly.
        // This code is copied from `findDOMNode` in inferno-extras.
        findDOMfromVNode(this.$LI, true),
        this.renderedContent,
        this.props.options,
      );
    });
  }

  componentDidUpdate() {
    this.popperInstance?.update();
  }

  componentWillUnmount() {
    this.popperInstance?.destroy();
    this.renderedContent.remove();
    this.renderedContent = null;
  }

  render() {
    return this.props.children;
  }
}
