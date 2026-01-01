<?php

namespace App\Services;

use App\Models\Notification as AppNotification;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class NotificationService
{
    /**
     * Create a notification record and optionally send push via FCM.
     *
     * @param int $userId
     * @param string $title
     * @param string $message
     * @param array $meta
     * @param string $type
     * @return \App\Models\Notification
     */
    public function send(int $userId, string $title, string $message, array $meta = [], $type = 'info')
    {
        $notif = AppNotification::create([
            'user_id' => $userId,
            'title' => $title,
            'message' => $message,
            'type' => $type,
        ]);

        // Optional: Send via FCM if you store device tokens (pseudo)
        if (!empty($meta['fcm_tokens']) && is_array($meta['fcm_tokens'])) {
            $serverKey = (string) config('services.fcm.server_key', '');
            if ($serverKey === '') {
                return $notif;
            }

            try {
                $payload = [
                    'registration_ids' => $meta['fcm_tokens'],
                    'notification' => [
                        'title' => $title,
                        'body' => $message,
                    ],
                    'data' => $meta['data'] ?? [],
                ];

                Http::timeout((int) config('services.fcm.timeout', 3))->withHeaders([
                    'Authorization' => 'key=' . $serverKey,
                    'Content-Type'  => 'application/json',
                ])->post('https://fcm.googleapis.com/fcm/send', $payload);
            } catch (\Throwable $e) {
                Log::warning('FCM send failed: ' . $e->getMessage());
            }
        }

        return $notif;
    }
}
