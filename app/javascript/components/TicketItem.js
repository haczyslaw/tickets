import React from "react"
import PropTypes from "prop-types"

class TicketItem extends React.Component {
  render () {
    return (
      <div>
        <div>Subject: {this.props.subject}</div>
        <div>Description: {this.props.description}</div>
      </div>
    );
  }
}

TicketItem.propTypes = {
  subject: PropTypes.string,
  description: PropTypes.string
};

export default TicketItem
