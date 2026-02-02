# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2026-01-29

### Added
- **Health Checks**: Implemented comprehensive health checks for all services (`n8n`, `postgres`, `redis`, etc.) to ensure orchestration reliability.
- **Standardization**: Reordered `docker-compose.yml` keys for establishing a strict configuration standard.

### Changed
- Documentation updated to reflect the new health check mechanisms.

## [2.1.0] - 2026-01-29

### Changed
- **Scaling Architecture**: Refactored `docker-compose.yml` to implement a "Paired Worker/Runner" model.
    - Ensures each runner is explicitly linked to a specific worker.
    - Solves concurrency and task delegation issues in high-scale environments.
- Updated `README.md` with strict scaling procedures and architecture diagrams.

## [2.0.0] - 2026-01-29

### Added
- **Replica Support**: Added `deploy.replicas` configuration for easy service scaling.

### Changed
- **Modular Architecture Refactor**:
    - **BREAKING**: Split the unified `custom-service.yml` into granular service definitions in `custom-services/`.
    - Created `custom-services/browserless.yml`
    - Created `custom-services/nocodb.yml`
    - Created `custom-services/qdrant.yml`
    - Updated root `docker-compose.yml` to include these modular files using `include`.

## [1.5.0] - 2026-01-26

### Added
- **External Runner Support**: Added configuration testing for running n8n workers externally.
- **Database Execution Mode**: Switched n8n execution mode to `db` (database) for better scalability compared to binary mode.

### Changed
- **Dockerfile Overhaul**: Revised `Dockerfile` and `Dockerfile.runner` for optimized binary handling and debugging.
- Fixed licensing headers in build files.

## [1.4.0] - 2026-01-26

### Changed
- **Nginx Tuning**: Increased proxy buffer sizes to fix gateway timeout issues with large payloads.
- **Documentation**: Extensive updates to `README.md` regarding external access and buffer settings.

## [1.3.0] - 2026-01-19

### Added
- **Cron Jobs**: Added `n8n.cron` for automated maintenance tasks.
- **Test Cases**: Added `TESTCASE.md` outlining standard verification procedures.

## [1.2.0] - 2026-01-17

### Changed
- **Performance Tuning**: Refined `nginx.conf` for better throughput and lower latency.
- Stability testing with specific internal runner configurations.

## [1.1.0] - 2026-01-16

### Added
- **Operational Scripts**:
    - Added `backup.sh` and `restore.sh` for disaster recovery.
    - Added `minio-bootstrap.sh` improvements.
- **Webhook Integration**: Configured dedicated webhook endpoints and environment variables.
- **Persistence**: Added folder mounts for persistent data storage across restarts.

### Changed
- **Nginx Architecture**:
    - Split monolithic `nginx.conf` into modular `conf.d/*.conf` files (`n8n.conf`, `minio.conf`, etc.).
    - Removed exposed high-risk ports for better security.

## [1.0.0] - 2026-01-16

### Added
- **Initial Release**:
    - Base `docker-compose.yml` setup.
    - Core Nginx reverse proxy configuration.
    - Basic Environment configuration (`.n8n.env`).
    - Project documentation initialization.
