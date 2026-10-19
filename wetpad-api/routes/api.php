<?php

use App\Http\Controllers\{AuthController, StoryController, PartController, ReportController, LibraryController, CommentController, ReactionController};
use App\Http\Controllers\HomeController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::get('/auth/check', [AuthController::class, 'check']);

Route::get('/home', [HomeController::class, 'index']);

Route::get('/stories/{id}', [StoryController::class, 'show']);
Route::get('/stories/{id}/parts', [StoryController::class, 'parts']);
Route::get('/parts/{id}', [PartController::class, 'show']);
Route::get('/parts/{id}/comments', [CommentController::class, 'index']);
Route::get('/comments/{id}/replies', [CommentController::class, 'replies']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::put('/auth/genres', [AuthController::class, 'setGenres']);
    Route::post('/parts/{id}/vote', [PartController::class, 'vote']);
    Route::post('/stories/{id}/reports', [ReportController::class, 'store']);
    Route::post('/parts/{id}/comments', [CommentController::class, 'store']);
    Route::post('/comments/{id}/like', [CommentController::class, 'like']);
    Route::post('/parts/{id}/paragraphs/{idx}/reactions', [ReactionController::class, 'store']);
});

Route::get('/stories/{id}/recommendations', [StoryController::class, 'recommendations']);

Route::post('/library', [LibraryController::class, 'store']);
Route::put('/library/{storyId}/progress', [LibraryController::class, 'progress']);

Route::get('/parts/{id}/paragraphs/{idx}/reactions', [ReactionController::class, 'index']);

