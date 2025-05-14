# Changelog

All notable changes to the Actorizer-CDC Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## Chart 0.0.2 [Actorizer-CDC 0.0.11] - 2023-11-30

### Helm changes
- Applications versions:
  - actorizer-cdc - 0.0.11

### Added
- Added support for configurable database host parameters
- Added `DB_HOST_ACTORIZER` parameter for actorizer database connection
- Added detailed documentation in README.md
- Added CHANGELOG.md file

### Changed
- Updated default values.yaml to use "public" repository type
- Improved handling of imagePullSecrets based on repository type
- Fixed Helm lint errors related to imagePullSecrets

### Fixed
- Fixed issue with secret.yaml template when using public repository
- Fixed deployment.yaml to conditionally include imagePullSecrets

## Chart 0.0.1 [Actorizer-CDC 0.0.10] - 2023-11-01

### Helm changes
- Applications versions:
  - actorizer-cdc - 0.0.10

### Added
- Initial release of Actorizer-CDC Helm chart
- Support for PostgreSQL database monitoring with logical replication
- Support for multiple database entities monitoring
- Prometheus alerts for error monitoring
- Configurable replication settings
