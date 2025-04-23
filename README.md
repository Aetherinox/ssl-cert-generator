# SSL Certificates & Generator <!-- omit in toc -->

<br>

---

<br>

- [About](#about)
  - [Certificate Types](#certificate-types)
    - [rootCA Authority](#rootca-authority)
    - [Domain Authority](#domain-authority)
    - [Authentication Authority (SSL)](#authentication-authority-ssl)
    - [Encryption Authority (Bitlocker)](#encryption-authority-bitlocker)
  - [Key Types](#key-types)
- [Quick Run](#quick-run)
  - [Normal Mode](#normal-mode)
  - [Mixed Mode](#mixed-mode)
- [Setup](#setup)
  - [Setup Using Git Repo](#setup-using-git-repo)
  - [Setup Manually](#setup-manually)
    - [Windows](#windows)
    - [Linux](#linux)
- [Customize](#customize)
- [Generate](#generate)
  - [File List](#file-list)
    - [Legend](#legend)
    - [RootCA](#rootca)
    - [Domain Authority](#domain-authority-1)
- [Options](#options)
- [Commands](#commands)
  - [Help](#help)
  - [New](#new)
  - [Algorithm](#algorithm)
  - [Curve](#curve)
  - [Bits](#bits)
  - [Folders](#folders)
    - [homeFolder](#homefolder)
    - [certsFolder](#certsfolder)
    - [rootcaFolder](#rootcafolder)
    - [domainFolder](#domainfolder)
  - [Passwords](#passwords)
  - [Friendly Name](#friendly-name)
  - [Days / Expiration](#days--expiration)
  - [Comment](#comment)
  - [Wipe \& Clean](#wipe--clean)
    - [Clean](#clean)
    - [Wipe](#wipe)
    - [Variables](#variables)
  - [Status](#status)
  - [Modes](#modes)
    - [New Key Generation](#new-key-generation)
      - [RSA](#rsa)
      - [ECC](#ecc)
    - [Existing Key Generation](#existing-key-generation)
      - [Option 1: --import option](#option-1---import-option)
      - [Option 2: Manual Import](#option-2-manual-import)


<br>

---

<br>

## About

This bash utility will generate the following types of certificates. See a larger explaination of these certificates in the subsection [Certificate Types](#certificate-types). The following lists the algorithm that will be used for each certificate and key if you use `--mixed` mode.

<br>

- **Root Certificate Authority (RSA 4096)**
  - Signs all certificates
  - Located in `📁 rootCA` folder
- **Domain Authority (ECC 384)**
  - SSL certificate for websites
  - Located in `📁 domain` folder
- **Authentication Authority (9A) (ECC 384)**
  - SSH authentication cert and keys
  - Located in `📁 auth` folder
- **Encryption Authority (9D) (ECC 384)**
  - Bitlocker & EFS encryption cert and keys
  - Located in `📁 bitlocker` folder

<br>

### Certificate Types

This subsection explains the different certificate types:

<br>

#### rootCA Authority

All certificates generated with this utility will be signed with the `rootCA`, as well as a revocation list.

The rootCA contains the following usages:

```ini
[ x509_rootCA ]
basicConstraints        = critical, CA:true
keyUsage                = critical, digitalSignature, cRLSign, keyCertSign
```

<br>
<br>

#### Domain Authority

These can be utilized for domains that you wish to enable SSL on. 

The domain authority certs contain the following usages:

```ini
[ x509_domain ]
basicConstraints        = CA:false, pathlen:0
keyUsage                = critical, digitalSignature, keyEncipherment, keyAgreement
extendedKeyUsage        = critical, serverAuth, clientAuth
```

<br>
<br>

#### Authentication Authority (SSL)

These certs / keys can be utilized for things such as SSH authentication. They are ready to be imported into a security device such as a Yubikey, and will typically go into `Slot 9A`. This can be achieved by using the [Yubikey Manager](https://yubico.com/support/download/yubikey-manager/) application

The authentication certs are not restricted in their usage permissions and are left blank. To assign certain usages to these certs, edit the `rootCA.cnf` file and define the desired usages.

```ini
[ x509_9a_master ]
basicConstraints        = CA:false, pathlen:0
# keyUsage              = critical, digitalSignature, keyEncipherment, keyAgreement
# extendedKeyUsage      = critical, serverAuth, clientAuth
```

<br>
<br>

#### Encryption Authority (Bitlocker)
These certs / keys can be utilized for things such as Bitlocker encryption and EFS (Windows encrypted filesystem). They are ready to be imported into a security device such as a Yubikey, and will typically go into `Slot 9D`. This can be achieved by using the [Yubikey Manager](https://www.yubico.com/support/download/yubikey-manager/) application

```ini
[ x509_9d_bitlocker ]
basicConstraints        = critical, CA:false, pathlen:0
keyUsage                = critical,nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement
extendedKeyUsage        = critical,serverAuth, clientAuth, emailProtection, msSGC, msEFS, msEFSR, nsSGC, msEFSRecovery, driveEncryption, driveRecovery, msSmartcardLogin, secureShellClient, secureShellServer, rda, gpgUsageCert, gpgUsageSign, gpgUsageEncr, gpgUsageAuth, msAuthenticode
```

<br>
<br>

### Key Types

This bash utility allows you to either generate all of your certificates / keys using one specific algorithm; or you can mix RSA with ECC. The reason for mixing RSA and ECC is:

- **RSA 4096** is used for the Root certificate authority and is common practice. 
- **ECC 384** is used for all other non-root certs which will be issued by the Root Certificate authority due to smaller keys with better security and more modern.

<br>

Using this bash utility, you can either generate a mixed RSA and ECC pair, or you can have all certificates use RSA or ECC and not mix. This is specified as an option when you execute the `generate` bash script.

To generate a mix of RSA rootCA with ECC subkeys, use the `generate --mixed` option:

```console
 -M,  --mixed       forces the rootCA to use RSA 4096; all subkeys will use ECC secp384r1
                    cannot be used in combination with option --algorithm
                    change RSA bits with option --bits <num>
                    change ECC curve with option --curve <value>

```

<br>

This project has **four** main files which allow you to generate RSA keys, ECC keys, or a combination of both. This is specified depending on what command you run:

| File            | Purpose                                                     |     |
| --------------- | ----------------------------------------------------------- | --- |
| `rootCA/rootCA-rsa.cnf`    | Create RSA based root certificate authority and RSA subkeys |     |
| `rootCA/rootCA-ecc.cnf`    | Create ECC based root certificate authority and ECC subkeys |     |
| `rootCA/bitlocker-rsa.cnf` | Creates Bitlocker encryption cert and keys using RSA        |     |
| `rootCA/bitlocker-ecc.cnf` | Creates Bitlocker encryption cert and keys using ECC        |     |

<br>

> [!NOTE]
> The `rootCA-*.cnf` is responsible for creating:
>   - Root Certificate Authority key
>   - Domain Authority subkey
>   - Authentication Authority subkey
>
> 
> The `bitlocker-*.cnf` is responsible for creating:
>   - Encryption Authority key

<br>

---

<br>

## Quick Run

This section gives brief commands on how to generate new keys using both **Normal Mode** and **Mixed Mode**. First, clone the repository files:

```shell
git clone https://github.com/Aetherinox/ssl-cert-generator.git .
```

<br>

Set the permissions:

```shell
sudo chmod +x generate
```

<br>

Create a symlink so that you can access the command from any folder:

```shell
sudo ln -s /path/to/generate /usr/local/bin
```

<br>

### Normal Mode

This mode generates keys with all the same specified algorithm.

```shell
# RSA
generate \
  --new  \
  --algorithm "rsa" \
  --bits 4096 \
  --name "Domain.lan" \
  --pass "PASS" \
  --passin "PASS" \
  --passout "PASS"

# ECC
generate \
  --new  \
  --algorithm "ecc" \
  --curve "secp384r1" \
  --name "Domain.lan" \
  --pass "PASS" \
  --passin "PASS" \
  --passout "PASS"
```

<br>

### Mixed Mode

Mixed Mode (`--mixed`) will generate the rootCA using RSA 4096, and all subkeys will be generated using ECC with curve secp384r1.

```shell
generate \
  --new \
  --mixed \
  --pass "PASS" \
  --passin "PASS" \
  --passout "PASS" \
  --name "Domain.lan"
```

<br>

---

<br>

## Setup

We need to set up a few folders which will serve as the location where we will generate our SSL certificates. If you do not have OpenSSL installed on your system, now is the time to do it. OpenSSL is available for
- [Linux](https://docs.openiam.com/docs-4.2.1.3/appendix/2-openssl)
- [Windows](https://cloudzy.com/blog/install-openssl-on-windows/)

<br>

### Setup Using Git Repo

Download the contents of this repo to your local machine.

```shell
git clone https://github.com/Aetherinox/ssl-cert-generator.git .
```

<br>

Set the correct permissions:

```shell
sudo chmod +x generate
```

<br>

Add the `generate` file to your `/usr/local/bin` so that it can be accessed from any directory

```shell
sudo ln -s /path/to/generate /usr/local/bin
```

<br>

To remove the symlink

```shell
sudo rm /usr/local/bin/generate
```

<br>
<br>

### Setup Manually

On your computer, create a new folder named `certificates`, within that folder, create the following structure shown below:. Ensure you create it just as its shown below, this will make it much easier to copy/paste the commands provided.

```
📁 certificates
    📁 rootCA
        📁 certs
        📁 crl
        📁 generated
        📄 crlnumber
        📄 certs.db
        📄 rootCA.cnf
        📄 serial
    📁 domain
    📁 auth
    📁 bitlocker
📄 README.md
📄 generate.sh
```

<br>

To create the above folders / structure, run the commands below:

<br>

#### Windows

```powershell
mkdir certificates\rootCA\generated certificates\rootCA\certs certificates\rootCA\crl certificates\domain
"00" | Out-File -encoding ascii -NoNewline "certificates/rootCA/crlnumber"
"0000" | Out-File -encoding ascii -NoNewline "certificates/rootCA/serial"
type nul > "certificates/rootCA/index.txt"
type nul > "certificates/rootCA/rootCA.cnf"
```

<br>

#### Linux

```shell
mkdir -p certificates/{rootCA/generated,rootCA/certs,rootCA/crl,domain,auth,bitlocker}
echo "00" > "certificates/rootCA/crlnumber"
echo "0000" > "certificates/rootCA/serial"
touch "certificates/rootCA/index.txt"

# OpenSSH Configs
touch "certificates/rootCA/rootCA-rsa.cnf"
touch "certificates/rootCA/rootCA-ecc.cnf"
touch "certificates/rootCA/bitlocker-rsa.cnf"
touch "certificates/rootCA/bitlocker-ecc.cnf"

# File must be chmod 600
chmod 600 "certificates/rootCA/index.txt"
```

<br>

You will then need to add the `generate` bash code from wherever you are getting the source from (such as Obsidian.md). Once you have the code added to the `generate` file; set the permissions:

```shell
sudo chmod +x generate
```

<br>

Add the `generate` file to your `/usr/local/bin` so that it can be accessed from any directory

```shell
sudo ln -s /path/to/generate /usr/local/bin
```

<br>

To remove the symlink

```shell
sudo rm /usr/local/bin/generate
```

<br>

---

<br>

## Customize

The file `/certificates/rootCA/rootCA-*.cnf` contains settings and properties you can just. Ensure you open the file and change the values to your own.

We will open `/certificates/rootCA/rootCA-*.cnf` and break down each section. Do not modify the top section of `[ req_distinguished_name ]`. This section defines what each label shows as helpful text if you were to manually generate your SSL certificate.

```ini title:"/certificates/rootCA/rootCA-*.cnf" ignore
[ dn_rootCA ]
countryName                     = Country Name 2 Letter
countryName_default             = NA

stateOrProvinceName             = State or Province Name
stateOrProvinceName_default     = NA

localityName                    = Locality Name
localityName_default            = NA

0.organizationName              = Organization Name
0.organizationName_default      = MyDomain LLC.

organizationalUnitName          = Organizational Unit Name
organizationalUnitName_default  = MyDomain Certificate Services

commonName                      = Common Name
commonName_default              = MyDomain Root CA

emailAddress                    = Email Address
emailAddress_default            = system@domain.lan

description                     = Description (main purpose for the certificate)
description_default             = MyDomain Certificate Authority RSA 4096

givenName                       = Given Name
givenName_default               = MyDomain Root Certificate Authority

title                           = Title
title_default                   = Root Certificate Authority

initials                        = Certificate Initials
initials                        = ocg-ssl-rootCA
```

<br>

Change the values above to whatever company name or email address you wish to see on your SSL certificate.
Next, we will define the domains / DNS that our certificate will be good for. Within the same file `/certificates/rootCA/rootCA-*.cnf`, look for the following lines:

```ini title:"/certificates/rootCA/rootCA-*.cnf" ignore
[ sans ]
IP.1                            = XX.XX.XX.XX
IP.2                            = 127.0.0.1
DNS.1                           = *.domain.com
DNS.2                           = domain.com
DNS.3                           = domain.local
DNS.4                           = *.domain.local
DNS.5                           = domain.lan
DNS.6                           = *.domain.lan
DNS.7                           = domain.localhost
DNS.8                           = *.domain.localhost
DNS.9                           = localhost
DNS.10                          = *.localhost
DNS.11                          = local
DNS.12                          = *.local
DNS.13                          = dns1.domain.com
DNS.14                          = dns2.domain.com
email.1                         = you1@domain.com
email.2                         = you2@domain.com
```

<br>

These lines define what domain / DNS your certificate will be good for. If you were to try and use this certificate on a domain that is **NOT** in the list above, your browser will return an error such as `NET:ERR_CERT_COMMON_NAME_INVALID` or `SSL_ERROR_UNRECOGNIZED_NAME_ALERT`.

<br>

The rest of the file `/certificates/rootCA/rootCA-*.cnf` contains mostly things that you should not modify. Throughout the file, you may see values that look like links, such as:

```ini title:"/certificates/rootCA/rootCA-*.cnf" hl:5,7,8,9,10,11,12,16,17,18
[ x509_domain ]
subjectKeyIdentifier            = hash
basicConstraints                = CA:false, pathlen:0
# nsCertType                      = sslCA, objsign, objCA
nsBaseUrl                       = "http://ssl.domain.lan/"
nsSslServerName                 = *.localhost
nsCaPolicyUrl                   = "http://ssl.domain.lan/rsa/policy.php"
nsRenewalUrl                    = "http://ssl.domain.lan/rsa/renewal.php"
nsCaRevocationUrl               = "http://ssl.domain.lan/rsa/rootCA.crl"
nsRevocationUrl                 = "http://ssl.domain.lan/rsa/domain.crl"
nsComment                       = "*.MyDomain Domain Certificate"
issuerAltName                   = URI:https://ssl.domain.lan/rsa/rootCA.crt
subjectAltName                  = @sans
keyUsage                        = critical, digitalSignature, keyEncipherment, keyAgreement
extendedKeyUsage                = critical, serverAuth, clientAuth
certificatePolicies             = @policies_domain_policy
crlDistributionPoints           = URI:http://ssl.domain.lan/rsa/domain.crl,URI:http://ssl.domain.lan/rsa/domain.crl.pem
authorityInfoAccess             = OCSP;URI:http://ssl.domain.lan/ocsp, caIssuers;URI:http://ssl.domain.lan/rsa/rootCA.crt
```

<br>

You may change anything above that appears to go to: `domain.com`.  This guide is not going to go into detail about each property individually, but there is plenty of information online as to what each one does.

<br>

---

<br>

## Generate

After you've completed the previous steps, it is time to generate your new SSL certificates and keys. Remember that this bash script is for Linux only. We need to now run the script `generate`. Open up a terminal window and execute the `chmod` command to make the script executable:

```shell
sudo chmod +x generate
```

<br>

Now we can run the command to generate. Notice that we are passing the `--mixed` option. This means that our rootCA cert and key will be made using `RSA`; our subkeys for the domain, SSL, and Bitlocker will be generated using `ECC`.

```shell
generate \
  --new \
  --mixed \
  --pass "PASS" \
  --passin "PASS" \
  --passout "PASS" \
  --name "Domain.lan"
```

<br>

> [!DANGER]
> **Remember Your Password**
> Write down the password you have chosen for your SSL certificate. If you forget the password, you will be unable to create any additional private keys later. You will also be unable to utilize the `.pfx` file.

<br>

A series of files are going to be generated. Don't feel over-whelmed, some of these files you may never use, and you can always generate new copies later utilizing OpenSSL. There are plenty of tutorials online to explain how to use OpenSSL..

A list of files have been provided below. A legend has been provided to explain what the abbreviations in the files mean:

<br>

### File List

After generating your new keys; the following files will be generated and places in your `certificates` folder:

<br>

#### Legend

When generating new certificates and keys; the filenames may contain any of the following abbreviations:

| Abbreviation | Description |
| --- | --- |
| `enc` | Encrypted private key |
| `unc` | Unencrypted private key |
| `pub` | Public key |
| `priv` | Private key |
| `crt` | Certificate |

<br>

#### RootCA

The following files are generated in relation to the **rootCA Certificate Authority**:

<br>

| File | Description |
| --- | --- |
| `rootCA.crt` | Domain Public Certificate |
| `rootCA.key.main-01.enc.priv.pem` | Private Key (Encrypted) |
| `rootCA.key.main-01.unc.priv.pem` | Private Key (Unencrypted) |
| `rootCA.keystore.normal.pfx` | Private Keystore |

<br>

#### Domain Authority

The following files are generated in relation to the **Domain Authority Certificate**:

<br>

| File | Description |
| --- | --- |
| `domain.crt` | Domain Public Certificate |
| `domain.csr` | Domain Certificate Signing Request |
| `domain.key.openssh.pub` | OpenSSH Public Key |
| `domain.key.main-01.enc.priv.pem` | Private Key (Encrypted) |
| `domain.key.main-01.unc.priv.pem` | Private Key (Unencrypted) |
| `domain.key.main-02.enc.priv.pem` | Private Key (Encrypted) |
| `domain.key.main-02.unc.priv.pem` | Private Key (Unencrypted) |
| `domain.keycert.main-01.enc.priv.pem` | Private Key & Certificate (Encrypted) |
| `domain.keycert.main-01.unc.priv.pem` | Private Key & Certificate (Unencrypted ) |
| `domain.key.rsa.priv.pem` | RSA Private Key |
| `domain.key.rsa.pub.pem` | RSA Public Key |
| `domain.keystore.normal.pfx` | Keystore |
| `domain.keystore.base64.pfx` | Keystore (Base64) |
| `domain_fullchain.pem` | Full Certificate Authority + Domain Certificate |
| `domain.sha1.key` | SHA1. Paste into Duplicati Global Settings |

<br>

The following files from above are **private keys** you can use, both encrypted and unencrypted. The bash script generates multiple so that you can use them on various different things. These private keys can be used to set up SSH, SSL on websites, or set up a self-signed certificate for applications like Duplicati, Syncthing, etc.

- `key.main-01.enc.priv.pem`
- `key.main-01.unc.priv.pem`
- `key.main-02.enc.priv.pem`
- `key.main-02.unc.priv.pem`

<br>

The following files are **private keys and certificates** combined into one file:

- `keycert.main-01.enc.priv.pem`
- `keycert.main-01.unc.priv.pem`

<br>

The **fullchain** certificate file will be used to set up SSL with your websites, as well as the individual certificate files for your Certificate Authority and domain certificate:

- `domain.fullchain.crt`
- `domain.crt`
- `rootCA.crt`

<br>

The **OpenSSH** public file is used for OpenSSH connections:

- `key.openssh.pub`

<br>

The **SHA1** file can be used with applications like Duplicati:

- `sha1.key`

<br>

The **keystore** files are a password protected file which contains your private key, public key, and certificate. The base64 encrypted keystore can be used for people who wish to add SSL to applications via Github Workflow.

- `keystore.normal.pfx`
- `keystore.base64.pfx`

<br>

The **Certificate Signing Request** is a file generated for your domain certificate. It is signed with your Certificate Authority _(rootCA)_. You can also send the `.csr` file off to other Certificate Authorities such as Veracrypt to be signed by them:

- `domain.csr`

<br>

---

<br>

## Options

Options are special flags you can append on to the base command in order to customize how this utility generates certificates and keys. Some options simply represent `true | on` or `false | off` by supplying the `--option`. While other options also expect an option after the option is declared.

<br />

```
generate \
   --parameter1 <argument1> \
   --parameter2 <argument2>

generate \
   --config-bitlocker bitlocker-rsa.cnf \
   --algorithm rsa
```

<br />

This utility has the following available options you can pass. Any option listed below **without** a default value represents a simple `on` or `off` option with no additional arguments needed after the option is declared.

<br>

| Options | Description | Default Value |
| --- | --- | --- |
| <small>`-n, --new`</small> | <small>Generates new keys if existing private keys do not exist in the base folders `📁 rootCA`, `📁 domain`, `📁 auth`, and `📁 bitlocker`</small> | <small></small> |
| <small>`-f, --config`</small> | <small>OpenSSL config file to load</small> | <small>`rootCA-rsa.cnf`</small> |
| <small>`-F, --config-bitlocker`</small> | <small>OpenSSL config file to load for bitlocker keys/cert</small> | <small>`bitlocker-rsa.cnf`</small> |
| <small>`-i, --import`</small> | <small>Import existing RSA or ECC private key, and generate new public keys and certificates based on the private key. <br/>Must specify a private key with an intact header. the following are acceptable: <br/> <br> `BEGIN ENCRYPTED PRIVATE KEY` <br> `BEGIN PRIVATE KEY` <br> `BEGIN EC PRIVATE KEY`</small> | <small></small> |
| <small>`-a, --algorithm`</small> | <small>Algorithm to use for key generation. These are the values available within OpenSSL. Cannot be used in combination with the option `--mixed` <br><br> `ecc`, `rsa`</small> | <small>`rsa`</small> |
| <small>`-V, --curve`</small> | <small>ECC curve; accepts all curves available through OpenSSL <br><br>`secp384r1`, `secp521r1`, `sect571k1`, `c2pnb368w1`, `c2tnb431r1`, `prime256v1`</small> | <small>`secp384r1`</small> |
| <small>`-b, --bits`</small> | <small>Specifies the number of bits to use with an RSA key</small> | <small>`4096`</small> |
| <small>`-dr, --digest-root`</small> | <small>Message digest to use with the rootCA <br><br>`SHA224`, `SHA256`, `SHA384`, `SHA512`</small> | <small>`sha512`</small> |
| <small>`-ds, --digest-sub`</small> | <small>Message digest to use with sub-keys <br><br> `SHA224`, `SHA256`, `SHA384`, `SHA512`</small> | <small>`sha512`</small> |
| <small>`-M, --mixed`</small> | <small>Toggles rootCA cert/key to be generated using `RSA 4096`, all sub-keys will use ECC `secp384r1` <br>Cannot be used in combination with the option `--algorithm` </small> | <small></small> |
| <small>`-N, --friendlyname`</small> | <small>Friendly name to use for certificate</small> | <small>`Self-hosted`</small> |
| <small>`-P, --pass`</small> | <small>Password to use for certs and keys</small> | <small></small> |
| <small>`-I, --passin`</small> | <small>Password to use for imported keys, and private keys needed to make new keys</small> | <small></small> |
| <small>`-O, --passout`</small> | <small>Password to use when creating a new private key from an existing, this password is applied to the newer keys</small> | <small></small> |
| <small>`-H, --homeFolder`</small> | <small>Set the home folder <br/> This is the folder where the `generate` app currently resides.</small> | <small>`${PWD}`</small> |
| <small>`-C, --certsFolder` </small> | <small>Set the certs folder <br/>Re-names the `certificates` folder.</small> | <small>`certificates`</small> |
| <small>`-R, --rootcaFolder`</small> | <small>Set the rootCA folder</small> | <small>`rootCA`</small> |
| <small>`-D, --domainFolder`</small> | <small>Set the domain folder</small> | <small>`domain`</small> |
| <small>`-d, --days`</small> | <small>Certificate expiration time in days</small> | <small>`36500`</small> |
| <small>`-t, --comment`</small> | <small>specify a comment to add to RSA and OpenSSH keys</small> | <small>`OCG 1.1.0.0`</small> | <small></small> |
| <small>`-c, --clean`</small> | <small>Remove all files except config `📄 rootCA.cnf` and main private `📄 .pem` keys </small> | <small></small> |
| <small>`-w, --wipe`</small> | <small>Remove every file in the folders `📁 certificates`, `📁 certsFolder`, and `📁 rootcaFolder`.<br>OpenSSL config `📄 rootCA.cnf` excluded and will remain</small> | <small></small> |
| <small>`-v, --vars`</small> | <small>List all variables / paths</small> | <small></small> |
| <small>`-T, --tree`</small> | <small>Shows an example of the files you should have when using this generator</small> | <small></small> |
| <small>`-s, --status`</small> | <small>Output a list of certs & keys generated to check for all files</small> | <small></small> |
| <small>`-v, --version`</small> | <small>Current version of this generator</small> | <small></small> |
| <small>`-x, --dev`</small> | <small>Developer mode; enables verbose logging</small> | <small></small> |
| <small>`-z, --help`</small> | <small>Show this help menu</small> | <small></small> |

<br>

---

<br>

## Commands

This utility includes a large list of options and commands. A complete list can be found by executing the command `generator --help`. Some of the most important commands are outlined below:

<br>

### Help

<small>`--help, -z`</small>

Displays helpful information about the script, including all available commands.

```shell
generator --help
```

<br>

`--help, -z` outputs the following:

```
  Options:                                         
        -n,  --new               Generate new keys                       
                                 requires that the utility folders be clean. any existing private keys will block
                                 this command from generating new keys. delete any private key files ending with
                                 .pem or .key             
        -i,  --import            Import existing RSA or ECC private key
                                 allows you to import an existing private key from another directory.
                                 must specify a private key with an intact header. the following are acceptable:
                                    - BEGIN ENCRYPTED PRIVATE KEY
                                    - BEGIN PRIVATE KEY     
                                    - BEGIN EC PRIVATE KEY  
        -a,  --algorithm         Type of key to generate             
                                    - ecc                   
                                    - rsa                   
        -V,  --curve             ECC curve                           
                                 accepts any curves included with OpenSSL
                                    - secp384r1             
                                    - secp521r1             
                                    - sect571k1             
                                    - c2pnb368w1            
                                    - c2tnb431r1            
                                    - prime256v1            
        -N,  --friendlyname      Friendly name to use for certificate
        -P,  --pass              Password to use for certs and keys  
        -I,  --passin            Password in                         
        -O,  --passout           Password out                        
        -H,  --homeFolder        Set the home folder
        -C,  --certsFolder       Set the certs folder - default: certificates
        -R,  --rootcaFolder      Set the rootCA folder - default: rootCA
        -D,  --domainFolder      Set the domain folder - default: domain
        -d,  --days              Certificate expiration time in days     
        -t,  --comment           specify a comment to add to RSA and OpenSSH keys
        -c,  --clean             Remove all files, but keep rootCA.cnf, and main private pem keys
        -w,  --wipe              Remove every file in certificates folder except rootCA.cnf
        -v,  --vars              List all variables / paths              
        -s,  --status            Output a list of certs & keys generated to check for all files
        -v,  --version           Current version of this generator       
        -x,  --dev               Developer mode                          
        -z,  --help              Show this help menu                     
```

<br>
<br>

### New
<small>`-n, --new`</small>

The new command generates new keys and certificates, including the main private keys. If you do not specify this flag, you must already have existing private keys added so that it will build certificates and public keys based on the private keys.

```shell
generate --new
```

<br>

If you do not wish to generate new private keys, and want to use your own; you must ensure you have the following files in the locations specified below:

- `certificates/rootCA/rootCA.key.main-01.enc.priv.pem`
- `certificates/domain/domain.key.main-01.enc.priv.pem`

<br>

If you have the above private keys in place, you can exclude the `-n, --new` arguments, and new public keys and certificates will be generated based on the private keys.

```shell
generate --comment "My Existing Key" --name "Original Key"
```

<br>
<br>

### Algorithm
<small>`--algorithm, -a`</small>

The `algorithm` option allows you to specify whether you will generate RSA or ECC / ECDSA keys & certs.

For ECC keys, use this option in combination with `--curve`; otherwise the default curve will be `secp384r1`.

```shell
generate --algorithm ecc --curve secp384r1
```

<br>
<br>

### Curve
<small>`--curve, -V`</small>

The `curve` option allows you to specify which curve to use for ECC / ECDSA. This option accepts the same values offered by OpenSSL.

```shell
generate --algorithm ecc --curve secp384r1
```

<br>
<br>

### Bits
<small>`--bits, -b`</small>

The `bits` option allows you tp specify the key size for RSA generated keys.

```shell
generate --algorithm rsa --bits 4096
```

<br>
<br>

### Folders

By default, this script utilizes the following structure:

```
📁 certificates
    📁 rootCA
        📁 certs
        📁 crl
           📄 rootCA.crl
           📄 rootCA.crl.pem
        📁 generated
           📄 00.pem
        📄 crlnumber
        📄 index.txt
        📄 rootCA.cnf
        📄 serial
    📁 domain
    📁 master
📄 generate
```

<br>

Options are provided so that these folder names can be changed.

<br>

#### homeFolder

<small>`--homeFolder, -H`</small>

By default, the generator will run in whatever folder the script was called from; however, you can force it to use another path:

```shell
generator --homeFolder /path/to/folder
```

<br>

#### certsFolder

<small>`--certsFolder, -C`</small>

Changes the `certificates` folder name. The following example will use the folder `certs` instead of `certificates`.

```shell
generate --certsFolder certs
```

<br>

#### rootcaFolder

<small>`--rootcaFolder, -R`</small>

Changes the `rootCA` folder name. The following example will use the folder `authority` instead of `rootCA`.

```shell
generate --rootcaFolder authority
```

<br>

#### domainFolder

<small>`--domainFolder, -D`</small>

Changes the `domain` folder name. The following example will use the folder `mydomain.com` instead of `domain`.

```shell
generate --rootcaFolder mydomain.com
```

<br>

### Passwords

This utility uses the same structure that OpenSSL does when dealing with the options:
- pass
- passin
- passout

<br>

Several commands accept password arguments, typically using -passin and -passout for input and output passwords respectively. These allow the password to be obtained from a variety of sources. Both of these options take a single option

If you are attempting to generate new files based on an existing key which is password protected; you must supply that password as part of the command.

```shell
generate --new --pass "YourExistingPassword"
```

<br>

If you are generating certs based on an existing key which has a password, and you'd also like your new keys to have a different password, specify `--passout`. 

This means your input password protected key will be specified by `--pass`, and the outgoing keys will use the password supplied by `--passout`.

```shell
generate --pass "YourExistingPassword" --passout "YourNewPassword"
```

<br>
<br>

### Friendly Name

<small>`--friendlyname, -N`</small>

This specifies the "friendly name" for the certificates and private key. This name is typically displayed in list boxes by software importing the file. Microsoft Windows will use this name when you view certificates and keys in your Windows Certificate Manager.

```shell
generate --new --name "My certificate" --pass "YourExistingPassword"
```

<br>
<br>

### Days / Expiration

<small>`--days, -d`</small>

Specifies how long until the created certificate expires. The following example will set the certificate to last `1095` days, or 3 years.

```shell
generate --new --name "My certificate" --days 1095 --pass "YourExistingPassword"
```

<br>
<br>

### Comment

<small>`--comment, -t`</small>

Defines a comment to be added to the end of OpenSSH files. If a comment is not specified, comment will default to `OCG 1.x.x`; which stands for **OpenSSL Certificate Generator**.

```shell
generate --new --name "My certificate" --days 1095 --comment "Work keys" --pass "YourExistingPassword"
```

<br>
<br>

### Wipe & Clean

This script comes with a few commands to throw away any existing files if you decide that you do not need them anymore. However, you should be careful with these commands. You will be unable to restore any previously generated certs and keys unless you have backed them up.

We provide you with two different commands:
- `--wipe, -w`
- `--clean, -C`

<br>
<br>

#### Clean

<small>`--clean, -c`</small>

The clean command will destroy **all** files except for the following:

- 📄 `rootCA.cnf` <small><small>(OpenSSL config)</small></small>
- 📄 `rootCA.key.main-01.enc.priv.pem` <small><small>Private key - Encrypted</small></small>
- 📄 `rootCA.key.main-01.unc.priv.pem` <small><small>Private key - Unencrypted</small></small>
- 📄 `domain.key.main-01.enc.priv.pem` <small><small>Private key - Encrypted</small></small>
- 📄 `domain.key.main-01.unc.priv.pem` <small><small>Private key - Unencrypted</small></small>

<br>

```shell
generate --clean
```

<br>
<br>

#### Wipe

<small>`--wipe, -w`</small>

The wipe command will destroy **all** files except for the following:

- 📄 `rootCA.cnf` <small><small>(OpenSSL config)</small></small>

<br>

```shell
generate --wipe
```

<br>
<br>

#### Variables

<small>`--vars, -v`</small>

The variables command outputs a list of stored variables and their values. Mainly this is used for development purposes only.

<br>

```shell
generate --vars
```

<br>

`--vars, -v` outputs the following:

```
   📁 Folders 
 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    ↳ 📁 $FOLDER_CERTS                      certificates                   
    ↳ 📁 $FOLDER_ROOTCA                     rootCA                         
    ↳ 📁 $FOLDER_ROOT_SUB_GEN               generated                      
    ↳ 📁 $FOLDER_ROOT_SUB_CRL               crl                            
    ↳ 📁 $FOLDER_ROOT_SUB_CERTS             certs                          
    ↳ 📁 $FOLDER_DOMAIN                     domain                         

   📄 Files 
 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    ↳ 📄 $FILE_ROOTCA_BASE                  rootCA                         
    ↳ 📄 $FILE_DOMAIN_BASE                  domain                         
    ↳ 🔑 $SSL_KEY_MAIN_ENC                  key.main-01.enc.priv.pem       
    ↳ 🔑 $SSL_KEY_MAIN_UNC                  key.main-01.unc.priv.pem       
    ↳ 🔑 $SSL_KEY_MAIN02_ENC                key.main-02.enc.priv.pem       
    ↳ 🔑 $SSL_KEY_MAIN02_UNC                key.main-02.unc.priv.pem       
    ↳ 🔑 $SSL_KEY_RSA_PRIV                  key.rsa.priv.pem               
    ↳ 🔑 $SSL_KEY_RSA_PUB                   key.rsa.pub.pem                
    ↳ 🔑 $SSL_KEY_SSH_PUB                   key.openssh.pub                
    ↳ 🔑 $SSL_CERT_MAIN_ENC                 keycert.main-01.enc.priv.pem   
    ↳ 🔑 $SSL_CERT_MAIN_UNC                 keycert.main-01.unc.priv.pem   
    ↳ 🔑 $SSL_KEYSTORE_PFX                  keystore.normal.pfx            
    ↳ 🔑 $SSL_KEYSTORE_B64                  keystore.base64.pfx            
    ↳ 🔑 $EXT_CRT                           crt                            
    ↳ 🔑 $EXT_CSR                           csr                            
    ↳ 🔑 $EXT_CRL                           crl                            
    ↳ 🔑 $EXT_CRL_PEM                       crl.pem                        
    ↳ 🔑 $SSL_CERT_FULLCHAIN                fullchain.pem                  
```

<br>

### Status

<small>`--status, -s`</small>

The `status` option will scan the working directory to detect if all of the files generated by this script are indeed found.

<br>

```shell
generate --status
```

<br>

`--status, -s` outputs the following:

```
   🎗️ SSL Config 
 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    ↳ 🔑 certificates/rootCA/rootCA.cnf                                       ✔️                         
    ↳ 🔑 certificates/rootCA/index.txt                                        ✔️                         
    ↳ 🔑 certificates/rootCA/crlnumber                                        ✔️                         
    ↳ 🔑 certificates/rootCA/serial                                           ✔️                         

   🎗️ rootCA 
 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    ↳ 🔑 certificates/rootCA/rootCA.key.main-01.enc.priv.pem                  ✔️                         
    ↳ 🔑 certificates/rootCA/rootCA.key.main-01.unc.priv.pem                  ✔️                         
    ↳ 🔑 certificates/rootCA/rootCA.crt                                       ✔️                         
    ↳ 🔑 certificates/rootCA/rootCA.pfx                                       ✔️                         

   🎗️ domain 
 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    ↳ 🔑 certificates/domain/domain.key.main-01.enc.priv.pem                  ✔️ 
    ↳ 🔑 certificates/domain/domain.key.main-01.unc.priv.pem                  ✔️ 
    ↳ 🔑 certificates/domain/domain.csr                                       ✔️ 
    ↳ 🔑 certificates/domain/domain.crt                                       ✔️ 
    ↳ 🔑 certificates/domain/domain.keystore.normal.pfx                       ✔️ 
    ↳ 🔑 certificates/domain/domain.keystore.base64.pfx                       ✔️
    ↳ 🔑 certificates/domain/domain.keycert.main-01.enc.priv.pem              ✔️
    ↳ 🔑 certificates/domain/domain.keycert.main-01.unc.priv.pem              ✔️
    ↳ 🔑 certificates/domain/domain.key.main-02.enc.priv.pem                  ✔️
    ↳ 🔑 certificates/domain/domain.key.main-02.unc.priv.pem                  ✔️
    ↳ 🔑 certificates/domain/domain.key.rsa.priv.pem                          ✔️
    ↳ 🔑 certificates/domain/domain.key.rsa.pub.pem                           ✔️
    ↳ 🔑 certificates/domain/domain.key.openssh.pub                           ✔️
         ↳ 4096 SHA256:9LxSiLUFC4oT6iM9V9BZ7bVNn5cBRdLHzAQdXfG4YFI OCG  (RSA)                 
    ↳ 🔑 certificates/domain/domain.key.openssh.priv.pem                      ✔️
    ↳ 🔑 certificates/domain/domain.key.openssh.priv.nopwd.pem                ✔️
         ↳ 4096 SHA256:9LxSiLUFC4oT6iM9V9BZ7bVNn5cBRdLHzAQdXfG4YFI OCG  (RSA)                 
    ↳ 🔑 certificates/domain/domain.fullchain.pem                             ✔️
    ↳ 🔑 certificates/rootCA/crl/domain.crl.pem                               ✔️
    ↳ 🔑 certificates/rootCA/crl/domain.crl                                   ✔️

   🎗️ 9a 
 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    ↳ 🔑 certificates/master/9a.key.main-01.enc.priv.pem                      ✔️
    ↳ 🔑 certificates/master/9a.key.main-01.unc.priv.pem                      ✔️
    ↳ 🔑 certificates/master/9a.csr                                           ✔️
    ↳ 🔑 certificates/master/9a.crt                                           ✔️
    ↳ 🔑 certificates/master/9a.keystore.normal.pfx                           ✔️
    ↳ 🔑 certificates/master/9a.keystore.base64.pfx                           ✔️
    ↳ 🔑 certificates/master/9a.keycert.main-01.enc.priv.pem                  ✔️
    ↳ 🔑 certificates/master/9a.keycert.main-01.unc.priv.pem                  ✔️
    ↳ 🔑 certificates/master/9a.key.main-02.enc.priv.pem                      ✔️
    ↳ 🔑 certificates/master/9a.key.main-02.unc.priv.pem                      ✔️
    ↳ 🔑 certificates/master/9a.key.rsa.priv.pem                              ✔️
    ↳ 🔑 certificates/master/9a.key.rsa.pub.pem                               ✔️
    ↳ 🔑 certificates/master/9a.key.openssh.pub                               ✔️
         ↳ 4096 SHA256:392GDJAbzW+DA6/i7RitpzWQqLWcH/n16zh/RdL/e7w OCG 1.0.0.0 (RSA)
    ↳ 🔑 certificates/master/9a.key.openssh.priv.pem                          ✔️
    ↳ 🔑 certificates/master/9a.key.openssh.priv.nopwd.pem                    ✔️
         ↳ 4096 SHA256:392GDJAbzW+DA6/i7RitpzWQqLWcH/n16zh/RdL/e7w OCG 1.0.0.0 (RSA)
    ↳ 🔑 certificates/master/9a.fullchain.pem                                 ✔️
    ↳ 🔑 certificates/rootCA/crl/9a.crl.pem                                   ✔️
    ↳ 🔑 certificates/rootCA/crl/9a.crl                                       ✔️
```

<br>
<br>

### Modes

The script comes with two modes:

<br>

1. **[New Key Generation](#new-key-generation)**
      - This mode generates entirely new keys, both private and public; as well as new certificates. 
      - If you have existing private keys and wish to generate new public keys or certificates for; this is **not** the setting you should use.
        - See [Existing Key Generation](#existing-key-generation).
2. **[Existing Key Generation](#existing-key-generation)**
    - This mode allows you to import your own private keys which will be used in order to generate new public keys and certificates.
    - This is useful for users who wish to keep their original private keys, but re-generate or renew.

<br>

<br>

#### New Key Generation

<small>`-n, --new`</small>

This mode generates entirely new keys, both private and public; as well as new certificates. If you have existing private keys you wish to generate new public keys or certificates for; this is **not** the setting you should use. See [Existing Key Generation](#existing-key-generation).

<br>

We give **two** different options for algorithms:

- **RSA** keys are the product of two prime numbers. This algorithm provides higher compatibility and is more widely used, especially in traditional digital signing scenarios. It is the most trusted algorithm of the two, whereas, some argue that ECC keys could be breakable in the future as quantum computers become more mainstream.

- **ECC** is a given point on a curve. This is calculated as a base point "multiplied" by a secret number, modulo the field prime. It is normally 256 bits in length (a 256-bit ECC key is equivalent to a 3072-bit RSA key), making it more secure and able to offer stronger anti-attack capabilities. Moreover, the computation of ECC is faster than RSA, and thus it offers higher efficiency and consumes fewer server resources.

<br>

##### RSA
By default, the `-n, --new` flag defaults to the RSA algorithm. To generate brand new keys, you must append `-n, --new` to the command:

```shell
generate --new
```

<br>

You may also specify the RSA algorithm, even though it is default:

```shell
generate --new --algorithm rsa
```

<br>

On top of defining the algorithm, you can also specify the bits for RSA. By default, this option is set to `4096`.

```shell
generate --new --algorithm rsa --bits 4096
```

<br>

If you wish for your keys to have a password, you must supply one using the `-P, --pass` option.

```shell
generate --new --algorithm rsa --bits 4096 --pass "YourPassword"
```

<br>

If you are handling more complex setups and generating new keys based on old private keys, you can specify `--passin` and `--passout`

<br>

If you wish for your keys to have a password, you must supply one using the `-P, --pass` option.

```shell
generate --new --algorithm rsa --bits 4096 --pass "YourPassword" --passin "IncomingPassword" --passout "OutgoingPassword"
```

<br>
<br>

##### ECC

<br>

To generate `ECC` / `ECDSA`:

```shell ignore
generate --new --algorithm ecc --pass "YourPassword"
```

<br>

If you are creating new keys based on existing keys with passwords, you can specify `--passin` and `--passout`

```shell
generate --new --algorithm ecc --pass "YourPassword" --passin "YourPassword" --passout "YourPassword"
```

<br>

You can also specify the **curve** to use, however, when generating ECC keys, `secp384r1` is the default. The available options are the same as offered by OpenSSL.

- secp384r1
- secp521r1
- sect571k1
- c2pnb368w1
- c2tnb431r1
- prime256v1

```shell
generate --new --algorithm ecc --curve "secp384r1"
```

<br>

> [!NOTE]
> As a security precaution so that you don't overwrite existing private keys, you **must** ensure you do not have any existing keys sitting in the folders. Even with using the `-n, --new` arguments; it will warn you about the existing keys and abort.

<br>

> [!NOTE]
> One of the keys that this script generates is a password protected OpenSSH private key located in the folders:
> - `certificates/domain/domain.key.openssh.priv.pem`
> - `certificates/master/9a.key.openssh.priv.pem`
> 
> This key requires that you provide a password which is a minimum of **5 characters**.
>
> If you do not specify a password, this key will be skipped.

<br>

#### Existing Key Generation

This mode allows you to import your own private keys which will be used in order to generate new public keys and certificates. This is useful for users who wish to keep their original private keys, but re-generate or renew.

There are two ways you can accomplish importing your own SSL keys:

- [Using the `--import` option](#option-1---import-option)
- [Manually copy/paste existing keys](#option-2-manual-import) 

<br>

##### Option 1: --import option

This option involves the usage of the `--import` option:

```shell
generate --import "/path/to/private-key.pem" 
```

<br>

If your existing key has a password, append `--pass` to your import command:

```shell
generate --import "/path/to/private-key.pem"  --pass "MyKeyPassword"
```

<br>

The utility will confirm that the key is correct, and also test to ensure you got the right password before it continues. Once your key has been validated, your existing private key will be copied from the specified `--import` path over to one of the following locations:

- 📁 `certificates/rootCA/rootCA.key.main-01.enc.priv.pem`
- 📁 `certificates/rootCA/rootCA.key.main-01.unc.priv.pem`

<br>

If your private key was unencrypted, it will be placed in the file ending with `main-01.unc.priv.pem`, and then an encrypted copy will be made.

If your private key was encrypted, it will be placed in the file ending with `main-01.enc.priv.pem`, and then an unencrypted copy will be made.

From this point, the utility will continue generating the other keys and certificates based on your private key.

<br>
<br>

##### Option 2: Manual Import

This option involves you manually copying over your existing private key to the following location:

- 📁 `certificates/rootCA/rootCA.key.main-01.enc.priv.pem`

<br>

Bare in mind that this utility generate numerous layers of keys:

- rootCA
- domain
- master

<br>

If you want to provide your own rootCA and domain private keys, you need to place your existing keys in the folders:

- 📁 `certificates/rootCA/rootCA.key.main-01.enc.priv.pem`
- 📁 `certificates/domain/domain.key.main-01.enc.priv.pem`
- 📁 `certificates/master/9a.key.main-01.enc.priv.pem`

<br>

By doing this, only new public keys and certificates will be generated for all three layers. No new private keys will be generated. The utility only generates new private keys when there are no available private keys in any of the folders.

When you are ready to update / generate new keys based on your imported ones, execute:

```shell
generate --name "Friendly Name" --days 365 --comment "Renewal for existing keys"
```

<br>

If your existing private keys contain a password, you must supply that password:

```shell
generate --name "Friendly Name" --days 365 --comment "Renewal for existing keys" --pass "YourPassword"
```

