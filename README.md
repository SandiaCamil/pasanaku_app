# Pasanaku App

Aplicación multiplataforma desarrollada en **Flutter** y **Dart** para la administración integral de grupos de ahorro colaborativo (*Pasanaku*). Permite organizar participantes, realizar sorteos aleatorios de turnos, gestionar aportes por ronda con persistencia relacional local y consultar cotizaciones referenciales entre el boliviano (BOB) y el dólar estadounidense (USD).

---

## Descargas Directas (Releases)

Los ejecutables compilados para instalación directa están disponibles en la sección [Releases](https://github.com/SandiaCamil/pasanaku_app/releases) del repositorio:

* **Android (`app-release.apk`):** Instalador universal compatible con arquitecturas `arm64`, `armeabi-v7a` y `x86_64`.
* **Windows (`pasanaku_app_windows.zip`):** Paquete portátil de escritorio (`x64`). Descomprimir el archivo completo y ejecutar `pasanaku_app.exe`.

---

## Características Principales

* **Gestión de Grupos y Rondas:** Creación, listado y eliminación de grupos con configuración de monto de cuota en bolivianos, frecuencia de aporte (*semanal*, *quincenal* o *mensual*), fecha de inicio y cantidad total de rondas (con soporte para múltiples vueltas mediante cálculo cíclico modular).
* **Registro y Validación de Participantes:** Incorporación dinámica de integrantes (mínimo dos por grupo) con validación estricta de formularios y verificación de formato numérico de 8 dígitos para teléfonos móviles en Bolivia.
* **Sorteo Aleatorio de Turnos:** Asignación imparcial y transaccional del orden de cobro habilitada antes de registrar el primer aporte de la ronda inicial.
* **Control de Pagos por Ronda:** Seguimiento individualizado de aportes mediante listas interactivas, cálculo automático del pozo recaudado frente al total esperado y cierre controlado de rondas.
* **Arquitectura Offline-First:** Persistencia local completa mediante SQLite (esquema v2 con migración automática) con integridad referencial (`ON DELETE CASCADE`) y restricciones de unicidad por ronda.
* **Conversión Referencial de Divisas:** Consulta en tiempo real a través de API REST para mostrar el tipo de cambio vigente USD/BOB, incorporando una tasa oficial de respaldo (`6.96 Bs`) ante ausencia de conectividad.

---

## Arquitectura y Estructura del Proyecto

El código fuente sigue una arquitectura en capas desacoplada mediante los patrones **Repository** y **Provider**:

```text
lib/
├── main.dart                         # Punto de entrada e inicialización SQLite por plataforma
├── app.dart                          # Configuración global de MaterialApp y tema
├── core/
│   └── tema.dart                     # Paleta cromática Material 3 y estilos de componentes
├── models/
│   ├── grupo.dart                    # Entidad Grupo, frecuencias y serialización SQL
│   ├── participante.dart             # Entidad Participante y asignación de turno
│   └── pago.dart                     # Entidad Pago por integrante y ronda
├── data/
│   ├── base_datos.dart               # Singleton de conexión SQLite, DDL y migración v2
│   ├── pasanaku_repositorio.dart     # Operaciones CRUD, transacciones y sorteo aleatorio
│   └── tipo_cambio_servicio.dart     # Cliente HTTP para cotización USD/BOB
├── providers/
│   ├── grupos_provider.dart          # Gestión reactiva del listado de grupos
│   └── detalle_grupo_provider.dart   # Lógica de rondas, recaudación y receptor cíclico
└── screens/
    ├── lista_grupos_screen.dart      # Vista principal y resumen de grupos
    ├── nuevo_grupo_screen.dart       # Formulario de creación y validaciones
    └── detalle_grupo_screen.dart     # Panel de control de ronda, sorteo y pagos
```

---

## Stack Tecnológico

| Componente | Tecnología / Paquete | Descripción |
| :--- | :--- | :--- |
| **Framework y Lenguaje** | Flutter `3.50.1` / Dart `3.14.0` | Desarrollo multiplataforma con compilación nativa y *null safety*. |
| **Gestión de Estado** | `provider` (`ChangeNotifier`) | Inyección de dependencias y actualización reactiva de la interfaz. |
| **Persistencia Local** | `sqflite`, `sqflite_common_ffi`, `sqflite_common_ffi_web` | Base de datos SQLite nativa en Android, FFI en Windows y WebAssembly/IndexedDB en Web. |
| **Conectividad y Formato** | `http`, `intl`, `path`, `path_provider` | Consumo de servicios REST, formateo de fechas/monedas y rutas del sistema. |
| **Pruebas Automatizadas** | `flutter_test` | Pruebas unitarias de serialización de modelos y reglas de dominio. |

---

## Compatibilidad Multiplataforma

El proyecto adapta automáticamente el motor de almacenamiento según el entorno de ejecución:

* **Android (Plataforma principal):** Almacenamiento nativo mediante `sqflite` y renderizado gráfico con Impeller.
* **Windows (Escritorio):** Ejecución nativa de escritorio con persistencia local mediante `sqflite_common_ffi`.
* **Web:** Despliegue en navegadores modernos respaldado por `sqlite3.wasm` y `sqflite_sw.js`.

---

## Instalación y Ejecución desde Código Fuente

### Requisitos previos
* Flutter SDK `3.50.1` o superior.
* Dart SDK `3.14.0` o superior.
* Android SDK (API 36), Visual Studio (para compilación en Windows) o navegador web compatible.

### Pasos de ejecución

1. Clonar el repositorio:
   ```bash
   git clone [https://github.com/SandiaCamil/pasanaku_app.git](https://github.com/SandiaCamil/pasanaku_app.git)
   cd pasanaku_app
   ```

2. Instalar las dependencias del proyecto:
   ```bash
   flutter pub get
   ```

3. Ejecutar las pruebas unitarias:
   ```bash
   flutter test
   ```

4. Iniciar la aplicación en el dispositivo deseado:
   ```bash
   # Android (emulador o dispositivo físico conectado)
   flutter run

   # Escritorio Windows
   flutter run -d windows

   # Navegador Web (Edge / Chrome)
   flutter run -d edge
   ```

---

## Atribución de Servicios Externos

Los datos referenciales de conversión de divisas son proporcionados por [ExchangeRate-API](https://www.exchangerate-api.com).

---

## Autor

**Hugo Camilo Cussi Suxo** ([SandiaCamil](https://github.com/SandiaCamil))
