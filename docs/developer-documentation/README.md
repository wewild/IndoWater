# Dokumentasi Pengembang IndoWater

## Daftar Isi
1. [Pendahuluan](#pendahuluan)
2. [Arsitektur Sistem](#arsitektur-sistem)
3. [Lingkungan Pengembangan](#lingkungan-pengembangan)
4. [Backend (API)](#backend-api)
5. [Frontend (Web)](#frontend-web)
6. [Mobile (Android & iOS)](#mobile-android--ios)
7. [Database](#database)
8. [Integrasi Pihak Ketiga](#integrasi-pihak-ketiga)
9. [Keamanan](#keamanan)
10. [Pengujian](#pengujian)
11. [Deployment](#deployment)
12. [Pemeliharaan](#pemeliharaan)
13. [Panduan Kontribusi](#panduan-kontribusi)
14. [FAQ](#faq)

## Pendahuluan

Selamat datang di dokumentasi pengembang IndoWater. Dokumen ini berisi informasi komprehensif tentang arsitektur, teknologi, dan praktik pengembangan yang digunakan dalam sistem IndoWater.

### Tentang IndoWater

IndoWater adalah sistem manajemen meter air prabayar yang memungkinkan pelanggan untuk memantau dan mengontrol penggunaan air mereka. Sistem ini terdiri dari beberapa komponen utama:

1. **Backend API**: Menyediakan layanan RESTful untuk manajemen pengguna, meter air, transaksi, dan data penggunaan.
2. **Frontend Web**: Antarmuka web untuk admin dan pelanggan.
3. **Aplikasi Mobile**: Aplikasi Android dan iOS untuk pelanggan dan teknisi.
4. **Meter Air Pintar**: Perangkat keras yang terhubung ke sistem melalui IoT.

### Teknologi Utama

- **Backend**: PHP (Laravel Framework)
- **Frontend**: React.js dengan Tailwind CSS
- **Mobile**: Flutter
- **Database**: MySQL
- **Caching**: Redis
- **Messaging**: RabbitMQ
- **Containerization**: Docker
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Grafana, ELK Stack

## Arsitektur Sistem

### Diagram Arsitektur

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Mobile Apps     |     |  Web Frontend    |     |  Admin Panel     |
|  (Flutter)       |     |  (React)         |     |  (React)         |
|                  |     |                  |     |                  |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         |                        |                        |
         v                        v                        v
+--------------------------------------------------+-----------------+
|                                                  |                 |
|                   API Gateway                    |  Authentication |
|                                                  |                 |
+--------------------------------------------------+-----------------+
         |                        |                        |
         |                        |                        |
+--------v---------+    +---------v--------+    +---------v--------+
|                  |    |                  |    |                  |
|  User Service    |    |  Meter Service   |    | Payment Service  |
|                  |    |                  |    |                  |
+--------+---------+    +--------+---------+    +--------+---------+
         |                        |                        |
         |                        |                        |
         v                        v                        v
+--------------------------------------------------+-----------------+
|                                                  |                 |
|                   Database                       |     Cache       |
|                   (MySQL)                        |     (Redis)     |
|                                                  |                 |
+--------------------------------------------------+-----------------+
                                                            ^
                                                            |
+------------------+     +------------------+               |
|                  |     |                  |               |
|  Smart Meters    |     |  IoT Gateway     +---------------+
|  (Hardware)      |     |                  |
|                  |     |                  |
+------------------+     +------------------+
```

### Arsitektur Microservices

Sistem IndoWater menggunakan arsitektur microservices yang terdiri dari beberapa layanan independen:

1. **Authentication Service**: Menangani autentikasi dan otorisasi pengguna.
2. **User Service**: Mengelola data pengguna dan profil.
3. **Meter Service**: Mengelola meter air dan data penggunaan.
4. **Payment Service**: Menangani transaksi pembayaran dan integrasi gateway pembayaran.
5. **Notification Service**: Mengirim notifikasi ke pengguna melalui berbagai saluran.
6. **Reporting Service**: Menghasilkan laporan dan analitik.

Setiap layanan memiliki database terpisah dan berkomunikasi melalui API RESTful atau message broker (RabbitMQ).

## Lingkungan Pengembangan

### Persyaratan Sistem

- **OS**: Windows 10/11, macOS 10.15+, atau Linux
- **Docker**: Docker Desktop 4.0+
- **Git**: Git 2.30+
- **IDE**: Visual Studio Code, PhpStorm, Android Studio, atau Xcode
- **Node.js**: v16.0+
- **PHP**: v8.1+
- **Composer**: v2.0+
- **Flutter**: v3.0+
- **MySQL**: v8.0+

### Menyiapkan Lingkungan Pengembangan

1. **Clone Repository**

```bash
git clone https://github.com/indowater/indowater.git
cd indowater
```

2. **Menyiapkan Backend**

```bash
cd api
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

3. **Menyiapkan Frontend**

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

4. **Menyiapkan Mobile**

```bash
cd mobile
flutter pub get
flutter run
```

5. **Menggunakan Docker (Rekomendasi)**

```bash
docker-compose up -d
```

Ini akan menjalankan semua komponen sistem (API, frontend, database, Redis, dll.) dalam container Docker.

### Struktur Direktori

```
indowater/
├── api/                  # Backend API (Laravel)
│   ├── app/              # Kode aplikasi
│   ├── config/           # Konfigurasi
│   ├── database/         # Migrasi dan seed
│   ├── routes/           # Definisi rute API
│   └── tests/            # Unit dan feature tests
├── frontend/             # Frontend Web (React)
│   ├── public/           # Aset statis
│   ├── src/              # Kode sumber
│   │   ├── components/   # Komponen React
│   │   ├── pages/        # Halaman
│   │   ├── services/     # Layanan API
│   │   └── utils/        # Utilitas
│   └── tests/            # Unit dan integration tests
├── mobile/               # Aplikasi Mobile (Flutter)
│   ├── android/          # Konfigurasi Android
│   ├── ios/              # Konfigurasi iOS
│   ├── lib/              # Kode sumber Dart
│   │   ├── models/       # Model data
│   │   ├── screens/      # Layar UI
│   │   ├── services/     # Layanan API
│   │   └── widgets/      # Widget kustom
│   └── test/             # Unit dan widget tests
├── docs/                 # Dokumentasi
├── docker/               # Konfigurasi Docker
└── scripts/              # Script utilitas
```

## Backend (API)

Backend IndoWater dibangun menggunakan Laravel, sebuah framework PHP yang kuat dan ekspresif.

### Struktur Aplikasi

```
api/
├── app/
│   ├── Console/          # Perintah artisan
│   ├── Exceptions/       # Handler pengecualian
│   ├── Http/
│   │   ├── Controllers/  # Controller API
│   │   ├── Middleware/   # Middleware
│   │   └── Requests/     # Form request dan validasi
│   ├── Models/           # Model Eloquent
│   ├── Providers/        # Service provider
│   └── Services/         # Layanan bisnis
├── config/               # Konfigurasi
├── database/
│   ├── factories/        # Factory untuk testing
│   ├── migrations/       # Migrasi database
│   └── seeders/          # Seeder database
├── routes/
│   ├── api.php           # Rute API
│   └── channels.php      # Saluran broadcasting
└── tests/                # Unit dan feature tests
```

### Konvensi Penamaan

- **Controller**: Nama jamak, diakhiri dengan `Controller` (mis. `UsersController`)
- **Model**: Nama tunggal (mis. `User`, `Meter`, `Transaction`)
- **Migration**: Deskriptif dengan timestamp (mis. `2023_01_15_create_users_table`)
- **Service**: Nama tunggal, diakhiri dengan `Service` (mis. `PaymentService`)
- **Repository**: Nama tunggal, diakhiri dengan `Repository` (mis. `UserRepository`)

### Pola Desain

Backend menggunakan beberapa pola desain:

1. **Repository Pattern**: Memisahkan logika akses data dari controller dan service.
2. **Service Layer**: Mengenkapsulasi logika bisnis kompleks.
3. **Factory Pattern**: Digunakan untuk membuat objek kompleks.
4. **Observer Pattern**: Digunakan untuk event handling.
5. **Strategy Pattern**: Digunakan untuk implementasi gateway pembayaran.

### Contoh Implementasi Controller

```php
<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\MeterRequest;
use App\Models\Meter;
use App\Services\MeterService;
use Illuminate\Http\Request;

class MetersController extends Controller
{
    protected $meterService;

    public function __construct(MeterService $meterService)
    {
        $this->meterService = $meterService;
    }

    public function index(Request $request)
    {
        $meters = $this->meterService->getAllMeters($request->all());
        
        return response()->json([
            'status' => 'success',
            'message' => 'Data meter air berhasil diambil',
            'data' => $meters->items(),
            'meta' => [
                'current_page' => $meters->currentPage(),
                'per_page' => $meters->perPage(),
                'total' => $meters->total(),
                'total_pages' => $meters->lastPage(),
                'links' => [
                    'first' => $meters->url(1),
                    'last' => $meters->url($meters->lastPage()),
                    'prev' => $meters->previousPageUrl(),
                    'next' => $meters->nextPageUrl(),
                ],
            ],
        ]);
    }

    public function store(MeterRequest $request)
    {
        $meter = $this->meterService->createMeter($request->validated());
        
        return response()->json([
            'status' => 'success',
            'message' => 'Meter air berhasil didaftarkan',
            'data' => $meter,
        ], 201);
    }

    public function show($id)
    {
        $meter = $this->meterService->getMeterById($id);
        
        return response()->json([
            'status' => 'success',
            'message' => 'Data meter air berhasil diambil',
            'data' => $meter,
        ]);
    }

    public function update(MeterRequest $request, $id)
    {
        $meter = $this->meterService->updateMeter($id, $request->validated());
        
        return response()->json([
            'status' => 'success',
            'message' => 'Meter air berhasil diperbarui',
            'data' => $meter,
        ]);
    }

    public function destroy($id)
    {
        $this->meterService->deleteMeter($id);
        
        return response()->json([
            'status' => 'success',
            'message' => 'Meter air berhasil dihapus',
            'data' => null,
        ]);
    }

    public function topup(Request $request, $id)
    {
        $request->validate([
            'amount' => 'required|numeric|min:0.1',
            'payment_method' => 'required|string',
            'reference_id' => 'nullable|string',
        ]);
        
        $transaction = $this->meterService->topupMeter($id, $request->all());
        
        return response()->json([
            'status' => 'success',
            'message' => 'Pulsa berhasil ditambahkan',
            'data' => $transaction,
        ]);
    }
}
```

### Contoh Implementasi Service

```php
<?php

namespace App\Services;

use App\Models\Meter;
use App\Models\Transaction;
use App\Repositories\MeterRepository;
use App\Repositories\TransactionRepository;
use Illuminate\Support\Str;

class MeterService
{
    protected $meterRepository;
    protected $transactionRepository;

    public function __construct(
        MeterRepository $meterRepository,
        TransactionRepository $transactionRepository
    ) {
        $this->meterRepository = $meterRepository;
        $this->transactionRepository = $transactionRepository;
    }

    public function getAllMeters(array $params)
    {
        return $this->meterRepository->getAllWithPagination($params);
    }

    public function getMeterById($id)
    {
        return $this->meterRepository->getById($id);
    }

    public function createMeter(array $data)
    {
        return $this->meterRepository->create($data);
    }

    public function updateMeter($id, array $data)
    {
        return $this->meterRepository->update($id, $data);
    }

    public function deleteMeter($id)
    {
        return $this->meterRepository->delete($id);
    }

    public function topupMeter($id, array $data)
    {
        $meter = $this->meterRepository->getById($id);
        
        $balanceBefore = $meter->balance;
        $amount = $data['amount'];
        $balanceAfter = $balanceBefore + $amount;
        
        // Update meter balance
        $this->meterRepository->update($id, [
            'balance' => $balanceAfter,
        ]);
        
        // Create transaction record
        $transaction = $this->transactionRepository->create([
            'id' => 'TRX-' . Str::random(5),
            'user_id' => $meter->user_id,
            'meter_id' => $meter->id,
            'type' => 'topup',
            'amount' => $amount,
            'balance_before' => $balanceBefore,
            'balance_after' => $balanceAfter,
            'payment_method' => $data['payment_method'],
            'reference_id' => $data['reference_id'] ?? null,
            'status' => 'success',
        ]);
        
        // Trigger events
        event(new MeterTopupEvent($meter, $transaction));
        
        return $transaction;
    }
}
```

### Contoh Implementasi Repository

```php
<?php

namespace App\Repositories;

use App\Models\Meter;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class MeterRepository
{
    protected $model;

    public function __construct(Meter $meter)
    {
        $this->model = $meter;
    }

    public function getAllWithPagination(array $params)
    {
        $query = $this->model->query();
        
        // Apply filters
        if (isset($params['search'])) {
            $query->where(function ($q) use ($params) {
                $q->where('serial_number', 'like', '%' . $params['search'] . '%')
                  ->orWhere('address', 'like', '%' . $params['search'] . '%');
            });
        }
        
        if (isset($params['status'])) {
            $query->where('status', $params['status']);
        }
        
        if (isset($params['user_id'])) {
            $query->where('user_id', $params['user_id']);
        }
        
        // Apply sorting
        $sortField = $params['sort_field'] ?? 'created_at';
        $sortDirection = $params['sort_direction'] ?? 'desc';
        $query->orderBy($sortField, $sortDirection);
        
        // Apply pagination
        $perPage = $params['per_page'] ?? 15;
        return $query->paginate($perPage);
    }

    public function getById($id)
    {
        $meter = $this->model->with(['user', 'usageHistory'])->find($id);
        
        if (!$meter) {
            throw new ModelNotFoundException("Meter dengan ID {$id} tidak ditemukan");
        }
        
        return $meter;
    }

    public function create(array $data)
    {
        return $this->model->create($data);
    }

    public function update($id, array $data)
    {
        $meter = $this->getById($id);
        $meter->update($data);
        return $meter;
    }

    public function delete($id)
    {
        $meter = $this->getById($id);
        return $meter->delete();
    }
}
```

### Autentikasi dan Otorisasi

Backend menggunakan JWT (JSON Web Token) untuk autentikasi API. Otorisasi diimplementasikan menggunakan Laravel Policies dan Gates.

```php
// AuthController.php
public function login(Request $request)
{
    $credentials = $request->validate([
        'email' => 'required|email',
        'password' => 'required|string',
    ]);

    if (!$token = auth()->attempt($credentials)) {
        return response()->json([
            'status' => 'error',
            'message' => 'Kredensial tidak valid',
        ], 401);
    }

    return response()->json([
        'status' => 'success',
        'message' => 'Login berhasil',
        'data' => [
            'token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
        ],
    ]);
}
```

### Validasi

Validasi request menggunakan Laravel Form Request:

```php
// MeterRequest.php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class MeterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        $rules = [
            'serial_number' => 'required|string|unique:meters,serial_number',
            'user_id' => 'required|exists:users,id',
            'address' => 'required|string|max:255',
            'initial_balance' => 'nullable|numeric|min:0',
        ];

        if ($this->isMethod('PUT') || $this->isMethod('PATCH')) {
            $rules['serial_number'] = 'required|string|unique:meters,serial_number,' . $this->route('meter');
        }

        return $rules;
    }

    public function messages()
    {
        return [
            'serial_number.required' => 'Nomor seri meter air wajib diisi',
            'serial_number.unique' => 'Nomor seri meter air sudah terdaftar',
            'user_id.required' => 'ID pengguna wajib diisi',
            'user_id.exists' => 'Pengguna tidak ditemukan',
            'address.required' => 'Alamat wajib diisi',
            'initial_balance.numeric' => 'Saldo awal harus berupa angka',
            'initial_balance.min' => 'Saldo awal tidak boleh negatif',
        ];
    }
}
```

### Penanganan Error

Backend menggunakan exception handler kustom untuk menangani error:

```php
// Handler.php
<?php

namespace App\Exceptions;

use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Throwable;

class Handler extends ExceptionHandler
{
    // ...

    public function render($request, Throwable $exception)
    {
        if ($request->expectsJson()) {
            if ($exception instanceof ModelNotFoundException) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Resource tidak ditemukan',
                ], 404);
            }

            if ($exception instanceof AuthenticationException) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Tidak terautentikasi',
                ], 401);
            }

            if ($exception instanceof ValidationException) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validasi gagal',
                    'errors' => $exception->errors(),
                ], 422);
            }

            if ($exception instanceof NotFoundHttpException) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Endpoint tidak ditemukan',
                ], 404);
            }

            // Handle other exceptions
            return response()->json([
                'status' => 'error',
                'message' => $exception->getMessage(),
            ], 500);
        }

        return parent::render($request, $exception);
    }
}
```

## Frontend (Web)

Frontend IndoWater dibangun menggunakan React.js dengan Tailwind CSS untuk styling.

### Struktur Aplikasi

```
frontend/
├── public/               # Aset statis
├── src/
│   ├── assets/           # Gambar, font, dll.
│   ├── components/       # Komponen React yang dapat digunakan kembali
│   │   ├── common/       # Komponen umum (Button, Card, dll.)
│   │   ├── layout/       # Komponen layout (Header, Footer, Sidebar)
│   │   └── specific/     # Komponen spesifik untuk fitur tertentu
│   ├── config/           # Konfigurasi aplikasi
│   ├── contexts/         # React Context untuk state global
│   ├── hooks/            # Custom React hooks
│   ├── pages/            # Komponen halaman
│   ├── services/         # Layanan API
│   ├── utils/            # Fungsi utilitas
│   ├── App.js            # Komponen root
│   └── index.js          # Entry point
└── tests/                # Unit dan integration tests
```

### State Management

Frontend menggunakan kombinasi React Context API dan React Query untuk state management:

```jsx
// AuthContext.js
import React, { createContext, useContext, useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../services/authService';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const initAuth = async () => {
      try {
        const token = localStorage.getItem('token');
        if (token) {
          const userData = await authService.getCurrentUser();
          setUser(userData);
        }
      } catch (error) {
        console.error('Failed to initialize auth:', error);
        localStorage.removeItem('token');
      } finally {
        setLoading(false);
      }
    };

    initAuth();
  }, []);

  const login = async (credentials) => {
    setLoading(true);
    try {
      const response = await authService.login(credentials);
      localStorage.setItem('token', response.data.token);
      const userData = await authService.getCurrentUser();
      setUser(userData);
      navigate('/dashboard');
      return true;
    } catch (error) {
      console.error('Login failed:', error);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    navigate('/login');
  };

  const value = {
    user,
    loading,
    login,
    logout,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => useContext(AuthContext);
```

### Contoh Komponen

```jsx
// MeterList.js
import React from 'react';
import { useQuery } from 'react-query';
import { Link } from 'react-router-dom';
import meterService from '../services/meterService';
import Pagination from '../components/common/Pagination';
import MeterCard from '../components/specific/MeterCard';
import Spinner from '../components/common/Spinner';
import ErrorMessage from '../components/common/ErrorMessage';

const MeterList = () => {
  const [page, setPage] = React.useState(1);
  const [filters, setFilters] = React.useState({
    search: '',
    status: '',
  });

  const { data, isLoading, isError, error } = useQuery(
    ['meters', page, filters],
    () => meterService.getMeters({ page, ...filters }),
    {
      keepPreviousData: true,
    }
  );

  const handleSearch = (e) => {
    e.preventDefault();
    setPage(1);
    setFilters({
      ...filters,
      search: e.target.elements.search.value,
    });
  };

  const handleStatusChange = (e) => {
    setPage(1);
    setFilters({
      ...filters,
      status: e.target.value,
    });
  };

  if (isLoading) {
    return <Spinner />;
  }

  if (isError) {
    return <ErrorMessage message={error.message} />;
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Daftar Meter Air</h1>
        <Link
          to="/meters/create"
          className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded"
        >
          Tambah Meter Air
        </Link>
      </div>

      <div className="mb-6">
        <form onSubmit={handleSearch} className="flex gap-2">
          <input
            type="text"
            name="search"
            placeholder="Cari berdasarkan nomor seri atau alamat..."
            className="flex-1 border border-gray-300 rounded px-4 py-2"
            defaultValue={filters.search}
          />
          <select
            value={filters.status}
            onChange={handleStatusChange}
            className="border border-gray-300 rounded px-4 py-2"
          >
            <option value="">Semua Status</option>
            <option value="active">Aktif</option>
            <option value="inactive">Tidak Aktif</option>
          </select>
          <button
            type="submit"
            className="bg-gray-200 hover:bg-gray-300 px-4 py-2 rounded"
          >
            Cari
          </button>
        </form>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {data.data.map((meter) => (
          <MeterCard key={meter.id} meter={meter} />
        ))}
      </div>

      {data.data.length === 0 && (
        <div className="text-center py-8">
          <p className="text-gray-500">Tidak ada meter air yang ditemukan.</p>
        </div>
      )}

      <Pagination
        currentPage={page}
        totalPages={data.meta.total_pages}
        onPageChange={setPage}
      />
    </div>
  );
};

export default MeterList;
```

### Layanan API

```jsx
// meterService.js
import api from './api';

const meterService = {
  getMeters: async (params = {}) => {
    const response = await api.get('/meters', { params });
    return response.data;
  },

  getMeterById: async (id) => {
    const response = await api.get(`/meters/${id}`);
    return response.data;
  },

  createMeter: async (data) => {
    const response = await api.post('/meters', data);
    return response.data;
  },

  updateMeter: async (id, data) => {
    const response = await api.put(`/meters/${id}`, data);
    return response.data;
  },

  deleteMeter: async (id) => {
    const response = await api.delete(`/meters/${id}`);
    return response.data;
  },

  topupMeter: async (id, data) => {
    const response = await api.post(`/meters/${id}/topup`, data);
    return response.data;
  },
};

export default meterService;
```

### Routing

```jsx
// App.js
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from 'react-query';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import Layout from './components/layout/Layout';
import Dashboard from './pages/Dashboard';
import Login from './pages/Login';
import Register from './pages/Register';
import MeterList from './pages/MeterList';
import MeterDetail from './pages/MeterDetail';
import MeterCreate from './pages/MeterCreate';
import MeterEdit from './pages/MeterEdit';
import TransactionList from './pages/TransactionList';
import TransactionDetail from './pages/TransactionDetail';
import NotFound from './pages/NotFound';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }

  return children;
};

const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <AuthProvider>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route
              path="/"
              element={
                <ProtectedRoute>
                  <Layout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Dashboard />} />
              <Route path="meters" element={<MeterList />} />
              <Route path="meters/create" element={<MeterCreate />} />
              <Route path="meters/:id" element={<MeterDetail />} />
              <Route path="meters/:id/edit" element={<MeterEdit />} />
              <Route path="transactions" element={<TransactionList />} />
              <Route path="transactions/:id" element={<TransactionDetail />} />
            </Route>
            <Route path="*" element={<NotFound />} />
          </Routes>
        </AuthProvider>
      </Router>
    </QueryClientProvider>
  );
};

export default App;
```

## Mobile (Android & iOS)

Aplikasi mobile IndoWater dibangun menggunakan Flutter, sebuah framework UI dari Google untuk membuat aplikasi native untuk Android dan iOS dari satu codebase.

### Struktur Aplikasi

```
mobile/
├── android/              # Konfigurasi Android
├── ios/                  # Konfigurasi iOS
├── lib/
│   ├── config/           # Konfigurasi aplikasi
│   ├── models/           # Model data
│   ├── screens/          # Layar UI
│   │   ├── auth/         # Layar autentikasi
│   │   ├── dashboard/    # Layar dashboard
│   │   ├── meters/       # Layar manajemen meter
│   │   ├── payments/     # Layar pembayaran
│   │   └── settings/     # Layar pengaturan
│   ├── services/         # Layanan API dan lokal
│   ├── utils/            # Fungsi utilitas
│   ├── widgets/          # Widget kustom
│   ├── main.dart         # Entry point
│   └── app.dart          # Konfigurasi aplikasi
└── test/                 # Unit dan widget tests
```

### State Management

Aplikasi mobile menggunakan Provider untuk state management:

```dart
// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:indowater/models/user.dart';
import 'package:indowater/services/auth_service.dart';
import 'package:indowater/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token != null) {
        final user = await _authService.getCurrentUser();
        _user = user;
      }
    } catch (e) {
      _error = e.toString();
      await _storageService.removeToken();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      await _storageService.saveToken(response.token);
      _user = await _authService.getCurrentUser();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storageService.removeToken();
    _user = null;
    notifyListeners();
  }
}
```

### Contoh Layar

```dart
// lib/screens/meters/meter_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater/models/meter.dart';
import 'package:indowater/providers/meter_provider.dart';
import 'package:indowater/widgets/meter_card.dart';
import 'package:indowater/widgets/error_message.dart';
import 'package:indowater/widgets/loading_indicator.dart';

class MeterListScreen extends StatefulWidget {
  const MeterListScreen({Key? key}) : super(key: key);

  @override
  _MeterListScreenState createState() => _MeterListScreenState();
}

class _MeterListScreenState extends State<MeterListScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeterProvider>(context, listen: false).getMeters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    Provider.of<MeterProvider>(context, listen: false).getMeters(
      search: _searchController.text,
      status: _statusFilter,
    );
  }

  void _handleStatusChange(String? value) {
    setState(() {
      _statusFilter = value ?? '';
    });
    _handleSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Meter Air'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/meters/create');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari meter air...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _statusFilter.isEmpty ? null : _statusFilter,
                  hint: const Text('Status'),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('Semua'),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Aktif'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Tidak Aktif'),
                    ),
                  ],
                  onChanged: _handleStatusChange,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<MeterProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator();
                }

                if (provider.error != null) {
                  return ErrorMessage(message: provider.error!);
                }

                final meters = provider.meters;

                if (meters.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada meter air yang ditemukan.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: meters.length,
                  itemBuilder: (context, index) {
                    final meter = meters[index];
                    return MeterCard(
                      meter: meter,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/meters/detail',
                          arguments: meter.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Layanan API

```dart
// lib/services/meter_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indowater/config/api_config.dart';
import 'package:indowater/models/meter.dart';
import 'package:indowater/models/pagination.dart';
import 'package:indowater/services/storage_service.dart';
import 'package:indowater/utils/api_exception.dart';

class MeterService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<PaginatedResponse<Meter>> getMeters({
    int page = 1,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final uri = Uri.parse(ApiConfig.baseUrl + '/meters')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<Meter> meters = (jsonData['data'] as List)
            .map((item) => Meter.fromJson(item))
            .toList();

        final meta = PaginationMeta.fromJson(jsonData['meta']);

        return PaginatedResponse<Meter>(
          data: meters,
          meta: meta,
        );
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Meter> getMeterById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/meters/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Meter.fromJson(jsonData['data']);
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Meter> createMeter(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/meters'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Meter.fromJson(jsonData['data']);
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Meter> updateMeter(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/meters/$id'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Meter.fromJson(jsonData['data']);
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeter(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/meters/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> topupMeter(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/meters/$id/topup'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

### Routing

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater/providers/auth_provider.dart';
import 'package:indowater/providers/meter_provider.dart';
import 'package:indowater/providers/transaction_provider.dart';
import 'package:indowater/screens/auth/login_screen.dart';
import 'package:indowater/screens/auth/register_screen.dart';
import 'package:indowater/screens/dashboard/dashboard_screen.dart';
import 'package:indowater/screens/meters/meter_list_screen.dart';
import 'package:indowater/screens/meters/meter_detail_screen.dart';
import 'package:indowater/screens/meters/meter_create_screen.dart';
import 'package:indowater/screens/meters/meter_edit_screen.dart';
import 'package:indowater/screens/payments/payment_screen.dart';
import 'package:indowater/screens/transactions/transaction_list_screen.dart';
import 'package:indowater/screens/transactions/transaction_detail_screen.dart';
import 'package:indowater/screens/settings/settings_screen.dart';
import 'package:indowater/widgets/auth_wrapper.dart';

class IndoWaterApp extends StatelessWidget {
  const IndoWaterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MeterProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'IndoWater',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/meters': (context) => const MeterListScreen(),
          '/meters/create': (context) => const MeterCreateScreen(),
          '/meters/detail': (context) => const MeterDetailScreen(),
          '/meters/edit': (context) => const MeterEditScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/transactions': (context) => const TransactionListScreen(),
          '/transactions/detail': (context) => const TransactionDetailScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
```

### Integrasi QR Code

```dart
// lib/screens/meters/meter_scan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:indowater/providers/meter_provider.dart';
import 'package:indowater/utils/snackbar_helper.dart';

class MeterScanScreen extends StatefulWidget {
  const MeterScanScreen({Key? key}) : super(key: key);

  @override
  _MeterScanScreenState createState() => _MeterScanScreenState();
}

class _MeterScanScreenState extends State<MeterScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing || scanData.code == null) return;

      setState(() {
        _isProcessing = true;
      });

      controller.pauseCamera();

      try {
        final meterProvider = Provider.of<MeterProvider>(
          context,
          listen: false,
        );

        final result = await meterProvider.getMeterBySerialNumber(
          scanData.code!,
        );

        if (result != null) {
          Navigator.pop(context, result);
        } else {
          SnackbarHelper.showError(
            context,
            'Meter air tidak ditemukan. Pastikan QR code valid.',
          );
          controller.resumeCamera();
        }
      } catch (e) {
        SnackbarHelper.showError(context, e.toString());
        controller.resumeCamera();
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Meter Air'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Arahkan kamera ke QR code pada meter air',
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Integrasi Payment Gateway

```dart
// lib/services/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indowater/config/api_config.dart';
import 'package:indowater/services/storage_service.dart';
import 'package:indowater/utils/api_exception.dart';

class PaymentService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> createPayment({
    required int meterId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/transactions'),
        headers: await _getHeaders(),
        body: json.encode({
          'meter_id': meterId,
          'type': 'topup',
          'amount': amount,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMidtransToken({
    required String transactionId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payments/midtrans/token'),
        headers: await _getHeaders(),
        body: json.encode({
          'transaction_id': transactionId,
          'amount': amount,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDokuToken({
    required String transactionId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payments/doku/token'),
        headers: await _getHeaders(),
        body: json.encode({
          'transaction_id': transactionId,
          'amount': amount,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transactions/$transactionId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

## Database

IndoWater menggunakan MySQL sebagai database utama. Berikut adalah skema database utama:

### Skema Database

```
+------------------+     +------------------+     +------------------+
|      users       |     |      meters      |     |   transactions   |
+------------------+     +------------------+     +------------------+
| id               |<-+  | id               |<-+  | id               |
| name             |  |  | serial_number    |  |  | user_id          |
| email            |  |  | user_id          |--+  | meter_id         |--+
| phone            |  |  | address          |     | type             |  |
| address          |  |  | status           |     | amount           |  |
| password         |  |  | balance          |     | balance_before   |  |
| status           |  |  | last_reading     |     | balance_after    |  |
| created_at       |  |  | created_at       |     | payment_method   |  |
| updated_at       |  |  | updated_at       |     | reference_id     |  |
+------------------+  |  +------------------+     | status           |  |
                      |                           | created_at       |  |
                      |                           | updated_at       |  |
                      |                           +------------------+  |
                      |                                                 |
                      |  +------------------+     +------------------+  |
                      |  |  meter_readings  |     |  notifications   |  |
                      |  +------------------+     +------------------+  |
                      |  | id               |     | id               |  |
                      |  | meter_id         |--+  | user_id          |--+
                      |  | reading          |  |  | type             |
                      |  | usage            |  |  | title            |
                      |  | balance_before   |  |  | message          |
                      |  | balance_after    |  |  | data             |
                      |  | read_at          |  |  | read             |
                      |  | created_at       |  |  | created_at       |
                      |  | updated_at       |  |  | updated_at       |
                      |  +------------------+  |  +------------------+
                      |                        |
                      +------------------------+
```

### Migrasi Database

Migrasi database menggunakan Laravel Migrations:

```php
// database/migrations/2023_01_15_000001_create_users_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone')->nullable();
            $table->text('address')->nullable();
            $table->string('password');
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
```

```php
// database/migrations/2023_01_15_000002_create_meters_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('meters', function (Blueprint $table) {
            $table->id();
            $table->string('serial_number')->unique();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->text('address');
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->decimal('balance', 10, 2)->default(0);
            $table->decimal('last_reading', 10, 2)->default(0);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('meters');
    }
};
```

```php
// database/migrations/2023_01_15_000003_create_transactions_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('meter_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['topup', 'usage'])->default('topup');
            $table->decimal('amount', 10, 2);
            $table->decimal('balance_before', 10, 2);
            $table->decimal('balance_after', 10, 2);
            $table->string('payment_method')->nullable();
            $table->string('reference_id')->nullable();
            $table->enum('status', ['pending', 'success', 'failed'])->default('pending');
            $table->json('payment_details')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('transactions');
    }
};
```

```php
// database/migrations/2023_01_15_000004_create_meter_readings_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('meter_readings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('meter_id')->constrained()->onDelete('cascade');
            $table->decimal('reading', 10, 2);
            $table->decimal('usage', 10, 2);
            $table->decimal('balance_before', 10, 2);
            $table->decimal('balance_after', 10, 2);
            $table->timestamp('read_at');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('meter_readings');
    }
};
```

```php
// database/migrations/2023_01_15_000005_create_notifications_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['balance_low', 'transaction', 'system'])->default('system');
            $table->string('title');
            $table->text('message');
            $table->json('data')->nullable();
            $table->boolean('read')->default(false);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('notifications');
    }
};
```

## Integrasi Pihak Ketiga

IndoWater terintegrasi dengan beberapa layanan pihak ketiga:

### Midtrans (Payment Gateway)

```php
// app/Services/PaymentGateway/MidtransService.php
<?php

namespace App\Services\PaymentGateway;

use App\Models\Transaction;
use Midtrans\Config;
use Midtrans\Snap;

class MidtransService implements PaymentGatewayInterface
{
    public function __construct()
    {
        Config::$serverKey = config('services.midtrans.server_key');
        Config::$clientKey = config('services.midtrans.client_key');
        Config::$isProduction = config('services.midtrans.is_production');
        Config::$isSanitized = true;
        Config::$is3ds = true;
    }

    public function createPayment(Transaction $transaction)
    {
        $params = [
            'transaction_details' => [
                'order_id' => $transaction->id,
                'gross_amount' => (int) ($transaction->amount * 10000),
            ],
            'customer_details' => [
                'first_name' => $transaction->user->name,
                'email' => $transaction->user->email,
                'phone' => $transaction->user->phone,
            ],
            'item_details' => [
                [
                    'id' => 'TOPUP-' . $transaction->meter_id,
                    'price' => (int) ($transaction->amount * 10000),
                    'quantity' => 1,
                    'name' => 'Topup Pulsa Air ' . $transaction->amount . ' m³',
                ],
            ],
        ];

        try {
            $snapToken = Snap::getSnapToken($params);
            
            return [
                'token' => $snapToken,
                'client_key' => Config::$clientKey,
            ];
        } catch (\Exception $e) {
            throw new \Exception('Gagal membuat pembayaran: ' . $e->getMessage());
        }
    }

    public function handleCallback(array $data)
    {
        $orderId = $data['order_id'];
        $statusCode = $data['status_code'];
        $transactionStatus = $data['transaction_status'];
        
        $transaction = Transaction::findOrFail($orderId);
        
        if ($statusCode == '200') {
            if (in_array($transactionStatus, ['capture', 'settlement'])) {
                $transaction->status = 'success';
            } elseif (in_array($transactionStatus, ['cancel', 'deny', 'expire'])) {
                $transaction->status = 'failed';
            } elseif ($transactionStatus == 'pending') {
                $transaction->status = 'pending';
            }
        } else {
            $transaction->status = 'failed';
        }
        
        $transaction->payment_details = $data;
        $transaction->save();
        
        if ($transaction->status == 'success') {
            // Update meter balance
            $meter = $transaction->meter;
            $meter->balance += $transaction->amount;
            $meter->save();
            
            // Create notification
            $transaction->user->notifications()->create([
                'type' => 'transaction',
                'title' => 'Pembayaran Berhasil',
                'message' => 'Pembayaran sebesar ' . $transaction->amount . ' m³ berhasil. Saldo meter air Anda telah diperbarui.',
                'data' => [
                    'transaction_id' => $transaction->id,
                    'amount' => $transaction->amount,
                    'balance' => $meter->balance,
                ],
            ]);
        }
        
        return $transaction;
    }
}
```

### DOKU (Payment Gateway)

```php
// app/Services/PaymentGateway/DokuService.php
<?php

namespace App\Services\PaymentGateway;

use App\Models\Transaction;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class DokuService implements PaymentGatewayInterface
{
    protected $baseUrl;
    protected $clientId;
    protected $secretKey;
    
    public function __construct()
    {
        $this->baseUrl = config('services.doku.base_url');
        $this->clientId = config('services.doku.client_id');
        $this->secretKey = config('services.doku.secret_key');
    }
    
    public function createPayment(Transaction $transaction)
    {
        $requestId = Str::uuid()->toString();
        $requestTimestamp = gmdate('Y-m-d H:i:s');
        $requestTarget = '/checkout/v1/payment';
        
        $digest = base64_encode(hash('sha256', json_encode([
            'amount' => $transaction->amount * 10000,
            'customer' => [
                'email' => $transaction->user->email,
                'name' => $transaction->user->name,
            ],
            'order' => [
                'invoice_number' => $transaction->id,
                'line_items' => [
                    [
                        'name' => 'Topup Pulsa Air ' . $transaction->amount . ' m³',
                        'price' => $transaction->amount * 10000,
                        'quantity' => 1,
                    ],
                ],
            ],
        ]), true));
        
        $signature = base64_encode(hash_hmac('sha256', "POST:{$requestTarget}:{$digest}:{$requestTimestamp}", $this->secretKey, true));
        
        $response = Http::withHeaders([
            'Client-Id' => $this->clientId,
            'Request-Id' => $requestId,
            'Request-Timestamp' => $requestTimestamp,
            'Signature' => "HMACSHA256={$signature}",
            'Content-Type' => 'application/json',
        ])->post("{$this->baseUrl}{$requestTarget}", [
            'amount' => $transaction->amount * 10000,
            'customer' => [
                'email' => $transaction->user->email,
                'name' => $transaction->user->name,
            ],
            'order' => [
                'invoice_number' => $transaction->id,
                'line_items' => [
                    [
                        'name' => 'Topup Pulsa Air ' . $transaction->amount . ' m³',
                        'price' => $transaction->amount * 10000,
                        'quantity' => 1,
                    ],
                ],
            ],
        ]);
        
        if ($response->successful()) {
            $data = $response->json();
            
            return [
                'payment_url' => $data['payment_url'],
                'request_id' => $requestId,
            ];
        } else {
            throw new \Exception('Gagal membuat pembayaran: ' . $response->body());
        }
    }
    
    public function handleCallback(array $data)
    {
        $transaction = Transaction::findOrFail($data['order']['invoice_number']);
        
        if ($data['transaction']['status'] == 'SUCCESS') {
            $transaction->status = 'success';
        } elseif ($data['transaction']['status'] == 'FAILED') {
            $transaction->status = 'failed';
        } else {
            $transaction->status = 'pending';
        }
        
        $transaction->payment_details = $data;
        $transaction->save();
        
        if ($transaction->status == 'success') {
            // Update meter balance
            $meter = $transaction->meter;
            $meter->balance += $transaction->amount;
            $meter->save();
            
            // Create notification
            $transaction->user->notifications()->create([
                'type' => 'transaction',
                'title' => 'Pembayaran Berhasil',
                'message' => 'Pembayaran sebesar ' . $transaction->amount . ' m³ berhasil. Saldo meter air Anda telah diperbarui.',
                'data' => [
                    'transaction_id' => $transaction->id,
                    'amount' => $transaction->amount,
                    'balance' => $meter->balance,
                ],
            ]);
        }
        
        return $transaction;
    }
}
```

### Firebase Cloud Messaging (Notifikasi)

```php
// app/Services/NotificationService.php
<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;

class NotificationService
{
    protected $serverKey;
    
    public function __construct()
    {
        $this->serverKey = config('services.firebase.server_key');
    }
    
    public function sendPushNotification(User $user, array $notification)
    {
        if (!$user->device_token) {
            return false;
        }
        
        $response = Http::withHeaders([
            'Authorization' => 'key=' . $this->serverKey,
            'Content-Type' => 'application/json',
        ])->post('https://fcm.googleapis.com/fcm/send', [
            'to' => $user->device_token,
            'notification' => [
                'title' => $notification['title'],
                'body' => $notification['message'],
                'sound' => 'default',
            ],
            'data' => [
                'type' => $notification['type'],
                'id' => $notification['id'],
                'data' => $notification['data'] ?? null,
            ],
        ]);
        
        return $response->successful();
    }
    
    public function sendBulkPushNotifications(array $deviceTokens, array $notification)
    {
        if (empty($deviceTokens)) {
            return false;
        }
        
        $response = Http::withHeaders([
            'Authorization' => 'key=' . $this->serverKey,
            'Content-Type' => 'application/json',
        ])->post('https://fcm.googleapis.com/fcm/send', [
            'registration_ids' => $deviceTokens,
            'notification' => [
                'title' => $notification['title'],
                'body' => $notification['message'],
                'sound' => 'default',
            ],
            'data' => [
                'type' => $notification['type'],
                'id' => $notification['id'],
                'data' => $notification['data'] ?? null,
            ],
        ]);
        
        return $response->successful();
    }
}
```

## Keamanan

### Autentikasi dan Otorisasi

IndoWater menggunakan JWT (JSON Web Token) untuk autentikasi API dan Laravel Policies untuk otorisasi.

```php
// config/auth.php
'guards' => [
    'web' => [
        'driver' => 'session',
        'provider' => 'users',
    ],
    'api' => [
        'driver' => 'jwt',
        'provider' => 'users',
    ],
],
```

```php
// app/Policies/MeterPolicy.php
<?php

namespace App\Policies;

use App\Models\Meter;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class MeterPolicy
{
    use HandlesAuthorization;

    public function viewAny(User $user)
    {
        return true;
    }

    public function view(User $user, Meter $meter)
    {
        return $user->id === $meter->user_id || $user->isAdmin();
    }

    public function create(User $user)
    {
        return $user->isAdmin();
    }

    public function update(User $user, Meter $meter)
    {
        return $user->isAdmin();
    }

    public function delete(User $user, Meter $meter)
    {
        return $user->isAdmin();
    }

    public function topup(User $user, Meter $meter)
    {
        return $user->id === $meter->user_id || $user->isAdmin();
    }
}
```

### Validasi Input

Semua input pengguna divalidasi menggunakan Laravel Form Request:

```php
// app/Http/Requests/MeterRequest.php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class MeterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        $rules = [
            'serial_number' => 'required|string|unique:meters,serial_number',
            'user_id' => 'required|exists:users,id',
            'address' => 'required|string|max:255',
            'initial_balance' => 'nullable|numeric|min:0',
        ];

        if ($this->isMethod('PUT') || $this->isMethod('PATCH')) {
            $rules['serial_number'] = 'required|string|unique:meters,serial_number,' . $this->route('meter');
        }

        return $rules;
    }
}
```

### Enkripsi Data

Data sensitif dienkripsi menggunakan Laravel's built-in encryption:

```php
// app/Models/User.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'address',
        'password',
        'status',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    public function setPasswordAttribute($value)
    {
        $this->attributes['password'] = bcrypt($value);
    }

    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }

    public function meters()
    {
        return $this->hasMany(Meter::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function isAdmin()
    {
        return $this->role === 'admin';
    }
}
```

### HTTPS

Semua komunikasi API menggunakan HTTPS dengan sertifikat SSL yang valid.

### Rate Limiting

API menerapkan rate limiting untuk mencegah serangan brute force dan DoS:

```php
// app/Http/Kernel.php
protected $middlewareGroups = [
    'api' => [
        'throttle:api',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],
];
```

```php
// app/Providers/RouteServiceProvider.php
public function boot()
{
    $this->configureRateLimiting();
    // ...
}

protected function configureRateLimiting()
{
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(60)->by(optional($request->user())->id ?: $request->ip());
    });
}
```

## Pengujian

IndoWater menggunakan berbagai jenis pengujian untuk memastikan kualitas kode:

### Unit Testing (Backend)

```php
// tests/Unit/Services/MeterServiceTest.php
<?php

namespace Tests\Unit\Services;

use App\Models\Meter;
use App\Models\User;
use App\Repositories\MeterRepository;
use App\Repositories\TransactionRepository;
use App\Services\MeterService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MeterServiceTest extends TestCase
{
    use RefreshDatabase;

    protected $meterService;
    protected $meterRepository;
    protected $transactionRepository;

    public function setUp(): void
    {
        parent::setUp();

        $this->meterRepository = $this->mock(MeterRepository::class);
        $this->transactionRepository = $this->mock(TransactionRepository::class);
        $this->meterService = new MeterService(
            $this->meterRepository,
            $this->transactionRepository
        );
    }

    public function testGetAllMeters()
    {
        $params = ['status' => 'active'];
        $expectedResult = collect([new Meter()]);

        $this->meterRepository
            ->shouldReceive('getAllWithPagination')
            ->with($params)
            ->once()
            ->andReturn($expectedResult);

        $result = $this->meterService->getAllMeters($params);

        $this->assertEquals($expectedResult, $result);
    }

    public function testGetMeterById()
    {
        $meterId = 1;
        $expectedMeter = new Meter(['id' => $meterId]);

        $this->meterRepository
            ->shouldReceive('getById')
            ->with($meterId)
            ->once()
            ->andReturn($expectedMeter);

        $result = $this->meterService->getMeterById($meterId);

        $this->assertEquals($expectedMeter, $result);
    }

    public function testCreateMeter()
    {
        $data = [
            'serial_number' => 'IW12345678',
            'user_id' => 1,
            'address' => 'Test Address',
        ];
        $expectedMeter = new Meter($data);

        $this->meterRepository
            ->shouldReceive('create')
            ->with($data)
            ->once()
            ->andReturn($expectedMeter);

        $result = $this->meterService->createMeter($data);

        $this->assertEquals($expectedMeter, $result);
    }

    public function testTopupMeter()
    {
        $meterId = 1;
        $user = User::factory()->create();
        $meter = Meter::factory()->create([
            'id' => $meterId,
            'user_id' => $user->id,
            'balance' => 10,
        ]);
        $data = [
            'amount' => 5,
            'payment_method' => 'credit_card',
            'reference_id' => 'REF123',
        ];

        $this->meterRepository
            ->shouldReceive('getById')
            ->with($meterId)
            ->once()
            ->andReturn($meter);

        $this->meterRepository
            ->shouldReceive('update')
            ->with($meterId, ['balance' => 15])
            ->once();

        $expectedTransaction = [
            'id' => 'TRX-12345',
            'user_id' => $user->id,
            'meter_id' => $meterId,
            'type' => 'topup',
            'amount' => 5,
            'balance_before' => 10,
            'balance_after' => 15,
            'payment_method' => 'credit_card',
            'reference_id' => 'REF123',
            'status' => 'success',
        ];

        $this->transactionRepository
            ->shouldReceive('create')
            ->once()
            ->andReturn($expectedTransaction);

        $result = $this->meterService->topupMeter($meterId, $data);

        $this->assertEquals($expectedTransaction, $result);
    }
}
```

### Feature Testing (Backend)

```php
// tests/Feature/API/MeterControllerTest.php
<?php

namespace Tests\Feature\API;

use App\Models\Meter;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Tymon\JWTAuth\Facades\JWTAuth;

class MeterControllerTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $token;

    public function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $this->token = JWTAuth::fromUser($this->user);
    }

    public function testIndex()
    {
        Meter::factory()->count(3)->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/meters');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'serial_number',
                        'user_id',
                        'address',
                        'status',
                        'balance',
                        'last_reading',
                        'created_at',
                        'updated_at',
                    ],
                ],
                'meta' => [
                    'current_page',
                    'per_page',
                    'total',
                    'total_pages',
                    'links',
                ],
            ]);
    }

    public function testStore()
    {
        $data = [
            'serial_number' => 'IW12345678',
            'user_id' => $this->user->id,
            'address' => 'Test Address',
            'initial_balance' => 10,
        ];

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/meters', $data);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'id',
                    'serial_number',
                    'user_id',
                    'address',
                    'status',
                    'balance',
                    'last_reading',
                    'created_at',
                    'updated_at',
                ],
            ]);

        $this->assertDatabaseHas('meters', [
            'serial_number' => 'IW12345678',
            'user_id' => $this->user->id,
            'address' => 'Test Address',
            'balance' => 10,
        ]);
    }

    public function testShow()
    {
        $meter = Meter::factory()->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->getJson('/api/v1/meters/' . $meter->id);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'id',
                    'serial_number',
                    'user_id',
                    'address',
                    'status',
                    'balance',
                    'last_reading',
                    'created_at',
                    'updated_at',
                ],
            ]);
    }

    public function testTopup()
    {
        $meter = Meter::factory()->create([
            'user_id' => $this->user->id,
            'balance' => 10,
        ]);

        $data = [
            'amount' => 5,
            'payment_method' => 'credit_card',
            'reference_id' => 'REF123',
        ];

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->token,
        ])->postJson('/api/v1/meters/' . $meter->id . '/topup', $data);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'transaction_id',
                    'meter_id',
                    'amount',
                    'balance_before',
                    'balance_after',
                    'payment_method',
                    'reference_id',
                    'status',
                    'created_at',
                ],
            ]);

        $this->assertDatabaseHas('transactions', [
            'meter_id' => $meter->id,
            'type' => 'topup',
            'amount' => 5,
            'balance_before' => 10,
            'balance_after' => 15,
            'payment_method' => 'credit_card',
            'reference_id' => 'REF123',
            'status' => 'success',
        ]);

        $meter->refresh();
        $this->assertEquals(15, $meter->balance);
    }
}
```

### Unit Testing (Frontend)

```jsx
// frontend/src/components/MeterCard.test.js
import React from 'react';
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import MeterCard from './MeterCard';

describe('MeterCard', () => {
  const mockMeter = {
    id: 1,
    serial_number: 'IW12345678',
    address: 'Test Address',
    status: 'active',
    balance: 25.5,
    last_reading: 150.75,
  };

  test('renders meter information correctly', () => {
    render(
      <BrowserRouter>
        <MeterCard meter={mockMeter} />
      </BrowserRouter>
    );

    expect(screen.getByText('IW12345678')).toBeInTheDocument();
    expect(screen.getByText('Test Address')).toBeInTheDocument();
    expect(screen.getByText('25.5 m³')).toBeInTheDocument();
    expect(screen.getByText('Aktif')).toBeInTheDocument();
  });

  test('renders status badge with correct color', () => {
    render(
      <BrowserRouter>
        <MeterCard meter={mockMeter} />
      </BrowserRouter>
    );

    const statusBadge = screen.getByText('Aktif');
    expect(statusBadge).toHaveClass('bg-green-100');
    expect(statusBadge).toHaveClass('text-green-800');
  });

  test('renders inactive status with correct color', () => {
    const inactiveMeter = { ...mockMeter, status: 'inactive' };
    
    render(
      <BrowserRouter>
        <MeterCard meter={inactiveMeter} />
      </BrowserRouter>
    );

    const statusBadge = screen.getByText('Tidak Aktif');
    expect(statusBadge).toHaveClass('bg-red-100');
    expect(statusBadge).toHaveClass('text-red-800');
  });

  test('renders low balance warning when balance is below 10', () => {
    const lowBalanceMeter = { ...mockMeter, balance: 5.0 };
    
    render(
      <BrowserRouter>
        <MeterCard meter={lowBalanceMeter} />
      </BrowserRouter>
    );

    expect(screen.getByText('Saldo Menipis!')).toBeInTheDocument();
  });

  test('does not render low balance warning when balance is above 10', () => {
    render(
      <BrowserRouter>
        <MeterCard meter={mockMeter} />
      </BrowserRouter>
    );

    expect(screen.queryByText('Saldo Menipis!')).not.toBeInTheDocument();
  });

  test('renders detail link correctly', () => {
    render(
      <BrowserRouter>
        <MeterCard meter={mockMeter} />
      </BrowserRouter>
    );

    const detailLink = screen.getByText('Lihat Detail');
    expect(detailLink).toHaveAttribute('href', '/meters/1');
  });
});
```

### Widget Testing (Mobile)

```dart
// test/widgets/meter_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater/models/meter.dart';
import 'package:indowater/widgets/meter_card.dart';

void main() {
  testWidgets('MeterCard displays meter information correctly', (WidgetTester tester) async {
    final meter = Meter(
      id: 1,
      serialNumber: 'IW12345678',
      address: 'Test Address',
      status: 'active',
      balance: 25.5,
      lastReading: 150.75,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeterCard(
            meter: meter,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('IW12345678'), findsOneWidget);
    expect(find.text('Test Address'), findsOneWidget);
    expect(find.text('25.5 m³'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
  });

  testWidgets('MeterCard displays status badge with correct color', (WidgetTester tester) async {
    final meter = Meter(
      id: 1,
      serialNumber: 'IW12345678',
      address: 'Test Address',
      status: 'active',
      balance: 25.5,
      lastReading: 150.75,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeterCard(
            meter: meter,
            onTap: () {},
          ),
        ),
      ),
    );

    final statusBadge = find.byType(Container).evaluate().where((element) {
      final container = element.widget as Container;
      return container.decoration is BoxDecoration &&
          (container.decoration as BoxDecoration).color == Colors.green[100];
    });

    expect(statusBadge, findsOneWidget);
  });

  testWidgets('MeterCard displays low balance warning when balance is below 10', (WidgetTester tester) async {
    final meter = Meter(
      id: 1,
      serialNumber: 'IW12345678',
      address: 'Test Address',
      status: 'active',
      balance: 5.0,
      lastReading: 150.75,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeterCard(
            meter: meter,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Saldo Menipis!'), findsOneWidget);
  });

  testWidgets('MeterCard does not display low balance warning when balance is above 10', (WidgetTester tester) async {
    final meter = Meter(
      id: 1,
      serialNumber: 'IW12345678',
      address: 'Test Address',
      status: 'active',
      balance: 25.5,
      lastReading: 150.75,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeterCard(
            meter: meter,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Saldo Menipis!'), findsNothing);
  });

  testWidgets('MeterCard calls onTap when tapped', (WidgetTester tester) async {
    final meter = Meter(
      id: 1,
      serialNumber: 'IW12345678',
      address: 'Test Address',
      status: 'active',
      balance: 25.5,
      lastReading: 150.75,
    );

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeterCard(
            meter: meter,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MeterCard));
    expect(tapped, true);
  });
}
```

## Deployment

IndoWater menggunakan Docker dan Docker Compose untuk deployment:

### Docker

```dockerfile
# api/Dockerfile
FROM php:8.1-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy existing application directory
COPY . .

# Install dependencies
RUN composer install --no-interaction --no-dev --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
```

```dockerfile
# frontend/Dockerfile
FROM node:16-alpine as build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  # PHP API Backend
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: indowater-api
    restart: unless-stopped
    volumes:
      - ./api:/var/www/html
      - ./api/storage:/var/www/html/storage
    depends_on:
      - db
      - redis
    networks:
      - indowater-network

  # Nginx Service for API
  nginx-api:
    image: nginx:alpine
    container_name: indowater-nginx-api
    restart: unless-stopped
    ports:
      - "8000:80"
    volumes:
      - ./api:/var/www/html
      - ./docker/nginx/api.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - api
    networks:
      - indowater-network

  # MySQL Database
  db:
    image: mysql:8.0
    container_name: indowater-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_USER: ${DB_USERNAME}
    volumes:
      - indowater-db-data:/var/lib/mysql
    networks:
      - indowater-network
    ports:
      - "3306:3306"

  # React Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: indowater-frontend
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      - api
    networks:
      - indowater-network

  # Redis Service
  redis:
    image: redis:alpine
    container_name: indowater-redis
    restart: unless-stopped
    networks:
      - indowater-network
    volumes:
      - indowater-redis-data:/data

  # PHPMyAdmin Service
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: indowater-phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: db
      PMA_PORT: 3306
      PMA_USER: ${DB_USERNAME}
      PMA_PASSWORD: ${DB_PASSWORD}
    ports:
      - "8080:80"
    depends_on:
      - db
    networks:
      - indowater-network

  # Mailhog Service (for email testing)
  mailhog:
    image: mailhog/mailhog
    container_name: indowater-mailhog
    restart: unless-stopped
    ports:
      - "1025:1025" # SMTP port
      - "8025:8025" # Web UI port
    networks:
      - indowater-network

networks:
  indowater-network:
    driver: bridge

volumes:
  indowater-db-data:
    driver: local
  indowater-redis-data:
    driver: local
```

### CI/CD

IndoWater menggunakan GitHub Actions untuk CI/CD:

```yaml
# .github/workflows/api.yml
name: API CI/CD

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'api/**'
      - '.github/workflows/api.yml'
  pull_request:
    branches: [ main, develop ]
    paths:
      - 'api/**'
      - '.github/workflows/api.yml'

jobs:
  test:
    name: Test API
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: indowater_test
          MYSQL_ROOT_PASSWORD: password
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.1'
          extensions: mbstring, dom, fileinfo, mysql
          coverage: xdebug
      
      - name: Copy .env
        run: |
          cd api
          cp .env.example .env
          sed -i 's/DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/g' .env
          sed -i 's/DB_DATABASE=laravel/DB_DATABASE=indowater_test/g' .env
          sed -i 's/DB_USERNAME=root/DB_USERNAME=root/g' .env
          sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env
      
      - name: Install Dependencies
        run: |
          cd api
          composer install --no-ansi --no-interaction --no-scripts --no-progress --prefer-dist
      
      - name: Generate key
        run: |
          cd api
          php artisan key:generate
      
      - name: Run Migrations
        run: |
          cd api
          php artisan migrate --seed
      
      - name: Run Tests
        run: |
          cd api
          php artisan test --coverage-clover=coverage.xml
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./api/coverage.xml
          fail_ci_if_error: false
  
  build:
    name: Build and Push API Docker Image
    runs-on: ubuntu-latest
    needs: test
    if: github.event_name == 'push'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Extract branch name
        shell: bash
        run: echo "BRANCH_NAME=$(echo ${GITHUB_REF#refs/heads/})" >> $GITHUB_ENV
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: ./api
          push: true
          tags: |
            indowater/api:${{ env.BRANCH_NAME }}
            ${{ env.BRANCH_NAME == 'main' && 'indowater/api:latest' || '' }}
  
  deploy:
    name: Deploy API
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name == 'push'
    
    steps:
      - name: Extract branch name
        shell: bash
        run: echo "BRANCH_NAME=$(echo ${GITHUB_REF#refs/heads/})" >> $GITHUB_ENV
      
      - name: Deploy to Development
        if: env.BRANCH_NAME == 'develop'
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.DEV_SSH_HOST }}
          username: ${{ secrets.DEV_SSH_USERNAME }}
          key: ${{ secrets.DEV_SSH_KEY }}
          script: |
            cd /opt/indowater
            docker-compose pull api
            docker-compose up -d api
            docker-compose exec -T api php artisan migrate --force
      
      - name: Deploy to Production
        if: env.BRANCH_NAME == 'main'
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.PROD_SSH_HOST }}
          username: ${{ secrets.PROD_SSH_USERNAME }}
          key: ${{ secrets.PROD_SSH_KEY }}
          script: |
            cd /opt/indowater
            docker-compose pull api
            docker-compose up -d api
            docker-compose exec -T api php artisan migrate --force
```

## Pemeliharaan

### Backup Database

```bash
#!/bin/bash
# scripts/backup-database.sh

# Set variables
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_DIR="/backups/database"
CONTAINER_NAME="indowater-db"
DB_NAME="indowater"
DB_USER="root"
DB_PASSWORD="your_password"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create backup
docker exec $CONTAINER_NAME mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME | gzip > $BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql.gz

# Remove backups older than 30 days
find $BACKUP_DIR -name "*.sql.gz" -type f -mtime +30 -delete

# Log backup
echo "Database backup created: $BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql.gz" >> $BACKUP_DIR/backup.log
```

### Monitoring

```yaml
# docker/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "api"
    metrics_path: /metrics
    static_configs:
      - targets: ["api:80"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "cadvisor"
    static_configs:
      - targets: ["cadvisor:8080"]

  - job_name: "mysql"
    static_configs:
      - targets: ["mysql-exporter:9104"]

  - job_name: "redis"
    static_configs:
      - targets: ["redis-exporter:9121"]
```

## Panduan Kontribusi

### Proses Kontribusi

1. Fork repositori
2. Buat branch fitur (`git checkout -b feature/amazing-feature`)
3. Commit perubahan Anda (`git commit -m 'Add some amazing feature'`)
4. Push ke branch (`git push origin feature/amazing-feature`)
5. Buka Pull Request

### Standar Kode

- **PHP**: Ikuti PSR-12
- **JavaScript/TypeScript**: Ikuti Airbnb Style Guide
- **Dart**: Ikuti Effective Dart

### Pesan Commit

Gunakan format pesan commit yang jelas dan deskriptif:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Contoh:

```
feat(meter): add topup functionality

- Add API endpoint for meter topup
- Implement transaction creation
- Update meter balance after successful transaction

Closes #123
```

### Pull Request

- Gunakan template Pull Request yang disediakan
- Pastikan semua tes lulus
- Pastikan kode Anda telah di-review oleh setidaknya satu pengembang lain
- Pastikan dokumentasi telah diperbarui jika diperlukan

## FAQ

### Umum

**Q: Bagaimana cara menjalankan aplikasi dalam mode pengembangan?**

A: Gunakan Docker Compose:

```bash
docker-compose up -d
```

**Q: Bagaimana cara menjalankan tes?**

A: 

- Backend:
  ```bash
  cd api
  php artisan test
  ```

- Frontend:
  ```bash
  cd frontend
  npm test
  ```

- Mobile:
  ```bash
  cd mobile
  flutter test
  ```

**Q: Bagaimana cara menambahkan fitur baru?**

A: 
1. Buat branch fitur baru
2. Implementasikan fitur
3. Tulis tes
4. Buat Pull Request

### Backend

**Q: Bagaimana cara membuat migrasi database baru?**

A:
```bash
cd api
php artisan make:migration create_new_table
```

**Q: Bagaimana cara membuat model baru?**

A:
```bash
cd api
php artisan make:model NewModel -m
```

**Q: Bagaimana cara membuat controller baru?**

A:
```bash
cd api
php artisan make:controller API/NewController --api
```

### Frontend

**Q: Bagaimana cara membuat komponen baru?**

A:
```bash
cd frontend
mkdir -p src/components/specific/NewComponent
touch src/components/specific/NewComponent/index.js
touch src/components/specific/NewComponent/NewComponent.js
touch src/components/specific/NewComponent/NewComponent.test.js
```

**Q: Bagaimana cara menambahkan rute baru?**

A: Edit file `src/App.js` dan tambahkan rute baru di dalam komponen `Routes`.

### Mobile

**Q: Bagaimana cara membuat layar baru?**

A:
```bash
cd mobile
mkdir -p lib/screens/new_feature
touch lib/screens/new_feature/new_feature_screen.dart
```

**Q: Bagaimana cara menambahkan rute baru?**

A: Edit file `lib/app.dart` dan tambahkan rute baru di dalam `routes` map.

---

Untuk pertanyaan lebih lanjut, silakan hubungi tim pengembangan di dev@indowater.com.