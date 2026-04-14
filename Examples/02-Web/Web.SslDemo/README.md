# Dext SSL/HTTPS Example

This example demonstrates how to enable and configure SSL (HTTPS) in a Dext Web application.

## Prerequisites

1.  **Dext.inc**: Ensure `DEXT_ENABLE_SSL` is defined in `Sources\Dext.inc`.
2.  **Libraries**:
    *   For **OpenSSL (Default)**: You need `libeay32.dll` and `ssleay32.dll` (OpenSSL 1.0.2u or compatible) in your application's folder.
    *   For **Taurus TLS**: You need the Taurus TLS libraries and correct OpenSSL 1.1.x/3.x DLLs as specified by the Taurus project. Ensure `DEXT_ENABLE_TAURUS_TLS` is defined in `Dext.inc`.
3.  **Certificates**: You need a certificate file (`.crt` or `.pem`) and a private key file (`.key`). For local testing, you can generate self-signed ones.

## Configuration

SSL is configured via the `Server` section in `appsettings.json`:

```json
{
  "Server": {
    "Port": 8080,
    "UseHttps": "true",
    "SslProvider": "OpenSSL",
    "SslCert": "server.crt",
    "SslKey": "server.key",
    "SslRootCert": ""
  }
}
```

### Settings Description
*   `UseHttps`: `true` to enable SSL, `false` for HTTP only.
*   `SslProvider`: 
    *   `OpenSSL` (Default): Uses Indy's native OpenSSL 1.0.x implementation.
    *   `Taurus`: Uses the Taurus TLS implementation (supports OpenSSL 1.1x / 3.x).
*   `SslCert`: Path to your certificate file.
*   `SslKey`: Path to your private key file.
*   `SslRootCert`: (Optional) Path to the root certificate/bundle.

## Self-Signed Certificate Generation (Quick Tip)

You can use OpenSSL to generate a self-signed certificate for testing:

```bash
openssl req -x509 -newkey rsa:4096 -keyout server.key -out server.crt -days 365 -nodes
```

## Running the Example

1.  Build the project.
2.  Ensure the DLLs and `.crt`/`.key` files are in the same directory as the executable.
3.  Run the application.
4.  Access `https://localhost:8080`.

## Troubleshooting

### ERR_CONNECTION_CLOSED
- Means the server closed connection during handshake.
- Check if you have valid certificates.
- Check if `server.crt` and `server.key` match.

### ERR_TIMED_OUT (Indy/OpenSSL)
- Common issue with OpenSSL DLL incompatibility.
- **Solution**: Ensure you are using OpenSSL **1.0.2u** DLLs (`libeay32.dll`, `ssleay32.dll`) in the same folder as the executable.
- Note: Standard Indy does NOT support OpenSSL 1.1.x or 3.x.

### Taurus TLS (OpenSSL 1.1+/3.0+)
To use modern OpenSSL versions, switch to Taurus TLS provider:
1. Ensure `DEXT_ENABLE_TAURUS_TLS` is defined in `Dext.inc`.
2. Install Taurus TLS library in Delphi.
3. Update `appsettings.json`:
   ```json
   "SslProvider": "Taurus"
   ```
4. Use OpenSSL 1.1.x or 3.x DLLs (`libcrypto-*.dll`, `libssl-*.dll`).

## Known Issues

- **ERR_SSL_PROTOCOL_ERROR / ERR_TIMED_OUT**: Some combinations of Windows/Indy/OpenSSL DLLs may fail the handshake even with correct configuration. This is often due to strict TLS version mismatch or DLL architecture mismatch (32 vs 64 bit). 
- If you encounter persistent issues, try testing with the **Taurus TLS** provider which allows using modern, supported OpenSSL versions.

- [Dext Framework Documentation](../../README.md)
- [Web.JwtAuthDemo](../Web.JwtAuthDemo) - JWT Authentication example
