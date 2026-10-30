echo "Oppretter scratch org"
call sf org create scratch --definition-file config\project-scratch-def.json --alias %1 --duration-days %2 --set-default --json --wait 30

echo "Installer crm-platform-base ver. 0.308"
call sf package install --package 04tQC000001UGhtYAG --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-shared-flowComponents ver. 0.4"
call sf package install --package 04t7U0000008qz4QAA --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installer crm-platform-access-control ver. 0.178"
call sf package install --package 04tQC000001WWfJYAW --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installer crm-community-base ver. 0.121"
call sf package install --package 04tQC000000ieEfYAI --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installer crm-henvendelse-base ver. 0.38"
call sf package install --package 04tQC000001So7lYAC --no-prompt --installation-key %3 

echo "Installer crm-henvendelse- ver. 0.207"
call sf package install --package 04tQC000001TjKXYA0 --no-prompt --installation-key %3--wait 30 --publish-wait 30

echo "Installer crm-platform-integration ver. 0.176"
call sf package install --package 04tQC000001e3HxYAI --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installer crm-hot-felles ver. 0.25"
call sf package install --package 04tQC000001eAkrYAE --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Dytter kildekoden til scratch org'en"
call sf project deploy start

echo "Tildeler tilatelsessett til brukeren"
call sf org assign permset --name HOT_Lesehjelp_Admin

echo "Publish Experience Site"
call sf community publish --name lesehjelpAura

echo "Creating testdata"
call sf apex run --file scripts/apex/createTestData.apex

echo "Ferdig"
