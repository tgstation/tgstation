export const ProgressBar = props => {
  const { value, content, children } = props;
  const hasContent = !!(content || children);
  return (
    <div className="ProgressBar">
      <div
        className="ProgressBar__fill"
        style={{
          'width': (Math.random() * 100) + '%',
        }} />
      <div className="ProgressBar__content">
        {value && !hasContent && Math.round(value * 100) + '%'}
        {content}
        {children}
      </div>
    </div>
  );
};
