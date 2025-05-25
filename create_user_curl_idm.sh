curl 'https://gidp.k8s.stg.allinformatix.com/openidm/managed/user?_action=create' \
  -H 'authorization: Bearer QUyV7cc-Mdm8TAW1AAagWZtwb04' \
  -H 'content-type: application/json' \
  -b 'route=1747821852.923.68073.382668|bf890d4ea3c4624fa2b6bbd786eb5c14; i18next=de-de; amlbcookie=01; iPlanetDirectoryPro=QXNI4cPmof4NJpZzfzeHPvOz47o.*AAJTSQACMDIAAlNLABx1WHNkNGtySDhKVzZIMkNiMGFlRTNTMGc4WG89AAR0eXBlAANDVFMAAlMxAAIwMQ..*' \
  --data-raw $'{"preferences":{"updates":false,"marketing":false},"mail":"test2@test2.local","sn":"test2","description":"test2","givenName":"test2","city":"test2","country":"test2","accountStatus":"active","telephoneNumber":"0987654321","stateProvince":"test2","postalAddress":"test2","userName":"test2","password":"Test2025\u0021"}'