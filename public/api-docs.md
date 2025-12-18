# BBEST API - Minimal docs

## Authentication
POST /api/auth/register
POST /api/auth/login

## Products
GET /api/products
POST /api/products
GET /api/products/{id}
PUT /api/products/{id}

## Listings
GET /api/listings/{id}
GET /api/listings/{id}/prices
GET /api/listings/{id}/recommendation

## Notifications
GET /api/notifications
POST /api/notifications/{id}/read
