# 🎫 Web.TicketSales

A complete example of a **Ticket Sales Web API** built with **Dext Framework** using the **Controller pattern**.

This project demonstrates:
- **Controllers** with `[ApiController]` and `[Route]` attributes
- **ORM** with `TDbContext` and entities
- **Dependency Injection** with scoped services
- **JWT Authentication** protection
- **Business Rules** validation
- **Unit Tests** with Dext.Testing

## 📁 Project Structure

```
Web.TicketSales/
├── Server/                         # Web API Project
│   ├── Web.TicketSales.dpr         # Entry point
│   ├── TicketSales.Startup.pas     # DI & middleware configuration
│   └── TicketSales.Controllers.pas # REST Controllers
├── Domain/                         # Domain Layer
│   ├── TicketSales.Domain.Entities.pas  # ORM Entities
│   ├── TicketSales.Domain.Enums.pas     # Business enums
│   └── TicketSales.Domain.Models.pas    # DTOs
├── Data/                           # Data Access Layer
│   ├── TicketSales.Data.Context.pas     # DbContext
│   └── TicketSales.Data.Seeder.pas      # Sample data
├── Services/                       # Business Logic Layer
│   └── TicketSales.Services.pas    # Business services
└── Tests/                          # Unit Tests Project
    ├── Web.TicketSales.Tests.dpr
    ├── TicketSales.Tests.Entities.pas
    ├── TicketSales.Tests.Services.pas
    └── TicketSales.Tests.Validation.pas
```

## 🚀 Quick Start (Standard Workflow)

To ensure the best development experience and avoid build errors (like stale DCUs or missing units), follow the standardized Dext workflow:

### 1. Environment Setup
Open a terminal (PowerShell or CMD) and run:
```powershell
.\setenv.bat
```
*This sets the correct SDK paths and environment variables.*

### 2. Building the Core
Ensure the Dext Framework core is built. From the root:
```powershell
msbuild Dext.Core.dproj /p:Configuration=Debug
```
(Or use the global `build_framework.bat` if available).

### 3. Build and Run Example
From this folder:
```powershell
msbuild Server\Web.TicketSales.dproj
.\Server\Win32\Debug\Web.TicketSales.exe
```

> [!IMPORTANT]
> **NO MANUAL PATH EDITS**: Avoid adding local absolute paths to the Project Options in Delphi. The project is pre-configured to find units via relative paths and the `Output` directory populated by `setenv`.

### 4. Access the API
- **Swagger UI**: http://localhost:9000/swagger
- **Health Check**: http://localhost:9000/api/health

## 🎭 Domain Model

### Entities

| Entity | Description |
|--------|-------------|
| `TEvent` | Events (concerts, shows, conferences) |
| `TTicketType` | Ticket categories (VIP, Standard) with pricing |
| `TCustomer` | Registered customers with type (Regular, Student, Senior) |
| `TOrder` | Purchase orders with status tracking |
| `TOrderItem` | Line items linking orders to ticket types |
| `TTicket` | Individual tickets with unique codes |

### Business Rules

1. **Stock Validation**: Cannot sell more tickets than available capacity
2. **Half-Price (Meia-Entrada)**: Students, seniors, and children get 50% off on eligible ticket types
3. **Event Availability**: Can only purchase from events that are "On Sale" and in the future
4. **Max Tickets**: Maximum 10 tickets per order
5. **Order Flow**: Pending → Paid → Completed (generates tickets)
6. **Stock Return**: Cancelling an order returns tickets to the pool

## 🔐 API Endpoints

### Events
```
GET    /api/events              # List all events
GET    /api/events/available    # List events on sale
GET    /api/events/{id}         # Get event by ID
GET    /api/events/{id}/ticket-types  # Get ticket types for event
POST   /api/events              # Create event (auth required)
PUT    /api/events/{id}         # Update event (auth required)
DELETE /api/events/{id}         # Delete event (auth required)
POST   /api/events/{id}/open-sales    # Open ticket sales
POST   /api/events/{id}/close-sales   # Close ticket sales
```

### Customers
```
GET    /api/customers           # List all (auth required)
GET    /api/customers/{id}      # Get by ID
POST   /api/customers           # Register new customer
```

### Orders
```
GET    /api/orders              # List all (auth required)
GET    /api/orders/{id}         # Get order by ID
GET    /api/orders/customer/{id}  # Get orders by customer
POST   /api/orders              # Create new order
POST   /api/orders/{id}/pay     # Pay for order
POST   /api/orders/{id}/cancel  # Cancel order
GET    /api/orders/{id}/tickets # Get tickets for order
```

### Tickets
```
GET    /api/tickets/{code}      # Get ticket by code
POST   /api/tickets/validate    # Validate and mark ticket as used
```

## 🧪 Running Tests

```bash
# Build and run the test project
Web.TicketSales.Tests.exe
```

### Test Categories

- **Entity Tests**: Business methods on domain entities
- **Service Tests**: Business rule validation
- **Validation Tests**: Half-price, stock, max tickets rules

## 📝 Example Requests

### Create Order
```http
POST /api/orders
Content-Type: application/json

{
  "customerId": 2,
  "items": [
    {"ticketTypeId": 1, "quantity": 2},
    {"ticketTypeId": 2, "quantity": 1}
  ]
}
```

### Pay Order
```http
POST /api/orders/1/pay
```

### Validate Ticket
```http
POST /api/tickets/validate
Content-Type: application/json

{
  "code": "TKT-ABC12345"
}
```

## 🔧 Configuration

### JWT Settings (in `TicketSales.Startup.pas`)
- Secret: Change `JWT_SECRET` for production
- Expiration: 120 minutes by default

### Database
- SQLite database: `TicketSales.db`
- Auto-created on first run
- Seeded with sample data

## 📚 References

- [Dext Book - Controllers](../../Docs/Book/02-web-framework/controllers.md)
- [Dext Book - ORM](../../Docs/Book/05-orm/README.md)
- [Dext Book - Testing](../../Docs/Book/08-testing/README.md)
- [Web.DextStore](../Web.DextStore) - Similar example with Controllers
- [Web.SalesSystem](../Web.SalesSystem) - Minimal API example

---

*Created as a comprehensive example for Dext Framework*
