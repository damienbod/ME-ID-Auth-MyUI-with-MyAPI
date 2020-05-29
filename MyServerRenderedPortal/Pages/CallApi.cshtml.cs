using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Threading.Tasks;

namespace MyServerRenderedPortal.Pages
{
    public class CallApiModel : PageModel
    {
        private readonly ApiService _apiService;

        public CallApiModel(ApiService apiService)
        {
            _apiService = apiService;
        }

        public async Task OnGetAsync()
        {
            var data = await _apiService.GetApiDataAsync();
        }
    }
}