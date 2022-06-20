using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Identity.Web;
using Newtonsoft.Json.Linq;

namespace MyServerRenderedPortal.Pages;

[AuthorizeForScopes(Scopes = new string[] { "api://98328d53-55ec-4f14-8407-0ca5ff2f2d20/access_as_user" })]
public class CallApiModel : PageModel
{
    private readonly ApiService _apiService;

    public JArray? DataFromApi { get; set; }

    public CallApiModel(ApiService apiService)
    {
        _apiService = apiService;
    }

    public async Task OnGetAsync()
    {
        DataFromApi = await _apiService.GetApiDataAsync();
    }
}