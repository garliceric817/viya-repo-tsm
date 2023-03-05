kubectl patch casdeployment default --type='json' -p='[{"op": "add", "path": "/spec/shutdown", "value":true}]'
