# 💾 Web.CachingDemo - Response Caching

This example demonstrates the **Response Caching Middleware** in the Dext Framework.

Response caching enables storing generated responses in memory (or other stores) and serving them for subsequent requests, significantly improving performance for read-heavy endpoints.

---

## ✨ Features Demonstrated

- **Response Caching**: Caching endpoint responses for a specific duration.
- **Vary By Query**: Different cache entries based on query string parameters.
- **Cache Headers**: Automatic handling of `X-Cache` and `Cache-Control` headers.
- **Fluent Configuration**: Modern API for configuring cache behavior.

---

## 🚀 Quick Start

### 1. Build the Project
Open `Web.CachingDemo.dproj` in Delphi and compile it (or use MSBuild).

### 2. Run Automation Tests
Using PowerShell:
```powershell
.\Test.Web.CachingDemo.ps1
```

### 3. Manual Testing
Start the server:
```bash
Web.CachingDemo.exe
```

Test with curl:
```bash
# First request (MISS - Generates response)
curl -v http://localhost:8080/api/time

# Second request (HIT - Returns cached response)
curl -v http://localhost:8080/api/time

# Wait 30 seconds...
# Third request (MISS - Expired, regenerates)
curl -v http://localhost:8080/api/time
```

---

## 💡 Code Example

```pascal
// Configure Caching
TApplicationBuilderCacheExtensions.UseResponseCache(Builder,
  procedure(Cache: TResponseCacheBuilder)
  begin
    Cache
      .WithDefaultDuration(30)
      .VaryByQueryString;
  end);

// Map Cached Endpoint
Builder.MapGet('/api/time',
  procedure(Ctx: IHttpContext)
  begin
    // Expensive operation...
    Ctx.Response.Json(Format('{"time":"%s"}', [TimeToStr(Now)]));
  end);
```
