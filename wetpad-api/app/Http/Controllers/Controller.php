<?php

namespace App\Http\Controllers;

abstract class Controller
{
    protected function ok($data = null, $message = null, $code = 200)
    {
        return response()->json(['success' => true, 'data' => $data, 'message' => $message], $code);
    }

    protected function fail($message, $code = 400)
    {
        return response()->json(['success' => false, 'data' => null, 'message' => $message], $code);
    }
}
