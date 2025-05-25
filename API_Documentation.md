# 🔌 Smarternak IoT API Documentation

## 📋 Overview

API ini dirancang untuk integrasi perangkat IoT dengan sistem Smarternak untuk monitoring kualitas telur. API menggunakan REST architecture dengan autentikasi berbasis token.

**Base URL:** `https://api.smarternak.com/v1`

## 🔐 Authentication

### API Token Authentication
Semua request harus menyertakan header autentikasi:

```http
Authorization: Bearer YOUR_API_TOKEN
Content-Type: application/json
```

### Mendapatkan API Token

**Endpoint:** `POST /auth/device-token`

```json
{
  "device_mac": "00:1B:44:11:3A:B7",
  "device_name": "Scanner-001",
  "device_type": "scanner"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "expires_at": "2024-12-31T23:59:59Z",
    "device_id": 1
  }
}
```

## 📊 Core Endpoints

### 1. Device Management

#### Register/Update Device Status
**Endpoint:** `POST /devices/heartbeat`

```json
{
  "device_id": 1,
  "status": "online",
  "firmware_version": "1.2.3",
  "configuration": {
    "scan_interval": 5,
    "quality_threshold": 0.8
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "device_id": 1,
    "status": "online",
    "last_ping": "2024-01-15T10:30:00Z"
  }
}
```

#### Get Device Configuration
**Endpoint:** `GET /devices/{device_id}/config`

**Response:**
```json
{
  "success": true,
  "data": {
    "device_id": 1,
    "configuration": {
      "scan_interval": 5,
      "quality_threshold": 0.8,
      "conveyor_speed": 65.5
    },
    "quality_standards": [
      {
        "standard_id": 1,
        "standard_name": "Standard Grade A",
        "min_weight": 50.00,
        "max_weight": 70.00,
        "min_length": 5.50,
        "max_length": 6.50
      }
    ]
  }
}
```

### 2. Egg Scanning

#### Submit Egg Scan Data
**Endpoint:** `POST /scans`

```json
{
  "egg_code": "EGG-20240115-0001",
  "device_id": 1,
  "conveyor_id": 1,
  "measurements": {
    "weight": 62.5,
    "length": 6.2,
    "width": 4.8,
    "height": 4.5
  },
  "quality_assessment": {
    "quality": "good",
    "quality_score": 0.92,
    "notes": "Perfect shape and size"
  },
  "image_data": {
    "image_url": "https://storage.smarternak.com/images/egg-001.jpg",
    "thumbnail_url": "https://storage.smarternak.com/thumbs/egg-001.jpg"
  },
  "scanned_at": "2024-01-15T10:30:15Z"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "scan_id": 12345,
    "egg_code": "EGG-20240115-0001",
    "quality": "good",
    "batch_id": 67,
    "processed_at": "2024-01-15T10:30:16Z"
  }
}
```

#### Batch Submit Multiple Scans
**Endpoint:** `POST /scans/batch`

```json
{
  "scans": [
    {
      "egg_code": "EGG-20240115-0001",
      "device_id": 1,
      "conveyor_id": 1,
      "measurements": {
        "weight": 62.5,
        "length": 6.2,
        "width": 4.8,
        "height": 4.5
      },
      "quality_assessment": {
        "quality": "good",
        "quality_score": 0.92
      },
      "scanned_at": "2024-01-15T10:30:15Z"
    }
  ]
}
```

### 3. Sensor Data

#### Submit Sensor Readings
**Endpoint:** `POST /sensors/data`

```json
{
  "sensor_id": 1,
  "readings": [
    {
      "value": 23.5,
      "status": "normal",
      "recorded_at": "2024-01-15T10:30:00Z"
    },
    {
      "value": 24.1,
      "status": "normal", 
      "recorded_at": "2024-01-15T10:31:00Z"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "inserted_count": 2,
    "sensor_id": 1,
    "latest_reading": {
      "value": 24.1,
      "status": "normal",
      "recorded_at": "2024-01-15T10:31:00Z"
    }
  }
}
```

### 4. Conveyor Control

#### Get Conveyor Status
**Endpoint:** `GET /conveyors/{conveyor_id}/status`

**Response:**
```json
{
  "success": true,
  "data": {
    "conveyor_id": 1,
    "status": "active",
    "speed_rpm": 65.5,
    "capacity": 1500,
    "current_load": 1250,
    "last_maintenance": "2024-01-10",
    "settings": {
      "auto_start": true,
      "max_speed": 100,
      "emergency_stop": false
    }
  }
}
```

#### Update Conveyor Status
**Endpoint:** `PUT /conveyors/{conveyor_id}/status`

```json
{
  "status": "active",
  "speed_rpm": 70.0,
  "action_type": "speed_change",
  "message": "Speed adjusted by IoT controller"
}
```

#### Submit Conveyor Log
**Endpoint:** `POST /conveyors/{conveyor_id}/logs`

```json
{
  "action_type": "start",
  "message": "Conveyor started automatically",
  "metadata": {
    "trigger": "schedule",
    "previous_status": "inactive",
    "operator": "system"
  }
}
```

### 5. Alerts & Notifications

#### Create Alert
**Endpoint:** `POST /alerts`

```json
{
  "device_id": 1,
  "conveyor_id": 1,
  "alert_type": "sensor_anomaly",
  "severity": "high",
  "title": "Temperature Sensor Anomaly",
  "message": "Temperature reading outside normal range: 45°C",
  "metadata": {
    "sensor_id": 3,
    "current_value": 45.0,
    "normal_range": "15-35",
    "duration": "5 minutes"
  }
}
```

#### Get Active Alerts
**Endpoint:** `GET /alerts/active`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "alert_id": 123,
      "alert_type": "quality_drop",
      "severity": "medium",
      "title": "Quality Drop Detected",
      "message": "Bad egg percentage increased to 15%",
      "triggered_at": "2024-01-15T10:25:00Z",
      "status": "active"
    }
  ]
}
```

## 📈 Data Formats & Standards

### Quality Assessment Values
```json
{
  "quality": "good|bad|unknown",
  "quality_score": 0.0-1.0,
  "criteria_met": {
    "weight": true,
    "size": true,
    "shape": true,
    "surface": false
  }
}
```

### Sensor Types & Units
```json
{
  "temperature": "celsius",
  "humidity": "percentage", 
  "weight": "grams",
  "distance": "millimeters",
  "speed": "rpm",
  "vibration": "hz"
}
```

### Device Status Values
- `online` - Device is connected and functioning
- `offline` - Device is not responding
- `maintenance` - Device is under maintenance
- `error` - Device has encountered an error

### Alert Severity Levels
- `low` - Informational alerts
- `medium` - Warnings that need attention
- `high` - Issues requiring immediate action
- `critical` - System failures or safety concerns

## 🔄 Real-time Communication

### WebSocket Connection
**Endpoint:** `wss://api.smarternak.com/v1/ws`

#### Authentication
```json
{
  "type": "auth",
  "token": "YOUR_API_TOKEN"
}
```

#### Subscribe to Events
```json
{
  "type": "subscribe",
  "channels": ["device.1", "conveyor.1", "alerts"]
}
```

#### Receive Real-time Updates
```json
{
  "type": "conveyor_status",
  "data": {
    "conveyor_id": 1,
    "status": "active",
    "speed_rpm": 65.5,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## 📊 Batch Operations

### Bulk Data Upload
**Endpoint:** `POST /data/bulk`

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "device_id": 1,
  "data": {
    "scans": [...],
    "sensor_readings": [...],
    "logs": [...]
  }
}
```

## ⚠️ Error Handling

### Standard Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid egg code format",
    "details": {
      "field": "egg_code",
      "expected_format": "EGG-YYYYMMDD-NNNN"
    }
  }
}
```

### Common Error Codes
- `AUTHENTICATION_FAILED` - Invalid or expired token
- `VALIDATION_ERROR` - Request data validation failed
- `DEVICE_NOT_FOUND` - Device ID not registered
- `RATE_LIMIT_EXCEEDED` - Too many requests
- `INTERNAL_ERROR` - Server error

## 🚀 Rate Limiting

- **Heartbeat:** 1 request per minute per device
- **Scan Data:** 100 requests per minute per device
- **Sensor Data:** 1000 requests per minute per device
- **Alerts:** 10 requests per minute per device

## 📝 Integration Examples

### Arduino/ESP32 Example
```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const char* API_BASE = "https://api.smarternak.com/v1";
const char* API_TOKEN = "your_api_token_here";

void submitScanData(String eggCode, float weight, float length) {
  HTTPClient http;
  http.begin(String(API_BASE) + "/scans");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Bearer " + String(API_TOKEN));
  
  DynamicJsonDocument doc(1024);
  doc["egg_code"] = eggCode;
  doc["device_id"] = 1;
  doc["conveyor_id"] = 1;
  doc["measurements"]["weight"] = weight;
  doc["measurements"]["length"] = length;
  doc["quality_assessment"]["quality"] = "good";
  doc["scanned_at"] = getCurrentTimestamp();
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  int httpResponseCode = http.POST(jsonString);
  
  if (httpResponseCode == 200) {
    String response = http.getString();
    Serial.println("Scan submitted successfully");
  }
  
  http.end();
}
```

### Python Example
```python
import requests
import json
from datetime import datetime

class SmarternakAPI:
    def __init__(self, api_token):
        self.base_url = "https://api.smarternak.com/v1"
        self.headers = {
            "Authorization": f"Bearer {api_token}",
            "Content-Type": "application/json"
        }
    
    def submit_scan(self, egg_code, device_id, measurements, quality):
        data = {
            "egg_code": egg_code,
            "device_id": device_id,
            "conveyor_id": 1,
            "measurements": measurements,
            "quality_assessment": quality,
            "scanned_at": datetime.utcnow().isoformat() + "Z"
        }
        
        response = requests.post(
            f"{self.base_url}/scans",
            headers=self.headers,
            json=data
        )
        
        return response.json()
    
    def send_heartbeat(self, device_id, status="online"):
        data = {
            "device_id": device_id,
            "status": status,
            "firmware_version": "1.0.0"
        }
        
        response = requests.post(
            f"{self.base_url}/devices/heartbeat",
            headers=self.headers,
            json=data
        )
        
        return response.json()

# Usage
api = SmarternakAPI("your_api_token_here")

# Submit scan data
measurements = {
    "weight": 62.5,
    "length": 6.2,
    "width": 4.8,
    "height": 4.5
}

quality = {
    "quality": "good",
    "quality_score": 0.92
}

result = api.submit_scan("EGG-20240115-0001", 1, measurements, quality)
print(result)
```

## 🔧 Testing & Development

### Test Environment
**Base URL:** `https://api-test.smarternak.com/v1`

### Postman Collection
Download: [Smarternak API Collection](https://api.smarternak.com/docs/postman-collection.json)

### API Documentation
Interactive docs: [https://api.smarternak.com/docs](https://api.smarternak.com/docs)

## 📞 Support

- **Technical Support:** tech@smarternak.com
- **API Issues:** api-support@smarternak.com
- **Documentation:** [https://docs.smarternak.com](https://docs.smarternak.com)
- **Status Page:** [https://status.smarternak.com](https://status.smarternak.com) 