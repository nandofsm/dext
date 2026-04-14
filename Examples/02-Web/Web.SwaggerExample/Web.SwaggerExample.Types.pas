unit Web.SwaggerExample.Types;

interface

uses
  Dext.OpenAPI.Attributes,
  System.SysUtils;

type
  [SwaggerSchema('User', 'Represents a user in the system')]
  TUser = record
    [SwaggerProperty('Unique identifier for the user')]
    [SwaggerExample('1')]
    Id: Integer;

    [SwaggerProperty('Full name of the user')]
    [SwaggerExample('John Doe')]
    Name: string;

    [SwaggerProperty('Email address')]
    [SwaggerFormat('email')]
    [SwaggerExample('john@example.com')]
    Email: string;
  end;

  [SwaggerSchema('CreateUserRequest', 'Request body for creating a new user')]
  TCreateUserRequest = record
    [SwaggerProperty('Full name of the user')]
    [SwaggerRequired]
    Name: string;

    [SwaggerProperty('Email address')]
    [SwaggerFormat('email')]
    [SwaggerRequired]
    Email: string;

    [SwaggerProperty('User password')]
    [SwaggerFormat('password')]
    [SwaggerRequired]
    Password: string;
  end;

  [SwaggerSchema('Product', 'Represents a product in the catalog')]
  TProduct = record
    [SwaggerProperty('Unique identifier for the product')]
    Id: Integer;

    [SwaggerProperty('Product name')]
    Name: string;

    [SwaggerProperty('Product price in USD')]
    [SwaggerExample('99.99')]
    Price: Currency;

    [SwaggerProperty('Availability status')]
    InStock: Boolean;
  end;

  TProductArray = TArray<TProduct>;
  
  [SwaggerSchema('ErrorResponse', 'Standard error response')]
  TErrorResponse = record
    [SwaggerProperty('Error message description')]
    error: string;
  end;

  [SwaggerSchema('HealthResponse', 'Health check status information')]
  THealthResponse = record
    [SwaggerProperty('Service status')]
    [SwaggerExample('healthy')]
    status: string;
    
    [SwaggerProperty('API version')]
    [SwaggerExample('1.0.0')]
    version: string;
  end;

implementation

end.
