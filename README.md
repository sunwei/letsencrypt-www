# ![logo](./assets/github.logo.png)

# Let's Encrypt WWW 

[![Build Status](https://travis-ci.org/sunwei/letsencrypt-www.svg?branch=master)](https://travis-ci.org/sunwei/letsencrypt-www)

For **developer** or **website admin** who need to **manage certificate**, the **Letsencrypt-WWW** is a **command line tool** 
that purely implemented by shell language, unlike other powerful and complex tool, LeWWW provide **lightweight solution**, 
you can easily adjust the source code and fit your requirement, powered by **TDD** and [Let's Encrypt](https://letsencrypt.org/).

---


## Table of Contents
- [OS](#-operating-system-support)
- [Install](#-install)
  - [Prerequisites](#prerequisites)
  - [Installing](#prerequisites)
- [Tests](#-running-the-tests)
- [Usage](#-usage)
  - [MacOS](#macos)
  - [Docker](#docker)
    - [Demo](#html)
- [Features](#-features)
  - [Create](#create)
  - [Renew](#renew)
  - [Revoke](#revoke)
  - [Challenge type](#challenge-type)
    - [dns-01](#dns-01)
    - [http-01](#easy-wysiwyg-mode)
  - [Provider](#dns-provider)
    - [DNSPod](#dns-pod)
    - [Potential providers](#potential-providers)
- [Build With](#-build-with)
- [Examples](#-examples)
- [Contributing](#-contributing)
- [Used By](#-used-by)
- [License](#-license)


## Operating System Support

| Darwin | 
| :---------: | 
| Yes |

## Install

### Prerequisites

* [OpenSSL](https://www.openssl.org/source/)

### Installing

Option 1. From git master 

```
git clone git@github.com:sunwei/letsencrypt-www.git
cd ./letsencrypt-www

```

Option 2. From release 

```
curl -OL  https://github.com/sunwei/letsencrypt-www/archive/v0.0.4.tar.gz
tar -xvzf v0.0.4.tar.gz
mv letsencrypt-www-0.0.4 letsencrypt-www
cd ./letsencrypt-www

```

Check releases here: [GitHub letsencrypt-www releases](https://github.com/sunwei/letsencrypt-www/releases)

## Features

What things you need to install the software and how to install them

### Productive Markdown mode

```
Give examples
```