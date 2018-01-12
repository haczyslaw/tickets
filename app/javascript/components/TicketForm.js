import React from "react"
import PropTypes from "prop-types"

class TicketForm extends React.Component {
  constructor() {
    super();
    this.state = { subject: '', description: '' };
  }

  handleSubmit(e) {
    if ((e.charCode == 13) || (e.keyCode == 13)) {
      if ((this.state.subject !== '') && (this.state.description !== '')) {
        this.props.createTicket({ subject: this.state.subject, description: this.state.description });
      }
      this.setState({ subject: '', description: '' });
    }
  }

  handleChange(e) {
    if (e.target.dataset.typeOf === 'subject') this.setState({ subject: e.target.value });
    if (e.target.dataset.typeOf === 'description') this.setState({ description:  e.target.value });
  }

  render () {
    return (
      <div>
        <div>
        <label> Subject </label>
        <input value={this.state.subject} data-type-of='subject' onKeyPress={this.handleSubmit.bind(this)} onChange={this.handleChange.bind(this)} />
        </div>
        <br />
        <div>
          <label> Description </label>
          <textarea value={this.state.description} data-type-of='description' onKeyPress={this.handleSubmit.bind(this)} onChange={this.handleChange.bind(this)}>
          </textarea>
        </div>
      </div>
    );
  }
}

TicketForm.propTypes = {
  subject: PropTypes.string,
  description: PropTypes.string,
  createTicket: PropTypes.func
};

export default TicketForm
