import React from "react"
import PropTypes from "prop-types"
import axios from "axios"
import TicketItem from "./TicketItem"
import TicketForm from "./TicketForm"

class Layout extends React.Component {
  constructor() {
    super();
    axios.get('/api/v1/tickets')
      .then((response) => {
        if (this.state) {
          this.setState({ tickets: response.data });
        } else {
          this.state = { tickets: response.data };
        }
      })
      .catch((err) => {
        console.log('error while fetching tickets');
      })
  }

  createTicket(ticket) {
    axios.post('/api/v1/tickets', ticket)
      .then((response) => {
        this.setState({ tickets:  [...this.state.tickets, ticket] });
      })
      .catch((err) => {
        console.log(err);
      })
  }

  render () {
    if (!this.state) this.state = { tickets: [] };
    const Tickets = this.state.tickets.map((ticket, i) => <TicketItem key={i} title={ticket.title} body={ticket.body}/>);

    return (
      <div>
        <b>Add new ticket:</b>
        <TicketForm createTicket={this.createTicket.bind(this)} />
        <hr />
        <div>
          <b>Tickets:</b>
          {Tickets}
        </div>
      </div>
    );
  }
}

Layout.propTypes = {
  tickets: PropTypes.array,
  createTicket: PropTypes.func
};

export default Layout
