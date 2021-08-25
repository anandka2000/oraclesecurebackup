#!/bin/bash -x

######################################################
# This scripts create a cloud stoage device to be used
# for backup restore.
# It uses Oracle Secure Backup 18.1.0.1 software
# Target cloud storage is Oracle Cloud infrastructure
######################################################

#################################
## Get following from OCI user page
#################################

user=ocid1.user.oc1.xxx
fingerprint=02:xx:yy:zz...
tenancy=ocid1.tenancy.oc1.abcdefghijklmnopqrstuvwxyz
region=us-ashburn-1
key_file=/home/opc/osb/oci_api_key.pem

#################################
# fill in these details manually
#################################
namespace=youdomain
comp_ocid=ocid1.compartment.oc1...yourocicompartment
authname=myauthoci
devname=mydevoci
bucket=mydevoci
media=anad-compute


###############################
# Create authentication object
##############################

obtool mkauth --type oci \
            --userocid "${user}"\
            --fingerprint "$fingerprint"\
            --tenancyocid "$tenancy"\
            --url "objectstorage.$region.oraclecloud.com"\
            --keyfile "$key_file"\
            --iddomain "$namespace"\
            $authname

#####################################
# List created authentication object
#####################################
obtool lsauth -l $authname

###############################
# Create cloud storage device
##############################
obtool mkdev --type cloudstorage\
            --servicetype oci\
            --mediaserver $media\
            --auth        $authname\
            --compartment $comp_ocid\
            --container   $bucket\
            --storageclass "object"\
            $devname

#####################################
# List created cloud storage device 
#####################################
obtool lsdev -l $devname
