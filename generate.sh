# #
#   OpenSSL Certificate Generator
#   
#   This is a utility which allows you to generate multiple types of certificates on your Linux system:
#   
#       Root Certificate Authority
#           Signs all certificates
#       Domain Authority
#           SSL certificate for websites
#       Authentication Authority
#           SSH authentication cert and keys
#   
#   After a successful run, you should have the following structure:
#       
#       📁 certificates
#           📁 rootCA
#               📁 certs
#               📁 crl
#                  📄 rootCA.crl
#                  📄 rootCA.crl.pem
#               📁 generated
#                  📄 00.pem
#                  📄 01.pem
#               📄 crlnumber
#               📄 crlnumber.old
#               📄 index.txt
#               📄 index.txt.attr
#               📄 index.txt.old
#               📄 rootCA.cnf
#               📄 rootCA.crt
#               📄 rootCA.key.main-01.enc.priv.pem
#               📄 rootCA.key.main-01.unc.priv.pem
#               📄 rootCA.pfx
#               📄 serial
#               📄 serial.old
#           📁 domain
#               📄 domain.crt
#               📄 domain.csr
#               📄 domain.key.main-01.enc.priv.pem
#               📄 domain.key.main-01.unc.priv.pem
#               📄 domain.key.main-02.enc.priv.pem
#               📄 domain.key.main-02.unc.priv.pem
#               📄 domain.key.openssh.pub
#               📄 domain.key.openssh.priv.pem
#               📄 domain.key.openssh.priv.nopwd.pem
#               📄 domain.key.rsa.priv.pem
#               📄 domain.key.rsa.pub.pem
#               📄 domain.keycert.main-01.enc.priv.pem
#               📄 domain.keycert.main-01.unc.priv.pem
#               📄 domain.keystore.base64.pfx
#               📄 domain.keystore.normal.pfx
#               📄 domain.fullchain.pem
#           📁 master
#               📄 9a.crt
#               📄 9a.csr
#               📄 9a.key.main-01.enc.priv.pem
#               📄 9a.key.main-01.unc.priv.pem
#               📄 9a.key.main-02.enc.priv.pem
#               📄 9a.key.main-02.unc.priv.pem
#               📄 9a.key.openssh.pub
#               📄 9a.key.openssh.priv.pem
#               📄 9a.key.openssh.priv.nopwd.pem
#               📄 9a.key.rsa.priv.pem
#               📄 9a.key.rsa.pub.pem
#               📄 9a.keycert.main-01.enc.priv.pem
#               📄 9a.keycert.main-01.unc.priv.pem
#               📄 9a.keystore.base64.pfx
#               📄 9a.keystore.normal.pfx
#               📄 9a.fullchain.pem
#       📄 generate.sh
#   
#   ―― SETUP ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#   
#       To start using this script, execute the following commands:
#   
#       sudo chmod +x generate.sh
#       ./generate.sh --newkey --pass "abc"
#   
#   ―― EXAMPLES  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#   
#       Use any of the following:
#   
#       ./generate.sh --newkey --pass "abc"
#       ./generate.sh --newkey --pass "abc" --keytype "ec" || "rsa"
#       ./generate.sh --newkey --pass "abc" --keytype "ec" --base "/path/to/cert/folder/out"
#       ./generate.sh --newkey --pass "abc" --keytype "ec" --base "/path/to/cert/folder/out" --domain "domain.com"
#       ./generate.sh --vars
#       ./generate.sh --wipe
#       ./generate.sh --clean
#       ./generate.sh --help
#   
#   ―― GENERATE NEW ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#   
#       Use the following command to generate new keys / certificates without any previous keys.
#       ./generate.sh --newkey  --name "YourCompany" --pass "PASSWORD"
#   
#   ―― Use Existing Private Keys ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#   
#       Make sure you have placed your private keys (main-01.enc.priv.pem) inside:
#           - certificates/rootCA
#           - certificates/domain
#   
#       ./generate.sh --name "YourCompany" --pass "PASSWORD" --passout "PASSOUT"
# #

#!/bin/bash
PATH="/bin:/usr/bin:/sbin:/usr/sbin:/home/${USER}/bin"
echo
set -f

# #
#   vars > colors
#
#   Use the color table at:
#       - https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
# #

END=$'\e[0m'
WHITE=$'\e[97m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
UNDERLINE=$'\e[4m'
BLINK=$'\e[5m'
INVERTED=$'\e[7m'
HIDDEN=$'\e[8m'
BLACK=$'\e[38;5;0m'
FUCHSIA1=$'\e[38;5;125m'
FUCHSIA2=$'\e[38;5;198m'
RED=$'\e[38;5;160m'
RED2=$'\e[38;5;196m'
ORANGE=$'\e[38;5;202m'
ORANGE2=$'\e[38;5;208m'
MAGENTA=$'\e[38;5;5m'
BLUE=$'\e[38;5;033m'
BLUE2=$'\e[38;5;39m'
CYAN=$'\e[38;5;6m'
GREEN=$'\e[38;5;2m'
GREEN2=$'\e[38;5;76m'
YELLOW=$'\e[38;5;184m'
YELLOW2=$'\e[38;5;190m'
YELLOW3=$'\e[38;5;193m'
GREY1=$'\e[38;5;240m'
GREY2=$'\e[38;5;244m'
GREY3=$'\e[38;5;250m'
NAVY=$'\e[38;5;99m'
OLIVE=$'\e[38;5;144m'
PEACH=$'\e[38;5;210m'

# #
#   vars > colors
#   
#   this is the OLD color method; it has been replaced with ASCII above.
#
#   tput setab  [1-7]       : Set a background color using ANSI escape
#   tput setb   [1-7]       : Set a background color
#   tput setaf  [1-7]       : Set a foreground color using ANSI escape
#   tput setf   [1-7]       : Set a foreground color
# #

# BLACK=$(tput setaf 0)
# RED=$(tput setaf 1)
# ORANGE=$(tput setaf 208)
# GREEN=$(tput setaf 2)
# YELLOW=$(tput setaf 156)
# LIME_YELLOW=$(tput setaf 190)
# POWDER_BLUE=$(tput setaf 153)
# BLUE=$(tput setaf 4)
# MAGENTA=$(tput setaf 5)
# CYAN=$(tput setaf 6)
# WHITE=$(tput setaf 7)
# GREYL=$(tput setaf 242)
# DEV=$(tput setaf 157)
# DEVGREY=$(tput setaf 243)
# FUCHSIA=$(tput setaf 198)
# PINK=$(tput setaf 200)
# BOLD=$(tput bold)
# NORMAL=$(tput sgr0)
# BLINK=$(tput blink)
# REVERSE=$(tput smso)
# UNDERLINE=$(tput smul)
# STRIKE="\e[9m"
# END="\e[0m"

# #
#   vars > system
# #

sys_arch=$(dpkg --print-architecture)
sys_code=$(lsb_release -cs)

# #
#   vars > app > folders
# #

# #
#   vars > app > folders
# #

app_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# #
#   Ensure we're in the correct directory
# #

cd ${app_dir}

# #
#   vars > app > files
# #

app_file_this=$(basename "$0")

# #
#   DEFINE > App repo paths and commands
# #

app_title="SSL-Gen (Aetherx)"
app_about="A script to generate SSL certificates in Linux"
app_ver=("1" "0" "0" "0")

# #
#   func > get version
#
#   returns current version of app
#   converts to human string.
#       e.g.    "1" "1" "0" "0"
#               1.1.0.0
# #

get_version()
{
    ver_join=${app_ver[@]}
    ver_str=${ver_join// /.}
    echo ${ver_str}
}

# #
#   OpenSSH Extensions & Sections
# #

EXTENSION_ROOT=x509_rootCA
EXTENSION_DOMAIN=x509_domain
EXTENSION_MASTER=x509_9a_master
SECTION_ROOT=req_rootCA
SECTION_DOMAIN=req_domain
SECTION_MASTER=req_9a_master

# #
#   DEFINE > Language
# #

LNG_STEP_CHECK_INTEGRITY="Integrity Check"
LNG_STEP_FOLDER_CREATE="Create Folder"

# #
#   DEFINE > Folders
# #

FOLDER_BASE=certificates
FOLDER_ROOT=rootCA
FOLDER_ROOT_SUB_GEN=generated
FOLDER_ROOT_SUB_CRL=crl
FOLDER_ROOT_SUB_CERTS=certs
FOLDER_DOMAIN=domain
FOLDER_MASTER=master

# #
#   DEFINE > Files
# #

FILE_ROOTCA_BASE=rootCA
FILE_DOMAIN_BASE=domain
FILE_MASTER_BASE=9a
FILE_ROOTCA_INDEX=index
FILE_ROOTCA_CRLNUMBER=crlnumber
FILE_ROOTCA_SERIAL=serial

# #
#   DEFINE > Paths
#
#   ROOTCA              path / folder for rootCA certs and keys
#   DOMAIN              path / folder to place domain level certificates, signed by rootCA
#   MASTER              path / folder to place master certs and keys; utilized for SSH, etc. No usage restrictions. Also classified as 9A
# #

PATH_CERTS=${app_dir}/${FOLDER_BASE}                                                # /home/USER/Desktop/ssh/certificates
PATH_ROOTCA=${PATH_CERTS}/${FOLDER_ROOT}                                            # /home/USER/Desktop/ssh/certificates/rootCA
PATH_ROOTCA_SUB_CRL=${PATH_CERTS}/${FOLDER_ROOT}/${FOLDER_ROOT_SUB_CRL}             # /home/USER/Desktop/ssh/certificates/rootCA/crl
PATH_ROOTCA_SUB_GEN=${PATH_CERTS}/${FOLDER_ROOT}/${FOLDER_ROOT_SUB_GEN}             # /home/USER/Desktop/ssh/certificates/rootCA/generated
PATH_ROOTCA_SUB_CERTS=${PATH_CERTS}/${FOLDER_ROOT}/${FOLDER_ROOT_SUB_CERTS}         # /home/USER/Desktop/ssh/certificates/rootCA/certs
PATH_ROOTCA_BASE=${PATH_ROOTCA}/${FILE_ROOTCA_BASE}                                 # /home/USER/Desktop/ssh/certificates/rootCA/rootCA.*
PATH_DOMAIN=${PATH_CERTS}/${FOLDER_DOMAIN}                                          # /home/USER/Desktop/ssh/certificates/domain
PATH_DOMAIN_BASE=${PATH_DOMAIN}/${FILE_DOMAIN_BASE}                                 # /home/USER/Desktop/ssh/certificates/domain/domain.*
PATH_MASTER=${PATH_CERTS}/${FOLDER_MASTER}                                          # /home/USER/Desktop/ssh/certificates/master
PATH_MASTER_BASE=${PATH_MASTER}/${FILE_MASTER_BASE}                                 # /home/USER/Desktop/ssh/certificates/master/master.*

# #
#   DEFINE > Passwords
#
#   passwords can be passed using CLI parameters
#       ./generate_ssl.sh --pass "Your Password"
# #

PWD_IN=""
PWD_OUT=""
PWD=""
PWD_STR=""

# #
#   DEFINE > Options
# #

PARAM_ISSUE_NAME="CompanyName"
PARAM_KEY_TYPE="rsa"
PARAM_DAYS=36500
PARAM_BITS=4096
PARAM_COMMENT="${app_title} v$(get_version)"
BOOL_DEV_ENABLED="false"
BOOL_NEW_KEYS="false"

# #
#   DEFINE > Extensions
# #

EXT_PEM="pem"
EXT_PUB="pub"
EXT_CRT="crt"
EXT_CSR="csr"
EXT_CRL="crl"
EXT_PFX="pfx"
EXT_CNF="cnf"
EXT_TXT="txt"
EXT_OLD="old"
EXT_ATTR="attr"

# #
#   DEFINE > Key Name
# #

SSL_KEY_MAIN_ENC="key.main-01.enc.priv.${EXT_PEM}"
SSL_KEY_MAIN_UNC="key.main-01.unc.priv.${EXT_PEM}"
SSL_KEY_MAIN02_ENC="key.main-02.enc.priv.${EXT_PEM}"
SSL_KEY_MAIN02_UNC="key.main-02.unc.priv.${EXT_PEM}"
SSL_KEY_RSA_PRIV="key.rsa.priv.${EXT_PEM}"
SSL_KEY_RSA_PUB="key.rsa.pub.${EXT_PEM}"
SSL_KEY_SSH_PUB="key.openssh.${EXT_PUB}"
SSL_KEY_SSH_PRIV="key.openssh.priv.${EXT_PEM}"
SSL_KEY_SSH_PRIV_NOPWD="key.openssh.priv.nopwd.${EXT_PEM}"
SSL_CERT_MAIN_ENC="keycert.main-01.enc.priv.${EXT_PEM}"
SSL_CERT_MAIN_UNC="keycert.main-01.unc.priv.${EXT_PEM}"
SSL_CERT_FULLCHAIN="fullchain.${EXT_PEM}"
SSL_KEYSTORE_PFX="keystore.normal.${EXT_PFX}"
SSL_KEYSTORE_B64="keystore.base64.${EXT_PFX}"
EXT_CRL_PEM="${EXT_CRL}.${EXT_PEM}"

# #
#   func > version > compare greater than
#
#   this function compares two versions and determines if an update may
#   be available. or the user is running a lesser version of a program.
# #

get_version_compare_gt()
{
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

# #
#   Check files
# #

readStatus()
{

    echo -e
    echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
    echo -e
    echo -e "  ${BOLD}${GREEN}COMPLETE  ${WHITE}A check has been performed to ensure your keys were generated.${END}"
    echo -e
    echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"

    echo -e
    echo -e "  ${BLUE} 🎗️ SSL Config ${END}"
    echo -e " ${GREY1}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
    if ( set +f; ls ${PATH_ROOTCA_BASE}.*${EXT_CNF}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${EXT_CNF}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${EXT_CNF}${END}" "${WHITE}❌${END}"
    fi

    if ( set +f; ls ${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT} ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}${END}" "${WHITE}❌${END}"
    fi

    if ( set +f; ls ${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER} ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL} ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}${END}" "${WHITE}❌${END}"
    fi


    echo -e
    echo -e "  ${BLUE} 🎗️ ${FILE_ROOTCA_BASE} ${END}"
    echo -e " ${GREY1}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
    if ( set +f; ls ${PATH_ROOTCA_BASE}.*${SSL_KEY_MAIN_ENC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_ROOTCA_BASE}.*${SSL_KEY_MAIN_UNC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_ROOTCA_BASE}.*${EXT_CRT}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${EXT_CRT}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${EXT_CRT}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_ROOTCA_BASE}.*${EXT_PFX}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${EXT_PFX}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_BASE}.${EXT_PFX}${END}" "${WHITE}❌${END}"
    fi

    echo -e
    echo -e "  ${BLUE} 🎗️ ${FILE_DOMAIN_BASE} ${END}"
    echo -e " ${GREY1}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
    if ( set +f; ls ${PATH_DOMAIN_BASE}.*${SSL_KEY_MAIN_ENC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.*${SSL_KEY_MAIN_UNC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_UNC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_UNC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.*${EXT_CSR}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${EXT_CSR}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${EXT_CSR}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.*${EXT_CRT}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${EXT_CRT}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${EXT_CRT}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_UNC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_UNC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_UNC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_ENC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_ENC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_ENC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_UNC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_UNC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_UNC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PUB}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PUB}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PUB}${END}" "${WHITE}❌${END}"
    fi

    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PUB}* ) 1> /dev/null 2>&1; then
            thumbprint=$(ssh-keygen -lf "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PUB}")
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PUB}${END}" "${WHITE}✔️${END}"
            printf '%-120s %-40s\n' "  ${BLUE}       ↳ ${thumbprint}${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PUB}${END}" "${WHITE}❌${END}"
    fi

    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}${END}" "${WHITE}❌${END}"
    fi

    if ( set +f; ls ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}* ) 1> /dev/null 2>&1; then
            thumbprint=$(ssh-keygen -lf "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}")
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}${END}" "${WHITE}✔️${END}"
            printf '%-120s %-40s\n' "  ${BLUE}       ↳ ${thumbprint}${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}${END}" "${WHITE}❌${END}"
    fi

    if ( set +f; ls ${PATH_DOMAIN}/${FILE_DOMAIN_BASE}.${SSL_CERT_FULLCHAIN}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN}/${FILE_DOMAIN_BASE}.${SSL_CERT_FULLCHAIN}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_DOMAIN}/${FILE_DOMAIN_BASE}.${SSL_CERT_FULLCHAIN}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL_PEM}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL_PEM}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL_PEM}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL}${END}" "${WHITE}❌${END}"
    fi

    echo -e
    echo -e "  ${BLUE} 🎗️ ${FILE_MASTER_BASE} ${END}"
    echo -e " ${GREY1}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
    if ( set +f; ls ${PATH_MASTER_BASE}.*${SSL_KEY_MAIN_ENC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.*${SSL_KEY_MAIN_UNC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_MAIN_UNC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_MAIN_UNC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.*${EXT_CSR}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${EXT_CSR}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${EXT_CSR}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.*${EXT_CRT}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${EXT_CRT}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${EXT_CRT}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_CERT_MAIN_UNC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_CERT_MAIN_UNC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_CERT_MAIN_UNC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_ENC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_ENC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_ENC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_UNC}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_UNC}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_UNC}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEY_RSA_PUB}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_RSA_PUB}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_RSA_PUB}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PUB}* ) 1> /dev/null 2>&1; then
            thumbprint=$(ssh-keygen -lf "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PUB}")
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PUB}${END}" "${WHITE}✔️${END}"
            printf '%-120s %-40s\n' "  ${BLUE}       ↳ ${thumbprint}${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PUB}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}* ) 1> /dev/null 2>&1; then
            thumbprint=$(ssh-keygen -lf "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}")
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}${END}" "${WHITE}✔️${END}"
            printf '%-120s %-40s\n' "  ${BLUE}       ↳ ${thumbprint}${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_MASTER}/${FILE_MASTER_BASE}.${SSL_CERT_FULLCHAIN}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER}/${FILE_MASTER_BASE}.${SSL_CERT_FULLCHAIN}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_MASTER}/${FILE_MASTER_BASE}.${SSL_CERT_FULLCHAIN}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL_PEM}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL_PEM}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL_PEM}${END}" "${WHITE}❌${END}"
    fi
    if ( set +f; ls ${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL}* ) 1> /dev/null 2>&1; then
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL}${END}" "${WHITE}✔️${END}"
    else
            printf '%-120s %-40s\n' "  ${GREEN}  ↳ 🔑 ${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL}${END}" "${WHITE}❌${END}"
    fi

    echo -e
    echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
    echo -e

    exit 1
}

# #
#   Display Usage Help
#
#   activate using ./generate.sh --help or -h
# #

opt_usage()
{
    echo -e
    printf "  ${BLUE}${app_title}${END}\n" 1>&2
    printf "  ${GREY3}${app_about}${END}\n" 1>&2
    echo -e
    printf '  %-5s %-40s\n' "${GREEN}Usage:${END}" "" 1>&2
    printf '  %-5s %-40s\n' "    " "${0} [ ${GREY3}options${END} ]" 1>&2
    printf '  %-5s %-40s\n\n' "    " "${0} [ ${GREY3}--newkey --keytype "rsa" --name \"CompanyName\"${END} ] [ ${GREY3}--pass \"YOUR_PASSWD\"${END} ] [ ${GREY3}--version${END} ] [ ${GREY3}--help${END} ]" 1>&2
    printf '  %-5s %-40s\n' "${GREEN}Structure:${END}" "" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3} 📁 ${FOLDER_BASE}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${BLUE}    📁 ${FOLDER_ROOT}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${BLUE}       📁 ${FOLDER_ROOT_SUB_CERTS}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${BLUE}       📁 ${FOLDER_ROOT_SUB_CRL}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}          📄 ${FILE_ROOTCA_BASE}.${EXT_CRL}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}          📄 ${FILE_ROOTCA_BASE}.${EXT_CRL}.${EXT_PEM}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${BLUE}       📁 ${FOLDER_ROOT_SUB_GEN}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}          📄 00.${EXT_PEM}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}          📄 01.${EXT_PEM}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_CRLNUMBER}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_CRLNUMBER}.${EXT_OLD}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_INDEX}.${EXT_TXT}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_ATTR}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_OLD}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_BASE}.${EXT_CNF}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_BASE}.${EXT_CRT}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_BASE}.${EXT_PFX}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_SERIAL}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3}       📄 ${FILE_ROOTCA_SERIAL}.${EXT_OLD}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${BLUE}    📁 ${FOLDER_DOMAIN}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${BLUE}    📁 ${FOLDER_MASTER}${END}" 1>&2
    printf '  %-5s %-40s\n' "    " "${GREY3} 📄 ${0}${END}" 1>&2
    printf '  %-5s %-40s\n' "" "" 1>&2
    printf '  %-5s %-40s\n' "${GREEN}Options:${END}" "" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-k,  --newkey" "generates brand new keys" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-K,  --keytype" "type of key to generate" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "" "    ${GREY3}options:${END} ec, rsa" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-n,  --name" "name / identity to use for certificate issuer name" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-P,  --pass" "sets the password to use for certs and keys" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-I, --passin" "Password in" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-O, --passout" "Password out" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-b,  --base" "Base folder name where certs and keys will be stored" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-r,  --root" "${FOLDER_ROOT} folder name" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-d,  --days" "certificate expiration time in days" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-D,  --domain" "domain folder name to store domain certs and keys" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-c,  --comment" "specify a comment to add to RSA and OpenSSH keys" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-C,  --clean" "removes all files, but keeps ${FILE_ROOTCA_BASE}.${EXT_CNF}, and main private .${EXT_PEM} keys" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-w,  --wipe" "removes every file in certificates folder except ${FILE_ROOTCA_BASE}.${EXT_CNF}" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-v,  --vars" "lists all variables / paths" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-s,  --status" "outputs a list of certs & keys generated to check for all files" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-v,  --version" "current version of this updater" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-x,  --dev" "dev mode" 1>&2
    printf '  %-5s %-24s %-40s\n' "    " "-h,  --help" "show this help menu" 1>&2
    echo -e
    echo -e

    exit 1
}

# #
#   command-line options
#   
#   reminder that any functions which need executed must be defined BEFORE
#   this point. Bash sucks like that.
# #

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--name)
            if [[ "$1" != *=* ]]; then shift; fi
            PARAM_ISSUE_NAME="${1#*=}"
            if [ -z "${PARAM_ISSUE_NAME}" ]; then
                echo -e "  ${END}Must specify a certificate name${END}"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} --name "Certificate Name"${END}"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} -n "Certificate Name"${END}"
                echo -e

                exit 1
            fi
            ;;

    -k|--nk|--newkey|--newkeys)
            BOOL_NEW_KEYS="true"
            echo -e "  ${FUCHSIA1}${BLINK}Generating New Keys${END}"
            ;;

    -K|--kt|--keytype)
            if [[ "$1" != *=* ]]; then shift; fi
            PARAM_KEY_TYPE="${1#*=}"
            if [ -z "${PARAM_KEY_TYPE}" ]; then
                echo -e "  ${END}Must specify a key type: ${GREY2}ec, rsa${END}"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} --keytype rsa${END}"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} --keytype ec${END}"
                echo -e

                exit 1
            fi
            ;;

    -P|--passwd|--pass|--password)
            if [[ "$1" != *=* ]]; then shift; fi
            PWD="${1#*=}"
            if [ -z "${PWD}" ]; then
                echo -e "  ${END}Must specify a password"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} --pass password${END}"
                echo -e

                exit 1
            fi

            if (( ${#PWD} < 5 )) ; then
                echo -e "  ${END}OpenSSH passphrase must be at least ${BLUE}five (5)${END} characters"
                echo -e

                exit 1
            fi

            PWD_STR=${PWD//?/*}
            ;;

    -I|--passin)
            if [[ "$1" != *=* ]]; then shift; fi
            PWD_IN="${1#*=}"
            if [ -z "${PWD_IN}" ]; then
                echo -e "  ${END}Must specify passin"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} --passin password${END}"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} -I password${END}"
                echo -e

                exit 1
            fi
            PWD_STR=${PWD_IN//?/*}
            ;;

    -O|--passout)
            if [[ "$1" != *=* ]]; then shift; fi
            PWD_OUT="${1#*=}"
            if [ -z "${PWD_OUT}" ]; then
                echo -e "  ${END}Must specify passout"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} --passout password${END}"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} -O password${END}"
                echo -e

                exit 1
            fi
            PWD_STR=${PWD_OUT//?/*}
            ;;

    -x|--dev)
            BOOL_DEV_ENABLED="true"
            echo -e "  ${FUCHSIA1}${BLINK}Developer Mode Enabled${END}"
            echo -e
            ;;

    -b|--base)
            if [[ "$1" != *=* ]]; then shift; fi
            FOLDER_BASE="${1#*=}"
            if [ -z "${FOLDER_BASE}" ]; then
                echo -e "  ${END}Must specify a valid base folder path"
                echo -e "  ${END}      Default:  ${YELLOW}${FOLDER_BASE}${END}"
                echo -e

                exit 1
            fi
            ;;

    -r|--root)
            if [[ "$1" != *=* ]]; then shift; fi
            FOLDER_ROOT="${1#*=}"
            if [ -z "${FOLDER_ROOT}" ]; then
                echo -e "  ${END}Must specify a valid name for the ${FOLDER_ROOT} folder"
                echo -e "  ${END}      Default:  ${YELLOW}${FOLDER_ROOT}${END}"
                echo -e

                exit 1
            fi
            ;;

    -D|-do|--domain)
            if [[ "$1" != *=* ]]; then shift; fi
            FOLDER_DOMAIN="${1#*=}"
            if [ -z "${FOLDER_DOMAIN}" ]; then
                echo -e "  ${END}Must specify a valid name for the domain folder"
                echo -e "  ${END}      Default:  ${YELLOW}${FOLDER_DOMAIN}${END}"
                echo -e

                exit 1
            fi
            ;;

    -d|--expires|--days)
            if [[ "$1" != *=* ]]; then shift; fi
            PARAM_DAYS="${1#*=}"
            if [ -z "${PARAM_DAYS}" ]; then
                echo -e "  ${END}Must specify valid expiration days ${GREY2}36500${END}"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} --days 360${END}"
                echo -e "      ${BOLD}${GREY2}./${app_file_this} --d 700${END}"
                echo -e

                exit 1
            fi
            ;;

    -c|--comment)
            if [[ "$1" != *=* ]]; then shift; fi
            PARAM_COMMENT="${1#*=}"
            ;;

    -C|--clean)

            # #
            #   clean removes all files except for private keys used to generate original files
            #
            #   @usage          ./generate.sh --wipe
            # #


            find ${PATH_CERTS} \
            ! -name "${FILE_ROOTCA_BASE}.${EXT_CNF}" \
            ! -name "${FILE_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}" \
            ! -name "${FILE_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}" \
            ! -name "${FILE_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}" \
            ! -name "${FILE_DOMAIN_BASE}.${SSL_KEY_MAIN_UNC}" \
            ! -name "${FILE_MASTER_BASE}.${SSL_KEY_MAIN_ENC}" \
            ! -name "${FILE_MASTER_BASE}.${SSL_KEY_MAIN_UNC}" \
            -type f -exec rm -f {} +

            exit 1
            ;;

    -w|--wipe)

            # #
            #   wipes all files from the generator, leaving you only the folders and the rootCA.cnf
            #
            #   @usage          ./generate.sh --wipe
            # #

            find ${PATH_CERTS} \
            ! -name "${FILE_ROOTCA_BASE}.${EXT_CNF}" \
            -type f -exec rm -f {} +

            exit 1
            ;;

    -v|--vars)

            # #
            #   wipes all files from the generator, leaving you only the folders and the rootCA.cnf
            #
            #   @usage          ./generate.sh --vars
            # #

            echo .

            echo -e "  ${BLUE} 🔖 Vars ${END}"
            echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"

            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔖 \$sys_arch${END}" "${WHITE}${sys_arch}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔖 \$sys_code${END}" "${WHITE}${sys_code}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔖 \$app_version${END}" "${WHITE}v$(get_version)${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔖 \$app_dir${END}" "${WHITE}${app_dir}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔖 \$app_file_this${END}" "${WHITE}${app_file_this}${END}"

            echo .
            echo .

            echo -e "  ${BLUE} 📁 Folders ${END}"
            echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 📁 \$FOLDER_BASE${END}" "${WHITE}${FOLDER_BASE}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 📁 \$FOLDER_ROOT${END}" "${WHITE}${FOLDER_ROOT}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 📁 \$FOLDER_ROOT_SUB_GEN${END}" "${WHITE}${FOLDER_ROOT_SUB_GEN}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 📁 \$FOLDER_ROOT_SUB_CRL${END}" "${WHITE}${FOLDER_ROOT_SUB_CRL}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 📁 \$FOLDER_ROOT_SUB_CERTS${END}" "${WHITE}${FOLDER_ROOT_SUB_CERTS}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 📁 \$FOLDER_DOMAIN${END}" "${WHITE}${FOLDER_DOMAIN}${END}"

            echo .
            echo .

            echo -e "  ${BLUE} 📄 Files ${END}"
            echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 📄 \$FILE_ROOTCA_BASE${END}" "${WHITE}${FILE_ROOTCA_BASE}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 📄 \$FILE_DOMAIN_BASE${END}" "${WHITE}${FILE_DOMAIN_BASE}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEY_MAIN_ENC${END}" "${WHITE}${SSL_KEY_MAIN_ENC}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEY_MAIN_UNC${END}" "${WHITE}${SSL_KEY_MAIN_UNC}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEY_MAIN02_ENC${END}" "${WHITE}${SSL_KEY_MAIN02_ENC}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEY_MAIN02_UNC${END}" "${WHITE}${SSL_KEY_MAIN02_UNC}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEY_RSA_PRIV${END}" "${WHITE}${SSL_KEY_RSA_PRIV}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEY_RSA_PUB${END}" "${WHITE}${SSL_KEY_RSA_PUB}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEY_SSH_PUB${END}" "${WHITE}${SSL_KEY_SSH_PUB}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_CERT_MAIN_ENC${END}" "${WHITE}${SSL_CERT_MAIN_ENC}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_CERT_MAIN_UNC${END}" "${WHITE}${SSL_CERT_MAIN_UNC}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEYSTORE_PFX${END}" "${WHITE}${SSL_KEYSTORE_PFX}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_KEYSTORE_B64${END}" "${WHITE}${SSL_KEYSTORE_B64}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$EXT_CRT${END}" "${WHITE}${EXT_CRT}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$EXT_CSR${END}" "${WHITE}${EXT_CSR}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$EXT_CRL${END}" "${WHITE}${EXT_CRL}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$EXT_CRL_PEM${END}" "${WHITE}${EXT_CRL_PEM}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ 🔑 \$SSL_CERT_FULLCHAIN${END}" "${WHITE}${SSL_CERT_FULLCHAIN}${END}"

            echo .
            echo .

            echo -e "  ${BLUE} ➡️  Paths ${END}"
            echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_CERTS${END}" "${WHITE}${PATH_CERTS}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_ROOTCA${END}" "${WHITE}${PATH_ROOTCA}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_ROOTCA_SUB_CRL${END}" "${WHITE}${PATH_ROOTCA_SUB_CRL}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_ROOTCA_SUB_GEN${END}" "${WHITE}${PATH_ROOTCA_SUB_GEN}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_ROOTCA_SUB_CERTS${END}" "${WHITE}${PATH_ROOTCA_SUB_CERTS}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_ROOTCA_BASE${END}" "${WHITE}${PATH_ROOTCA_BASE}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_DOMAIN${END}" "${WHITE}${PATH_DOMAIN}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_DOMAIN_BASE${END}" "${WHITE}${PATH_DOMAIN_BASE}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_MASTER${END}" "${WHITE}${PATH_MASTER}${END}"
            printf '%-60s %-40s\n' "  ${GREEN}  ↳ ➡️  \$PATH_MASTER_BASE${END}" "${WHITE}${PATH_MASTER_BASE}${END}"

            echo .
            echo .

            exit 1
            ;;

    -h*|--help*)
            opt_usage
            ;;

    -s|--status)
            readStatus
            ;;

    -v|--version)
            echo
            echo -e "  ${GREEN}${BOLD}${app_title}${END} - v$(get_version)${END}"
            echo -e "  ${GREY3}${BOLD}${app_repo_url}${END}"
            echo -e "  ${GREY3}${BOLD}${OS} | ${OS_VER}${END}"
            echo
            exit 1
            ;;
    *)
            opt_usage
            ;;
  esac
  shift
done

# #
#   Check if OpenSSL installed
# #

if ! command -v openssl 2>&1 >/dev/null; then
    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e
    echo -e "  ${BOLD}${ORANGE}WARNING  ${WHITE}Cannot find the package ${ORANGE}OpenSSL${END}.${END}"
    echo -e "  ${BOLD}You must install this package before certs and keys can be generated."
    echo -e
    echo -e "      ${BOLD}${GREY2}sudo apt update && sudo apt install openssl${END}"
    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e

    exit 1
fi

# #
#   Check if PASSWORD, PASSWORD IN, and PASSWORD OUT are empty.
# #

if [ -n "$PWD" ]; then
    if [ -z "${PWD_IN}" ] || [ "${PWD_IN}" == "false" ]; then
            PWD_IN=$PWD
    fi

    if [ -z "${PWD_OUT}" ] || [ "${PWD_OUT}" == "false" ]; then
            PWD_OUT=$PWD
    fi
fi

# #
#   Core > Integrity Check
#
#   📁 Parent folder
#       📁 certificates
#           📁 rootCA
#               📁 certs
#               📁 crl
#               📁 generated
#               📄 rootCA.cnf
#           📁 domain
#       📄 generate.sh
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-001${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${YELLOW}Scanning ${GREY3}${PATH_ROOTCA}/${END}"

if [ ! -d "${PATH_ROOTCA}/${FOLDER_ROOT_SUB_GEN}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-002${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${YELLOW}Created ${GREY3}${PATH_ROOTCA}/${FOLDER_ROOT_SUB_GEN}/${END}"
    mkdir -p ${PATH_ROOTCA}/${FOLDER_ROOT_SUB_GEN}
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-003${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${GREEN}Found ${GREY3}${PATH_ROOTCA}/${FOLDER_ROOT_SUB_GEN}/${END}"
fi

if [ ! -d "${PATH_ROOTCA_SUB_CERTS}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-004${END}" "${GREY3}${LNG_STEP_FOLDER_CREATE}${END}" "${RED}›${END}" "${YELLOW}Created ${GREY3}${PATH_ROOTCA_SUB_CERTS}/${END}"
    mkdir -p ${PATH_ROOTCA_SUB_CERTS}
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-005${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${GREEN}Found ${GREY3}${PATH_ROOTCA_SUB_CERTS}/${END}"
fi

if [ ! -d "${PATH_ROOTCA_SUB_CRL}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-006${END}" "${GREY3}${LNG_STEP_FOLDER_CREATE}${END}" "${RED}›${END}" "${YELLOW}Created ${GREY3}${PATH_ROOTCA_SUB_CRL}/${END}"
    mkdir -p ${PATH_ROOTCA_SUB_CRL}
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-007${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${GREEN}Found ${GREY3}${PATH_ROOTCA_SUB_CRL}/${END}"
fi

if [ ! -d "${PATH_DOMAIN}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-008${END}" "${GREY3}${LNG_STEP_FOLDER_CREATE}${END}" "${RED}›${END}" "${YELLOW}Created ${GREY3}${PATH_DOMAIN}/${END}"
    mkdir -p ${PATH_DOMAIN}
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-009${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${GREEN}Found ${GREY3}${PATH_DOMAIN}/${END}"
fi

if [ ! -d "${PATH_MASTER}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-010${END}" "${GREY3}${LNG_STEP_FOLDER_CREATE}${END}" "${RED}›${END}" "${YELLOW}Created ${GREY3}${PATH_MASTER}/${END}"
    mkdir -p ${PATH_MASTER}
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-011${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${GREEN}Found ${GREY3}${PATH_MASTER}/${END}"
fi

# #
#   Core > Check > Private Key
# #

if [ -z "${BOOL_NEW_KEYS}" ] || [ "${BOOL_NEW_KEYS}" == "false" ]; then
    if ( set +f; ls ${PATH_ROOTCA_BASE}.*${SSL_KEY_MAIN_ENC}* ) 1> /dev/null 2>&1; then
        printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-012${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${YELLOW}Found private key${END}"
    else
        echo -e
        echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
        echo -e
        echo -e "  ${BOLD}${ORANGE}WARNING  ${WHITE}Could not locate an existing ${YELLOW}${FILE_ROOTCA_BASE}${WHITE} private key at:${END}"
        echo -e "      ${BOLD}${GREY2}${PATH_ROOTCA_BASE}.*${SSL_KEY_MAIN_ENC}*${END}"
        echo -e
        echo -e "  ${BOLD}You must either supply an existing private key, or re-run this command with the argument ${ORANGE}--newkey${END}"
        echo -e "      ${BOLD}${GREY2}./${app_file_this} --newkey --name \"Certificate Name\"${END}"
        echo -e
        echo -e "  ${BOLD}You can also specify a password so that you don't have to keep entering it with ${ORANGE}--pass YOUR_PASS${END}"
        echo -e "      ${BOLD}${GREY2}./${app_file_this} --newkey --name \"Certificate Name\" --pass \"YOUR_PASS\"${END}"
        echo -e
        echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
        echo -e

        exit 1
    fi

    if ( set +f; ls ${PATH_DOMAIN_BASE}.*${SSL_KEY_MAIN_ENC}* ) 1> /dev/null 2>&1; then
        printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-013${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${YELLOW}Found private key${END}"
    else
        echo -e
        echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
        echo -e
        echo -e "  ${BOLD}${ORANGE}WARNING  ${WHITE}Could not locate an existing ${YELLOW}${FILE_DOMAIN_BASE}${WHITE} private key at:${END}"
        echo -e "      ${BOLD}${GREY2}${PATH_DOMAIN_BASE}.*${SSL_KEY_MAIN_ENC}*${END}"
        echo -e
        echo -e "  ${BOLD}You must either supply an existing private key, or re-run this command with the argument ${ORANGE}--newkey${END}"
        echo -e "      ${BOLD}${GREY2}./${app_file_this} --newkey --name \"Certificate Name\"${END}"
        echo -e
        echo -e "  ${BOLD}You can also specify a password so that you don't have to keep entering it with ${ORANGE}--pass YOUR_PASS${END}"
        echo -e "      ${BOLD}${GREY2}./${app_file_this} --newkey --name \"Certificate Name\" --pass \"YOUR_PASS\"${END}"
        echo -e
        echo -e " ${BLUE}―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${END}"
        echo -e

        exit 1
    fi
fi

# #
#   Core > Check > OpenSSL Configs
# #

if [ ! -f "${PATH_ROOTCA_BASE}.${EXT_CNF}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-014${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${RED}Missing ${GREY3}${PATH_ROOTCA_BASE}.${EXT_CNF}${END}"

    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e
    echo -e "  ${BOLD}${ORANGE}WARNING  ${WHITE}Could not locate ${FILE_ROOTCA_BASE}.${EXT_CNF} OpenSSL Config${END}"
    echo -e "  ${BOLD}This script cannot continue to run without the file being available in your folder structure."
    echo -e
    echo -e "      ${BOLD}${GREY2}Missing: ${ORANGE}${PATH_ROOTCA_BASE}.${EXT_CNF}${END}"
    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e

    exit 1

else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Core-015${END}" "${GREY3}${LNG_STEP_CHECK_INTEGRITY}${END}" "${RED}›${END}" "${GREEN}Found ${GREY3}${PATH_ROOTCA_BASE}.${EXT_CNF}${END}"
fi

# #
#   Core > Check cnf files for unset IP
# #

if grep -R "XX.XX.XX.XX" "${PATH_ROOTCA_BASE}.${EXT_CNF}" >/dev/null 2>&1; then

    STR_FOUND=$(grep -R "XX.XX.XX.XX" "${PATH_ROOTCA_BASE}.${EXT_CNF}")
    STR_LINE=$(grep -n "XX.XX.XX.XX" "${PATH_ROOTCA_BASE}.${EXT_CNF}" | cut -d : -f 1)

    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e
    echo -e "  ${BOLD}${ORANGE}WARNING  ${WHITE}You have not configured a valid IP address.${END}"
    echo -e "  ${BOLD}Open ${GREY2}${PATH_ROOTCA_BASE}.${EXT_CNF}${END} and change ${ORANGE}XX.XX.XX.XX${END} to a real IP."
    echo -e
    echo -e "      ${BOLD}${GREY2}Line ${STR_LINE}     ${RED}${STR_FOUND}${END}"
    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e

    exit 1
fi

# #
#   rootCA > Clean > index.txt
# #

if [ -f "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-001${END}" "${GREY3}Clean Certificates${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}${END}"
> "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}"
else
    touch "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}"
    chmod 600 "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}"
fi

# #
#   rootCA > Setup > index.txt.attr
# #

if [ -f "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_ATTR}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-002${END}" "${GREY3}Setup Attributes${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.attr${END}"
> "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_ATTR}"
else
    touch "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_ATTR}"
fi

echo "unique_subject = yes" > "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_ATTR}"

# #
#   rootCA > Reset > crlnumber
# #

if [ -f "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-003${END}" "${GREY3}Reset CRL 00${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER}${END}"
    echo "00" > "${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER}"
else
    touch "${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER}"
fi

# #
#   rootCA > Reset > serial
#
#   It is VITAL that no matter whether you're creating a new serial file, or resetting the existing one;
#       you MUST ensure the file is not empty; and at least has the value `0000`; otherwise the generation process
#       will error out.
# #

if [ -f "${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-004${END}" "${GREY3}Reset Serial 0000${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}${END}"
    echo "0000" > "${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}"
else
    touch "${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}"
    echo "0000" > "${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}"
fi

# #
#   rootCA > Delete > crlnumber.old
# #

if [ -f "${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER}.${EXT_OLD}" ]; then
    rm "${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER}.${EXT_OLD}"
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-005${END}" "${GREY3}Delete File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA}/${FILE_ROOTCA_CRLNUMBER}.${EXT_OLD}${END}"
fi

# #
#   rootCA > Delete > index.txt.attr.old
# #

if [ -f "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_ATTR}.${EXT_OLD}" ]; then
    rm "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_ATTR}.${EXT_OLD}"
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-006${END}" "${GREY3}Delete File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_ATTR}.${EXT_OLD}${END}"
fi

# #
#   rootCA > Delete > index.txt.old
# #

if [ -f "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_OLD}" ]; then
    rm "${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_OLD}"
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-007${END}" "${GREY3}Delete File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA}/${FILE_ROOTCA_INDEX}.${EXT_TXT}.${EXT_OLD}${END}"
fi

# #
#   rootCA > Delete > serial.old
# #

if [ -f "${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}.${EXT_OLD}" ]; then
    rm "${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}.${EXT_OLD}"
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-008${END}" "${GREY3}Delete File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA}/${FILE_ROOTCA_SERIAL}.${EXT_OLD}${END}"
fi

# #
#   rootCA > --newKey specified, no --pass provided
# #

if [ "${BOOL_NEW_KEYS}" == "true" ] && [ -z "${PWD}" ]; then
    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e
    echo -e "  ${BOLD}${ORANGE}WARNING  ${WHITE}You must supply a password when generating new keys${END}"
    echo -e "      ${BOLD}${GREY2}./${app_file_this} --newkey --pass \"CERT_PASS\" --name "Certificate Name"${END}"
    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e

    exit 1
fi

# #
#   rootCA > --newKey not specified, no --pass provided
# #

if [ "${BOOL_NEW_KEYS}" == "false" ] && [ -z "${PWD}" ]; then
    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e
    echo -e "  ${BOLD}${ORANGE}WARNING  ${WHITE}You must supply a password for an existing keys${END}"
    echo -e "      ${BOLD}${GREY2}./${app_file_this} --pass \"CERT_PASS\" --name "Certificate Name"${END}"
    echo -e
    echo -e " ${BLUE}---------------------------------------------------------------------------------------------------${END}"
    echo -e

    exit 1
fi

# #
#   rootCA > Create > RSA           rootCA.key.main-01.enc.priv.pem
# #

if [ "${BOOL_NEW_KEYS}" == "true" ]; then
    if [ "${PARAM_KEY_TYPE}" == "rsa" ]; then
        printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-009${END}" "${GREY3}Generate Keys${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}${END}"
        openssl genrsa -aes256 -passout pass:"${PWD_OUT}" -out "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}" ${PARAM_BITS}

        if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
            echo ‎ ‎${GREY2} ↳  openssl genrsa -aes256 -passout pass:\"${PWD_OUT}\" -out \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}\" ${PARAM_BITS}${END}
            echo -e
        fi
    fi
else
    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo -e
        echo ‎ ‎${GREEN}${BLINK} ⚠️ ‎ ‎  Skipped generating ${YELLOW}${FILE_ROOTCA_BASE}${WHITE} private key ${YELLOW}${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}${GREEN}, key already exists from previous generation${END}
        echo -e
    fi
fi

# #
#   rootCA > Create > RSA           rootCA.key.main-01.unc.priv.pem
# #


if ( set +f; ls ${PATH_ROOTCA_BASE}.*${SSL_KEY_MAIN_UNC}* ) 1> /dev/null 2>&1; then
    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREEN}${BLINK} ⚠️ ‎ ‎  Skipped generating ${YELLOW}${FILE_ROOTCA_BASE}${WHITE} private key ${YELLOW}${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}${GREEN}, key already exists from previous generation${END}
        echo -e
    fi
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-010${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}${END}"
    openssl rsa -in "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}"  -out "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}" -passin pass:"${PWD_IN}" -passout pass:"${PWD_OUT}"

    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREY2} ↳  openssl rsa -in \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}\"  -out \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}\" -passin pass:\"${PWD_IN}\" -passout pass:\"${PWD_OUT}\"
        echo -e
    fi
fi

# #
#   rootCA > Create > EC            rootCA.key.main-01.enc.priv.pem
#                                   rootCA.key.main-01.unc.priv.pem
# #

if [ "${BOOL_NEW_KEYS}" == "true" ]; then
    if [ "${PARAM_KEY_TYPE}" == "ec" ] || [ "${PARAM_KEY_TYPE}" == "ecdsa" ]; then
        printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-011${END}" "${GREY3}Generate Keys${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}${END}"
        openssl ecparam -genkey -name secp384r1 -noout -out "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}" -pass pass:"${PWD}" -passout pass:"${PWD_OUT}" -passin pass:"${PWD_IN}"
        openssl ec -in "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}" -out "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}" -aes256 -pass pass:"${PWD}" -passout pass:"${PWD_OUT}" -passin pass:"${PWD_IN}"

        if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
            echo ‎ ‎${GREY2} ↳  openssl ecparam -genkey -name secp384r1 -noout -out \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}\" -pass pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\" -passin pass:\"${PWD_IN}\"${END}
            echo ‎ ‎${GREY2} ↳  openssl ec -in \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_UNC}\" -out \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}\" -aes256 -pass pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\" -passin pass:\"${PWD_IN}\"${END}
            echo -e
        fi
    fi
fi

# #
#   rootCA > Create > rootCA.crt
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-012${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_BASE}.${EXT_CRT}${END}"
openssl req -config "${PATH_ROOTCA_BASE}.${EXT_CNF}" -key "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}" -new -x509 -days ${PARAM_DAYS} -sha512 -section ${SECTION_ROOT} -extensions ${EXTENSION_ROOT} -out "${PATH_ROOTCA_BASE}.${EXT_CRT}" -passout pass:"${PWD_OUT}" -passin pass:"${PWD_IN}" --batch

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl req -config \"${PATH_ROOTCA_BASE}.${EXT_CNF}\" -key \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}\" -new -x509 -days ${PARAM_DAYS} -sha512 -section ${EXTENSION_ROOT} -extensions ${EXTENSION_ROOT} -out \"${PATH_ROOTCA_BASE}.${EXT_CRT}\" -passout pass:\"${PWD_OUT}\" -passin pass:\"${PWD_IN}\" --batch${END}
    echo -e
fi

# #
#   rootCA > Create > rootCA.pfx
#
#   rootCA -name should use "CompanyName Certificate Authority"
#   domain -name should use "CompanyName Domain Authority"
#   master -name should use "CompanyName Authentication Authority"
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-013${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_BASE}.${EXT_PFX}${END}"
openssl pkcs12 -export -name "${PARAM_ISSUE_NAME} Certificate Authority" -in "${PATH_ROOTCA_BASE}.${EXT_CRT}" -inkey "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}" -out "${PATH_ROOTCA_BASE}.${EXT_PFX}" -passin pass:"${PWD_IN}" -password pass:"${PWD}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -export -name \"${PARAM_ISSUE_NAME} Certificate Authority\" -in \"${PATH_ROOTCA_BASE}.${EXT_CRT}\" -inkey \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}\" -out \"${PATH_ROOTCA_BASE}.${EXT_PFX}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\"
    echo -e
fi

# #
#   rootCA > Create > crl/rootCA.crl.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-014${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_SUB_CRL}/${FILE_ROOTCA_BASE}.${EXT_CRL_PEM}${END}"
openssl ca -gencrl -config "${PATH_ROOTCA_BASE}.${EXT_CNF}" -keyfile "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}" -cert "${PATH_ROOTCA_BASE}.${EXT_CRT}" -out "${PATH_ROOTCA_SUB_CRL}/${FILE_ROOTCA_BASE}.${EXT_CRL_PEM}" -passin pass:"${PWD_IN}" -batch

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl ca -gencrl -config \"${PATH_ROOTCA_BASE}.${EXT_CNF}\" -keyfile \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}\" -cert \"${PATH_ROOTCA_BASE}.${EXT_CRT}\" -out \"${PATH_ROOTCA_SUB_CRL}/${FILE_ROOTCA_BASE}.${EXT_CRL_PEM}\" -passin pass:\"${PWD_IN}\" -batch
    echo -e
fi

# #
#   rootCA > Create > crl/rootCA.crl
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_ROOTCA_BASE}-015${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_SUB_CRL}/${FILE_ROOTCA_BASE}.${EXT_CRL}${END}"
openssl crl -inform PEM -in "${PATH_ROOTCA_SUB_CRL}/${FILE_ROOTCA_BASE}.${EXT_CRL_PEM}" -outform DER -out "${PATH_ROOTCA_SUB_CRL}/${FILE_ROOTCA_BASE}.${EXT_CRL}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl crl -inform PEM -in \"${PATH_ROOTCA_SUB_CRL}/${FILE_ROOTCA_BASE}.${EXT_CRL_PEM}\" -outform DER -out \"${PATH_ROOTCA_SUB_CRL}/${FILE_ROOTCA_BASE}.${EXT_CRL}\"
    echo -e
fi

# #
#   Domain > Create > domain.key.main-01.enc.priv.pem
# #

if [ "${BOOL_NEW_KEYS}" == "true" ]; then
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-001${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}${END}"
    openssl genpkey -aes256 -algorithm RSA -pkeyopt rsa_keygen_bits:${PARAM_BITS} -out "${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}" -pass pass:"${PWD}"

    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREY2} ↳  openssl genpkey -aes256 -algorithm RSA -pkeyopt rsa_keygen_bits:${PARAM_BITS} -out \"${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}\" -pass pass:\"${PWD}\"
        echo -e
    fi
else
    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREEN}${BLINK} ⚠️ ‎ ‎  Skipped generating ${YELLOW}${FILE_DOMAIN_BASE}${WHITE} private key ${YELLOW}${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}${GREEN}, key already exists from previous generation${END}
        echo -e
    fi
fi

# #
#   Domain > Create > domain.key.main-01.unc.priv.pem
# #

if ( set +f; ls ${PATH_DOMAIN_BASE}.*${SSL_KEY_MAIN_UNC}* ) 1> /dev/null 2>&1; then
    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREEN}${BLINK} ⚠️ ‎ ‎  Skipped generating ${YELLOW}${FILE_DOMAIN_BASE}${WHITE} private key ${YELLOW}${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_UNC}${GREEN}, key already exists from previous generation${END}
        echo -e
    fi
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-002${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_UNC}${END}"
    openssl rsa -in "${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}"  -out "${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_UNC}" -passin pass:"${PWD_IN}" -passout pass:"${PWD_OUT}"

    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREY2} ↳  openssl rsa -in \"${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}\"  -out \"${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_UNC}\" -passin pass:\"${PWD_IN}\" -passout pass:\"${PWD_OUT}\"
        echo -e
    fi
fi

# #
#   Domain > Create > domain.csr
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-003${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${EXT_CSR}${END}"
openssl req -sha512 -new -key "${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}" -config "${PATH_ROOTCA_BASE}.${EXT_CNF}" -section ${SECTION_DOMAIN} -out "${PATH_DOMAIN_BASE}.${EXT_CSR}" -passout pass:"${PWD_OUT}" -passin pass:"${PWD_IN}" --batch

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl req -sha512 -new -key \"${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}\" -config \"${PATH_ROOTCA_BASE}.${EXT_CNF}\" -section ${SECTION_DOMAIN} -out \"${PATH_DOMAIN_BASE}.${EXT_CSR}\" -passout pass:\"${PWD_OUT}\" -passin pass:\"${PWD_IN}\" --batch
    echo -e
fi

# #
#   Domain > Create > domain.crt
#
#   creates certificate, registers the cert within the rootCA index.txt.
#   you must remove the certificate from the index.txt to run this again.
#   .crt file does NOT have the Bag Attributes at the top.
#
#   this command must run last, otherwise it wont generate cert serial
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-004${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${EXT_CRT}${END}"
openssl ca -config "${PATH_ROOTCA_BASE}.${EXT_CNF}" -multivalue-rdn -preserveDN -extensions ${EXTENSION_DOMAIN} -days ${PARAM_DAYS} -notext -md sha512 -in "${PATH_DOMAIN_BASE}.${EXT_CSR}" -out "${PATH_DOMAIN_BASE}.${EXT_CRT}" -passin pass:"${PWD_IN}" -batch

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl ca -config \"${PATH_ROOTCA_BASE}.${EXT_CNF}\" -multivalue-rdn -preserveDN -extensions ${EXTENSION_DOMAIN} -days ${PARAM_DAYS} -notext -md sha512 -in \"${PATH_DOMAIN_BASE}.${EXT_CSR}\" -out \"${PATH_DOMAIN_BASE}.${EXT_CRT}\" -passin pass:\"${PWD_IN}\" -batch
    echo -e
fi

# #
#   Domain > Create > domain.keystore.normal.pfx
#
#   rootCA -name should use "CompanyName Certificate Authority"
#   domain -name should use "CompanyName Domain Authority"
#   master -name should use "CompanyName Authentication Authority"
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-005${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}${END}"
openssl pkcs12 -export -name "${PARAM_ISSUE_NAME} Domain Authority" -in "${PATH_DOMAIN_BASE}.${EXT_CRT}" -inkey "${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}" -out "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}" -passin pass:"${PWD_IN}" -password pass:"${PWD}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -export -name \"${PARAM_ISSUE_NAME} Domain Authority\" -in \"${PATH_DOMAIN_BASE}.${EXT_CRT}\" -inkey \"${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}\" -out \"${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\"
    echo -e
fi

# #
#   Domain > Create > domain.crt
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-006${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${EXT_CRT}${END}"
openssl pkcs12 -in "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}" -clcerts -nokeys -out "${PATH_DOMAIN_BASE}.${EXT_CRT}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}\" -clcerts -nokeys -out \"${PATH_DOMAIN_BASE}.${EXT_CRT}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Domain > Remove > domain.keystore.base64.pfx
# #

if [ -f "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}" ]; then
    rm "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}"

    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREY2} ↳  rm \"${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}\"
        echo -e
    fi

    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-007${END}" "${GREY3}Remove File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}${END}"
fi

# #
#   Domain > Create > domain.keystore.base64.pfx
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-008${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}${END}"
cat "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}" | base64 > "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_B64}"

# #
#   Domain > Create > domain.keystore.p12
#
#   @note       : p12 file is the same keystore as pfx.
# #

# #
#   printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Domain${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_P12}${END}"
#   openssl pkcs12 -export -in "${PATH_DOMAIN_BASE}.${EXT_CRT}" -inkey "${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}" -out "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_P12}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"
# 
#   if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
#       echo ‎ ‎${GREY2} ↳  openssl pkcs12 -export -in \"${PATH_DOMAIN_BASE}.${EXT_CRT}\" -inkey \"${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN_ENC}\" -out \"${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_P12}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
#       echo -e
#   fi
# #

# #
#   Domain > Create > domain.keycert.main-01.enc.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-009${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}${END}"
openssl pkcs12 -in "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}" -aes-256-cbc -out "${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}\" -aes-256-cbc -out \"${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Domain > Create > domain.keycert.main-01.unc.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-010${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_UNC}${END}"
openssl pkcs12 -in "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}" -nodes -out "${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_UNC}" -passin pass:"${PWD_IN}" -password pass:"${PWD}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}\" -nodes -out \"${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_UNC}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\"
    echo -e
fi

# #
#   Domain > Create > domain.key.main-02.enc.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-011${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_ENC}${END}"
openssl pkcs12 -in "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}" -nocerts -out "${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_ENC}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}\" -nocerts -out \"${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_ENC}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Domain > Create > domain.key.main-02.unc.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-012${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_UNC}${END}"
openssl pkcs12 -in "${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}" -nocerts -nodes -out "${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_UNC}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_DOMAIN_BASE}.${SSL_KEYSTORE_PFX}\" -nocerts -nodes -out \"${PATH_DOMAIN_BASE}.${SSL_KEY_MAIN02_UNC}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Domain > Create > domain.key.rsa.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-014${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV}${END}"
openssl rsa -in "${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}" -out "${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV}" -outform PEM -traditional -passin pass:"${PWD_IN}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl rsa -in \"${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}\" -out \"${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV}\" -outform PEM -traditional -passin pass:\"${PWD_IN}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Domain > Create > domain.key.rsa.pub.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-015${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PUB}${END}"
openssl rsa -in "${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}" -pubout > "${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PUB}" -passin pass:"${PWD_IN}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl rsa -in \"${PATH_DOMAIN_BASE}.${SSL_CERT_MAIN_ENC}\" -pubout \> \"${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PUB}\" -passin pass:\"${PWD_IN}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Domain > Create > domain.key.openssh.priv.pem
#   also known as id_rsa
#
#   password must be at least five characters
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-017${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}${END}"
cp ${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV} ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}
ssh-keygen -p -m PEM -P "${PWD}" -N "${PWD}" -f "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}"

if [ -n "$PARAM_COMMENT" ]; then
    ssh-keygen -c -C "${PARAM_COMMENT}" -P "${PWD}" -f  "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}"
fi

chmod 600 "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  cp \"${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV}\" \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}\"
    echo ‎ ‎${GREY2} ↳  ssh-keygen -p -m PEM -P \"${PWD}\"  -N \"${PWD}\" -f \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}\"
    if [ -n "$PARAM_COMMENT" ]; then
        echo ‎ ‎${GREY2} ↳  ssh-keygen -c -C \"${PARAM_COMMENT}\" -P \"${PWD}\" -f  \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}\"
    fi
    echo ‎ ‎${GREY2} ↳  chmod 600 \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV}\"
    echo -e
fi

# #
#   Domain > Create > domain.key.openssh.priv.nopwd.pem
#   also known as id_rsa
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-018${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}${END}"
cp ${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV} ${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}
ssh-keygen -p -m PEM -N "" -f "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}"

if [ -n "$PARAM_COMMENT" ]; then
    ssh-keygen -c -C "${PARAM_COMMENT}" -P "${PWD}" -f  "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}"
fi

chmod 600 "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  cp \"${PATH_DOMAIN_BASE}.${SSL_KEY_RSA_PRIV}\" \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\"
    echo ‎ ‎${GREY2} ↳  ssh-keygen -p -m PEM -P \"${PWD}\"  -N \"${PWD}\" -f \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\"
    if [ -n "$PARAM_COMMENT" ]; then
        echo ‎ ‎${GREY2} ↳  ssh-keygen -c -C \"${PARAM_COMMENT}\" -P \"${PWD}\" -f  \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\"
    fi
    echo ‎ ‎${GREY2} ↳  chmod 600 \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\"
    echo -e
fi

# #
#   Domain > Create > domain.key.openssh.pub
#   also known as id_rsa.pub
#   
#   -y      Read a private OpenSSH format file and print an OpenSSH public key to stdout. 
#   -P      passphrase - Provides the (old) passphrase
#   -f      filename - Specifies the filename of the key file. 
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-016${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PUB}${END}"
ssh-keygen -P "${PWD}" -f "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}" -y > "${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PUB}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  ssh-keygen -P \"${PWD}\" -f \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\" -y \> \"${PATH_DOMAIN_BASE}.${SSL_KEY_SSH_PUB}\"
    echo -e
fi

# #
#   Domain > Create > crl/domain.crl.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-019${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL_PEM}${END}"
openssl ca -gencrl -config "${PATH_ROOTCA_BASE}.${EXT_CNF}" -keyfile "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}" -cert "${PATH_ROOTCA_BASE}.${EXT_CRT}" -out "${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL_PEM}" -passin pass:"${PWD_IN}" -batch

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl ca -gencrl -config \"${PATH_ROOTCA_BASE}.${EXT_CNF}\" -keyfile \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}\" -cert \"${PATH_ROOTCA_BASE}.${EXT_CRT}\" -out \"${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL_PEM}\" -passin pass:\"${PWD_IN}\" -batch
    echo -e
fi

# #
#   Domain > Create > crl/domain.crl
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-020${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL}${END}"
openssl crl -inform PEM -in "${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL_PEM}" -outform DER -out "${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl crl -inform PEM -in \"${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL_PEM}\" -outform DER -out \"${PATH_ROOTCA_SUB_CRL}/${FILE_DOMAIN_BASE}.${EXT_CRL}\"
    echo -e
fi

# #
#   Domain > domain.Fullchain.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_DOMAIN_BASE}-018${END}" "${GREY3}Create Full Chain${END}" "${RED}›${END}" "${WHITE}${PATH_DOMAIN}/${SSL_CERT_FULLCHAIN}${END}"
> "${PATH_DOMAIN}/${FILE_DOMAIN_BASE}.${SSL_CERT_FULLCHAIN}"
cat "${PATH_DOMAIN_BASE}.${EXT_CRT}" >> "${PATH_DOMAIN}/${FILE_DOMAIN_BASE}.${SSL_CERT_FULLCHAIN}"
cat "${PATH_ROOTCA_BASE}.${EXT_CRT}" >> "${PATH_DOMAIN}/${FILE_DOMAIN_BASE}.${SSL_CERT_FULLCHAIN}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  cat ${PATH_DOMAIN_BASE}.${EXT_CRT} \>\> ${PATH_DOMAIN}/${FILE_DOMAIN_BASE}.${SSL_CERT_FULLCHAIN}
    echo ‎ ‎${GREY2} ↳  cat ${PATH_ROOTCA_BASE}.${EXT_CRT} \>\> ${PATH_DOMAIN}/${FILE_DOMAIN_BASE}.${SSL_CERT_FULLCHAIN}
    echo -e
fi

# #
#   Naster > Create > 9a.key.main-01.enc.priv.pem
# #

if ( set +f; ls ${PATH_MASTER_BASE}.*${SSL_KEY_MAIN_ENC}* ) 1> /dev/null 2>&1; then
    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREEN}${BLINK} ⚠️ ‎ ‎  Skipped generating ${YELLOW}${FILE_MASTER_BASE}${WHITE} private key ${YELLOW}${FILE_MASTER_BASE}.${SSL_KEY_MAIN_ENC}${GREEN}, key already exists from previous generation${END}
        echo -e
    fi
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-001${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}${END}"
    openssl genpkey -aes256 -algorithm RSA -pkeyopt rsa_keygen_bits:${PARAM_BITS} -out "${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}" -pass pass:"${PWD}"

    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREY2} ↳  openssl genpkey -aes256 -algorithm RSA -pkeyopt rsa_keygen_bits:${PARAM_BITS} -out \"${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}\" -pass pass:\"${PWD}\"
        echo -e
    fi
fi

# #
#   Naster > Create > 9a.key.main-01.unc.priv.pem
# #

if ( set +f; ls ${PATH_MASTER_BASE}.*${SSL_KEY_MAIN_UNC}* ) 1> /dev/null 2>&1; then
    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREEN}${BLINK} ⚠️ ‎ ‎  Skipped generating ${YELLOW}${FILE_MASTER_BASE}${WHITE} private key ${YELLOW}${FILE_MASTER_BASE}.${SSL_KEY_MAIN_UNC}${GREEN}, key already exists from previous generation${END}
        echo -e
    fi
else
    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-002${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_MAIN_UNC}${END}"
    openssl rsa -in "${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}"  -out "${PATH_MASTER_BASE}.${SSL_KEY_MAIN_UNC}" -passin pass:"${PWD_IN}" -passout pass:"${PWD_OUT}"

    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREY2} ↳  openssl rsa -in \"${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}\"  -out \"${PATH_MASTER_BASE}.${SSL_KEY_MAIN_UNC}\" -passin pass:\"${PWD_IN}\" -passout pass:\"${PWD_OUT}\"
        echo -e
    fi
fi

# #
#   Naster > Create > 9a.csr
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-003${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${EXT_CSR}${END}"
openssl req -sha512 -new -key "${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}" -config "${PATH_ROOTCA_BASE}.${EXT_CNF}" -section ${SECTION_MASTER} -out "${PATH_MASTER_BASE}.${EXT_CSR}" -passout pass:"${PWD_OUT}" -passin pass:"${PWD_IN}" --batch

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl req -sha512 -new -key \"${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}\" -config \"${PATH_ROOTCA_BASE}.${EXT_CNF}\" -section ${SECTION_MASTER} -out \"${PATH_MASTER_BASE}.${EXT_CSR}\" -passout pass:\"${PWD_OUT}\" -passin pass:\"${PWD_IN}\" --batch
    echo -e
fi

# #
#   Naster > Create > 9a.crt
#
#   creates certificate, registers the cert within the rootCA index.txt.
#   you must remove the certificate from the index.txt to run this again.
#   .crt file does NOT have the Bag Attributes at the top.
#
#   this command must run last, otherwise it wont generate cert serial
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-004${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${EXT_CRT}${END}"
openssl ca -config "${PATH_ROOTCA_BASE}.${EXT_CNF}" -multivalue-rdn -preserveDN -extensions ${EXTENSION_MASTER} -days ${PARAM_DAYS} -notext -md sha512 -in "${PATH_MASTER_BASE}.${EXT_CSR}" -out "${PATH_MASTER_BASE}.${EXT_CRT}" -passin pass:"${PWD_IN}" -batch

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl ca -config \"${PATH_ROOTCA_BASE}.${EXT_CNF}\" -multivalue-rdn -preserveDN -extensions ${EXTENSION_MASTER} -days ${PARAM_DAYS} -notext -md sha512 -in \"${PATH_MASTER_BASE}.${EXT_CSR}\" -out \"${PATH_MASTER_BASE}.${EXT_CRT}\" -passin pass:\"${PWD_IN}\" -batch
    echo -e
fi

# #
#   Naster > Create > 9a.keystore.normal.pfx
#
#   rootCA -name should use "CompanyName Certificate Authority"
#   domain -name should use "CompanyName Domain Authority"
#   master -name should use "CompanyName Authentication Authority"
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-005${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}${END}"
openssl pkcs12 -export -name "${PARAM_ISSUE_NAME} Authentication Authority" -in "${PATH_MASTER_BASE}.${EXT_CRT}" -inkey "${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}" -out "${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}" -passin pass:"${PWD_IN}" -password pass:"${PWD}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -export -name \"${PARAM_ISSUE_NAME} Authentication Authority\" -in \"${PATH_MASTER_BASE}.${EXT_CRT}\" -inkey \"${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}\" -out \"${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\"
    echo -e
fi

# #
#   Naster > Create > 9a.crt
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-006${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${EXT_CRT}${END}"
openssl pkcs12 -in "${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}" -clcerts -nokeys -out "${PATH_MASTER_BASE}.${EXT_CRT}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}\" -clcerts -nokeys -out \"${PATH_MASTER_BASE}.${EXT_CRT}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Naster > Remove > 9a.keystore.base64.pfx
# #

if [ -f "${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}" ]; then
    rm "${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}"

    if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
        echo ‎ ‎${GREY2} ↳  rm \"${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}\"
        echo -e
    fi

    printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-007${END}" "${GREY3}Remove File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}${END}"
fi

# #
#   Naster > Create > 9a.keystore.base64.pfx
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-008${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}${END}"
cat "${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}" | base64 > "${PATH_MASTER_BASE}.${SSL_KEYSTORE_B64}"

# #
#   Naster > Create > 9a.keystore.p12
#
#   @note       : p12 file is the same keystore as pfx.
# #

# #
#   printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}Domain${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEYSTORE_P12}${END}"
#   openssl pkcs12 -export -in "${PATH_MASTER_BASE}.${EXT_CRT}" -inkey "${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}" -out "${PATH_MASTER_BASE}.${SSL_KEYSTORE_P12}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"
# 
#   if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
#       echo ‎ ‎${GREY2} ↳  openssl pkcs12 -export -in \"${PATH_MASTER_BASE}.${EXT_CRT}\" -inkey \"${PATH_MASTER_BASE}.${SSL_KEY_MAIN_ENC}\" -out \"${PATH_MASTER_BASE}.${SSL_KEYSTORE_P12}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
#       echo -e
#   fi
# #

# #
#   Naster > Create > 9a.keycert.main-01.enc.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-009${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}${END}"
openssl pkcs12 -in "${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}" -aes-256-cbc -out "${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}\" -aes-256-cbc -out \"${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Naster > Create > 9a.keycert.main-01.unc.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-010${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_CERT_MAIN_UNC}${END}"
openssl pkcs12 -in "${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}" -nodes -out "${PATH_MASTER_BASE}.${SSL_CERT_MAIN_UNC}" -passin pass:"${PWD_IN}" -password pass:"${PWD}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}\" -nodes -out \"${PATH_MASTER_BASE}.${SSL_CERT_MAIN_UNC}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\"
    echo -e
fi

# #
#   Naster > Create > 9a.key.main-02.enc.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-011${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_ENC}${END}"
openssl pkcs12 -in "${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}" -nocerts -out "${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_ENC}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}\" -nocerts -out \"${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_ENC}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Naster > Create > 9a.key.main-02.unc.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-012${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_UNC}${END}"
openssl pkcs12 -in "${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}" -nocerts -nodes -out "${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_UNC}" -passin pass:"${PWD_IN}" -password pass:"${PWD}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl pkcs12 -in \"${PATH_MASTER_BASE}.${SSL_KEYSTORE_PFX}\" -nocerts -nodes -out \"${PATH_MASTER_BASE}.${SSL_KEY_MAIN02_UNC}\" -passin pass:\"${PWD_IN}\" -password pass:\"${PWD}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Naster > Create > 9a.key.rsa.priv.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-014${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV}${END}"
openssl rsa -in "${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}" -out "${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV}" -outform PEM -traditional -passin pass:"${PWD_IN}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl rsa -in \"${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}\" -out \"${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV}\" -outform PEM -traditional -passin pass:\"${PWD_IN}\" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Naster > Create > 9a.key.rsa.pub.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-015${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_RSA_PUB}${END}"
openssl rsa -in "${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}" -pubout > "${PATH_MASTER_BASE}.${SSL_KEY_RSA_PUB}" -passin pass:"${PWD_IN}" -passout pass:"${PWD_OUT}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl rsa -in \"${PATH_MASTER_BASE}.${SSL_CERT_MAIN_ENC}\" -pubout \> \"${PATH_MASTER_BASE}.${SSL_KEY_RSA_PUB}\" -passin pass:"${PWD_IN}" -passout pass:\"${PWD_OUT}\"
    echo -e
fi

# #
#   Naster > Create > 9a.key.openssh.priv.pem
#   also known as id_rsa
#
#   password must be at least five characters
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-013${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}${END}"
cp ${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV} ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}
ssh-keygen -p -m PEM -P "${PWD}" -N "${PWD}" -f "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}"

if [ -n "$PARAM_COMMENT" ]; then
    ssh-keygen -c -C "${PARAM_COMMENT}" -P "${PWD}" -f  "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}"
fi

chmod 600 "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  cp \"${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV}\" \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}\"
    echo ‎ ‎${GREY2} ↳  ssh-keygen -p -m PEM -P \"${PWD}\"  -N \"${PWD}\" -f \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}\"
    if [ -n "$PARAM_COMMENT" ]; then
        echo ‎ ‎${GREY2} ↳  ssh-keygen -c -C \"${PARAM_COMMENT}\" -P \"${PWD}\" -f  \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}\"
    fi
    echo ‎ ‎${GREY2} ↳  chmod 600 \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV}\"
    echo -e
fi

# #
#   Naster > Create > 9a.key.openssh.priv.nopwd.pem
#   also known as id_rsa
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-013${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}${END}"
cp ${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV} ${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}
ssh-keygen -p -m PEM -N "" -f "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}"

if [ -n "$PARAM_COMMENT" ]; then
    ssh-keygen -c -C "${PARAM_COMMENT}" -P "${PWD}" -f  "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}"
fi

chmod 600 "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  cp \"${PATH_MASTER_BASE}.${SSL_KEY_RSA_PRIV}\" \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\"
    echo ‎ ‎${GREY2} ↳  ssh-keygen -p -m PEM -N \"\" -f \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\"
    if [ -n "$PARAM_COMMENT" ]; then
        echo ‎ ‎${GREY2} ↳  ssh-keygen -c -C \"${PARAM_COMMENT}\" -P \"${PWD}\" -f  \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\"
    fi
    echo ‎ ‎${GREY2} ↳  chmod 600 \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\"
    echo -e
fi

# #
#   Naster > Create > 9a.key.openssh.pub
#   also known as id_rsa.pub
#   
#   -y      Read a private OpenSSH format file and print an OpenSSH public key to stdout. 
#   -P      passphrase - Provides the (old) passphrase
#   -f      filename - Specifies the filename of the key file. 
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-013${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER_BASE}.${SSL_KEY_SSH_PUB}${END}"
ssh-keygen -P "${PWD}" -f "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}" -y > "${PATH_MASTER_BASE}.${SSL_KEY_SSH_PUB}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  ssh-keygen -P \"${PWD}\" -f \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PRIV_NOPWD}\" -y \> \"${PATH_MASTER_BASE}.${SSL_KEY_SSH_PUB}\"
    echo -e
fi

# #
#   Naster > Create > crl/master.crl.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-016${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL_PEM}${END}"
openssl ca -gencrl -config "${PATH_ROOTCA_BASE}.${EXT_CNF}" -keyfile "${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}" -cert "${PATH_ROOTCA_BASE}.${EXT_CRT}" -out "${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL_PEM}" -passin pass:"${PWD_IN}" -batch

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl ca -gencrl -config \"${PATH_ROOTCA_BASE}.${EXT_CNF}\" -keyfile \"${PATH_ROOTCA_BASE}.${SSL_KEY_MAIN_ENC}\" -cert \"${PATH_ROOTCA_BASE}.${EXT_CRT}\" -out \"${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL_PEM}\" -passin pass:\"${PWD_IN}\" -batch
    echo -e
fi

# #
#   Naster > Create > crl/master.crl
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-017${END}" "${GREY3}Create File${END}" "${RED}›${END}" "${WHITE}${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL}${END}"
openssl crl -inform PEM -in "${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL_PEM}" -outform DER -out "${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  openssl crl -inform PEM -in \"${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL_PEM}\" -outform DER -out \"${PATH_ROOTCA_SUB_CRL}/${FILE_MASTER_BASE}.${EXT_CRL}\"
    echo -e
fi

# #
#   Naster > 9a.Fullchain.pem
# #

printf '%-30s %-40s %-5s %-40s\n' "  ${ORANGE}${FILE_MASTER_BASE}-018${END}" "${GREY3}Create Full Chain${END}" "${RED}›${END}" "${WHITE}${PATH_MASTER}/${SSL_CERT_FULLCHAIN}${END}"
> "${PATH_MASTER}/${FILE_MASTER_BASE}.${SSL_CERT_FULLCHAIN}"
cat "${PATH_MASTER_BASE}.${EXT_CRT}" >> "${PATH_MASTER}/${FILE_MASTER_BASE}.${SSL_CERT_FULLCHAIN}"
cat "${PATH_ROOTCA_BASE}.${EXT_CRT}" >> "${PATH_MASTER}/${FILE_MASTER_BASE}.${SSL_CERT_FULLCHAIN}"

if [ "${BOOL_DEV_ENABLED}" == "true" ]; then
    echo ‎ ‎${GREY2} ↳  cat ${PATH_MASTER_BASE}.${EXT_CRT} \>\> ${PATH_MASTER}/${FILE_MASTER_BASE}.${SSL_CERT_FULLCHAIN}
    echo ‎ ‎${GREY2} ↳  cat ${PATH_ROOTCA_BASE}.${EXT_CRT} \>\> ${PATH_MASTER}/${FILE_MASTER_BASE}.${SSL_CERT_FULLCHAIN}
    echo -e
fi

readStatus

exit 1