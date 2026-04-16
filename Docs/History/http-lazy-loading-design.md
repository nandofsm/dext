# 🚀 HTTP Request Lazy Loading - Design Document

## Overview

This document describes the architectural changes made to implement **lazy loading** for HTTP request components in the Dext framework. This is a foundational step toward achieving zero-allocation, high-performance request processing.

## Problem Statement

### Current (Eager Loading) Model

In the traditional implementation, when an HTTP request arrives:

1. **All headers** are immediately parsed into a `TDictionary<string, string>`
2. **Query string** is immediately parsed into a `TStrings`
3. **Request body** is immediately copied from the Indy stream into a `TMemoryStream`

**Impact:**
- Memory allocated for data that may never be accessed
- CPU cycles wasted parsing headers/query params that endpoints don't need
- Body streams copied into memory even for GET requests with no body
- Increased GC pressure from temporary string allocations

### Example Scenario

```pascal
// Simple endpoint that only needs the path
App.MapGet('/health', procedure(Context: IHttpContext)
begin
  Context.Response.Write('OK');
end);
```

**Before:** Headers, Query, and Body are all parsed (wasted work)  
**After:** Only the path is accessed (minimal work)

---

## Solution: Lazy Loading

### Design Principles

1. **On-Demand Initialization**: Parse data structures only when accessed
2. **Single Initialization**: Once loaded, cache the result for subsequent access
3. **Backward Compatibility**: Existing code continues to work without changes
4. **Foundation for Zero-Copy**: Prepares the ground for `TSpan<T>` integration

### Implementation

#### 1. New Lazy Methods in `IHttpRequest`

```pascal
IHttpRequest = interface
  // Existing methods (unchanged)
  function GetMethod: string;
  function GetPath: string;
  function GetQuery: TStrings;
  function GetBody: TStream;
  function GetRouteParams: TDictionary<string, string>;
  function GetHeaders: TDictionary<string, string>;
  function GetRemoteIpAddress: string;
  
  // NEW: Lazy access methods
  function GetHeader(const AName: string): string;
  function GetQueryParam(const AName: string): string;
end;
```

#### 2. Lazy Initialization Pattern

```pascal
function TIndyHttpRequest.GetHeaders: TDictionary<string, string>;
begin
  if FHeaders = nil then
    FHeaders := ParseHeaders(FRequestInfo.RawHeaders);
  Result := FHeaders;
end;

function TIndyHttpRequest.GetHeader(const AName: string): string;
begin
  // Direct access without allocating dictionary
  Result := FRequestInfo.RawHeaders.Values[AName];
end;
```

#### 3. Constructor Simplification

**Before:**
```pascal
constructor TIndyHttpRequest.Create(ARequestInfo: TIdHTTPRequestInfo);
begin
  FRequestInfo := ARequestInfo;
  FQuery := ParseQueryString(FRequestInfo.QueryParams);      // Eager
  FHeaders := ParseHeaders(FRequestInfo.RawHeaders);         // Eager
  FBodyStream := CopyBodyStream(FRequestInfo.PostStream);    // Eager
  FRouteParams := TDictionary<string, string>.Create;
end;
```

**After:**
```pascal
constructor TIndyHttpRequest.Create(ARequestInfo: TIdHTTPRequestInfo);
begin
  FRequestInfo := ARequestInfo;
  FRouteParams := TDictionary<string, string>.Create;
  // Note: FQuery, FHeaders, FBodyStream are NIL and will be lazy loaded
end;
```

---

## Performance Benefits

### Memory Savings

| Scenario | Before (Eager) | After (Lazy) | Savings |
|----------|---------------|--------------|---------|
| Simple GET `/health` | ~2KB (Headers + Query) | ~0 bytes | 100% |
| GET with 10 headers | ~3KB | ~0 bytes (if not accessed) | 100% |
| POST with JSON body | ~5KB + Body size | Body size only (if headers not accessed) | ~5KB |

### CPU Savings

- **Header Parsing**: Avoided for endpoints that don't inspect headers
- **Query Parsing**: Avoided for endpoints without query parameters
- **Body Copying**: Deferred until `Body` property is accessed

### Real-World Impact

For a typical API with:
- 1000 req/s
- Average 2KB headers per request
- 70% of requests don't access headers

**Savings:**
- **Memory**: 1.4 MB/s not allocated
- **CPU**: ~700 dictionary allocations/s avoided
- **GC Pressure**: Significantly reduced

---

## Future Enhancements

### Phase 2: TSpan<T> Integration

Once `TSpan<T>` is mature, we can eliminate allocations entirely:

```pascal
function GetHeaderSpan(const AName: string): TByteSpan;
begin
  // Return a span pointing directly to Indy's internal buffer
  Result := TByteSpan.Create(/* pointer to header value */, Length);
end;
```

### Phase 3: Zero-Copy Body Streaming

Instead of copying the body into `TMemoryStream`:

```pascal
function GetBodySpan: TByteSpan;
begin
  // Return a span over Indy's receive buffer
  Result := TByteSpan.Create(FRequestInfo.PostStream.Memory, Size);
end;
```

---

## Migration Guide

### For Framework Users

**No changes required!** Existing code continues to work:

```pascal
// This still works exactly as before
var Headers := Context.Request.Headers;
var Body := Context.Request.Body;
```

### For Performance-Critical Code

Use the new lazy methods:

```pascal
// Before (allocates dictionary)
if Context.Request.Headers.ContainsKey('Authorization') then
  Token := Context.Request.Headers['Authorization'];

// After (no allocation)
Token := Context.Request.GetHeader('Authorization');
if Token <> '' then
  // Process token
```

---

## Testing

### Unit Tests Required

- [ ] Verify lazy initialization (headers not parsed until accessed)
- [ ] Verify single initialization (second access doesn't re-parse)
- [ ] Verify `GetHeader` returns correct value without allocating dictionary
- [ ] Verify `GetQueryParam` returns correct value without allocating TStrings
- [ ] Verify body stream lazy loading
- [ ] Verify backward compatibility (existing tests pass)

### Performance Benchmarks

- [ ] Measure memory allocation reduction
- [ ] Measure CPU time reduction for simple endpoints
- [ ] Measure throughput improvement under load

---

## Related Documents

- [Architecture & Performance](../architecture-performance.md)
- [Infrastructure Roadmap](infra-roadmap.md)
- [Framework Improvements 2025-12](framework-improvements-2025-12.md)

---

**Status**: ✅ Implemented  
**Version**: Dext v1.0 (Performance Track)  
**Author**: Cesar Romero  
**Date**: 2025-12-18
