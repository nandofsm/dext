# DextStore Example

A comprehensive example of a Web API built with the Dext Framework, demonstrating how to structure a real-world application.

## 🚀 Features

*   **MVC Controllers**: Structured API using `[DextController]`, `[DextGet]`, `[DextPost]`.
*   **Dependency Injection**: Full usage of DI container for Services, Repositories, and Controllers.
*   **JWT Authentication**: Secure endpoints using `[Authorize]` and Bearer tokens.
*   **Fluent API**: Modern configuration syntax for Middleware (CORS, Auth).
*   **Model Binding**: Automatic mapping of JSON bodies to DTOs.
*   **Service Layer**: Logic separation into `Services`, `Models`, and `Controllers`.

## 🛠️ Getting Started

1.  **Compile** the project `Web.DextStore.dproj` using Delphi or MSBuild.
2.  **Run** the executable `Web.DextStore.exe`.
    *   The server will start on **http://localhost:9000**.
3.  **Test** the API using the provided scripts:
    *   **Full Test (Recommended)**: Login -> Products -> Cart -> Checkout.
        ```powershell
        .\Test.Web.DextStore.Full.ps1
        ```
    *   **API Suite**: Comprehensive test of all individual endpoints.
        ```powershell
        .\Test.Web.DextStore.Api.ps1
        ```
    *   **Health Check**: Quick check to see if the server is up.
        ```powershell
        .\Test.Web.DextStore.Health.ps1
        ```

## 📂 Structure

*   **Web.DextStore.dpr**: Application entry point and configuration (DI, Middleware).
*   **DextStore.Controllers.pas**: API Endpoints definition.
*   **DextStore.Services.pas**: Business logic and in-memory data storage (simulated DB).
*   **DextStore.Models.pas**: Data Transfer Objects (DTOs) and Entities.

## 🔐 Credentials (Demo)

*   **Username**: `user`
*   **Password**: `password`
