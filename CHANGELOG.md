# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.3] - 2026-03-05

## [0.1.2] - 2026-03-03

### Changed

- Added a patch to set default credentials to empty string values in secret.

## [0.1.1] - 2026-03-03

### Changed

- Removed `application.giantswarm.io/branch` and `application.giantswarm.io/commit` labels.
- Added healthz port 8081 to controller.
- Skip linter check.

## [0.1.0] - 2026-03-03

### Changed

- Migrate to App Build Suite (ABS).
- Label group `app.giantswarm.io` was changed to `application.giantswarm.io`.
- Change `kubectl` image to `docker-kubectl`.

[Unreleased]: https://github.com/giantswarm/cluster-api-provider-proxmox-app/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/giantswarm/cluster-api-provider-proxmox-app/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/giantswarm/cluster-api-provider-proxmox-app/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/giantswarm/cluster-api-provider-proxmox-app/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/cluster-api-provider-proxmox-app/releases/tag/v0.1.0
