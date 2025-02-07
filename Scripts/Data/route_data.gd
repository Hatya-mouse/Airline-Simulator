extends Resource
class_name RouteData

## ID of the route.
var route_id: String = ""
## Array of airports.
var airports: Array[AirportData] = []
## Whether back to the first airport.
var back_to_first: bool = false
## Whether this route is one way.
var one_way: bool = false
## Ticket price of this route.
var ticket_price: float = 50.0
## Whether this airline is being edited.
var is_editing: bool = false
