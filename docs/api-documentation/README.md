# Dokumentasi API IndoWater

## Daftar Isi
1. [Pendahuluan](#pendahuluan)
2. [Autentikasi](#autentikasi)
3. [Format Respons](#format-respons)
4. [Kode Status](#kode-status)
5. [Rate Limiting](#rate-limiting)
6. [Versioning](#versioning)
7. [Endpoint API](#endpoint-api)
8. [Webhook](#webhook)
9. [Contoh Integrasi](#contoh-integrasi)
10. [FAQ](#faq)

## Pendahuluan

Selamat datang di dokumentasi API IndoWater. API ini memungkinkan pengembang untuk mengintegrasikan sistem mereka dengan platform IndoWater untuk mengelola meter air prabayar, transaksi, dan data pengguna.

### Basis URL

```
https://api.indowater.com/api/v1
```

### Format Data

API IndoWater menggunakan format JSON untuk request dan response. Semua request harus menyertakan header `Content-Type: application/json`.

### Lingkungan

IndoWater menyediakan dua lingkungan API:

- **Produksi**: `https://api.indowater.com/api/v1`
- **Sandbox**: `https://sandbox-api.indowater.com/api/v1`

Gunakan lingkungan Sandbox untuk pengujian integrasi sebelum beralih ke lingkungan Produksi.

## Autentikasi

API IndoWater menggunakan JSON Web Token (JWT) untuk autentikasi. Untuk mendapatkan token akses, Anda perlu melakukan request ke endpoint `/auth/login` dengan kredensial API Anda.

### Mendapatkan Token Akses

**Request:**

```http
POST /auth/login
Content-Type: application/json

{
  "email": "your-api-email@example.com",
  "password": "your-api-password"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

### Menggunakan Token Akses

Sertakan token akses di header `Authorization` untuk semua request API yang memerlukan autentikasi:

```http
GET /users
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Memperbaharui Token Akses

Token akses kedaluwarsa setelah periode waktu tertentu (biasanya 1 jam). Untuk memperbaharui token tanpa harus login ulang, gunakan endpoint `/auth/refresh`:

```http
POST /auth/refresh
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**

```json
{
  "status": "success",
  "message": "Token berhasil diperbaharui",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

## Format Respons

Semua respons API mengikuti format standar berikut:

```json
{
  "status": "success|error",
  "message": "Pesan deskriptif",
  "data": {
    // Data respons (jika ada)
  },
  "meta": {
    // Metadata (pagination, dll.) jika ada
  }
}
```

### Pagination

Untuk endpoint yang mengembalikan banyak item, API menggunakan pagination dengan format berikut:

```json
{
  "status": "success",
  "message": "Data berhasil diambil",
  "data": [
    // Array item
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 50,
    "total_pages": 4,
    "links": {
      "first": "https://api.indowater.com/api/v1/resource?page=1",
      "last": "https://api.indowater.com/api/v1/resource?page=4",
      "prev": null,
      "next": "https://api.indowater.com/api/v1/resource?page=2"
    }
  }
}
```

## Kode Status

API IndoWater menggunakan kode status HTTP standar:

- `200 OK`: Request berhasil
- `201 Created`: Resource berhasil dibuat
- `204 No Content`: Request berhasil, tidak ada konten yang dikembalikan
- `400 Bad Request`: Request tidak valid
- `401 Unauthorized`: Autentikasi gagal
- `403 Forbidden`: Tidak memiliki izin untuk mengakses resource
- `404 Not Found`: Resource tidak ditemukan
- `422 Unprocessable Entity`: Validasi gagal
- `429 Too Many Requests`: Rate limit terlampaui
- `500 Internal Server Error`: Terjadi kesalahan server

## Rate Limiting

API IndoWater menerapkan rate limiting untuk memastikan kinerja dan ketersediaan layanan. Batas default adalah 60 request per menit per API key.

Header berikut disertakan dalam setiap respons API:

- `X-RateLimit-Limit`: Jumlah maksimum request yang diizinkan per jendela waktu
- `X-RateLimit-Remaining`: Jumlah request yang tersisa dalam jendela waktu saat ini
- `X-RateLimit-Reset`: Waktu (dalam detik) hingga jendela waktu di-reset

Jika Anda melebihi batas rate, Anda akan menerima respons `429 Too Many Requests`.

## Versioning

API IndoWater menggunakan versioning dalam URL untuk memastikan kompatibilitas. Format URL adalah:

```
https://api.indowater.com/api/v{version_number}/{endpoint}
```

Versi saat ini adalah `v1`. Ketika perubahan yang tidak kompatibel ke belakang diperkenalkan, versi baru akan dirilis.

## Endpoint API

### Pengguna

#### Mendapatkan Daftar Pengguna

```http
GET /users
```

**Parameter Query:**
- `page` (opsional): Nomor halaman untuk pagination (default: 1)
- `per_page` (opsional): Jumlah item per halaman (default: 15, maks: 100)
- `search` (opsional): Kata kunci pencarian
- `status` (opsional): Filter berdasarkan status (`active`, `inactive`)

**Response:**

```json
{
  "status": "success",
  "message": "Data pengguna berhasil diambil",
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+6281234567890",
      "address": "Jl. Contoh No. 123, Jakarta",
      "status": "active",
      "created_at": "2023-01-15T08:30:00Z",
      "updated_at": "2023-01-15T08:30:00Z"
    },
    // ...
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 50,
    "total_pages": 4,
    "links": {
      "first": "https://api.indowater.com/api/v1/users?page=1",
      "last": "https://api.indowater.com/api/v1/users?page=4",
      "prev": null,
      "next": "https://api.indowater.com/api/v1/users?page=2"
    }
  }
}
```

#### Mendapatkan Detail Pengguna

```http
GET /users/{id}
```

**Response:**

```json
{
  "status": "success",
  "message": "Data pengguna berhasil diambil",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+6281234567890",
    "address": "Jl. Contoh No. 123, Jakarta",
    "status": "active",
    "meters": [
      {
        "id": 101,
        "serial_number": "IW12345678",
        "address": "Jl. Contoh No. 123, Jakarta",
        "status": "active",
        "balance": 25.5,
        "created_at": "2023-01-15T08:30:00Z",
        "updated_at": "2023-01-15T08:30:00Z"
      }
    ],
    "created_at": "2023-01-15T08:30:00Z",
    "updated_at": "2023-01-15T08:30:00Z"
  }
}
```

#### Membuat Pengguna Baru

```http
POST /users
Content-Type: application/json

{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "phone": "+6281234567891",
  "address": "Jl. Contoh No. 456, Jakarta",
  "password": "securepassword123"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Pengguna berhasil dibuat",
  "data": {
    "id": 2,
    "name": "Jane Smith",
    "email": "jane@example.com",
    "phone": "+6281234567891",
    "address": "Jl. Contoh No. 456, Jakarta",
    "status": "active",
    "created_at": "2023-01-16T10:15:00Z",
    "updated_at": "2023-01-16T10:15:00Z"
  }
}
```

#### Memperbarui Pengguna

```http
PUT /users/{id}
Content-Type: application/json

{
  "name": "Jane Smith Updated",
  "address": "Jl. Contoh No. 789, Jakarta"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Pengguna berhasil diperbarui",
  "data": {
    "id": 2,
    "name": "Jane Smith Updated",
    "email": "jane@example.com",
    "phone": "+6281234567891",
    "address": "Jl. Contoh No. 789, Jakarta",
    "status": "active",
    "created_at": "2023-01-16T10:15:00Z",
    "updated_at": "2023-01-16T11:30:00Z"
  }
}
```

#### Menghapus Pengguna

```http
DELETE /users/{id}
```

**Response:**

```json
{
  "status": "success",
  "message": "Pengguna berhasil dihapus",
  "data": null
}
```

### Meter Air

#### Mendapatkan Daftar Meter Air

```http
GET /meters
```

**Parameter Query:**
- `page` (opsional): Nomor halaman untuk pagination (default: 1)
- `per_page` (opsional): Jumlah item per halaman (default: 15, maks: 100)
- `search` (opsional): Kata kunci pencarian
- `status` (opsional): Filter berdasarkan status (`active`, `inactive`)
- `user_id` (opsional): Filter berdasarkan ID pengguna

**Response:**

```json
{
  "status": "success",
  "message": "Data meter air berhasil diambil",
  "data": [
    {
      "id": 101,
      "serial_number": "IW12345678",
      "user_id": 1,
      "address": "Jl. Contoh No. 123, Jakarta",
      "status": "active",
      "balance": 25.5,
      "last_reading": 150.75,
      "created_at": "2023-01-15T08:30:00Z",
      "updated_at": "2023-01-15T08:30:00Z"
    },
    // ...
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 30,
    "total_pages": 2,
    "links": {
      "first": "https://api.indowater.com/api/v1/meters?page=1",
      "last": "https://api.indowater.com/api/v1/meters?page=2",
      "prev": null,
      "next": "https://api.indowater.com/api/v1/meters?page=2"
    }
  }
}
```

#### Mendapatkan Detail Meter Air

```http
GET /meters/{id}
```

**Response:**

```json
{
  "status": "success",
  "message": "Data meter air berhasil diambil",
  "data": {
    "id": 101,
    "serial_number": "IW12345678",
    "user_id": 1,
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+6281234567890"
    },
    "address": "Jl. Contoh No. 123, Jakarta",
    "status": "active",
    "balance": 25.5,
    "last_reading": 150.75,
    "usage_history": [
      {
        "date": "2023-01-15",
        "usage": 0.5
      },
      {
        "date": "2023-01-14",
        "usage": 0.7
      },
      // ...
    ],
    "created_at": "2023-01-15T08:30:00Z",
    "updated_at": "2023-01-15T08:30:00Z"
  }
}
```

#### Mendaftarkan Meter Air Baru

```http
POST /meters
Content-Type: application/json

{
  "serial_number": "IW87654321",
  "user_id": 2,
  "address": "Jl. Contoh No. 456, Jakarta",
  "initial_balance": 10.0
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Meter air berhasil didaftarkan",
  "data": {
    "id": 102,
    "serial_number": "IW87654321",
    "user_id": 2,
    "address": "Jl. Contoh No. 456, Jakarta",
    "status": "active",
    "balance": 10.0,
    "last_reading": 0.0,
    "created_at": "2023-01-16T11:45:00Z",
    "updated_at": "2023-01-16T11:45:00Z"
  }
}
```

#### Memperbarui Meter Air

```http
PUT /meters/{id}
Content-Type: application/json

{
  "address": "Jl. Contoh No. 789, Jakarta",
  "status": "inactive"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Meter air berhasil diperbarui",
  "data": {
    "id": 102,
    "serial_number": "IW87654321",
    "user_id": 2,
    "address": "Jl. Contoh No. 789, Jakarta",
    "status": "inactive",
    "balance": 10.0,
    "last_reading": 0.0,
    "created_at": "2023-01-16T11:45:00Z",
    "updated_at": "2023-01-16T12:30:00Z"
  }
}
```

#### Menambahkan Pulsa ke Meter Air

```http
POST /meters/{id}/topup
Content-Type: application/json

{
  "amount": 15.0,
  "payment_method": "bank_transfer",
  "reference_id": "INV-12345"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Pulsa berhasil ditambahkan",
  "data": {
    "transaction_id": "TRX-67890",
    "meter_id": 102,
    "amount": 15.0,
    "balance_before": 10.0,
    "balance_after": 25.0,
    "payment_method": "bank_transfer",
    "reference_id": "INV-12345",
    "status": "success",
    "created_at": "2023-01-16T13:15:00Z"
  }
}
```

### Transaksi

#### Mendapatkan Daftar Transaksi

```http
GET /transactions
```

**Parameter Query:**
- `page` (opsional): Nomor halaman untuk pagination (default: 1)
- `per_page` (opsional): Jumlah item per halaman (default: 15, maks: 100)
- `user_id` (opsional): Filter berdasarkan ID pengguna
- `meter_id` (opsional): Filter berdasarkan ID meter
- `type` (opsional): Filter berdasarkan jenis transaksi (`topup`, `usage`)
- `status` (opsional): Filter berdasarkan status (`pending`, `success`, `failed`)
- `start_date` (opsional): Filter transaksi setelah tanggal tertentu (format: YYYY-MM-DD)
- `end_date` (opsional): Filter transaksi sebelum tanggal tertentu (format: YYYY-MM-DD)

**Response:**

```json
{
  "status": "success",
  "message": "Data transaksi berhasil diambil",
  "data": [
    {
      "id": "TRX-67890",
      "user_id": 2,
      "meter_id": 102,
      "type": "topup",
      "amount": 15.0,
      "balance_before": 10.0,
      "balance_after": 25.0,
      "payment_method": "bank_transfer",
      "reference_id": "INV-12345",
      "status": "success",
      "created_at": "2023-01-16T13:15:00Z",
      "updated_at": "2023-01-16T13:15:00Z"
    },
    // ...
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 45,
    "total_pages": 3,
    "links": {
      "first": "https://api.indowater.com/api/v1/transactions?page=1",
      "last": "https://api.indowater.com/api/v1/transactions?page=3",
      "prev": null,
      "next": "https://api.indowater.com/api/v1/transactions?page=2"
    }
  }
}
```

#### Mendapatkan Detail Transaksi

```http
GET /transactions/{id}
```

**Response:**

```json
{
  "status": "success",
  "message": "Data transaksi berhasil diambil",
  "data": {
    "id": "TRX-67890",
    "user_id": 2,
    "user": {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com",
      "phone": "+6281234567891"
    },
    "meter_id": 102,
    "meter": {
      "id": 102,
      "serial_number": "IW87654321",
      "address": "Jl. Contoh No. 789, Jakarta"
    },
    "type": "topup",
    "amount": 15.0,
    "balance_before": 10.0,
    "balance_after": 25.0,
    "payment_method": "bank_transfer",
    "reference_id": "INV-12345",
    "status": "success",
    "payment_details": {
      "bank": "BCA",
      "account_number": "****1234",
      "payment_time": "2023-01-16T13:10:00Z"
    },
    "created_at": "2023-01-16T13:15:00Z",
    "updated_at": "2023-01-16T13:15:00Z"
  }
}
```

#### Membuat Transaksi Baru

```http
POST /transactions
Content-Type: application/json

{
  "user_id": 2,
  "meter_id": 102,
  "type": "topup",
  "amount": 20.0,
  "payment_method": "credit_card",
  "payment_details": {
    "card_number": "****5678",
    "card_holder": "Jane Smith",
    "expiry_date": "12/25"
  }
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Transaksi berhasil dibuat",
  "data": {
    "id": "TRX-67891",
    "user_id": 2,
    "meter_id": 102,
    "type": "topup",
    "amount": 20.0,
    "balance_before": 25.0,
    "balance_after": 45.0,
    "payment_method": "credit_card",
    "reference_id": "INV-12346",
    "status": "success",
    "payment_details": {
      "card_number": "****5678",
      "card_holder": "Jane Smith",
      "expiry_date": "12/25"
    },
    "created_at": "2023-01-17T09:30:00Z",
    "updated_at": "2023-01-17T09:30:00Z"
  }
}
```

#### Memperbarui Status Transaksi

```http
PUT /transactions/{id}/status
Content-Type: application/json

{
  "status": "success",
  "notes": "Pembayaran telah dikonfirmasi"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Status transaksi berhasil diperbarui",
  "data": {
    "id": "TRX-67891",
    "status": "success",
    "notes": "Pembayaran telah dikonfirmasi",
    "updated_at": "2023-01-17T10:15:00Z"
  }
}
```

### Pembacaan Meter

#### Mendapatkan Daftar Pembacaan Meter

```http
GET /meter-readings
```

**Parameter Query:**
- `page` (opsional): Nomor halaman untuk pagination (default: 1)
- `per_page` (opsional): Jumlah item per halaman (default: 15, maks: 100)
- `meter_id` (opsional): Filter berdasarkan ID meter
- `start_date` (opsional): Filter pembacaan setelah tanggal tertentu (format: YYYY-MM-DD)
- `end_date` (opsional): Filter pembacaan sebelum tanggal tertentu (format: YYYY-MM-DD)

**Response:**

```json
{
  "status": "success",
  "message": "Data pembacaan meter berhasil diambil",
  "data": [
    {
      "id": 1001,
      "meter_id": 101,
      "reading": 150.75,
      "usage": 0.5,
      "balance_before": 26.0,
      "balance_after": 25.5,
      "read_at": "2023-01-15T08:00:00Z",
      "created_at": "2023-01-15T08:00:00Z",
      "updated_at": "2023-01-15T08:00:00Z"
    },
    // ...
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 60,
    "total_pages": 4,
    "links": {
      "first": "https://api.indowater.com/api/v1/meter-readings?page=1",
      "last": "https://api.indowater.com/api/v1/meter-readings?page=4",
      "prev": null,
      "next": "https://api.indowater.com/api/v1/meter-readings?page=2"
    }
  }
}
```

#### Mendapatkan Detail Pembacaan Meter

```http
GET /meter-readings/{id}
```

**Response:**

```json
{
  "status": "success",
  "message": "Data pembacaan meter berhasil diambil",
  "data": {
    "id": 1001,
    "meter_id": 101,
    "meter": {
      "id": 101,
      "serial_number": "IW12345678",
      "address": "Jl. Contoh No. 123, Jakarta"
    },
    "reading": 150.75,
    "usage": 0.5,
    "balance_before": 26.0,
    "balance_after": 25.5,
    "read_at": "2023-01-15T08:00:00Z",
    "created_at": "2023-01-15T08:00:00Z",
    "updated_at": "2023-01-15T08:00:00Z"
  }
}
```

#### Menambahkan Pembacaan Meter Baru

```http
POST /meter-readings
Content-Type: application/json

{
  "meter_id": 101,
  "reading": 151.25,
  "read_at": "2023-01-16T08:00:00Z"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Pembacaan meter berhasil ditambahkan",
  "data": {
    "id": 1002,
    "meter_id": 101,
    "reading": 151.25,
    "usage": 0.5,
    "balance_before": 25.5,
    "balance_after": 25.0,
    "read_at": "2023-01-16T08:00:00Z",
    "created_at": "2023-01-16T08:00:00Z",
    "updated_at": "2023-01-16T08:00:00Z"
  }
}
```

### Notifikasi

#### Mendapatkan Daftar Notifikasi

```http
GET /notifications
```

**Parameter Query:**
- `page` (opsional): Nomor halaman untuk pagination (default: 1)
- `per_page` (opsional): Jumlah item per halaman (default: 15, maks: 100)
- `user_id` (opsional): Filter berdasarkan ID pengguna
- `type` (opsional): Filter berdasarkan jenis notifikasi (`balance_low`, `transaction`, `system`)
- `read` (opsional): Filter berdasarkan status dibaca (`true`, `false`)

**Response:**

```json
{
  "status": "success",
  "message": "Data notifikasi berhasil diambil",
  "data": [
    {
      "id": 5001,
      "user_id": 1,
      "type": "balance_low",
      "title": "Saldo Menipis",
      "message": "Saldo meter air Anda tinggal 5 m³. Segera isi ulang untuk menghindari pemutusan.",
      "data": {
        "meter_id": 101,
        "balance": 5.0
      },
      "read": false,
      "created_at": "2023-01-17T10:00:00Z",
      "updated_at": "2023-01-17T10:00:00Z"
    },
    // ...
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 25,
    "total_pages": 2,
    "links": {
      "first": "https://api.indowater.com/api/v1/notifications?page=1",
      "last": "https://api.indowater.com/api/v1/notifications?page=2",
      "prev": null,
      "next": "https://api.indowater.com/api/v1/notifications?page=2"
    }
  }
}
```

#### Menandai Notifikasi sebagai Dibaca

```http
PUT /notifications/{id}/read
```

**Response:**

```json
{
  "status": "success",
  "message": "Notifikasi berhasil ditandai sebagai dibaca",
  "data": {
    "id": 5001,
    "read": true,
    "updated_at": "2023-01-17T11:30:00Z"
  }
}
```

#### Mengirim Notifikasi

```http
POST /notifications
Content-Type: application/json

{
  "user_id": 1,
  "type": "system",
  "title": "Pemeliharaan Sistem",
  "message": "Sistem akan mengalami pemeliharaan pada tanggal 20 Januari 2023 pukul 02:00-04:00 WIB.",
  "data": {
    "maintenance_start": "2023-01-20T02:00:00+07:00",
    "maintenance_end": "2023-01-20T04:00:00+07:00"
  }
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Notifikasi berhasil dikirim",
  "data": {
    "id": 5002,
    "user_id": 1,
    "type": "system",
    "title": "Pemeliharaan Sistem",
    "message": "Sistem akan mengalami pemeliharaan pada tanggal 20 Januari 2023 pukul 02:00-04:00 WIB.",
    "data": {
      "maintenance_start": "2023-01-20T02:00:00+07:00",
      "maintenance_end": "2023-01-20T04:00:00+07:00"
    },
    "read": false,
    "created_at": "2023-01-17T12:00:00Z",
    "updated_at": "2023-01-17T12:00:00Z"
  }
}
```

## Webhook

IndoWater menyediakan webhook untuk memberitahu sistem eksternal tentang peristiwa tertentu yang terjadi di platform.

### Mendaftarkan Webhook

```http
POST /webhooks
Content-Type: application/json

{
  "url": "https://your-server.com/webhook",
  "events": ["transaction.created", "transaction.updated", "meter.low_balance"],
  "secret": "your-webhook-secret"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Webhook berhasil didaftarkan",
  "data": {
    "id": "WH-12345",
    "url": "https://your-server.com/webhook",
    "events": ["transaction.created", "transaction.updated", "meter.low_balance"],
    "active": true,
    "created_at": "2023-01-17T14:00:00Z",
    "updated_at": "2023-01-17T14:00:00Z"
  }
}
```

### Format Payload Webhook

Setiap webhook yang dikirim akan menyertakan header `X-IndoWater-Signature` yang berisi HMAC SHA-256 dari payload menggunakan secret webhook Anda. Gunakan ini untuk memverifikasi bahwa webhook benar-benar berasal dari IndoWater.

Contoh payload untuk event `transaction.created`:

```json
{
  "id": "evt_12345",
  "type": "transaction.created",
  "created_at": "2023-01-17T15:30:00Z",
  "data": {
    "transaction": {
      "id": "TRX-67891",
      "user_id": 2,
      "meter_id": 102,
      "type": "topup",
      "amount": 20.0,
      "status": "success",
      "created_at": "2023-01-17T15:30:00Z"
    }
  }
}
```

### Jenis Event Webhook

- `transaction.created`: Dipicu ketika transaksi baru dibuat
- `transaction.updated`: Dipicu ketika status transaksi diperbarui
- `meter.registered`: Dipicu ketika meter air baru didaftarkan
- `meter.low_balance`: Dipicu ketika saldo meter air di bawah ambang batas tertentu
- `meter.empty`: Dipicu ketika saldo meter air habis
- `user.registered`: Dipicu ketika pengguna baru mendaftar

## Contoh Integrasi

### PHP

```php
<?php
// Contoh menggunakan Guzzle HTTP Client
require 'vendor/autoload.php';

use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;

$client = new Client([
    'base_uri' => 'https://api.indowater.com/api/v1/',
    'timeout'  => 30.0,
]);

// Mendapatkan token akses
try {
    $response = $client->post('auth/login', [
        'json' => [
            'email' => 'your-api-email@example.com',
            'password' => 'your-api-password'
        ]
    ]);
    
    $data = json_decode($response->getBody(), true);
    $token = $data['data']['token'];
    
    // Menggunakan token untuk request lain
    $response = $client->get('users', [
        'headers' => [
            'Authorization' => 'Bearer ' . $token
        ]
    ]);
    
    $users = json_decode($response->getBody(), true);
    print_r($users);
    
} catch (RequestException $e) {
    echo "Error: " . $e->getMessage();
}
```

### Python

```python
import requests

base_url = 'https://api.indowater.com/api/v1/'

# Mendapatkan token akses
login_data = {
    'email': 'your-api-email@example.com',
    'password': 'your-api-password'
}

response = requests.post(f'{base_url}auth/login', json=login_data)
data = response.json()

if data['status'] == 'success':
    token = data['data']['token']
    
    # Menggunakan token untuk request lain
    headers = {
        'Authorization': f'Bearer {token}'
    }
    
    response = requests.get(f'{base_url}users', headers=headers)
    users = response.json()
    print(users)
else:
    print(f"Error: {data['message']}")
```

### JavaScript

```javascript
// Contoh menggunakan Fetch API
const baseUrl = 'https://api.indowater.com/api/v1/';

// Mendapatkan token akses
const loginData = {
    email: 'your-api-email@example.com',
    password: 'your-api-password'
};

fetch(`${baseUrl}auth/login`, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(loginData)
})
.then(response => response.json())
.then(data => {
    if (data.status === 'success') {
        const token = data.data.token;
        
        // Menggunakan token untuk request lain
        return fetch(`${baseUrl}users`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
    } else {
        throw new Error(data.message);
    }
})
.then(response => response.json())
.then(users => {
    console.log(users);
})
.catch(error => {
    console.error('Error:', error);
});
```

## FAQ

### Umum

**Q: Berapa lama token akses berlaku?**

A: Token akses berlaku selama 1 jam (3600 detik). Setelah itu, Anda perlu memperbaharui token menggunakan endpoint `/auth/refresh` atau login ulang.

**Q: Bagaimana cara menangani error dari API?**

A: API akan mengembalikan kode status HTTP yang sesuai dan pesan error dalam format JSON. Contoh:

```json
{
  "status": "error",
  "message": "Validasi gagal",
  "errors": {
    "email": ["Email harus berupa alamat email yang valid"],
    "password": ["Kata sandi minimal harus 8 karakter"]
  }
}
```

**Q: Apakah API mendukung CORS?**

A: Ya, API mendukung CORS (Cross-Origin Resource Sharing) untuk domain yang terdaftar. Jika Anda perlu mengakses API dari domain baru, hubungi tim dukungan kami.

### Teknis

**Q: Bagaimana cara memverifikasi webhook?**

A: Verifikasi webhook dengan membandingkan nilai header `X-IndoWater-Signature` dengan HMAC SHA-256 dari payload menggunakan secret webhook Anda:

```php
// PHP example
$payload = file_get_contents('php://input');
$signature = $_SERVER['HTTP_X_INDOWATER_SIGNATURE'];
$secret = 'your-webhook-secret';

$calculated_signature = hash_hmac('sha256', $payload, $secret);

if (hash_equals($calculated_signature, $signature)) {
    // Webhook valid
    $data = json_decode($payload, true);
    // Process the webhook
} else {
    // Invalid signature
    http_response_code(403);
    echo 'Invalid signature';
}
```

**Q: Bagaimana cara menangani rate limiting?**

A: Pantau header `X-RateLimit-Remaining` dalam respons API. Jika nilainya mendekati 0, kurangi frekuensi request atau tunggu hingga jendela waktu di-reset (lihat header `X-RateLimit-Reset`).

**Q: Apakah API mendukung kompresi?**

A: Ya, API mendukung kompresi GZIP. Untuk mengaktifkannya, sertakan header `Accept-Encoding: gzip` dalam request Anda.

### Bisnis

**Q: Bagaimana cara mendapatkan akses ke API?**

A: Hubungi tim penjualan kami di sales@indowater.com atau telepon 0800-1234-5678 untuk mendapatkan akses ke API.

**Q: Apakah ada batasan jumlah request?**

A: Ya, ada batasan 60 request per menit per API key. Jika Anda memerlukan batas yang lebih tinggi, hubungi tim dukungan kami.

**Q: Apakah ada biaya untuk menggunakan API?**

A: Penggunaan API termasuk dalam paket layanan IndoWater. Tidak ada biaya tambahan untuk penggunaan API dalam batas wajar.

---

Untuk bantuan lebih lanjut, silakan hubungi tim dukungan teknis kami di api-support@indowater.com.