# Backend Integration Checklist

This document outlines what the backend API should provide for optimal frontend integration.

---

## 📡 API Endpoints Required

### 1. Authentication
```
POST /api/auth/login
- Request: { email: string, password: string }
- Response: { token: string }
- Status: 200 on success, 401 on auth failure

GET /api/me
- Headers: Authorization: Bearer {token}
- Response: { id, name, email, ...user_fields }
- Status: 200 on success, 401 if unauthorized
```

### 2. Search Endpoint
```
GET /api/search?platform=shopee&query=laptop&page=1&page_size=20
- Query Parameters:
  - platform: 'shopee' | 'lazada' | 'tiktok'
  - query: string (search term)
  - page: number (default: 1)
  - page_size: number (default: 20)

- Response:
{
  "data": [
    {
      "platform": "shopee",
      "platform_product_id": "12345",
      "title": "Product Name",
      "price": 999.99,
      "original_price": 1200.00,
      "discount": 16.67,
      "rating": 4.5,
      "review_count": 150,
      "seller_rating": 4.8,
      "image": "https://example.com/image.jpg",
      "url": "https://shopee.ph/product",
      "affiliate_url": "https://affiliate.shopee.ph/product",
      "data_source": "scraper",
      "ai_recommendation": {
        "recommended_price": 899.99,
        "confidence": 0.95,
        "source": "price_history"
      }
    }
  ]
}

- Status: 200 on success, 400 on bad request, 500 on server error
```

### 3. Home Endpoint
```
GET /api/home
- Headers: Authorization: Bearer {token} (optional)

- Response:
{
  "sections": [
    {
      "title": "Trending Searches",
      "items": [
        { "query": "laptop" },
        { "query": "phone" },
        { "query": "shoes" }
      ]
    },
    {
      "title": "Best Deals Today",
      "items": [
        {
          "platform": "shopee",
          "platform_product_id": "12345",
          "title": "Product Name",
          "price": 999.99,
          // ... full product object (see search response)
        }
      ]
    },
    {
      "title": "Recommended for You",
      "items": [
        {
          "platform": "lazada",
          "platform_product_id": "67890",
          // ... full product object
        }
      ]
    }
  ]
}

- Status: 200 on success, 500 on server error
```

---

## ✅ API Response Format Standards

### Product Object Structure
```json
{
  "platform": "string (shopee|lazada|tiktok)",
  "platform_product_id": "string (unique per platform)",
  "title": "string (product name)",
  "price": "number (current price in PHP)",
  "original_price": "number (optional, original price before discount)",
  "discount": "number (optional, discount percentage)",
  "rating": "number (optional, 0-5 stars)",
  "review_count": "number (optional, total reviews)",
  "seller_rating": "number (optional, seller rating 0-5)",
  "image": "string (optional, image URL)",
  "url": "string (product URL on platform)",
  "affiliate_url": "string (affiliate tracking URL)",
  "data_source": "string (scraper|api|manual)",
  "ai_recommendation": {
    "recommended_price": "number (optional, AI suggested price)",
    "confidence": "number (optional, 0-1 confidence score)",
    "source": "string (optional, e.g., price_history, ml_model)"
  }
}
```

### Error Response Format
```json
{
  "message": "string (error message)",
  "code": "string (error code)",
  "details": "object (optional, additional error details)"
}
```

---

## 🔐 Authentication

### Token Management
- Tokens should be JWT format
- Include expiration time (recommend 24 hours)
- Provide refresh endpoint `/api/auth/refresh` if needed
- Support Bearer token in Authorization header

### Headers Required
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

---

## 🌐 CORS Configuration

Ensure backend is configured with CORS to accept requests from Flutter:
```
Access-Control-Allow-Origin: * (or specify Flutter app domain)
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

---

## 📊 Performance Recommendations

1. **Pagination**: Always paginate large result sets (use page_size parameter)
2. **Caching**: Add ETag headers for cacheable responses
3. **Compression**: Enable gzip compression for large responses
4. **Timeouts**: Keep response time < 5 seconds for best UX
5. **Rate Limiting**: Implement reasonable rate limits (e.g., 100 req/min per IP)

---

## 🧪 Testing Scenarios

### Test API Responses
```bash
# Search endpoint
curl -X GET "http://localhost:8000/api/search?platform=shopee&query=laptop&page=1&page_size=20" \
  -H "Accept: application/json"

# Home endpoint
curl -X GET "http://localhost:8000/api/home" \
  -H "Accept: application/json"

# Login
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### Test Error Cases
1. Empty search results → should return empty data array
2. Invalid platform → should return 400 error
3. Missing auth token → should return 401 error
4. Server error → should return 500 with error details
5. Timeout → should not hang > 10 seconds

---

## 🚨 Common Issues & Solutions

### Issue: "Failed to search products: HTTP 400"
- Check: API endpoint spelling and method (GET vs POST)
- Check: Query parameters format and encoding
- Check: Request headers (Content-Type, Authorization)

### Issue: "Unexpected error: null"
- Check: API response format matches expected structure
- Check: Response status code is in 200-299 range
- Check: Response body contains expected fields

### Issue: Products not displaying
- Check: Image URLs are valid and accessible
- Check: Price values are numbers, not strings
- Check: Required fields (title, url, affiliateUrl) are present

### Issue: Slow loading
- Check: API response time (should be < 1 second)
- Check: Image sizes (compress images to < 100KB each)
- Check: Number of items returned (limit to 20-30 per page)

---

## 🔄 Update Schedule

The Flutter app expects stable API contracts. Major changes should:
1. Maintain backward compatibility
2. Use API versioning (e.g., /api/v1/search)
3. Provide deprecation warnings before breaking changes
4. Update this document

---

## 📋 Implementation Status

- [ ] `/api/auth/login` endpoint
- [ ] `/api/me` endpoint (user profile)
- [ ] `/api/search` endpoint
- [ ] `/api/home` endpoint
- [ ] Error handling with proper HTTP status codes
- [ ] CORS configuration
- [ ] Rate limiting
- [ ] Request logging
- [ ] Response compression
- [ ] API documentation (Swagger/OpenAPI)

---

**Last Updated**: December 11, 2025
**Backend Status**: Ready for implementation
