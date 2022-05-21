import { Component } from 'inferno';
import { recallWindowGeometry } from 'tgui/drag';
import { Layout } from 'tgui/layouts/Layout';

const DEFAULT_SIZE = [300, 200];

export class Modal extends Component {
  componentDidMount() {
    recallWindowGeometry({ size: DEFAULT_SIZE });
  }

  render() {
    const {
      theme,
      children,
    } = this.props;
    return (
      <Layout
        className="Window"
        theme={theme}>
        <TitleBar title={title} />
        <div
          className="Window__rest">
          {children}
        </div>
      </Layout>
    );
  }
}

const WindowContent = props => {
  const {
    className,
    fitted,
    children,
    ...rest
  } = props;
  return (
    <Layout.Content
      className="Window__content"
      {...rest}>
      {fitted && children || (
        <div className="Window__contentPadding">
          {children}
        </div>
      )}
    </Layout.Content>
  );
};

Window.Content = WindowContent;

const TitleBar = (props) => {
  const {
    title,
    onClose,
    children,
  } = props;
  return (
    <div
      className="TitleBar">
      <div className="TitleBar__title">
        {typeof title === 'string'
          && title === title.toLowerCase()}
        {!!children && (
          <div className="TitleBar__buttons">
            {children}
          </div>
        )}
      </div>
      <div
        className="TitleBar__close TitleBar__clickable"
        // IE8: Synthetic onClick event doesn't work on IE8.
        // IE8: Use a plain character instead of a unicode symbol.
        // eslint-disable-next-line react/no-unknown-property
        onclick={onClose}>
        {Byond.IS_LTE_IE8 ? 'x' : '×'}
      </div>
    </div>
  );
};
