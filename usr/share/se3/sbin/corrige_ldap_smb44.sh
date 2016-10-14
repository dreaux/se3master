#!/bin/bash

# Script destiné à remettre d'aplomb les comptes admin et root au niveau attributs ldap.
# Auteur: Franck molle 
# Dernière modification: /09/2016
. /etc/se3/config_c.cache.sh
. /etc/se3/config_m.cache.sh
. /etc/se3/config_l.cache.sh


# /usr/share/se3/includes/config.inc.sh -lm

BASEDN="$ldap_base_dn"
ADMINRDN="$adminRdn"
ADMINPW="$adminPw"
PEOPLERDN="$peopleRdn"
GROUPSRDN="$groupsRdn"
RIGHTSRDN="$rightsRdn"

testgecos_adm=$(ldapsearch -xLLL uid=admin gecos | grep -v "dn:")
if [ -z "$testgecos_adm" ]; then
ldapmodify -x -v -D "$ADMINRDN,$BASEDN" -w "$ADMINPW" <<EOF
dn: uid=admin,$PEOPLERDN,$BASEDN
changetype: modify
add: givenName
givenName: Admin
-
add: initials
initials: Admin
-
add: gecos
gecos: Administrateur  Se3,,,
EOF
fi

ldapdelete -x -v -D "$ADMINRDN,$BASEDN" -w "$ADMINPW" "cn=root,$BASEDN"

ldapadd -x -v -D "$ADMINRDN,$BASEDN" -w "$ADMINPW" <<EOF
dn: uid=root,$PEOPLERDN,$BASEDN
uid: root
sn: Se3
cn: root Se3
gecos: root Se3,,,
mail: root@$domain
loginShell: /bin/true
objectClass: top
objectClass: posixAccount
objectClass: shadowAccount
objectClass: person
objectClass: inetOrgPerson
objectClass: sambaSamAccount
uidNumber: 0
sambaPwdMustChange: 2147483647
gidNumber: 0
shadowLastChange: 1468229295
homeDirectory: /root
sambaSID: $domainsid-0
sambaPrimaryGroupSID: $domainsid-0
sambaLMPassword: FFB67A52AC531164AAD3B435B51404EE
sambaNTPassword: 538388DFE2BF2556833682EABF77CB10
sambaPasswordHistory: 00000000000000000000000000000000000000000000000000000000
 00000000
userPassword:: e1NTSEF9UjYrYVpLZGU2RmVnak5uZGRENll4SWxualBIcDcxVis=
sambaPwdLastSet: 1
sambaAcctFlags: [DU         ]
EOF


ldapadd -x -v -D "$ADMINRDN,$BASEDN" -w "$ADMINPW" <<EOF
dn: sambaDomainName=$se3_domain,$BASEDN
sambaAlgorithmicRidBase: 1000
gidNumber: 1000
uidNumber: 1000
objectClass: sambaDomain
objectClass: sambaUnixIdPool
sambaSID: $domainsid
sambaDomainName: $se3_domain
sambaLockoutThreshold: 0
sambaMinPwdAge: 0
sambaRefuseMachinePwdChange: 0
sambaMinPwdLength: 5
sambaLogonToChgPwd: 0
sambaForceLogoff: -1
sambaLockoutDuration: 30
sambaLockoutObservationWindow: 30
sambaMaxPwdAge: -1
sambaPwdHistoryLength: 0
sambaNextRid: 6752
EOF

echo "Modification de l'attribut sambaPwdLastSet pour tous les utilisateurs"
ldapsearch -xLLL -D $adminRdn,$ldap_base_dn -b $PEOPLERDN,$BASEDN -w $adminPw objectClass=person uid| grep uid:| cut -d ' ' -f2| while read uid
do
# cat > /tmp/t.ldif <<EOF
ldapmodify -x -D "$ADMINRDN,$BASEDN" -w "$ADMINPW" <<EOF  >/dev/null
dn: uid=$uid,$peopleRdn,$ldap_base_dn
changetype: modify
replace: sambaPwdLastSet
sambaPwdLastSet: 1
EOF
done


exit 0