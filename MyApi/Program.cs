using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.Identity.Web;
using Microsoft.OpenApi.Models;
using MyApi;
using System.IdentityModel.Tokens.Jwt;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.AddServerHeader = false;
});

var services = builder.Services;
var configuration = builder.Configuration;
var env = builder.Environment;

JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();
// IdentityModelEventSource.ShowPII = true;

services.AddCors(options =>
{
    options.AddPolicy("AllowMyOrigins",
        builder =>
        {
            builder
                .AllowCredentials()
                .WithOrigins(
                    "https://localhost:4200")
                .SetIsOriginAllowedToAllowWildcardSubdomains()
                .AllowAnyHeader()
                .AllowAnyMethod();
        });
});


// This is required to be instantiated before the OpenIdConnectOptions starts getting configured.
// By default, the claims mapping will map claim names in the old format to accommodate older SAML applications.
// 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role' instead of 'roles'
// This flag ensures that the ClaimsIdentity claims collection will be built from the claims in the token
// JwtSecurityTokenHandler.DefaultMapInboundClaims = false;

// Adds Microsoft Identity platform (AAD v2.0) support to protect this Api
services.AddMicrosoftIdentityWebApiAuthentication(configuration);

services.AddControllers(options =>
{
    var policy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        // .RequireClaim("email") // disabled this to test with users that have no email (no license added)
        .Build();
    options.Filters.Add(new AuthorizeFilter(policy));
});

services.AddSwaggerGen(c =>
{
    c.EnableAnnotations();

    // add JWT Authentication
    var securityScheme = new OpenApiSecurityScheme
    {
        Name = "JWT Authentication",
        Description = "Enter JWT Bearer token **_only_**",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer", // must be lower case
        BearerFormat = "JWT",
        Reference = new OpenApiReference
        {
            Id = JwtBearerDefaults.AuthenticationScheme,
            Type = ReferenceType.SecurityScheme
        }
    };
    c.AddSecurityDefinition(securityScheme.Reference.Id, securityScheme);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {securityScheme, Array.Empty<string>() }
            });
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "API",
        Version = "v1",
        Description = "Exam Manager API"
    });

    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    // c.IncludeXmlComments(xmlPath);
});
var app = builder.Build();

app.UseSecurityHeaders(
    SecurityHeadersDefinitions.GetHeaderPolicyCollection(env.IsDevelopment()));

if (env.IsDevelopment())
{
    app.UseDeveloperExceptionPage();

    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "API v1");
    });
}

app.UseCors("AllowMyOrigins");

app.UseHttpsRedirection();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.UseEndpoints(endpoints =>
{
    endpoints.MapControllers();
});

app.Run();