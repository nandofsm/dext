# JWT Authentication Example

A demonstration of stateless authentication using JSON Web Tokens (JWT) in the Dext Framework.

## 🚀 Features

*   **JWT Middleware**: `TApplicationBuilderJwtExtensions.UseJwtAuthentication` validates tokens automatically
*   **Token Generation**: Creating signed tokens with Claims (Roles, Name, Email) using `TJwtTokenHandler`
*   **Claims Builder**: Fluent API for building claims with `TClaimsBuilder`
*   **Protected Endpoints**: Securing routes by checking `User.Identity.IsAuthenticated`
*   **Role-Based Access Control (RBAC)**: Restricting access to specific roles using `User.IsInRole`
*   **Claim Extraction**: Reading custom claims from the token payload

## 🛠️ Getting Started

1.  **Compile** `Web.JwtAuthDemo.dproj`
2.  **Run** `Web.JwtAuthDemo.exe`
    *   Server starts on **http://localhost:8080**
3.  **Test**:
    ```powershell
    .\Test.Web.JwtAuthDemo.ps1
    ```

## 🔐 Endpoints

| Endpoint | Auth | Description |
|----------|------|-------------|
| `POST /api/auth/login` | Public | Authenticates user and returns JWT token |
| `GET /api/public` | Public | Accessible without token |
| `GET /api/protected` | Bearer Token | Requires valid JWT in `Authorization` header |
| `GET /api/admin` | Bearer Token + Role | Requires token AND **Admin** role |

## 📖 Code Examples

### Configuring JWT Middleware

```pascal
// Add JWT authentication middleware
TApplicationBuilderJwtExtensions.UseJwtAuthentication(
  Builder, 
  TJwtOptions.Create(SecretKey)
);
```

### Login Endpoint (Token Generation)

```pascal
TApplicationBuilderExtensions.MapPostR<TLoginRequest, IResult>(Builder, '/api/auth/login',
  function(Request: TLoginRequest): IResult
  var
    Claims: TArray<TClaim>;
    Token: string;
  begin
    if (Request.Username = 'admin') and (Request.Password = 'password') then
    begin
      // Build claims using fluent API
      Claims := TClaimsBuilder.Create
        .WithNameIdentifier('123')
        .WithName(Request.Username)
        .WithRole('Admin')
        .WithEmail('admin@example.com')
        .Build;

      Token := JwtHandler.GenerateToken(Claims);
      Result := Results.Ok(Format('{"token":"%s"}', [Token]));
    end
    else
      Result := Results.BadRequest('{"error":"Invalid credentials"}');
  end);
```

### Protected Endpoint

```pascal
TApplicationBuilderExtensions.MapGetR<IHttpContext, IResult>(Builder, '/api/protected',
  function(Context: IHttpContext): IResult
  begin
    if (Context.User = nil) or not Context.User.Identity.IsAuthenticated then
      Exit(Results.StatusCode(401, '{"error":"Unauthorized"}'));

    Result := Results.Ok(Format('{"user":"%s"}', [Context.User.Identity.Name]));
  end);
```

### Role-Based Authorization

```pascal
// Check if user has Admin role
if not Context.User.IsInRole('Admin') then
  Exit(Results.StatusCode(403, '{"error":"Forbidden"}'));
```

## 🧪 Testing with cURL

```bash
# 1. Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# 2. Access protected endpoint
curl http://localhost:8080/api/protected \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Access admin endpoint
curl http://localhost:8080/api/admin \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 📚 See Also

- [JWT Authentication Guide](../../Docs/jwt-authentication.md) - Complete documentation
- [Claims Builder Examples](../../Docs/claims-builder-examples.md) - Advanced claims usage
- [Web.ControllerExample](../Web.ControllerExample) - Controllers with `[Authorize]` attribute
