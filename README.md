# [oliviervanaken.com](https://oliviervanaken.com)

[![github.com release badge](https://img.shields.io/github/release/shiouen/oliviervanaken.com.svg)](https://github.com/shiouen/oliviervanaken.com/)
[![github.com workflow badge](https://github.com/shiouen/oliviervanaken.com/workflows/main/badge.svg)](https://github.com//shiouen/oliviervanaken.com/actions?query=workflow%3Amain)
[![img.shields.io MPL2 license badge](https://img.shields.io/github/license/shiouen/oliviervanaken.com)](./LICENSE)
[![License: CC BY 4.0](https://licensebuttons.net/l/by/4.0/80x15.png)](./app/content/LICENSE)

Professional developer web page for Olivier Van Aken.

## Requirements

### Development
* Golang: 1.21
* Hugo: 0.147.3
* PaperMod: 8.0

### Infrastructure

* AWS CLI: 2.0.0
* Google Cloud SDK: 522.0.0
* Nushell: 0.98.0
* Terraform: 1.12.0

## Commands

### Building the app

```sh
nu run.nu build
```

### Serve the app locally

```sh
nu run.nu serve
```

### Clean up app and infra

```sh
nu run.nu clean
```

### Deploy the app

```sh
nu run.nu deploy [--infra]
```

--infra: deploy the infrastructure as well

### Deploy only infra

```sh
nu run.nu deploy-infra
```

For more technical information check [run.nu](./run.nu)