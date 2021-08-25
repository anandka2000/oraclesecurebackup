# ################################
# Get following from OCI user page
# #################################

$user        = "ocid1.user.oc1."
$fingerprint = "02:29:d1:23:68:89:8e:8b:f8:61:d3:ec:c9:c7:79:2f"
$tenancy     = "ocid1.tenancy.oc1."
$region      = "us-ashburn-1"
$key_file    = "C:\OSB18\oci_api_key.pem"

# #################################
#  fill in these details manually
# #################################
$namespace = "youspace"
$comp_ocid = "ocid1.compartment.oc1..your_compartment_ocid"
$authname  = "myauthoci"
$devname   = "mydevoci"
$bucket    = "mydevoci"
$media     = hostname


######################################
# Create an authentication object
#########################################
obtool mkauth --type oci --userocid $user --fingerprint $fingerprint --tenancyocid $tenancy  --url "objectstorage.$region.oraclecloud.com" --keyfile $key_file --iddomain $namespace $authname
obtool lsauth -l $authname

########################################
# Create cloud storage device
########################################

obtool chhost -R mediaserver $media
obtool mkdev --type cloudstorage --servicetype oci  --mediaserver $media --auth   $authname   --compartment $comp_ocid --container $bucket --storageclass object $devname
obtool lsdev -l $devname
