using BlazorServer.Services;
using System.Net.Http.Headers;
using System.Text.Json;

namespace BlazorServer.Services;

public interface IApiService
{
    Task<T?> GetAsync<T>(string endpoint);
    Task<string> GetRawAsync(string endpoint);
    Task<bool> TestConnectionAsync();
}

public class ApiService : IApiService
{
    private readonly HttpClient _httpClient;
    private readonly IAuthService _authService;
    private readonly ILogger<ApiService> _logger;
    private readonly JsonSerializerOptions _jsonOptions;

    public ApiService(HttpClient httpClient, IAuthService authService, ILogger<ApiService> logger)
    {
        _httpClient = httpClient;
        _authService = authService;
        _logger = logger;
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
    }

    public async Task<T?> GetAsync<T>(string endpoint)
    {
        try
        {
            await SetAuthorizationHeaderAsync();
            
            var response = await _httpClient.GetAsync(endpoint);
            
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<T>(content, _jsonOptions);
            }
            else
            {
                _logger.LogWarning("API call failed: {StatusCode} - {Reason}", response.StatusCode, response.ReasonPhrase);
                return default(T);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling API endpoint: {Endpoint}", endpoint);
            return default(T);
        }
    }

    public async Task<string> GetRawAsync(string endpoint)
    {
        try
        {
            await SetAuthorizationHeaderAsync();
            
            var response = await _httpClient.GetAsync(endpoint);
            var content = await response.Content.ReadAsStringAsync();
            
            if (response.IsSuccessStatusCode)
            {
                return content;
            }
            else
            {
                return $"Error {response.StatusCode}: {content}";
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling API endpoint: {Endpoint}", endpoint);
            return $"Exception: {ex.Message}";
        }
    }

    public async Task<bool> TestConnectionAsync()
    {
        try
        {
            // Test public endpoint first (no auth required)
            var response = await _httpClient.GetAsync("/api/values");
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "API connection test failed");
            return false;
        }
    }

    private async Task SetAuthorizationHeaderAsync()
    {
        var accessToken = await _authService.GetAccessTokenAsync();
        
        if (!string.IsNullOrEmpty(accessToken))
        {
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            _logger.LogInformation("Authorization header set with token: {TokenPrefix}...", accessToken.Substring(0, Math.Min(20, accessToken.Length)));
        }
        else
        {
            _httpClient.DefaultRequestHeaders.Authorization = null;
            _logger.LogWarning("No access token available for API call");
        }
    }
}
