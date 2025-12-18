# Backend API Implementation Guide

This document provides detailed implementation guidance for the Laravel backend API endpoints required by the BBest Flutter app.

## Table of Contents

1. [Required Endpoints](#required-endpoints)
2. [Authentication](#authentication)
3. [Endpoint Specifications](#endpoint-specifications)
4. [Sample cURL Commands](#sample-curl-commands)
5. [Database Schema](#database-schema)
6. [Validation Rules](#validation-rules)

---

## Required Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/v1/home` | Home page sections & products | Optional |
| GET | `/api/v1/search` | Search affiliate products | Optional |
| POST | `/api/v1/auth/login` | User login | No |
| POST | `/api/v1/auth/register` | User registration | No |
| POST | `/api/v1/auth/logout` | User logout | Yes |
| GET | `/api/v1/user/favorites` | Get user favorites | Yes |
| POST | `/api/v1/user/favorites` | Add to favorites | Yes |
| DELETE | `/api/v1/user/favorites/{id}` | Remove from favorites | Yes |

---

## Authentication

Use Laravel Sanctum for API token authentication.

### Headers Required
```
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

---

## Endpoint Specifications

### 1. GET /api/v1/home

Returns home page sections with featured products.

**Response Format:**
```json
{
  "success": true,
  "data": {
    "sections": [
      {
        "title": "Best Deals Today",
        "type": "horizontal_scroll",
        "items": [
          {
            "id": "prod_123",
            "name": "Product Name",
            "imageUrl": "https://example.com/image.jpg",
            "originalPrice": 100.00,
            "discountedPrice": 75.00,
            "discountPercent": 25,
            "platform": "shopee",
            "affiliateUrl": "https://affiliate.shopee.com/...",
            "rating": 4.5,
            "soldCount": 1500,
            "aiRecommendation": {
              "score": 0.92,
              "reason": "High discount with excellent reviews"
            }
          }
        ]
      }
    ]
  }
}
```

**Laravel Controller:**
```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\HomeService;

class HomeController extends Controller
{
    public function __construct(
        private readonly HomeService $homeService
    ) {}

    public function index()
    {
        $sections = $this->homeService->getSections();

        return response()->json([
            'success' => true,
            'data' => [
                'sections' => $sections
            ]
        ]);
    }
}
```

---

### 2. GET /api/v1/search

Search for affiliate products across platforms.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `q` | string | Yes | Search query |
| `platform` | string | No | Filter by platform (shopee, lazada, tiktok) |
| `page` | int | No | Page number (default: 1) |
| `limit` | int | No | Items per page (default: 20, max: 100) |

**Response Format:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "prod_456",
        "name": "Searched Product",
        "imageUrl": "https://example.com/image.jpg",
        "originalPrice": 50.00,
        "discountedPrice": 40.00,
        "discountPercent": 20,
        "platform": "lazada",
        "affiliateUrl": "https://affiliate.lazada.com/...",
        "rating": 4.2,
        "soldCount": 500,
        "aiRecommendation": null
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 10,
      "totalItems": 200,
      "hasMore": true
    }
  }
}
```

**Laravel Controller:**
```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\SearchRequest;
use App\Services\SearchService;

class SearchController extends Controller
{
    public function __construct(
        private readonly SearchService $searchService
    ) {}

    public function index(SearchRequest $request)
    {
        $results = $this->searchService->search(
            query: $request->input('q'),
            platform: $request->input('platform'),
            page: $request->input('page', 1),
            limit: $request->input('limit', 20)
        );

        return response()->json([
            'success' => true,
            'data' => $results
        ]);
    }
}
```

---

### 3. POST /api/v1/auth/login

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response Format:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com"
    },
    "token": "1|abc123xyz..."
  }
}
```

---

## Sample cURL Commands

### Home Endpoint
```bash
# Get home sections
curl -X GET "https://api.bbest.com/api/v1/home" \
  -H "Accept: application/json"
```

### Search Endpoint
```bash
# Search for products
curl -X GET "https://api.bbest.com/api/v1/search?q=laptop&platform=shopee&page=1&limit=20" \
  -H "Accept: application/json"

# Search all platforms
curl -X GET "https://api.bbest.com/api/v1/search?q=headphones" \
  -H "Accept: application/json"
```

### Authentication
```bash
# Login
curl -X POST "https://api.bbest.com/api/v1/auth/login" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'

# Logout (authenticated)
curl -X POST "https://api.bbest.com/api/v1/auth/logout" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Favorites
```bash
# Get favorites (authenticated)
curl -X GET "https://api.bbest.com/api/v1/user/favorites" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Add to favorites (authenticated)
curl -X POST "https://api.bbest.com/api/v1/user/favorites" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"product_id": "prod_123", "platform": "shopee"}'

# Remove from favorites (authenticated)
curl -X DELETE "https://api.bbest.com/api/v1/user/favorites/1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Database Schema

### Products Table (Cached)
```sql
CREATE TABLE products (
    id VARCHAR(255) PRIMARY KEY,
    external_id VARCHAR(255) NOT NULL,
    platform ENUM('shopee', 'lazada', 'tiktok') NOT NULL,
    name VARCHAR(500) NOT NULL,
    image_url VARCHAR(1000),
    original_price DECIMAL(10, 2),
    discounted_price DECIMAL(10, 2),
    discount_percent INT,
    affiliate_url VARCHAR(2000),
    rating DECIMAL(2, 1),
    sold_count INT DEFAULT 0,
    ai_score DECIMAL(3, 2),
    ai_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_platform (platform),
    INDEX idx_name (name(100)),
    FULLTEXT INDEX idx_fulltext_name (name)
);
```

### Favorites Table
```sql
CREATE TABLE favorites (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    platform ENUM('shopee', 'lazada', 'tiktok') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, product_id, platform)
);
```

---

## Validation Rules

### SearchRequest
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SearchRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'q' => ['required', 'string', 'min:2', 'max:200'],
            'platform' => ['nullable', 'string', 'in:shopee,lazada,tiktok'],
            'page' => ['nullable', 'integer', 'min:1'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:100'],
        ];
    }
}
```

### LoginRequest
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'email'],
            'password' => ['required', 'string', 'min:8'],
        ];
    }
}
```

---

## Error Response Format

All errors should follow this format:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The given data was invalid.",
    "details": {
      "email": ["The email field is required."]
    }
  }
}
```

### Error Codes
| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 422 | Request validation failed |
| `UNAUTHORIZED` | 401 | Authentication required or failed |
| `FORBIDDEN` | 403 | User lacks permission |
| `NOT_FOUND` | 404 | Resource not found |
| `RATE_LIMITED` | 429 | Too many requests |
| `SERVER_ERROR` | 500 | Internal server error |

---

## Rate Limiting

Configure rate limiting in `RouteServiceProvider`:

```php
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

RateLimiter::for('search', function (Request $request) {
    return Limit::perMinute(30)->by($request->user()?->id ?: $request->ip());
});
```

---

## Testing the API

Use the provided cURL commands or import this Postman collection:

```json
{
  "info": {
    "name": "BBest API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "base_url",
      "value": "https://api.bbest.com/api/v1"
    },
    {
      "key": "token",
      "value": ""
    }
  ]
}
```

---

## Next Steps for Backend Team

1. [ ] Create API routes in `routes/api.php`
2. [ ] Implement controllers with proper request validation
3. [ ] Set up Sanctum authentication
4. [ ] Create service classes for business logic
5. [ ] Integrate affiliate platform APIs (Shopee, Lazada, TikTok)
6. [ ] Add caching layer for product data (Redis recommended)
7. [ ] Implement search with Elasticsearch or Meilisearch
8. [ ] Set up rate limiting
9. [ ] Add API documentation (Laravel Scribe or Swagger)
10. [ ] Write feature tests for all endpoints
