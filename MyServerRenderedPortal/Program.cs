using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;
using MyServerRenderedPortal;
using NetEscapades.AspNetCore.SecurityHeaders.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.AddServerHeader = false;
});

var services = builder.Services;
var configuration = builder.Configuration;

services.AddSecurityHeaderPolicies()
  .SetPolicySelector((PolicySelectorContext ctx) =>
  {
      return SecurityHeadersDefinitions.GetHeaderPolicyCollection(
          builder.Environment.IsDevelopment());
  });

services.AddTransient<ApiService>();
services.AddHttpClient();

services.AddOptions();

string[]? initialScopes = configuration.GetValue<string>("CallApi:ScopeForAccessToken")?.Split(' ');

services.AddDistributedMemoryCache();

services.AddMicrosoftIdentityWebAppAuthentication(configuration)
    .EnableTokenAcquisitionToCallDownstreamApi(initialScopes)
    .AddDistributedTokenCaches();

services.AddRazorPages().AddMvcOptions(options =>
{
    var policy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();
    options.Filters.Add(new AuthorizeFilter(policy));
}).AddMicrosoftIdentityUI();

var app = builder.Build();

app.UseSecurityHeaders();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapRazorPages();
app.MapControllers();

app.Run();