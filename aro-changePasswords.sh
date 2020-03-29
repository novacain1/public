#!/bin/bash
set -eu pipefail

# update both Admin and User passwords on Azure Active Directory
# instance supporting Red Hat GPTE workshops through RHPDS
# SUGGEST 10 characters of NON complex entry to not irritate students
# Use something like: https://passwordsgenerator.net/

# You MUST have the Azure CLI installed to use this script; tested on Fedora below

# written by dcain on 29-Mar 2020
# -------------------------------------------------------
INSTRUCTOR_ACCOUNTS="arouser aroadmin"
STUDENT_USERACCOUNTS=49
GPTE_TENANT="INPUTTENANT"
GPTE_DOMAIN="INPUTDOMAIN"

#CHANGEME
NEW_STUDENTPW=CHANGEME
NEW_INSTRUCTORPW=CHANGEME
#/CHANGEME

# log in and validation basic checks
echo -n "Please enter your Azure username: "
read AZ_USER
read -sp "Please enter your Azure password: " AZ_PASS && echo && az login -u $AZ_USER -p $AZ_PASS --tenant $GPTE_TENANT
#az account list --refresh
test "$(az account get-access-token --query "tenant" --output tsv)" != $GPTE_TENANT && (echo "You must have access to the GPTE tenant"; exit 1)

# login checks passed and tenant membership good, update passwords
echo -e "\nOK, Updating student passwords now."
while [ $STUDENT_USERACCOUNTS -ge 0 ]
do
  az ad user update --id arouser$STUDENT_USERACCOUNTS@$GPTE_DOMAIN --force-change-password-next-login false --password $NEW_STUDENTPW
  echo Updated password to $NEW_STUDENTPW for: arouser$STUDENT_USERACCOUNTS@$GPTE_DOMAIN.
  ((STUDENT_USERACCOUNTS--))
  if [ $STUDENT_USERACCOUNTS -eq 0 ]; then
    break
  fi
done

echo -e "\nOK, Updating instructor passwords now."
for accounts in $INSTRUCTOR_ACCOUNTS
do
  az ad user update --id $accounts@$GPTE_DOMAIN --force-change-password-next-login false --password $NEW_INSTRUCTORPW
  echo Updated password to $NEW_INSTRUCTORPW for: $accounts@$GPTE_DOMAIN.
done

echo -e "\nDone updating passwords."

exit 0
