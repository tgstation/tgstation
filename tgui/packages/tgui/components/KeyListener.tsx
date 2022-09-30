import { Component } from "inferno";
import { KeyEvent } from "../events";
import { listenForKeyEvents } from "../hotkeys";

type KeyListenerProps = Partial<{
  onKey: (key: KeyEvent) => void,
  onKeyDown: (key: KeyEvent) => void,
  onKeyUp: (key: KeyEvent) => void,
}>;

export class KeyListener extends Component<KeyListenerProps> {
  dispose: () => void;

  constructor() {
    super();

    this.dispose = listenForKeyEvents(key => {
      if (this.props.onKey) {
        this.props.onKey(key);
      }

      if (key.isDown() && this.props.onKeyDown) {
        this.props.onKeyDown(key);
      }

      if (key.isUp() && this.props.onKeyUp) {
        this.props.onKeyUp(key);
      }
    });
  }

  componentWillUnmount() {
    this.dispose();
  }

  render() {
    return null;
  }
}
