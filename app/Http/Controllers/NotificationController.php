<?php

namespace App\Http\Controllers;

use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $notifications = Notification::where('user_id', $user->id)->latest()->paginate(20);

        return NotificationResource::collection($notifications);
    }

    public function markRead(Request $request, $id)
    {
        $notif = Notification::where('user_id', $request->user()->id)->findOrFail($id);
        $notif->update([
            'is_read' => true,
            'read_at' => now(),
        ]);

        return new NotificationResource($notif);
    }
}
