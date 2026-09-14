import sys

path = 'ThreeOneOSFive/helpers/AppNotificationManager.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    'https://app-notification-server.yourdomain.workers.dev/api/get-notification',
    'https://app-notification-server.ddnstore.workers.dev/api/get-notification'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated AppNotificationManager.swift with actual URL')
