echo "Oppretter scratch org"
call sf org create scratch --definition-file config\project-scratch-def.json --alias %1 --duration-days %2 --set-default --json --wait 30

echo "Installerer crm-platform-base ver. 0.203"
call sf package install --package 04t7U000000Y2gcQAC --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-access-control ver. 0.116"
call sf package install --package 04t7U000000Y2ZlQAK --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-community-base ver. 0.99"
call sf package install --package 04t7U000000Y2mpQAC --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-henvendelse-base ver. 0.18"
call sf package install --package 04t7U000000LPPAQA4 --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-integration ver. 0.107"
call sf package install --package 04t7U000000Y2dsQAC --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-integratione ver. 0.107"
call sf package install --package 04t7U000000Y2dsQAC --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Dytter kildekoden til scratch org'en"
call sf project deploy start

echo "Tildeler tilatelsessett til brukeren"
call sf org assign permset --name HOT_Lesehjelp_Admin

echo "Publish Experience Site"
call sf community publish --name lesehjelp

echo "Creating testdata"
call sf apex run --file scripts/apex/createTestData.apex

echo "Ferdig"
