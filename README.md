# 🥚 Smarternak - IoT Egg Quality Monitoring System

## 📋 Overview

Smarternak adalah sistem monitoring kualitas telur berbasis IoT yang mengintegrasikan perangkat keras (conveyor, scanner, sensor) dengan aplikasi web untuk monitoring real-time dan analisis data produksi telur.

## 🔐 Authentication System

Sistem ini dilengkapi dengan authentication dan role-based access control (RBAC) yang komprehensif:

### Default Login Credentials

| Role | Email | Password | Access Level |
|------|-------|----------|--------------|
| **Super Admin** | `superadmin@smarternak.com` | `superadmin123` | Full access + User management |
| **Admin** | `admin@smarternak.com` | `admin123` | All features except user management |

### Role Hierarchy & Permissions

```
SuperAdmin (Level 2) → Can manage all users and access all features
    ↓
Admin (Level 1) → Access all features except user management
```

### Key Features
- **🔒 Secure Authentication** - JWT-based with session persistence
- **👥 User Management** - SuperAdmin can create, edit, delete accounts
- **🛡️ Role-Based Access** - Hierarchical permission system
- **📱 Responsive Design** - Works on desktop, tablet, and mobile
- **🌙 Dark/Light Mode** - Theme switching with persistent storage

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │    │   Backend API   │    │   Web Frontend  │
│                 │    │                 │    │                 │
│ • Egg Scanner   │◄──►│ • REST API      │◄──►│ • React App     │
│ • Conveyor      │    │ • WebSocket     │    │ • Dashboard     │
│ • Sensors       │    │ • Database      │    │ • Reports       │
│ • Camera        │    │ • File Storage  │    │ • Settings      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Features

### 📱 Web Application
- **🔐 Login System** - Secure authentication with role management
- **📊 Dashboard Real-time** - Monitoring produksi dan kualitas telur
- **🥚 Data Kualitas Telur** - Analisis detail hasil scanning
- **📄 Unduh Laporan** - Generate laporan dalam format PDF, Excel, CSV
- **👥 Manajemen Akun** - User management (SuperAdmin only)
- **⚙️ Pengaturan** - System settings dan user profile
- **🌙 Dark/Light Mode** - Theme switching dengan persistent storage

### 🔧 IoT Integration
- **📡 Device Management** - Registration dan monitoring perangkat IoT
- **⚡ Real-time Data** - Streaming data dari sensor dan scanner
- **🚨 Alert System** - Notifikasi otomatis untuk anomali
- **🔄 Data Synchronization** - Sinkronisasi data offline/online

### 📊 Analytics & Reporting
- **📈 Quality Analytics** - Analisis trend kualitas telur
- **📊 Production Statistics** - Statistik produksi harian/bulanan
- **⚡ Performance Monitoring** - Monitoring performa perangkat
- **🔮 Predictive Maintenance** - Prediksi kebutuhan maintenance

## 🗄️ Database Design

### 📈 Entity Relationship Diagram

Database dirancang dengan 15+ tabel utama yang saling terintegrasi:

#### Core Tables
- **users** - User management dan authentication dengan role hierarchy
- **devices** - IoT device registration dan status
- **egg_scans** - Data hasil scanning telur (tabel utama)
- **quality_standards** - Standard kualitas telur

#### Supporting Tables
- **sensor_data** - Time-series data dari sensor (partitioned)
- **production_batches** - Batch produksi harian
- **alerts** - System alerts dan notifications
- **maintenance_logs** - Log maintenance perangkat
- **reports** - Generated reports tracking

#### Security & Audit
- **user_sessions** - Session management
- **api_tokens** - IoT device authentication
- **audit_logs** - Security audit trail

### 🔧 Database Features
- **🔐 Role-Based Security** - User hierarchy dengan created_by tracking
- **📊 Partitioning** - Sensor data table dipartisi berdasarkan tanggal
- **⚡ Indexing** - Optimized indexes untuk query performance
- **🔄 Triggers** - Automatic data processing dan validation
- **📝 Stored Procedures** - Automated daily statistics calculation
- **👁️ Views** - Pre-built views untuk common queries
- **⏰ Events** - Scheduled tasks untuk maintenance

## 🛠️ Installation & Setup

### Prerequisites
```bash
# Frontend
Node.js 18+
npm atau yarn

# Backend
PHP 8.1+
MySQL 8.0+
Composer

# IoT Development
Arduino IDE
ESP32/Arduino boards
```

### 1. Database Setup
```sql
-- Import database schema
mysql -u root -p < database_schema.sql

-- Verify installation
mysql -u root -p smarternak_db -e "SHOW TABLES;"
```

### 2. Frontend Setup
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

### 3. Backend Setup (Example with Laravel)
```bash
# Install Laravel
composer create-project laravel/laravel smarternak-api

# Configure database
cp .env.example .env
# Edit .env with database credentials

# Run migrations (if using Laravel migrations)
php artisan migrate

# Start server
php artisan serve
```

### 4. IoT Device Setup
```cpp
// Arduino/ESP32 configuration
#define WIFI_SSID "your_wifi_ssid"
#define WIFI_PASSWORD "your_wifi_password"
#define API_BASE_URL "https://api.smarternak.com/v1"
#define API_TOKEN "your_device_api_token"
```

## 🔐 Quick Start Guide

### 1. Login to System
1. Open the application in your browser
2. Use one of the default credentials from the table above
3. Or click the quick login buttons for demo access

### 2. SuperAdmin Features
- Login as SuperAdmin to access user management
- Navigate to "Manajemen Akun" in the sidebar
- Create, edit, or delete user accounts
- Assign roles and manage permissions

### 3. Testing Different Roles
- Login with different accounts to test role restrictions
- Verify that menu items appear/disappear based on permissions
- Test protected routes and access control

## 📡 API Integration

### Authentication
```javascript
// Get API token for device
const response = await fetch('/api/auth/device-token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    device_mac: '00:1B:44:11:3A:B7',
    device_name: 'Scanner-001',
    device_type: 'scanner'
  })
});
```

### Submit Scan Data
```javascript
// Submit egg scan result
const scanData = {
  egg_code: 'EGG-20240115-0001',
  device_id: 1,
  measurements: {
    weight: 62.5,
    length: 6.2,
    width: 4.8,
    height: 4.5
  },
  quality_assessment: {
    quality: 'good',
    quality_score: 0.92
  },
  scanned_at: new Date().toISOString()
};

await fetch('/api/scans', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${apiToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(scanData)
});
```

## 🔧 Configuration

### Environment Variables
```env
# Database
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=smarternak_db
DB_USERNAME=smarternak_app
DB_PASSWORD=secure_password

# API
API_BASE_URL=https://api.smarternak.com/v1
JWT_SECRET=your_jwt_secret_key

# File Storage
STORAGE_DRIVER=local
STORAGE_PATH=/var/www/storage

# Email (for notifications)
MAIL_DRIVER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
```

### Quality Standards Configuration
```json
{
  "standards": [
    {
      "name": "Grade A",
      "weight": { "min": 50, "max": 70 },
      "length": { "min": 5.5, "max": 6.5 },
      "width": { "min": 4.0, "max": 5.0 },
      "height": { "min": 4.0, "max": 5.0 }
    }
  ]
}
```

## 📊 Monitoring & Analytics

### Key Metrics
- **Production Rate** - Telur per jam/hari
- **Quality Percentage** - Persentase telur berkualitas baik
- **Device Uptime** - Availability perangkat IoT
- **Alert Response Time** - Waktu response terhadap alert
- **User Activity** - Login patterns dan usage statistics

### Dashboard Widgets
- Real-time production counter
- Quality distribution chart
- Device status indicators
- Recent alerts panel
- Performance trends
- User management statistics (SuperAdmin only)

## 🚨 Alert System

### Alert Types
- **Device Offline** - Perangkat tidak merespon
- **Quality Drop** - Penurunan kualitas telur
- **Sensor Anomaly** - Pembacaan sensor abnormal
- **Maintenance Due** - Jadwal maintenance
- **System Error** - Error sistem
- **Security Alert** - Failed login attempts, unauthorized access

### Notification Channels
- Web notifications
- Email alerts
- SMS (optional)
- Mobile push notifications

## 🔒 Security

### Authentication & Authorization
- JWT-based authentication dengan refresh tokens
- Role-based access control (RBAC) dengan hierarchy
- API token authentication untuk IoT devices
- Session management dengan timeout
- Multi-factor authentication (optional)

### Data Protection
- Password hashing dengan bcrypt
- SQL injection prevention
- XSS protection
- CSRF protection
- Rate limiting
- Input validation dan sanitization

### Audit Trail
- User action logging
- Data change tracking
- Login attempt monitoring
- API access logging
- Role change notifications

## 📈 Performance Optimization

### Database Optimization
- Indexed queries untuk fast retrieval
- Partitioned tables untuk time-series data
- Query optimization dengan EXPLAIN
- Regular maintenance procedures
- Connection pooling

### Caching Strategy
- Redis untuk session storage
- Application-level caching
- Database query result caching
- Static asset caching
- API response caching

### Scalability
- Horizontal scaling dengan load balancer
- Database replication (master-slave)
- Microservices architecture ready
- CDN untuk static assets
- Auto-scaling infrastructure

## 🧪 Testing

### Unit Testing
```bash
# Frontend tests
npm run test

# Backend tests (Laravel example)
php artisan test
```

### Integration Testing
```bash
# API endpoint testing
npm run test:api

# Database integration tests
npm run test:db

# Authentication flow tests
npm run test:auth
```

### IoT Device Testing
```cpp
// Arduino test functions
void testSensorReading() {
  float weight = readWeightSensor();
  assert(weight > 0 && weight < 200);
}

void testAPIConnection() {
  bool connected = connectToAPI();
  assert(connected == true);
}
```

## 📚 Documentation

### API Documentation
- [API Reference](./API_Documentation.md)
- [Authentication Guide](./docs/authentication.md)
- [Error Handling](./docs/error-handling.md)

### Database Documentation
- [Schema Documentation](./docs/database-schema.md)
- [Migration Guide](./docs/migrations.md)
- [Backup Procedures](./docs/backup.md)

### IoT Integration
- [Device Setup Guide](./docs/iot-setup.md)
- [Sensor Calibration](./docs/sensor-calibration.md)
- [Troubleshooting](./docs/troubleshooting.md)

### User Management
- [Login Credentials](./LOGIN_CREDENTIALS.md)
- [Role Management Guide](./docs/role-management.md)
- [User Administration](./docs/user-admin.md)

## 🚀 Deployment

### Production Deployment
```bash
# Build frontend
npm run build

# Deploy to server
rsync -avz dist/ user@server:/var/www/smarternak/

# Database migration
mysql -u root -p smarternak_db < database_schema.sql

# Start services
systemctl start nginx
systemctl start php-fpm
systemctl start mysql
```

### Docker Deployment
```yaml
# docker-compose.yml
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
  
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    depends_on:
      - database
  
  database:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: smarternak_db
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - ./database_schema.sql:/docker-entrypoint-initdb.d/schema.sql
```

## 🔧 Maintenance

### Regular Tasks
- **Daily**: Backup database, check system health, monitor user activity
- **Weekly**: Clean old data, update statistics, security audit
- **Monthly**: Performance review, user access review
- **Quarterly**: System updates, capacity planning, role audit

### Monitoring
```bash
# Check database size
SELECT 
  table_schema AS 'Database',
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'smarternak_db';

# Check slow queries
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;

# Monitor user sessions
SELECT COUNT(*) as active_sessions FROM user_sessions WHERE is_active = 1;
```

## 🤝 Contributing

### Development Workflow
1. Fork repository
2. Create feature branch
3. Implement changes
4. Write tests
5. Submit pull request

### Code Standards
- ESLint untuk JavaScript/React
- PSR-12 untuk PHP
- Conventional Commits untuk commit messages
- Code review required untuk production

## 📞 Support

### Technical Support
- **Email**: tech@smarternak.com
- **Documentation**: [https://docs.smarternak.com](https://docs.smarternak.com)
- **Issue Tracker**: [GitHub Issues](https://github.com/smarternak/issues)

### Community
- **Discord**: [Smarternak Community](https://discord.gg/smarternak)
- **Forum**: [https://forum.smarternak.com](https://forum.smarternak.com)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- React.js community untuk frontend framework
- Tailwind CSS untuk styling system
- Chart.js untuk data visualization
- MySQL untuk database management
- Arduino/ESP32 community untuk IoT integration

---

**Smarternak** - Revolutionizing egg quality monitoring with IoT technology 🥚✨

**🔐 Quick Login:** Use the credentials above to test different user roles and permissions!
