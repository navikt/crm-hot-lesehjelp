echo "Oppretter scratch org"
call sf org create scratch --definition-file config\project-scratch-def.json --alias %1 --duration-days %2 --set-default --json --wait 30

echo "Installerer crm-platform-base ver. 0.198"
call sf package install --package 04t7U000000LPIYQA4 --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-access-control ver. 0.113"
call sf package install --package 04t7U0000004e8tQAA --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-community-base ver. 0.93"
call sf package install --package 04t7U000000Y26AQAS --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Dytter kildekoden til scratch org'en"
call sf project deploy start

echo "Tildeler tilatelsessett til brukeren"
call sf org assign permset --name HOT_Lesehjelp_Admin

echo "Publish Experience Site"
call sf community publish --name lesehjelp

echo "Creating testdata"
call scripts/apex/createTestData.apex

echo "Ferdig"
