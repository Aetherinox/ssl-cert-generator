# SSL Generator <!-- omit in toc -->

- [About](#about)
  - [New Key Generation](#new-key-generation)
    - [RSA](#rsa)
    - [ECC](#ecc)
  - [Existing Key Generation](#existing-key-generation)
    - [Option 1: --import argument](#option-1---import-argument)
    - [Option 2: Manual Import](#option-2-manual-import)
- [rootCA Authority](#rootca-authority)
- [Domain Authority](#domain-authority)
- [Authentication Authority](#authentication-authority)
- [Install](#install)
- [Arguments](#arguments)
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


<br />

---

<br />

## About
Generates a bundle of SSL certificates with varying purposes. After the set of certs / keys are generated, you will have the following:

- rootCA Certificate Authority
- Domain Authority
- Authentication Authority

<br />

The script comes with two modes:

1. New Key Generation
2. Existing Key Generation

<br />

### New Key Generation

<small>`-n, --new`</small>

This mode generates entirely new keys, both private and public; as well as new certificates. If you have existing private keys you wish to generate new public keys or certificates for; this is **not** the setting you should use. See [Existing Key Generation](#existing-key-generation).

<br />

We given two different options for algorithms:

- **RSA** keys are the product of two prime numbers. This algorithm provides higher compatibility and is more widely used, especially in traditional digital signing scenarios. It is the most trusted algorithm of the two, whereas, some argue that ECC keys could be breakable in the future as quantum computers become more mainstream.

- **ECC** is a given point on a curve. This is calculated as a base point "multiplied" by a secret number, modulo the field prime. It is normally 256 bits in length (a 256-bit ECC key is equivalent to a 3072-bit RSA key), making it more secure and able to offer stronger anti-attack capabilities. Moreover, the computation of ECC is faster than RSA, and thus it offers higher efficiency and consumes fewer server resources.

<br />

#### RSA
By default, the `-n, --new` flag defaults to the RSA algorithm. To generate brand new keys, you must append `-n, --new` to the command:

```shell
generate --new
```

<br />

You may also specify the RSA algorithm, even though it is default:

```shell
generate --new --algorithm rsa
```

<br />

On top of defining the algorithm, you can also specify the bits for RSA. By default, this parameter is set to `4096`.

```shell
generate --new --algorithm rsa --bits 4096
```

<br />

If you wish for your keys to have a password, you must supply one using the `-P, --pass` argument.

```shell
generate --new --algorithm rsa --bits 4096 --pass "YourPassword"
```

If you are handling more complex setups and generating new keys based on old private keys, you can specify `--passin` and `--passout`

<br />

If you wish for your keys to have a password, you must supply one using the `-P, --pass` argument.

```shell
generate --new --algorithm rsa --bits 4096 --pass "YourPassword" --passin "IncomingPassword" --passout "OutgoingPassword"
```

<br />

#### ECC

<br />

To generate `ECC` / `ECDSA`:

```shell ignore
generate --new --algorithm ecc --pass "YourPassword"
```

<br />

If you are creating new keys based on existing keys with passwords, you can specify `--passin` and `--passout`

```shell
generate --new --algorithm ecc --pass "YourPassword" --passin "YourPassword" --passout "YourPassword"
```

<br />

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

<br />

> [!NOTE]
> As a security precaution so that you don't overwrite existing private keys, you **must** ensure you do not have any existing keys sitting in the folders. Even with using the `-n, --new` arguments; it will warn you about the existing keys and abort.

<br />

> [!NOTE]
> One of the keys that this script generates is a password protected OpenSSH private key located in the folders:
> - `certificates/domain/domain.key.openssh.priv.pem`
> - `certificates/master/9a.key.openssh.priv.pem`
> 
> This key requires that you provide a password which is a minimum of **5 characters**.
>
> If you do not specify a password, this key will be skipped.

<br />

### Existing Key Generation

This mode allows you to import your own private keys which will be used in order to generate new public keys and certificates. This is useful for users who wish to keep their original private keys, but re-generate or renew.

There are two ways you can accomplish importing your own SSL keys:

- [Using the `--import` argument](#option-1---import-argument)
- [Manually copy/paste existing keys](#option-2-manual-import) 

<br />

#### Option 1: --import argument

This option involves the usage of the `--import` argument:

```shell
generate --import "/path/to/private-key.pem" 
```

<br />

If your existing key has a password, append `--pass` to your import command:

```shell
generate --import "/path/to/private-key.pem"  --pass "MyKeyPassword"
```

<br />

The utility will confirm that the key is correct, and also test to ensure you got the right password before it continues. Once your key has been validated, your existing private key will be copied from the specified `--import` path over to one of the following locations:

- 📁 `certificates/rootCA/rootCA.key.main-01.enc.priv.pem`
- 📁 `certificates/rootCA/rootCA.key.main-01.unc.priv.pem`

<br />

If your private key was unencrypted, it will be placed in the file ending with `main-01.unc.priv.pem`, and then an encrypted copy will be made.

If your private key was encrypted, it will be placed in the file ending with `main-01.enc.priv.pem`, and then an unencrypted copy will be made.

From this point, the utility will continue generating the other keys and certificates based on your private key.

<br />

#### Option 2: Manual Import

This option involves you manually copying over your existing private key to the following location:

- 📁 `certificates/rootCA/rootCA.key.main-01.enc.priv.pem`

<br />

Bare in mind that this utility generate numerous layers of keys:

- rootCA
- domain
- master

<br />

If you want to provide your own rootCA and domain private keys, you need to place your existing keys in the folders:

- 📁 `certificates/rootCA/rootCA.key.main-01.enc.priv.pem`
- 📁 `certificates/domain/domain.key.main-01.enc.priv.pem`
- 📁 `certificates/master/9a.key.main-01.enc.priv.pem`

<br />

By doing this, only new public keys and certificates will be generated for all three layers. No new private keys will be generated. The utility only generates new private keys when there are no available private keys in any of the folders.

When you are ready to update / generate new keys based on your imported ones, execute:

```shell
generate --name "Friendly Name" --days 365 --comment "Renewal for existing keys"
```

<br />

If your existing private keys contain a password, you must supply that password:

```shell
generate --name "Friendly Name" --days 365 --comment "Renewal for existing keys" --pass "YourPassword"
```

<br />

---

<br />

## rootCA Authority
All certificates generated with this utility will be signed with the `rootCA`, as well as a revocation list.

The rootCA contains the following usages:

```ini
[ x509_rootCA ]
basicConstraints        = critical, CA:true
keyUsage                = critical, digitalSignature, cRLSign, keyCertSign
```

<br />

---

<br />

## Domain Authority
These can be utilized for domains that you wish to enable SSL on. 

The domain authority certs contain the following usages:

```ini
[ x509_domain ]
basicConstraints        = CA:false, pathlen:0
keyUsage                = critical, digitalSignature, keyEncipherment, keyAgreement
extendedKeyUsage        = critical, serverAuth, clientAuth
```

<br />

---

<br />

## Authentication Authority
These certs / keys can be utilized for things such as SSH authentication. They are ready to be imported into a security device such as a Yubikey, and will typically go into `Slot 9A`. This can be achieved by using the [Yubikey Manager](https://www.yubico.com/support/download/yubikey-manager/) application

The authentication certs are not restricted in their usage permissions and are left blank. To assign certain usages to these certs, edit the `rootCA.cnf` file and define the desired usages.

```ini
[ x509_9a_master ]
basicConstraints        = CA:false, pathlen:0
# keyUsage              = critical, digitalSignature, keyEncipherment, keyAgreement
# extendedKeyUsage      = critical, serverAuth, clientAuth
```

<br />

---

<br />

## Install

Download the contents of this repo to your local machine.

```shell
git clone https://github.com/Aetherinox/ssl-cert-generator.git .
```

<br />

Set the correct permissions:

```shell
sudo chmod +x generator
```

<br />

Add the `generator` file to your `/usr/local/bin` so that it can be accessed from any directory

```shell
sudo ln -s /path/to/generate /usr/local/bin
```

<br />

To remove the symlink

```shell
sudo rm /usr/local/bin/generate
```

<br />

---

<br />

## Arguments

This utility has the following available arguments you can pass:

| Argument | Description |
| --- | --- |
| <small>`-n, --new`</small> | <small>Generates new keys if existing private keys do not exist in the base folders `rootCA`, `domain`, and `master`</small> |
| <small>`--import, -i`</small> | <small>Import existing RSA or ECC private key, and generate new public keys and certificates based on the private key.</small> |
| <small>`--algorithm, -a`</small> | <small>Algorithm to use for key generation. These are the values available within OpenSSL. <br /><br /> `ecc`, `rsa` <br /><br /> Default: `rsa`</small> |
| <small>`--curve, -V`</small> | <small>ECC curve; accepts all curves available through OpenSSL <br /><br /> `secp384r1`, `secp521r1`, `sect571k1`, `c2pnb368w1`, `c2tnb431r1`, `prime256v1` <br /><br /> Default: `rsa`</small> |
| <small>`--bits, -b`</small> | <small>Specifies the number of bits to use with an RSA key <br /><br /> Default: `4096`</small> |
| <small>`--friendlyname, -N`</small> | <small>Friendly name to use for certificate</small> |
| <small>`--pass, -P`</small> | <small>Password to use for certs and keys</small> |
| <small>`--passin, -I`</small> | <small>Password to use for imported keys, and private keys needed to make new keys</small> |
| <small>`--passout, -O`</small> | <small>Password to use when creating a new private key from an existing, this password is applied to the newer keys</small> |
| <small>`--homeFolder, -H`</small> | <small>Set the home folder <br/> This is the folder where the `generate` app currently resides.<br/><br/> Default: `${PWD}`</small> |
| <small>`--certsFolder, -C`</small> | <small>Set the certs folder <br/>Re-names the `certificates` folder. <br/><br/> Default: `certificates`</small> |
| <small>`--rootcaFolder, -R`</small> | <small>Set the rootCA folder <br/><br/> Default: `rootCA`</small> |
| <small>`--domainFolder, -D`</small> | <small>Set the domain folder <br /><br/> Default: `domain`</small> |
| <small>`--days, -d`</small> | <small>Certificate expiration time in days <br /><br/> Default: `36500`</small> |
| <small>`--comment, -t`</small> | <small>specify a comment to add to RSA and OpenSSH keys <br /><br/> Default: `OCG 1.0.0.0`</small> |
| <small>`--clean, -c`</small> | <small>Remove all files, but keep OpenSSL config `rootCA.cnf` and main private `.pem` keys</small> |
| <small>`--wipe, -w`</small> | <small>Remove every file in `certificates` / `certsFolder` folder, `rootcaFolder` OpenSSL config `rootCA.cnf` excluded and will remain</small> |
| <small>`--vars, -v`</small> | <small>List all variables / paths</small> |
| <small>`--status, -s`</small> | <small>Output a list of certs & keys generated to check for all files</small> |
| <small>`--version, -v`</small> | <small>Current version of this generator</small> |
| <small>`--dev, -x`</small> | <small>Developer mode</small> |
| <small>`--help, -z`</small> | <small>Show this help menu</small> |

<br />

---

<br />

## Commands

This utility includes a large list of options and commands. A complete list can be found by executing the command `generator --help`. Some of the most important commands are outlined below:

<br />

### Help

<small>`--help, -z`</small>

Displays helpful information about the script, including all available commands.

```shell
generator --help
```

<br />

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

<br />

### New
<small>`-n, --new`</small>

The new command generates new keys and certificates, including the main private keys. If you do not specify this flag, you must already have existing private keys added so that it will build certificates and public keys based on the private keys.

```shell
generate --new
```

<br />

If you do not wish to generate new private keys, and want to use your own; you must ensure you have the following files in the locations specified below:

- `certificates/rootCA/rootCA.key.main-01.enc.priv.pem`
- `certificates/domain/domain.key.main-01.enc.priv.pem`

<br />

If you have the above private keys in place, you can exclude the `-n, --new` arguments, and new public keys and certificates will be generated based on the private keys.

```shell
generate --comment "My Existing Key" --name "Original Key"
```

<br />

### Algorithm
<small>`--algorithm, -a`</small>

The **algorithm** parameter allows you to specify whether you generate RSA based keys, or ECC / ECDSA.

For ECC keys, use this parameter in combination with `--curve`; otherwise the default curve will be `secp384r1`.

```shell
generate --algorithm ecc --curve secp384r1
```

<br />

### Curve
<small>`--curve, -V`</small>

The **curve** parameter allows you to specify which curve to use for ECC / ECDSA. This parameter accepts the same values offered by OpenSSL.

```shell
generate --algorithm ecc --curve secp384r1
```

<br />

### Bits
<small>`--bits, -b`</small>

The **curve** parameter allows you to specify which curve to use for ECC / ECDSA. This parameter accepts the same values offered by OpenSSL.

```shell
generate --algorithm ecc --curve secp384r1
```

<br />

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

<br />

Parameters are provided so that these folder names can be changed.

<br />

#### homeFolder

<small>`--homeFolder, -H`</small>

By default, the generator will run in whatever folder the script was called from; however, you can force it to use another path:

```shell
generator --homeFolder /path/to/folder
```

<br />

#### certsFolder

<small>`--certsFolder, -C`</small>

Changes the `certificates` folder name. The following example will use the folder `certs` instead of `certificates`.

```shell
generate --certsFolder certs
```

<br />

#### rootcaFolder

<small>`--rootcaFolder, -R`</small>

Changes the `rootCA` folder name. The following example will use the folder `authority` instead of `rootCA`.

```shell
generate --rootcaFolder authority
```

<br />

#### domainFolder

<small>`--domainFolder, -D`</small>

Changes the `domain` folder name. The following example will use the folder `mydomain.com` instead of `domain`.

```shell
generate --rootcaFolder mydomain.com
```

<br />

### Passwords

This utility uses the same structure that OpenSSL does when dealing with the parameters:
- pass
- passin
- passout

<br />

Several commands accept password arguments, typically using -passin and -passout for input and output passwords respectively. These allow the password to be obtained from a variety of sources. Both of these options take a single argument

If you are attempting to generate new files based on an existing key which is password protected; you must supply that password as part of the command.

```shell
generate --new --pass "YourExistingPassword"
```

<br />

If you are generating certs based on an existing key which has a password, and you'd also like your new keys to have a different password, specify `--passout`. 

This means your input password protected key will be specified by `--pass`, and the outgoing keys will use the password supplied by `--passout`.

```shell
generate --pass "YourExistingPassword" --passout "YourNewPassword"
```

<br />

### Friendly Name

<small>`--friendlyname, -N`</small>

This specifies the "friendly name" for the certificates and private key. This name is typically displayed in list boxes by software importing the file.

```shell
generate --new --name "My certificate" --pass "YourExistingPassword"
```

<br />

### Days / Expiration

<small>`--days, -d`</small>

Specifies how long until the created certificate expires. The following example will set the certificate to last `1095` days, or 3 years.

```shell
generate --new --name "My certificate" --days 1095 --pass "YourExistingPassword"
```

<br />

### Comment

<small>`--comment, -t`</small>

Defines a comment to be added to RSA keys generated. If a comment is not specified, comment will default to `OCG 1.x.x`; which stands for **OpenSSL Certificate Generator**.

```shell
generate --new --name "My certificate" --days 1095 --comment "Work keys" --pass "YourExistingPassword"
```

<br />

### Wipe & Clean

This script comes with a few commands to throw away any existing files if you decide that you do not need them anymore. However, you should be careful with these commands. You will be unable to restore any previously generated certs and keys unless you have backed them up.

We provide you with two different commands:
- `--wipe, -w`
- `--clean, -C`

<br />

#### Clean

<small>`--clean, -c`</small>

The clean command will destroy all files except for the following:

- 📄 `rootCA.cnf` <small><small>(OpenSSL config)</small></small>
- 📄 `rootCA.key.main-01.enc.priv.pem` <small><small>Private key - Encrypted</small></small>
- 📄 `rootCA.key.main-01.unc.priv.pem` <small><small>Private key - Unencrypted</small></small>
- 📄 `domain.key.main-01.enc.priv.pem` <small><small>Private key - Encrypted</small></small>
- 📄 `domain.key.main-01.unc.priv.pem` <small><small>Private key - Unencrypted</small></small>

<br />

```shell
generate --clean
```

<br />

#### Wipe

<small>`--wipe, -w`</small>

The wipe command will destroy all files except for the following:

- 📄 `rootCA.cnf` <small><small>(OpenSSL config)</small></small>

<br />

```shell
generate --wipe
```

<br />

#### Variables

<small>`--vars, -v`</small>

The variables command outputs a list of stored variables and their values. Mainly this is used for development purposes only.

<br />

```shell
generate --vars
```

<br />

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

### Status

<small>`--status, -s</small>

The status command will scan the working directory to detect if all of the files generated by this script are indeed found.

<br />

```shell
generate --status
```

<br />

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
