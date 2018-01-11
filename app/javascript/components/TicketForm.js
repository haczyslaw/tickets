import React from "react"
import PropTypes from "prop-types"

class TicketForm extends React.Component {
  constructor() {
    super();
    this.state = { title: '', body: '' };
  }

  handleSubmit(e) {
    if ((e.charCode == 13) || (e.keyCode == 13)) {
      if ((this.state.title !== '') && (this.state.body !== '')) {
        this.props.createTicket({ title: this.state.title, body: this.state.body });
      }
      this.setState({ title: '', body: '' });
    }
  }

  handleChange(e) {
    if (e.target.dataset.typeOf === 'title') this.setState({ title: e.target.value });
    if (e.target.dataset.typeOf === 'body') this.setState({ body:  e.target.value });
  }

  render () {
    return (
      <div>
        <label> Title </label>
        <input value={this.state.title} data-type-of='title' onKeyPress={this.handleSubmit.bind(this)} onChange={this.handleChange.bind(this)} />
        <label> Body </label>
        <input value={this.state.body} data-type-of='body' onKeyPress={this.handleSubmit.bind(this)} onChange={this.handleChange.bind(this)} />
      </div>
    );
  }
}

TicketForm.propTypes = {
  title: PropTypes.string,
  body: PropTypes.string,
  createTicket: PropTypes.func
};

export default TicketForm
