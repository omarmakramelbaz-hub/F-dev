# Address Distance Filtering Implementation

## Overview
Implemented distance-based filtering for user addresses in the `AddressController::index()` method. The function now filters user addresses based on their proximity to restaurant delivery areas using geographic coordinates (latitude/longitude).

## How It Works

### 1. **Get Restaurant Context**
When `area_id` is provided in the request, the system:
- Retrieves the user's latest cart
- Gets the restaurant ID from that cart

### 2. **Fetch Restaurant Areas**
Queries all restaurant areas for the current restaurant that have:
- Valid latitude (`lat`)
- Valid longitude (`lng`)
- Valid `expected_delivery` distance (in kilometers)

### 3. **Fetch User Addresses**
Retrieves all user addresses that have valid latitude and longitude coordinates.

### 4. **Distance Calculation**
For each user address, the system:
- Calculates the distance to each restaurant area using the **Haversine formula**
- Compares the calculated distance with the `expected_delivery` value
- Includes the address if it's within range of ANY restaurant area

### 5. **Haversine Formula**
The `calculateDistance()` method implements the Haversine formula to calculate the great-circle distance between two points on Earth:

```php
private function calculateDistance($lat1, $lng1, $lat2, $lng2)
{
    $earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert degrees to radians
    $lat1 = deg2rad($lat1);
    $lng1 = deg2rad($lng1);
    $lat2 = deg2rad($lat2);
    $lng2 = deg2rad($lng2);
    
    // Calculate differences
    $latDiff = $lat2 - $lat1;
    $lngDiff = $lng2 - $lng1;
    
    // Haversine formula
    $a = sin($latDiff / 2) * sin($latDiff / 2) +
         cos($lat1) * cos($lat2) *
         sin($lngDiff / 2) * sin($lngDiff / 2);
    
    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    
    $distance = $earthRadius * $c;
    
    return $distance; // Returns distance in kilometers
}
```

## Database Requirements

### ResturantArea Table
Must have the following columns:
- `lat` (nullable string) - Latitude coordinate
- `lng` (nullable string) - Longitude coordinate
- `expected_delivery` (nullable) - Maximum delivery distance in kilometers
- `resturant_id` - Foreign key to restaurants table

### UserAddress Table
Must have the following columns:
- `lat` (nullable) - Latitude coordinate
- `lng` (nullable) - Longitude coordinate
- `user_id` - Foreign key to users table

## Example Usage

**Request:**
```
GET /api/addresses?area_id=123
```

**Process:**
1. User has addresses at coordinates: (30.0444, 31.2357), (30.0500, 31.2400)
2. Restaurant has delivery areas with:
   - Area 1: (30.0450, 31.2360), expected_delivery = 5 km
   - Area 2: (30.0600, 31.2500), expected_delivery = 3 km
3. System calculates distances and filters addresses within range
4. Returns only addresses that are within the `expected_delivery` distance of at least one restaurant area

## Fallback Behavior
If no addresses match the distance criteria or if no `area_id` is provided, the system returns all user addresses.

## Notes
- The lint warnings about `auth()` and `collect()` are false positives - these are Laravel helper functions
- Distance is calculated in kilometers using Earth's radius (6371 km)
- The formula accounts for the curvature of the Earth for accurate distance calculation
