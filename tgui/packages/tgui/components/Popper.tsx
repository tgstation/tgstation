import { createPopper, OptionsGeneric } from "@popperjs/core";
import { Component, InfernoNode, render } from "inferno";

type PopperProps = {
  popperContent?: InfernoNode;
  options?: OptionsGeneric<unknown>;
  render: (id: string) => InfernoNode;
};

export class Popper extends Component<PopperProps> {
  static id: number = 0;

  content: Element;
  ourId: string;
  renderedContent: HTMLDivElement;
  popperInstance: ReturnType<typeof createPopper>;

  constructor() {
    super();

    Popper.id += 1;
    this.ourId = `Popper-${Popper.id}`;
  }

  componentDidMount() {
    this.content = document.getElementById(this.ourId);

    this.renderedContent = document.createElement("div");

    render(this.props.popperContent, this.renderedContent, () => {
      document.body.appendChild(this.renderedContent);

      this.popperInstance = createPopper(
        this.content,
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
    // Creating a new element and getting the ref of that breaks layouts.
    // Creating a ref and passing it down doesn't propagate, and requires
    // children be function components.
    // So you know what? Fuck it, everyone gets a god damn ID.
    return this.props.render(this.ourId);
  }
}
