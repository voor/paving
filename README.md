# Paving

This repository contains Terraform templates for paving the necessary
infrastructure to deploy Pivotal Platform (PKS and PAS) to a single foundation.
The templates support AWS, vSphere, Azure, and GCP.


## Requirements

- [Terraform v0.12+](https://www.terraform.io/downloads.html)

## Usage

### configuration

In each IaaS directory, there is a `terraform.tfvars.example` you can copy
and modify with your configuration choices and credentials.

1. `terraform init`
1. `terraform plan -var-file terraform.tfvars`
1. `terraform apply -var-file terraform.tfvars`
1. `terraform output stable_config`
1. `terraform destroy -var-file terraform.tfvars`


## Decisions

- These templates support deploying Pivotal Application Service (PAS)
and Pivotal Container Service (PKS) to the same foundation.

- The templates **do not** create an Ops Manager VM but **do**
create the necessary infrastructure for the VM (security groups, keys, etc).

- These templates demonstrate a modest production deployment in three (3) AZs on
each IaaS.

- These templates contain extremely minimal interdependence or cleverness,
to facilitate incorporating these templates into your own automation easily.

## Versioning

The semantics of the versioning of paving's releases are based on the contents
of `terraform output stable_config`. `stable_config` should always represent
the minimum necessary to install Pivotal Platform. Any other output may be
added or removed without a change in version. However, MAJOR.MINOR.PATCH should
change according to the following:
- If an output is removed, the MAJOR version should be incremented
- If an output is added, the MINOR version should be incremented
- Otherwise, the patch version should be incremented

## Customization

### Jumpbox

In our current configuration, we are using the Ops Manager VM as the
jumpbox. The Ops Manager VM is deployed in the public subnet with a
configuration (`var.ops_manager_allowed_ips`) to restrict it by IP. If you want to use a
jumpbox instead, you may deploy ops manager in the management subnet.

## Next Steps (Azure sample manual approach)

This environment is designed specifically to work in conjunction with [Platform Automation](https://docs.pivotal.io/platform-automation). The terraform does not create an Ops Manager VM, since Platform Automation will automatically create and then upgrade the Ops Manager for you.  If you do not have access to a [Concourse](https://concourse-ci.org/) installation, you can leverage a shared environment (like Hush House) or execute some of the following commands to get you started:

### Prerequisites
 * [pivnet cli](https://github.com/pivotal-cf/pivnet-cli/releases)
 * [om](https://github.com/pivotal-cf/om/releases)
 * `p-automator` - extracted from the Platform Automation docker container (see below where it's downloaded)
 * Run [acme.sh](https://github.com/acmesh-official/acme.sh) and get the certs, make sure to set `${DOMAIN_NAME}` prior to that step.
    * The certs are also added to `creds.yml` (see below)
 * There are a few terraform files *not* committed to this repository as well as some `var-files`:
    * `common.yml` -- contains non-sensitive information like base64 images and proper noun settings
    * `creds.yml` -- contains credential information eventually meant to be stored in secrets for Platform Automation
    * `dns_override.tf` -- contains information due to how DNS is handled in DEV and TEST
    * `env.yml` -- pre-populated `om` file that needs to be modified for SAML authentication
    * `provider_override.tf` -- used to setup Azure blob storage as the backend
    * `terraform.tfvars` -- pre-populated terraform file with sensitive account information

```shell

git clone https://github.com/voor/paving.git paving
git checkout customer-sample-fork-1 # Use customer-sample-fork-with-private-dns for staging and prod.
mkdir -p junk vars

# Download contents for vars for dev, test, staging, and prod

pushd junk

pivnet download-product-files --product-slug='platform-automation' --release-version='4.2.3' --product-file-id=556088
pivnet download-product-files --product-slug='platform-automation' --release-version='4.2.3' --product-file-id=556091
# Copied p-automator out

pivnet download-product-files --product-slug='elastic-runtime' --release-version='2.8.2' --product-file-id=577909
pivnet download-product-files --product-slug='elastic-runtime' --release-version='2.8.2' --product-file-id=580787
pivnet download-product-files --product-slug='p-healthwatch' --release-version='1.8.0' --product-file-id=553565
pivnet download-product-files --product-slug='pivotal_single_sign-on_service' --release-version='1.11.0' --product-file-id=554497
pivnet download-product-files --product-slug='p-compliance-scanner' --release-version='1.2.16' --product-file-id=504880
pivnet download-product-files --product-slug='pivotal-container-service' --release-version='1.6.1' --product-file-id=582811

pivnet download-product-files --product-slug='stemcells-ubuntu-xenial' --release-version='456.84' --product-file-id=576965

pivnet download-product-files --product-slug='p-clamav-addon' --release-version='2.2.2' --product-file-id=555038 # Mirror
pivnet download-product-files --product-slug='p-clamav-addon' --release-version='2.2.2' --product-file-id=555036 # Add-On

pivnet download-product-files --product-slug='harbor-container-registry' --release-version='1.10.0' --product-file-id=561852

pivnet download-product-files --product-slug='ops-manager' --release-version='2.8.1' --product-file-id=580475

popd
pushd paving/azure

# Terraform executed with Azure storage backend
# hold music ....
# Okay that's done
terraform output stable_config > output.json

# Everything is relative to the initial terraform folder, it's assuming you have a junk and vars folder parallel to that.
export DOMAIN_NAME="CHANGEME"
export ENVIRONMENT_NAME="test"

# Download from the storage account the config files (auth.yml, creds.yml, director.yml, and opsman.yml)
# hold music .....
p-automator create-vm --config ../ci/configuration/azure/ops-manager.yml --image-file ../../junk/ops-manager-azure-2.8.1-build.198.yml --state-file ../../vars/${ENVIRONMENT_NAME}/state.yml --vars-file ../../vars/${ENVIRONMENT_NAME}/creds.yml --vars-file output.json

# Setup authentication temporarily as internal
# TODO Change to SAML
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml configure-authentication --config ../ci/configuration/azure/auth.yml --vars-file ../../vars/${ENVIRONMENT_NAME}/creds.yml

# Configure the Director
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml configure-director --config ../ci/configuration/azure/director.yml --vars-file ../../vars/${ENVIRONMENT_NAME}/creds.yml --vars-file output.json

# Change SSL Key
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml update-ssl-certificate --certificate-pem "$(cat ~/.acme.sh/*.${ENVIRONMENT_NAME}.${DOMAIN_NAME}/fullchain.cer)" --private-key-pem "$(cat ~/.acme.sh/*.${ENVIRONMENT_NAME}.${DOMAIN_NAME}/*.${ENVIRONMENT_NAME}.${DOMAIN_NAME}.key)"

# Apply changes to deploy Director
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml apply-changes --skip-deploy-products --reattach

# Upload PAS
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-product --product ../../junk/srt-2.8.2-build.11.pivotal

# Stage Product
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml stage-product --product-name cf --product-version 2.8.2

# Upload PKS
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-product --product ../../junk/pivotal-container-service-1.6.1-build.6.pivotal
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-stemcell --stemcell ../../junk/bosh-stemcell-456.84-azure-hyperv-ubuntu-xenial-go_agent.tgz

# Stage PKS
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml stage-product --product-name pivotal-container-service --product-version 1.6.1-build.6

# Configure PKS
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml configure-product --config ../ci/configuration/azure/pks.yml --vars-file ../../vars/${ENVIRONMENT_NAME}/creds.yml --vars-file output.json

# Configure PAS
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml configure-product --config ../ci/configuration/azure/cf.yml --vars-file ../../vars/${ENVIRONMENT_NAME}/creds.yml --vars-file ../../vars/common.yml --vars-file output.json

# Deploy PAS and PKS
om --env ../../vars/${ENVIRONMENT_NAME}/env.yml apply-changes --skip-deploy-products --reattach

# Supporting tiles.
time om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-product --product ../../junk/harbor-container-registry-1.10.0-build.18.pivotal \
  && time om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-product --product ../../junk/p-antivirus-2.2.2.pivotal \
  && time om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-product --product ../../junk/p-antivirus-mirror-2.2.2.pivotal \
  && time om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-product --product ../../junk/p-compliance-scanner-1.2.16.pivotal \
  && time om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-product --product ../../junk/p-healthwatch-1.8.0-build.66.pivotal \
  && time om --env ../../vars/${ENVIRONMENT_NAME}/env.yml upload-product --product ../../junk/Pivotal_Single_Sign-On_Service_1.11.0.pivotal

```