[![.NET](https://github.com/damienbod/AzureAD-Auth-MyUI-with-MyAPI/actions/workflows/dotnet.yml/badge.svg)](https://github.com/damienbod/AzureAD-Auth-MyUI-with-MyAPI/actions/workflows/dotnet.yml)

# Microsoft Entra ID  authentication and authorization

different examples of implementing UIs, APIs using Microsoft Entra ID  as the token server. 

- [Login and use an ASP.NET Core API with Microsoft Entra ID Auth and user access tokens](https://damienbod.com/2020/05/29/login-and-use-asp-net-core-api-with-azure-ad-auth-and-user-access-tokens/)
- [Angular SPA with an ASP.NET Core API using Microsoft Entra ID Auth and user access tokens](https://damienbod.com/2020/06/08/angular-spa-with-an-asp-net-core-api-using-azure-ad-auth-and-user-access-tokens/)
- [Restricting access to an Microsoft Entra ID protected API using Microsoft Entra ID  Groups](https://damienbod.com/2020/06/13/restricting-access-to-an-azure-ad-protected-api-using-azure-ad-groups/)
- [Using Azure CLI to create Azure App Registrations](https://damienbod.com/2020/06/22/using-azure-cli-to-create-azure-app-registrations/)
- [Improving application security in an ASP.NET Core API using HTTP headers](https://damienbod.com/2021/08/30/improving-application-security-in-an-asp-net-core-api-using-http-headers-part-3/)

> [!NOTE]  
> Switch to BFF security
>
> It is now recommended to use backend for frontend security instead of two separate applications with seperate security contexts. 
> 
> See the following for implementation details:
> 
> https://github.com/damienbod/bff-aspnetcore-angular

## History

- 2024-10-03 Updated packages, update security headers
- 2024-08-08 Updated packages
- 2023-11-26 Updated .NET 8
- 2023-11-03 Updated packages, fix security headers
- 2023-08-14 Updated packages
- 2023-04-28 Updated packages
- 2023-03-11 Updated Security Headers to always apply
- 2023-03-02 Updated Microsoft.Identity.Web 2.5.0, updated Angular
- 2023-01-10 Updated the .NET 7
- 2022-10-09 Updated packages
- 2022-06-20 .NET 6 styles
- 2022-02-10 Updated namespaces
- 2022-01-08 Updated Angular packages, Nuget packages
- 2021-12-01 Updated Angular packages
- 2021-11-02 Update to .NET 6
- 2021-08-13 Security headers and api update
- 2021-07-01 Updated Microsoft.Identity.Web and packages
- 2021-05-13 Updated Microsoft.Identity.Web to 1.9.2 and packages
- 2021-04-15 Updated Microsoft.Identity.Web to 1.9.1
- 2021-03-05 Switch to SPA with refresh tokens due to IFrame problems
- 2021-02-28 Updated Microsoft.Identity.Web to 1.7.0
- 2021-02-13 Updated Microsoft.Identity.Web to 1.6.0, added MSAL exception handling
- 2021-01-31 Updated Microsoft.Identity.Web to 1.5.1
- 2021-01-02 Updated Microsoft.Identity.Web to 1.4.1
- 2020-12-05 Updated to .NET 5, Angular 11.0.3, oidc lib
- 2020-11-15 Updated Microsoft.Identity.Web to 1.3.0, Angular 11
- 2020-10-25 Updated Microsoft.Identity.Web to 1.2.0
- 2020-10-08 Updated Microsoft.Identity.Web to 1.1.0
- 2020-09-30 Updated Microsoft.Identity.Web to 1.0.0
- 2020-09-11 Updated Microsoft.Identity.Web to 0.4.0-preview
- 2020-08-27 Updated Microsoft.Identity.Web to 0.3.0-preview
- 2020-08-09 Updated Nuget packages, Updated Microsoft.Identity.Web to 0.2.2-preview

## Links

https://github.com/damienbod/bff-aspnetcore-angular

https://github.com/AzureAD/microsoft-identity-web

https://github.com/Azure-Samples/active-directory-aspnetcore-webapp-openidconnect-v2

https://jwt.io/

https://www.npmjs.com/package/angular-auth-oidc-client
